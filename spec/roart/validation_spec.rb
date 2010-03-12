require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "validations" do
  
	describe "field length" do
		
		it "show validate too short" do
			class ShortTicket < Roart::Ticket; validates_length_of(:subject, :min => 6); end
			ticket = inst_ticket(ShortTicket)
			ticket.subject = "short"
			ticket.valid?.should be_false
			ticket.subject = "longer subject"
			ticket.valid?.should be_true
		end
		
		it "should validate too long" do
			class LongTicket < Roart::Ticket; validates_length_of(:subject, :max => 6); end
			ticket = inst_ticket(LongTicket)
			ticket.subject = "too long"
			ticket.valid?.should be_false
			ticket.subject = "short"
			ticket.valid?.should be_true
		end
		
		it "should validate exact" do
			class ExactTicket < Roart::Ticket; validates_length_of(:subject, :is => 5); end
			ticket = inst_ticket(ExactTicket)
			ticket.subject = "Not Five"
			ticket.valid?.should be_false
			ticket.subject = "Yes 5"
			ticket.valid?.should be_true
		end
		
		it "should validate range" do
		  class RangeTicket < Roart::Ticket; validates_length_of(:subject, :within => 7..12); end
			ticket = inst_ticket(RangeTicket)
			ticket.subject = 'short'
			ticket.valid?.should be_false
			ticket.subject = 'waaaaay toooooo long'
			ticket.valid?.should be_false
			ticket.subject = 'just right'
			ticket.valid?.should be_true
		end
		
	end
	
	describe "format" do
		
		it "should validate format" do
			class FormatTicket < Roart::Ticket; validates_format_of(:subject, :format => /^lol$/); end
			ticket = inst_ticket(FormatTicket)
			ticket.subject = 'poop'
			ticket.valid?.should be_false
			ticket.subject = 'lol'
			ticket.valid?.should be_true
		end

	end
	
	describe "numericality" do
		
		it "should validate greater than" do
			class GTTicket < Roart::Ticket; validates_numericality_of(:subject, :greater_than => 5); end
			ticket = inst_ticket(GTTicket)
			ticket.subject = 4
			ticket.valid?.should be_false
			ticket.subject = 6
			ticket.valid?.should be_true
		end
		
		it "should validate less than" do
			class LTTicket < Roart::Ticket; validates_numericality_of(:subject, :less_than => 5); end
			ticket = inst_ticket(LTTicket)
			ticket.subject = 6
			ticket.valid?.should be_false
			ticket.subject = 4
			ticket.valid?.should be_true
		end
		
		it "should validate integer" do
			class IntTicket < Roart::Ticket; validates_numericality_of(:subject, :only_integer => true); end
			ticket = inst_ticket(IntTicket)
			ticket.subject = 6.3
			ticket.valid?.should be_false
			ticket.subject = 4
			ticket.valid?.should be_true
		end
		
		it "should validate integer" do
			class EqualTicket < Roart::Ticket; validates_numericality_of(:subject, :equal_to => 4); end
			ticket = inst_ticket(EqualTicket)
			ticket.subject = 6.3
			ticket.valid?.should be_false
			ticket.subject = 4
			ticket.valid?.should be_true
		end
		
		it "should validate even" do
			class EvenTicket < Roart::Ticket; validates_numericality_of(:subject, :even => true); end
			ticket = inst_ticket(EvenTicket)
			ticket.subject = 6.3
			ticket.valid?.should be_false
			ticket.subject = 5
			ticket.valid?.should be_false
			ticket.subject = 4
			ticket.valid?.should be_true
		end
		
		it "should validate two at once" do
			class DoubleTeam < Roart::Ticket; validates_numericality_of(:subject, :even => true, :greater_than => 5); end
			ticket = inst_ticket(DoubleTeam)
			ticket.subject = 6.3
			ticket.valid?.should be_false
			ticket.subject = 9
			ticket.valid?.should be_false
			ticket.subject = 4
			ticket.valid?.should be_false
			ticket.subject = 8
			ticket.valid?.should be_true
		end
		
	end
	
end

#helpers

def inst_ticket(klass)
	klass.send(:instantiate,{:subject => 'A New Ticket', :queue => 'My Queue', :id => 1})
end
