require File.join(File.dirname(__FILE__), %w[ .. spec_helper])

describe "Ticket" do
  
  it "should have a connection" do
    Roart::Connection.should_receive(:new).with('some options').and_return(true)
    Roart::Ticket.connection('some options').should == true
  end
  
  it "should find the first ticket" do
    Roart::Ticket.should_receive(:find_initial).with(:my => 'options').and_return('a ticket')
    Roart::Ticket.find(:first, :my => 'options').should == 'a ticket'
  end
  
  it 'should find all tickets' do
    Roart::Ticket.should_receive(:find_all).with(:my => 'options').and_return(%w[array of tickets])
    Roart::Ticket.find(:all, :my => 'options').should == ['array', 'of', 'tickets']
  end
  
  it 'should find a ticket by id' do
    Roart::Ticket.should_receive(:find_by_ids).with([12345],{}).and_return('a ticket')
    Roart::Ticket.find(12345).should == 'a ticket'
  end
  
  describe "find initial" do 
  
    it 'should set options to include :limit => 1' do 
      Roart::Ticket.should_receive(:find_all).with({:limit => 1}).and_return(['ticket', 'not seen'])
      Roart::Ticket.send(:find_initial)
    end
    
    it 'should not overwrite the options hash' do
      Roart::Ticket.should_receive(:find_all).with({:queue => 'queue', :limit => 1}).and_return(['ticket', 'not seen'])
      Roart::Ticket.send(:find_initial, :queue => 'queue')      
    end
    
    it 'should return 1 ticket object' do
      Roart::Ticket.should_receive(:find_all).with({:limit => 1}).and_return(['ticket', 'not seen'])
      Roart::Ticket.send(:find_initial).should == 'ticket'
    end
    
  end
  
  describe 'page array' do
    
    it 'should raise an error if not a 200 response' do
      connection = mock('connection', :get => 'some error message')
      Roart::Ticket.should_receive(:connection).and_return(connection)
      lambda do 
        Roart::Ticket.send(:page_array, 'www.whatever')
      end.should raise_error(Roart::TicketSystemInterfaceError)
    end
    
    it 'should raise an error if nothing is returned' do
      connection = mock('connection', :get => nil)
      Roart::Ticket.should_receive(:connection).and_return(connection)
      lambda do 
        Roart::Ticket.send(:page_array, 'www.whatever')
      end.should raise_error(Roart::TicketSystemError)
    end
    
    it 'should give back an array of strings' do
      connection = mock('connection', :get => "200 OK\n23:SomeTicket\n33:Another")
      Roart::Ticket.should_receive(:connection).and_return(connection)
      Roart::Ticket.send(:page_array, 'uri').should == ['23:SomeTicket', '33:Another']
    end
    
  end
  
  describe 'getting tickets from URI' do
    
    describe 'search' do
      
      it 'should give an array of tickets' do
        Roart::Ticket.should_receive(:page_array).with('uri').and_return(['23:SomeTicket', '33:Another'])
        Roart::Ticket.send(:get_tickets_from_search_uri, 'uri').size.should == 2
      end
      
      it 'should not have full tickets' do
        Roart::Ticket.should_receive(:page_array).with('uri').and_return(['23:SomeTicket', '33:Another'])
        Roart::Ticket.send(:get_tickets_from_search_uri, 'uri').each do |ticket|
          ticket.full.should_not be_true
        end
      end
      
    end
    
    describe 'full ticket' do
      
      it 'should give a ticket' do
        Roart::Ticket.should_receive(:page_array).with('uri').and_return(['id:23', 'subject:someticket'])
        Roart::Ticket.send(:get_ticket_from_uri, 'uri').is_a?(Roart::Ticket).should be_true
      end
      
      it 'should be a full ticket' do
        Roart::Ticket.should_receive(:page_array).with('uri').and_return(['id:23', 'subject:someticket'])
        Roart::Ticket.send(:get_ticket_from_uri, 'uri').full.should be_true
      end
      
    end
    
    describe 'getting ticket from id' do
      
      it 'should give a ticket' do
        connection = mock('connection', :server => "server")
        Roart::Ticket.should_receive(:connection).and_return(connection)
        Roart::Ticket.should_receive(:get_ticket_from_uri).with('server' + '/REST/1.0/ticket/' + 12345.to_s).and_return('a ticket')
        Roart::Ticket.send(:get_ticket_by_id, 12345).should == 'a ticket'
      end
      
    end
    
    describe 'find methods' do
      
      it 'should get all tickets from an options hash' do
        Roart::Ticket.should_receive('construct_search_uri').with('searches').and_return('uri')
        Roart::Ticket.should_receive('get_tickets_from_search_uri').with('uri').and_return(['tickets'])
        Roart::Ticket.send(:find_all, 'searches').should == ['tickets']
      end
      
      it 'should find tickets from id' do
        Roart::Ticket.should_receive(:get_ticket_by_id).with('id').and_return('a ticket')
        Roart::Ticket.send(:find_by_ids, ['id'], {}).should == 'a ticket'
      end
      
    end
    
    describe 'building a search uri' do
      
      before do
        @connection = mock('connection', :server => "server")
        @search_string = "/REST/1.0/search/ticket?"
        Roart::Ticket.should_receive(:connection).and_return(@connection)
        @query = @connection.server + @search_string + 'query= '
      end
      
      describe 'queues' do
        
        it 'should include a queue' do
          Roart::Ticket.send(:construct_search_uri, {:queue => 'myQueue'}).should == @query + "Queue = 'myQueue'"
        end
        
        it 'should take multiple queues' do
          Roart::Ticket.send(:construct_search_uri, {:queue => ['myQueue', 'another']}).should == @query + "( Queue = 'myQueue' OR Queue = 'another' )"
        end
        
      end
      
      describe 'dates' do
      
        before do 
          @time = Time.now
        end
        
        it 'should accept a date' do
          Roart::Ticket.send(:construct_search_uri, {:created => @time}).should == @query + "( Created > '#{dbtime(@time)}' )"
        end
        
        it 'should accept an array of dates' do
          Roart::Ticket.send(:construct_search_uri, {:created => [@time, @time + 300]}).should == @query + "( Created > '#{dbtime(@time)}' AND Created < '#{dbtime(@time + 300)}' )"
        end
        
        it 'should accept a range of dates' do
          Roart::Ticket.send(:construct_search_uri, {:created => (@time..(@time + 300))}).should == @query + "( Created > '#{dbtime(@time)}' AND Created < '#{dbtime(@time + 300)}' )"
        end
        
        it 'should accept an array of strings' do
          Roart::Ticket.send(:construct_search_uri, {:created => %w[cat dog]}).should == @query + "( Created > 'cat' AND Created < 'dog' )"
        end
        
        it 'should accept a string' do
          Roart::Ticket.send(:construct_search_uri, {:created => 'time'}).should == @query + "( Created > 'time' )"
        end
        
        describe 'date fields' do
        
          it 'should search started' do
            Roart::Ticket.send(:construct_search_uri, {:started => 'time'}).should == @query + "( Started > 'time' )"
          end
        
          it 'should search resolved' do
            Roart::Ticket.send(:construct_search_uri, {:resolved => 'time'}).should == @query + "( Resolved > 'time' )"
          end
        
          it 'should search told' do
            Roart::Ticket.send(:construct_search_uri, {:told => 'time'}).should == @query + "( Told > 'time' )"
          end
        
          it 'should search last_updated' do
            Roart::Ticket.send(:construct_search_uri, {:last_updated => 'time'}).should == @query + "( LastUpdated > 'time' )"
          end
        
          it 'should search starts' do
            Roart::Ticket.send(:construct_search_uri, {:starts => 'time'}).should == @query + "( Starts > 'time' )"
          end
        
          it 'should search due' do
            Roart::Ticket.send(:construct_search_uri, {:due => 'time'}).should == @query + "( Due > 'time' )"
          end
        
          it 'should search updated' do
            Roart::Ticket.send(:construct_search_uri, {:updated => 'time'}).should == @query + "( Updated > 'time' )"
          end
        
        end
        
      end
      
      describe 'searches' do
        
        it 'should accept a string' do 
          Roart::Ticket.send(:construct_search_uri, {:subject => 'fish'}).should == @query + "Subject LIKE 'fish'"
        end
        
        it 'should accept an array' do 
          Roart::Ticket.send(:construct_search_uri, {:subject => %w[cramanation station]}).should == @query + "( Subject LIKE 'cramanation' AND Subject LIKE 'station' )"
        end
        
        describe 'search fields' do 
          
          it 'should search content' do 
            Roart::Ticket.send(:construct_search_uri, {:content => 'fish'}).should == @query + "Content LIKE 'fish'"
          end
          
          it 'should search content_type' do 
            Roart::Ticket.send(:construct_search_uri, {:content_type => 'fish'}).should == @query + "ContentType LIKE 'fish'"
          end
          
          it 'should search file_name' do 
            Roart::Ticket.send(:construct_search_uri, {:file_name => 'fish'}).should == @query + "FileName LIKE 'fish'"
          end
          
        end
        
      end
      
      describe 'status' do
        
        it 'should accept a string' do
          Roart::Ticket.send(:construct_search_uri, {:status => 'new'}).should == @query + "Status = 'new'"
        end
        
        it 'should accept a symbol' do
          Roart::Ticket.send(:construct_search_uri, {:status => :new}).should == @query + "Status = 'new'"
        end
        
        it 'should accept an array' do
          Roart::Ticket.send(:construct_search_uri, {:status => ['new', 'open']}).should == @query + "( Status = 'new' OR Status = 'open' )"
        end
        
      end
      
      describe 'custom_fields' do
        
        it 'should accept a hash with string values' do
          Roart::Ticket.send(:construct_search_uri, {:custom_fields => {:phone => '8675309'}}).should == @query + "'CF.{phone}' = '8675309'"
        end

        it 'should accept a hash with string values' do
          Roart::Ticket.send(:construct_search_uri, {:custom_fields => {:phone => ['8675309', '5553265']}}).should == @query + "( 'CF.{phone}' = '8675309' OR 'CF.{phone}' = '5553265' )"
        end
        
      end
      
      describe 'multiple find options' do
        
        it 'should allow multiple find options' do
          query = Roart::Ticket.send(:construct_search_uri, {:status => 'new', :queue => 'MyQueue'})
          query.include?("Status = 'new'").should be_true
          query.include?("Queue = 'MyQueue'").should be_true
        end
        
        it "should search for :queue => 'A Queue', :status => [:new, :open]" do 
          query = Roart::Ticket.send(:construct_search_uri, {:queue => 'A Queue', :status => [:new, :open]})
          query.include?("( Status = 'new' OR Status = 'open' )").should be_true
          query.include?("Queue = 'A Queue'").should be_true
        end
        
      end
      
    end  
    
  end
  
  describe 'ticket methods' do
    
    it 'should be able to load the full ticket' do
      search_array = ['1:subject']
      search_array.extend(Roart::TicketPage)
      full_ticket = Roart::Ticket.send(:instantiate, {:id => 1, :subject => 'subject', :full => true})
      ticket = Roart::Ticket.send(:instantiate, search_array.to_search_array ).first
      Roart::Ticket.should_receive(:find).with(1).and_return(full_ticket)
      ticket.load_full!
      ticket.full.should be_true
    end
    
  end
  
  describe 'histories' do
    
    before(:each) do
      search_array = ['1:subject']
      search_array.extend(Roart::TicketPage)
      full_ticket = Roart::Ticket.send(:instantiate, {:id => 1, :subject => 'subject', :full => true})
      @mock_connection.should_receive(:get).with('uri').and_return('200')
      @ticket = Roart::Ticket.send(:instantiate, search_array.to_search_array).first
      @ticket.class.should_receive(:connection).and_return(@mock_connection)
      Roart::History.should_receive(:uri_for).with(@ticket).and_return('uri')
    end
    
    it 'should return history objects' do
      @ticket.histories.class.should == Roart::HistoryArray
    end
    
    it 'should have a default of the ticket id' do
      @ticket.histories.ticket.should == @ticket
    end
    
    it 'should only spawn 1 dup class for each ticket' do
      @ticket.histories.should === @ticket.histories
    end
    
    it 'should have a last history that is equal to the last value' do
      @ticket.histories.last.should == @ticket.histories[@ticket.histories.size - 1]
    end
    
    it 'should have count, which is equal to size' do
      @ticket.histories.count.should == @ticket.histories.size
    end
    
  end
  
end