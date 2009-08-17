require File.join(File.dirname(__FILE__), %w[ .. spec_helper])

describe "History" do
  
  it 'should have a ticket' do
    search_array = ['1:subject']
    search_array.extend(Roart::TicketPage)
    full_ticket = Roart::Ticket.send(:instantiate, {:id => 1, :subject => 'subject', :full => true})
    @ticket = Roart::Ticket.send(:instantiate, search_array.to_search_array ).first
    Roart::History.should_receive(:get_page).and_return('200')    

    history = @ticket.histories
    history.ticket.should == @ticket
    
  end
  
  describe 'reading history pages' do
    
    before do
      @page = File.open(File.join(File.dirname(__FILE__), %w[ .. test_data full_history.txt])).readlines.join
      Roart::History.should_receive(:get_page).and_return(@page)
      @histories = Roart::History.default(:ticket => @ticket)
    end
    
    it 'should have the right number of histories' do
      @histories.size.should == 5
    end
    
    it 'should have a ticket' do
      @histories.first.ticket.should == @ticket
    end
    
    it 'should have an id' do
      @histories.first.id.should == 34725
    end
    
  end
  
end 