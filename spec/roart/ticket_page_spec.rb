require File.join(File.dirname(__FILE__), %w[ .. spec_helper])

describe 'ticket page' do
  
  describe 'ticket hash' do
    
    it 'should convert an array to a hash' do
      array = ["id : 10", "subject : asdf"]
      array.extend(Roart::TicketPage)
      hash = array.to_hash
      hash.has_key?(:id).should be_true
      hash[:id].should == 10
      hash[:subject].should == 'asdf'
    end
  
  end

	describe 'reading a ticket' do
		
		before do
			@page = File.open(File.join(File.dirname(__FILE__), %w[ .. test_data ticket.txt])).readlines.join
			@page = @page.split("\n")
      @page.extend(Roart::TicketPage)
		end
		
		it 'should include custom fields' do
			@page.to_hash[:cf_BTN].should == '1035328269'
		end
		
		it 'should be a hash' do
			@page.to_hash.class.should == Hash
		end
		
	end
  
  describe 'search array' do
    
    before do
      @array = ["123 : Subject", "234 : Subject"]
      @array.extend(Roart::TicketPage)
      @array = @array.to_search_array
    end
    
    it 'should make an array of search results' do
      @array.size.should == 2
    end
    
    it 'should put search elements into the search array' do
      @array.first[:id].should == 123
      @array.last[:id].should == 234
    end
    
  end
  
  describe 'ticket history hash' do
    
    before do
      @page = File.open(File.join(File.dirname(__FILE__), %w[ .. test_data single_history.txt])).readlines.join
      @page = @page.split("\n")
      @page.extend(Roart::TicketPage)
    end
    
    it 'should give back the hash of history' do
      @page.to_history_hash.class.should == Hash
    end
    
    it 'should have some content' do
      @page.to_history_hash[:content].should_not be_nil
    end
    
    it 'should have the create type' do
      @page.to_history_hash[:type].should == 'Create'
    end
    
  end
  
end