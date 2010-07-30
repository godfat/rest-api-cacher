
if respond_to?(:require_relative, true)
  require_relative 'common'
else
  require File.dirname(__FILE__) + '/common'
end

describe RestApiCacher::Params do
  it 'would build up params correctly' do
    u0, u1 = 'http://v00.tw/', 'http://v01.tw:80'
    env = {'QUERY_STRING' => "k0=#{CGI.escape(u0)}&k1=#{CGI.escape(u1)}",
           'rack.input'   => StringIO.new}
    params = RestApiCacher::Params.new(env)

    params.env     .should == env
    params.url2name.should == {u0 => 'k0', 'http://v01.tw/' => 'k1'}
  end
end
