module Roart
  
  module Histories
    
    DefaultAttributes = %w(ticket creator type)
    RequiredAttributes = %w(ticket creator type)
  
  end
  
  class History
    
    class << self
      
      def default(options)
        history = self.dup
        history.instance_variable_set("@default_options", options)
        history
      end
      
      def ticket
        @default_options[:ticket]
      end
      
    end
    
    protected 
    
  end
  
end