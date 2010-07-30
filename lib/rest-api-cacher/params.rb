
require 'digest/md5'
require 'rack/request'

class RestApiCacher
  class Params
    attr_reader   :url2name, :env
    attr_accessor :records
    def initialize env
      @env      = env
      @url2name =
        Rack::Request.new(env).params.inject({}){ |result, (name, url)|
          result[Addressable::URI.parse(url).normalize!.to_s] = name
          result
        }
    end

    def urls
      @urls ||= url2name.keys
    end

    def names
      @names ||= url2name.values
    end

    def _ids us=urls
      us.map{ |u| Digest::MD5.hexdigest(u) }
    end

    def name2record
      @name2record ||= build_name2record
    end

    def name2record_miss
      @name2record_miss ||= names - name2record.keys
    end

    def url2name_miss
      @url2name_miss ||= build_url2name_miss
    end

    protected
    def build_name2record
      records.inject({}){ |name2record, record|
        name2record[url2name[record['url']]] = record['val']
        name2record
      }
    end

    def build_url2name_miss
      result = url2name.select{ |url, name| name2record_miss.member?(name) }
      return result if result.kind_of?(Hash) # RUBY_VERSION >= 1.9.1
      result.inject({}){ |r, (k, v)| r[k] = v; r }
    end
  end
end
