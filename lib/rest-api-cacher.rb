
require 'rest-api-cacher/params'

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

class RestApiCacher
  def call env
    db, cl = env['PATH_INFO'][1..-1].split('/', 2)

    return need_eventmachine if !EM.reactor_running?
    return need_db_or_cl     if db.strip.empty? || cl.strip.empty?

    params = Params.new(env)

    mongo = EM::Mongo::Connection.new.db(db).collection(cl)
    mongo.find('_id' => {'$in' => params._ids}){ |records|
      params.records = records
      build(env, mongo, params)
    }

    throw :async
  end

  protected
  def build env, mongo, params
    debug(env, 'Cache  Hit:', params.name2record_hit .keys)
    debug(env, 'Cache Miss:', params.name2record_miss.keys)

    if params.name2record_miss.empty?
      respond_async(env, JSON.dump(params.name2record_hit))
    else
      fetch(env, mongo, params)
    end
  end

  def fetch env, mongo, params
    mul = EM::MultiRequest.new
    params.url2name_miss.keys.each{ |url|
      mul.add(EM::HttpRequest.new(url).get)
    }
    mul.callback{
      name2val = mul.responses.values.flatten.inject({}){ |result, conn|
        val, uri = conn.response, conn.uri.normalize!.to_s
        mongo.insert('_id' => params._ids([uri]).first,
                     'url' => uri,
                     'val' => val)
        result[params.url2name_miss[uri]] = val
        result
      }
      respond_async(env, JSON.dump(params.name2record_miss.merge(name2val)))
    }
  end

  # -----

  def debug env, *args
    env['rack.logger'].debug(args.join(' - '))
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
