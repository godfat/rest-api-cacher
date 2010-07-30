
require 'rubygems' if RUBY_VERSION < '1.9.0'
require 'rest-api-cacher'

require 'cgi'
require 'stringio'

require 'rr'
require 'webmock'
require 'bacon'

include RR::Adapters::RRMethods
include WebMock
WebMock.disable_net_connect!
Bacon.summary_on_exit
