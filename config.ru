
require 'rest-api-cacher'

use Rack::Reloader
use Rack::ContentLength
run RestApiCacher.new
