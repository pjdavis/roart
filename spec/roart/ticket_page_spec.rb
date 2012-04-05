require 'spec_helper'

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

    subject { @page.to_hash }

    it 'should be a hash' do
      subject.class.should == HashWithIndifferentAccess
    end

    it 'should include id' do
      subject[:id].should == 358171
    end

    it 'should include regular fields' do
      subject[:subject].should == 'MyQueue - some_guy - 1035328269 - DSL Modem Reset ESCALATED'
    end

    it 'should include custom fields with old format' do
      subject[:cf_BTN].should == '1035328269'
    end

    it 'should include custom fields with new format' do
      subject[:cf_NEW_BTN].should == '2035328269'
    end

    it 'should properly build old formatted custom fields with multiple line value' do
      subject['cf_Contact_Source'].should == (<<-DATA).strip
<contact-info>
      <name>Jane Smith</name>
      <company>AT&amp;T</company>
      <phone>(212) 555-4567</phone>
    </contact-info>
DATA
    end

    it 'should properly build new formatted custom fields with multiple line value' do
      subject['cf_Feed_Source'].should == (<<-DATA).strip
<item>
    <title>Example entry</title>
    <description>Here is some text containing an interesting description.</description>
    <link>http://www.wikipedia.org/</link>
    <guid>unique string per item</guid>
    <pubDate>Mon, 06 Sep 2009 16:45:00 +0000 </pubDate>
  </item>
DATA
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

  describe "search list array" do
    before do
      @array = [['id:234', 'subject:SomeTicket', ], ['id:432','subject:Another']]
      @array.extend(Roart::TicketPage)
      @array = @array.to_search_list_array
    end

    it "should return an array of hashes" do
      @array.first.class.should == HashWithIndifferentAccess
    end

    it "should put the search elements into the array" do
      @array.first[:id].should == 234
    end
  end

  describe 'ticket history hash' do

    before do
      @page = File.open(File.join(File.dirname(__FILE__), %w[ .. test_data single_history.txt])).readlines.join
      @page = @page.split("\n")
      @page.extend(Roart::TicketPage)
    end

    it 'should give back the hash of history' do
      @page.to_history_hash.class.should == HashWithIndifferentAccess
    end

    it 'should have some content' do
      @page.to_history_hash[:content].should == "Now you can get big real fast at an affordable price\nhttp://www.lameppe.com/"
    end

    it 'should have the create type' do
      @page.to_history_hash[:type].should == 'Create'
    end

  end

end
