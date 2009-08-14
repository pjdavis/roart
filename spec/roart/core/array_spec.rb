require File.join(File.dirname(__FILE__), %w[ .. .. spec_helper])

describe 'array extentions' do
  
  it 'should turn an array to a nil valued hash' do
    array = %w[key1 key2]
    hash = array.to_hash
    hash.has_key?(:key1).should be_true
    hash.has_key?(:key2).should be_true
    hash[:key1].should be_nil
  end
  
end