
require 'digest/md5'

require 'rack/request'
require 'async-rack'

require 'em-mongo'
require 'em-http-request'

# pick a json gem if available
%w[ yajl/json_gem json json_pure ].each{ |json|
  begin
    require json
    break
  rescue LoadError
  end
}

class PreloadData
  def call env
    db, cl = env['PATH_INFO'][1..-1].split('/', 2)

    return need_eventmachine if !EM.reactor_running?
    return need_db_or_cl     if db.strip.empty? || cl.strip.empty?

    url2name = Rack::Request.new(env).params.inject({}){ |result, (name, url)|
                 result[Addressable::URI.parse(url).normalize!.to_s] = name
                 result
               }

    mongo = EM::Mongo::Connection.new.db(db).collection(cl)
    mongo.find('_id' => {'$in' => md5s(*url2name.keys)}){ |resource|
      debug(env, 'resource', resource)
      build(env, url2name, extract(url2name, resource), mongo)
    }

    throw :async
  end

  protected
  def md5s *urls
    urls.map{ |url| Digest::MD5.hexdigest(url) }
  end

  def fetch env, mongo, partial, url2name
    mul = EM::MultiRequest.new
    url2name.keys.each{ |url| mul.add(EM::HttpRequest.new(url).get) }
    mul.callback{
      name2val = mul.responses.values.flatten.inject({}){ |result, conn|
        val, uri = conn.response, conn.uri.to_s
        mongo.insert('_id' => md5s(uri).first,
                     'url' => uri,
                     'val' => val)
        result[url2name[uri]] = val
        result
      }
      respond_async(env, JSON.dump(partial.merge(name2val)))
    }
  end

  def build env, url2name, name2record, mongo
    partial = url2name.inject({}){ |result, (url, name)|
                result[name] = name2record[name]
                result
              }
    missing = partial.select{ |name, record| record.nil? }

    if missing.empty?
      respond_async(env, JSON.dump(partial))
    else
      fetch(env, mongo, partial, url2name.select{ |url, name|
                                   missing.has_key?(name)
                                 })
    end
  end

  def extract url2name, resource
    resource.inject({}){ |name2record, record|
      name2record[url2name[record['url']]] = record['val']
      name2record
    }
  end

  def debug env, *args
    env['rack.logger'].debug("#{args.join(' --- ')}")
  end

  def respond_async env, body=''
    env['async.callback'].call(ok(body))
  end

  def ok body='"200 OK"'
    [200, headers_js, ["#{body}\n"]]
  end

  def need_db_or_cl
    [400, headers_text, ["Usage: GET /database/collection\n"]]
  end

  def need_eventmachine
    body = "#{self.class} needs to be running under EventMachine, " \
           "try Rainbows! with EventMachine or Thin server\n"

    [500, headers_text, ["#{body}\n"]]
  end

  def headers_text
    {'Content-Type' => 'text/plain; charset=UTF-8'}
  end

  def headers_js
    {'Content-Type' => 'text/javascript; charset=UTF-8'}
  end
end
