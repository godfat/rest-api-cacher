
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

    url2name = Rack::Request.new(env).params.invert

    EM::Mongo::Connection.new.db(db).collection(cl).
      find('_id' => {'$in' => url2name.keys}){ |mongoes|
        debug(env, 'mongoes', mongoes)
        respond_async(env, ok(build(url2name, extract(url2name, mongoes))))
      }

    throw :async
  end

  protected
  def fetch id
  end

  def build url2name, name2mongo
    JSON.dump(url2name.inject({}){ |result, (id, name)|
      result[name] = name2mongo[name] || fetch(id)
      result
    })
  end

  def extract url2name, mongoes
    mongoes.inject({}){ |result, record|
      result[url2name[record['_id']]] = record
      result
    }
  end

  def debug env, *args
    env['rack.logger'].debug("#{Time.now}: #{args.join(' --- ')}")
  end

  def respond_async env, body=''
    env['async.callback'].call(body)
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
