
require File.join(File.dirname(__FILE__), %w[ .. spec_helper])

describe "Connection" do

  describe 'get and post' do

    before do
      @agent = mock("agent", :null_object => true)
      @options = {:server => 'server', :user => 'user', :pass => 'pass', :adapter => 'whatev'}
      Roart::ConnectionAdapter.should_receive(:new).and_return(@agent)
    end  
  
    it 'should respond to get' do
      @agent.should_receive(:get).with('some_uri').and_return('body')
      connection = Roart::Connection.new(@options)
      connection.get("some_uri").should == 'body'
    end
  
    it 'should respond to post' do
      @agent.should_receive(:post).with('some_uri', 'a payload').and_return('body')
      connection = Roart::Connection.new(@options)
      connection.post("some_uri", "a payload").should == 'body'
    end

  end
  
  it 'should raise an exception if it doesnt have all the options' do
    lambda{Roart::Connection.new(:user => 'bad')}.should raise_error
  end
  
  it 'should give us the rest path' do
    @agent = mock("agent", :null_object => true)
    @options = {:server => 'server', :user => 'user', :pass => 'pass', :adapter => 'whatev'}
    Roart::ConnectionAdapter.should_receive(:new).and_return(@agent)
    connection = Roart::Connection.new(@options)
    connection.rest_path.should == 'server/REST/1.0/'
  end
  
  it 'should give us back the whole thing' do
    mock_mech = mock('mech')
    @options = {:server => 'server', :user => 'user', :pass => 'pass', :adapter => 'mechanize'}
    Roart::ConnectionAdapters::Mechanize.should_receive(:new).with(@options).and_return(mock_mech)
    mock_mech.should_receive(:get).with('uri').and_return('body')
    connection = Roart::Connection.new(@options)
    connection.get('uri').should == 'body'
  end
  
end 