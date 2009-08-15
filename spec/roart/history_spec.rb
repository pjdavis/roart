require File.join(File.dirname(__FILE__), %w[ .. spec_helper])

describe "History" do
  
  it 'should have a ticket' do
    search_array = ['1:subject']
    search_array.extend(Roart::TicketPage)
    full_ticket = Roart::Ticket.send(:instantiate, {:id => 1, :subject => 'subject', :full => true})
    @ticket = Roart::Ticket.send(:instantiate, search_array.to_search_array ).first
    
    history = @ticket.histories
    history.ticket.should == @ticket
    
  end
  
end