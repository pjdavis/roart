require File.join(File.dirname(__FILE__), %w[ .. .. spec_helper])

describe 'content formatter' do
  before do
    @formatter = Roart::ContentFormatter
  end

  describe 'formatting strings' do
    it "should remove \\r characters" do
      @formatter.format_string("a\r\ntext with\ndifferent\rnew\r\nlines").should_not include("\r")
    end

    it "should pad new lines with 2 spaces" do
      @formatter.format_string("a\ntext with\n\ndifferent\nnew\n  \nlines").should == "a\n" +
                                                                                      "  text with\n" +
                                                                                      "  \n" +
                                                                                      "  different\n" +
                                                                                      "  new\n" +
                                                                                      "    \n" +
                                                                                      "  lines"
    end
  end
end
