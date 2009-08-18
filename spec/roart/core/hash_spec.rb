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
  
end