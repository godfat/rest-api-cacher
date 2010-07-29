
require 'preload_data'

use Rack::Reloader
use Rack::ContentLength
run PreloadData.new
