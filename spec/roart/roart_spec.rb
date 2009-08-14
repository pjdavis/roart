
require File.join(File.dirname(__FILE__), %w[ .. spec_helper])

describe "Roart" do
  
  it "should raise an error if there aren't required fields" do
    attributes = {:subject => "Not Enough Stuff"}
    lambda { Roart::check_keys!(attributes, Roart::Tickets::RequiredAttributes) }.should raise_error(Roart::ArgumentError)
  end
  
end