
require File.join(File.dirname(__FILE__), %w[ .. spec_helper])

describe "ConnectionAdapter" do
  
  it 'should give us back a connection' do
    Roart::ConnectionAdapters::Mechanize.should_receive(:new).with(:adapter => 'mechanize').and_return(mock('mechanize'))
    Roart::ConnectionAdapter.new(:adapter => 'mechanize')
  end

end
