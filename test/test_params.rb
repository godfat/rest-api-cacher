
if respond_to?(:require_relative, true)
  require_relative 'common'
else
  require File.dirname(__FILE__) + '/common'
end

describe RestApiCacher::Params do
  it 'would build up params correctly' do
    u0, u1, u1o = 'http://v00.tw/', 'http://v01.tw/', 'http://v01.tw:80'
    i0, i1      = ['144db4f8ea04030ca3e15089c421c509',
                   'cbb4997794d4b4f0eb350007a4f891a5']
    env = {'QUERY_STRING' => "n0=#{CGI.escape(u0)}&n1=#{CGI.escape(u1o)}",
           'rack.input'   => StringIO.new}
    params = RestApiCacher::Params.new(env)

    params.env      .should == env
    params.url2name .should == {u0 => 'n0', u1 => 'n1'}
    params.urls.sort.should == [u0, u1]
    params._ids.sort.should == [i0, i1]

    val = '"ok"'
    records = [{'_id' => i1, 'val' => val, 'url' => u1, 'updated_at' => 123}]
    params.records = records
    params.name2record     .should == {'n1' => val}
    params.name2record_miss.should == ['n0']
    params.   url2name_miss.should == {u0 => 'n0'}
  end
end
