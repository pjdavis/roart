module Roart
  
  module Histories
    
    DefaultAttributes = %w(creator type description content created)
    RequiredAttributes = %w(creator type)
  
  end
  
  class HistoryArray < Array
    
    def ticket
      @default_options[:ticket]
    end
    
    def all
      self
    end
    
    def count
      self.size
    end
    
    def last
      self[self.size - 1]
    end
    
  end
  
  class History

#TODO Figure out why i can't include Roart::MethodFunctions
    def add_methods!
      @attributes.each do |key, value|
        (class << self; self; end).send :define_method, key do
          return value
        end
      end 
    end
    
    class << self
    
      def default(options)
        history = self.dup
        history.instance_variable_set("@default_options", options)
        history.all
      end
    
      def ticket
        @default_options[:ticket]
      end
    
      def all
        @histories ||= get_all
      end
      
      def default_options
        @default_options
      end
      
      protected
      
      def instantiate(attrs)
        object = nil
        if attrs.is_a?(Array)
          array = Array.new
          attrs.each do |attr|
            object = self.allocate
            object.instance_variable_set("@attributes", attr.merge(self.default_options))
            object.send("add_methods!")
            array << object
          end
          return array
        elsif attrs.is_a?(Hash)
          object = self.allocate
          object.instance_variable_set("@attributes", attrs.merge(self.default_options))
          object.send("add_methods!")
        end
        object
      end
      
      def get_all
        page = get_page
        raise TicketSystemError, "Can't get history." unless page
        raise TicketSystemInterfaceError, "Error getting history for Ticket: #{ticket.id}." unless page.split("\n")[0].include?("200")
        history_array = get_histories_from_page(page)
        history_array
      end
      
      def get_histories_from_page(page)
        full_history = HistoryArray.new
        for history in page.split(/^--$/)
          history = history.split("\n")
          history.extend(Roart::TicketPage)
          full_history << self.instantiate(history.to_history_hash)
        end
        full_history.instance_variable_set("@default_options", @default_options)
        full_history
      end
      
      def get_page
        @default_options[:ticket].class.connection.get(uri_for(@default_options[:ticket]))
      end
      
      def uri_for(ticket)
        uri = self.default_options[:ticket].class.connection.rest_path + "ticket/#{ticket.id}/history?format=l"
      end
      
    end
    
    protected 
    
  end
  
end