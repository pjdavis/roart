unless defined?(ActiveSupport)
  # used from ActiveSupport
  # Copyright (c) 2005-2009 David Heinemeier Hansson

  class String
  
    def underscore
      self.gsub(/::/, '/').
        gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
        gsub(/([a-z\d])([A-Z])/,'\1_\2').
        tr("-", "_").
        downcase
    end
  
    def camelize
      self.gsub(/\/(.?)/) { "::#{$1.upcase}" }.gsub(/(?:^|_)(.)/) { $1.upcase }
    end
  
    def humanize
      self.gsub(/_id$/, "").gsub(/_/, " ").capitalize
    end
  
    def blank?
      self == ""
    end
  
  end
end
