require File.join(File.dirname(__FILE__), %w[ .. .. spec_helper])

describe 'string extentions' do

  it 'should underscore a word' do
    'SomeGuy'.underscore.should == 'some_guy'
  end
  
  it 'should camelcase a word' do
    'some_guy'.camelize.should == 'SomeGuy'
  end

end