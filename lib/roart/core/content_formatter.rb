module Roart
  class ContentFormatter
    # The following is only based on quick trial&error on my part. The RT Api (at least in 3.6) does not have good documentation.
    # Strings in a RT request:
    #  - are not allowed to contain '\r'
    #  - must use equally padded new-lines to distinguish them from the beginning of a new field (we use 2-space padding)
    def self.format_string(string)
      string.gsub("\r", '').gsub("\n", "\n  ")
    end

  end
end
