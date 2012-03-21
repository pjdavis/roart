require File.join(File.dirname(__FILE__), %w[ .. .. spec_helper])

describe 'hash extentions' do

  it 'should format the content correctly' do
    payload = {:subject => "A New Ticket", :queue => 'My Queue'}
    payload.to_content_format.include?("Subject: A New Ticket").should be_true
    payload.to_content_format.include?("Queue: My Queue").should be_true
  end
  
  it 'should handel custom fields' do
    payload = {:cf_stuff => 'field'}
    payload.to_content_format.should == "CF-Stuff: field"
  end

  it 'should NOT change custom key when it starts with CF-' do
    payload = { 'CF-My CustomField wiTout magic' => 'hello' }
    payload.to_content_format.should == "CF-My CustomField wiTout magic: hello"
  end

  it 'should use our content formatter for strings' do
    payload = {:subject => 'A new ticket', :queue => 'My queue', :text => "A text"}
    Roart::ContentFormatter.should_receive(:format_string).at_least(:once)
    payload.to_content_format
  end

end
