require File.join(File.dirname(__FILE__), %w[ .. spec_helper])

describe 'ticket callbacks' do

  describe 'create callbacks' do
    
    before do
      post_data = @payload = {:subject => 'A New Ticket', :queue => 'My Queue'}
      post_data.update(:id => 'ticket/new')
      post_data = to_content_format(post_data)
      mock_connection = mock('connection')
      mock_connection.should_receive(:post).with('uri/REST/1.0/ticket/new', {:content => post_data}).and_return("RT/3.6.6 200 Ok\n\n# Ticket 267783 created.")
      mock_connection.should_receive(:server).and_return('uri')
      Roart::Ticket.should_receive(:connection).twice.and_return(mock_connection)
    end
    
    it 'should call before_create callback' do
      
      ticket = Roart::Ticket.new(@payload)
      ticket.should_receive(:before_create)
      ticket.should_receive(:after_create)
      ticket.save
    end
    
  end
  
  describe 'update callbacks' do
    
    before do
      @post_data = @payload = {:subject => 'A New Ticket', :queue => 'My Queue'}
      @post_data[:subject] = 'An Old Ticket'
      @post_data = to_content_format(@post_data)
      @mock_connection = mock('connection')
      @mock_connection.should_receive(:server).and_return('uri')
      Roart::Ticket.should_receive(:connection).twice.and_return(@mock_connection)
    end
    
    it 'should call before_update callbacks' do
      @mock_connection.should_receive(:post).with('uri/REST/1.0/ticket/1/edit', {:content => @post_data}).and_return("RT/3.6.6 200 Ok\n\n# Ticket 267783 updated.")
      ticket = Roart::Ticket.send(:instantiate, @payload.update(:id => 1))
      ticket.instance_variable_set("@saved", false)
      ticket.should_receive(:before_update)
      ticket.should_receive(:after_update)
      ticket.save
    end
    
  end

end