module Roart

  module Tickets

    DefaultAttributes = %w(queue owner creator subject status priority initial_priority final_priority requestors cc admin_cc created starts started due resolved told last_updated time_estimated time_worked time_left text).inject({}){|memo, k| memo[k] = nil; memo}
    RequiredAttributes = %w(queue subject)

  end

  class Ticket

    include Roart::MethodFunctions
    include Roart::Callbacks
    require File.join(File.dirname(__FILE__), %w[ validations.rb ])
    include Roart::Validations

    attr_reader :full, :history, :saved

    # Creates a new ticket. Attributes queue and subject are required. Expects a hash with the attributes of the ticket.
    #
    #   ticket = MyTicket.new(:queue => "Some Queue", :subject => "The System is Down.")
    #   ticket.id #-> This will be the ID of the ticket in the RT System.
    #
    def initialize(attributes=nil)
      if attributes
        @attributes = Roart::Tickets::DefaultAttributes.merge(attributes)
      else
        @attributes = Roart::Tickets::DefaultAttributes
      end
      @attributes.update(:id => 'ticket/new')
      @saved = false
      @history = false
      @new_record = true
      add_methods!
    end

    # Loads all information for a ticket from RT and lets full to true.
    # This changes the ticket object and adds methods for all the fields on the ticket.
    # Custom fields will be prefixed with 'cf' so a custom field of 'phone'
    # would be cf_phone. custom fields hold their case from how they are defined in RT, so a custom field of PhoneNumber would be cf_PhoneNumber and a custom field of phone_number would be cf_phone_number
    #
    def load_full!
      unless self.full
        ticket = self.class.find(self.id)
        @attributes = ticket.instance_variable_get("@attributes")
        add_methods!
      end
    end

    #loads the ticket history from rt
    #
    def histories
      @histories ||= Roart::History.default(:ticket => self)
    end

    # if a ticket is new, calling save will create it in the ticketing system and assign the id that it gets to the id attribute. It returns true if the save was successful, and false if something went wrong
    #
    def save
      if self.id == "ticket/new"
        self.create
      else
        self.update
      end
    end

    # Add a comment to a ticket
    # Example:
    #   tix = Ticket.find(1000)
    #   tix.comment("This is a comment", :time_worked => 45, :cc => 'someone@example.com')
    def comment(comment, opt = {})
      comment = {:text => comment, :action => 'Correspond'}.merge(opt)

      uri = "#{self.class.connection.server}/REST/1.0/ticket/#{self.id}/comment"
      payload = comment.to_content_format
      resp = self.class.connection.post(uri, :content => payload)
      resp = resp.split("\n")
      raise TicketSystemError, "Ticket Comment Failed" unless resp.first.include?("200")
      !!resp[2].match(/^# Message recorded/)
    end

    # works just like save, but if the save fails, it raises an exception instead of silently returning false
    #
    def save!
      raise TicketSystemError, "Ticket Create Failed" unless self.save
      true
    end

    def new_record?
      return @new_record
    end

    protected

      def create #:nodoc:
        self.before_create
        uri = "#{self.class.connection.server}/REST/1.0/ticket/new"
        payload = @attributes.to_content_format
        resp = self.class.connection.post(uri, :content => payload)

        process_save_response(resp, :create)
      end

      def update
        self.before_update
        uri = "#{self.class.connection.server}/REST/1.0/ticket/#{self.id}/edit"
        payload = @attributes.clone
        payload.delete("text")
        payload.delete("id") # Can't have text in an update, only create, use comment for updateing
        payload = payload.to_content_format
        resp = self.class.connection.post(uri, :content => payload)

        process_save_response(resp, :update)
      end

      SUCCESS_CODES = (200..299).to_a
      CLIENT_ERROR_CODES = (400..499).to_a

      def process_save_response(response, action)
        errors.clear
        action_name = action.to_s.capitalize

        lines = response.split("\n").reject { |l| l.blank? }

        status_line = lines.shift
        status_line.present? or
          raise TicketSystemError, "Ticket #{action_name} Failed (blank response)"

        version, status_code, status_text = status_line.split(/\s+/,2)

        if SUCCESS_CODES.include?(status_code.to_i) && lines[0] =~ /^# Ticket (\d+) (created|updated)/
          @attributes[:id] = $1.to_i if $2 == 'created'
          @new_record = false
          @saved = true
          self.__send__("after_#{action}")
          return true
        elsif (SUCCESS_CODES + CLIENT_ERROR_CODES).include?(status_code.to_i)
          lines[0] =~ /^# Could not (create|update) ticket/ and lines.shift
          lines.each { |line| errors.add_to_base(line) if line =~ /^#/ }
          return false
        else
          raise TicketSystemError, "Ticket #{action_name} Failed (#{status_line})"
        end
      end

      def create! #:nodoc:
        raise TicketSystemError, "Ticket Create Failed" unless self.create
        true
      end

    class << self #class methods

      # Searches for a ticket or group of tickets with an active record like interface.
      #
      # Find has 3 different ways to search for tickets
      #
      # * search for tickets by the id. This will search for the Ticket with the exact id and will automatically load the entire ticket into the object (full will return true).
      # * search for all tickets with a hash for search options by specifying :all along with your options. This will return an array of tickets or an empty array if no tickets are found that match the options.
      # * search for a single ticket with a hash for search options by specifying :first along with your options. This will return a single ticket object or nil if no tickets are found.
      #
      # A hash of options for search paramaters are passed in as the last argument.
      #
      # ====Parameters
      # * <tt>:queue</tt> or <tt>:queues</tt> - the name of a queue in the ticket system. This can be specified as a string, a symbol or an array of strings or symbols. The array will search for tickets included in either queue.
      # * <tt>:status</tt> - the status of the tickets to search for. This can be specified as a string, a symbol or an array of strings or symbols.
      # * <tt>:subject</tt>, <tt>:content</tt>, <tt>content_type</tt>, <tt>file_name</tt> - takes a string and searches for that string in the respective field.
      # * <tt>:created</tt>, <tt>:started</tt>, <tt>:resolved</tt>, <tt>:told</tt>, <tt>:last_updated</tt>, <tt>:starts</tt>, <tt>:due</tt>, <tt>:updated</tt> - looks for dates for the respective fields. Can take a Range, Array, String, Time. Range will find all tickets between the two dates (after the first, before the last). Array works the same way, using #first and #last on the array. The elements should be either db-time formatted strings or Time objects. Time will be formatted as a db string. String will be passed straight to the search.
      # * <tt>:custom_fields</tt> - takes a hash of custom fields to search for. the key should be the name of the field exactly how it is in RT and the value will be what to search for.
      #
      # ==== Examples
      #
      #   # find first
      #   MyTicket.find(:first)
      #   MyTicket.find(:first, :queue => 'My Queue')
      #   MyTicket.find(:first, :status => [:new, :open])
      #   MyTicket.find(:first, :queue => 'My Queue', :status => :resolved)
      #   MyTicket.find(:first, :custom_fields => {:phone => '8675309'})
      #
      #   # find all
      #   MyTicket.find(:all, :subject => 'is down')
      #   MyTicket.find(:all, :created => [Time.now - 300, Time.now])
      #   MyTicket.find(:all, :queues => ['my queue', 'issues'])
      #
      #   # find by id
      #   MyTicket.find(12345)
      #
      def find(*args)
        options = args.last.is_a?(Hash) ? args.pop : {}
        case args.first
          when :first then  find_initial(options)
          when :all then    find_all(options)
          else              find_by_ids(args, options)
        end
      end


      # Accepts parameters for connecting to an RT server.
      # Required:
      # :server sets the URL for the rt server, :ie http://rt.server.com/
      # Optional:
      # :user sets the username to connect to RT
      # :pass sets the password for the user to connect with
      # :adapter is the connection adapter to connect with. Defaults to Mechanize
      #
      #     class Ticket < Roart::Ticket
      #       connection :server => 'server', :user => 'user', :pass => 'pass'
      #     end
      #
      def connection(options=nil)
        if options
          @connection = Roart::Connection.new({:adapter => "mechanize"}.merge(options))
        else
          defined?(@connection) ? @connection : nil
        end
      end

      # Sets the username and password used to connect to the RT server
      # Required:
      # :user sets the username to connect to RT
      # :pass sets the password for the user to connect with
      # This can be used to change a connection once the Ticket class has
      # been initialized. Not required if you sepecify :user and :pass in
      # the connection method
      #
      #     class Ticket < Roart::Ticket
      #       connection :server => 'server'
      #       authenticate :user => 'user', :pass => 'pass'
      #     end
      #
      def authenticate(options)
        @connection.authenticate(options)
      end

      # Adds a default queue to search each time. This is overridden by
      # specifically including a :queue option in your find method. This can
      # be an array of queue names or a string with a single queue name.
      #
      def default_queue(options=nil)
        if options
          @default_queue = options
        else
          defined?(@default_queue) ? @default_queue : nil
        end
      end

      # creates a new ticket object and immediately saves it to the database.
      def create(options)
        ticket = self.new(options)
        ticket.save
        ticket
      end

      protected

      def instantiate(attrs) #:nodoc:
        object = nil
        if attrs.is_a?(Array)
          array = Array.new
          attrs.each do |attr|
            object = self.allocate
            object.instance_variable_set("@attributes", attr)
            object.send("add_methods!")
            array << object
          end
          return array
        elsif attrs.is_a?(Hash) || attrs.is_a?(HashWithIndifferentAccess)
          object = self.allocate
          object.instance_variable_set("@attributes", attrs)
          object.send("add_methods!")
        end
        object.instance_variable_set("@history", false)
        object.instance_variable_set("@new_record", false)
        object
      end

      def find_initial(options={}) #:nodoc:
        options.update(:limit => 1)
        find_all(options).first
      end

      def find_all(options) #:nodoc:
        uri = construct_search_uri(options)
        tickets = get_tickets_from_search_uri(uri)
      end

      def find_by_ids(args, options) #:nodoc:
        raise ArgumentError, "First argument must be :all or :first, or an ID with no hash options" unless args.first.is_a?(Fixnum) || args.first.is_a?(String)
        get_ticket_by_id(args.first)
      end

      def page_array(uri) #:nodoc:
        page = self.connection.get(uri)
        raise TicketSystemError, "Can't get ticket." unless page
        page = page.split("\n")
        status = page.delete_at(0)
        if status.include?("200")
          page
        else
          raise TicketSystemInterfaceError, "Error Getting Ticket: #{status}"
        end
      end

      def page_list_array(uri) #:nodoc:
        page = self.connection.get(uri)
        raise TicketSystemInterfaceError, "Can't get ticket." unless page
        page = page.split("\n")
        status = page.delete_at(0)
        if status.include?("200")
          page = page.join("\n")
          chunks = page.split(/^--$/)
          page = []
          for chunk in chunks
            chunk = chunk.split("\n")
            chunk.delete_if{|x| !x.include?(":")}
            page << chunk
          end
          page
        else
          raise TicketSystemInterfaceError, "Error Getting Ticket: #{status}"
        end
      end

      def get_tickets_from_search_uri(uri) #:nodoc:
        page = page_list_array(uri + "&format=l")
        page.extend(Roart::TicketPage)
        page = page.to_search_list_array
        array = Array.new
        for ticket in page
          ticket = self.instantiate(ticket)
          ticket.instance_variable_set("@full", true)
          array << ticket
        end
        array ||= []
      end

      def get_ticket_from_uri(uri) #:nodoc:
        page = page_array(uri)
        page.extend(Roart::TicketPage)
        unless page = page.to_hash
          raise TicketNotFoundError, "No ticket matching search criteria found."
        end
        ticket = self.instantiate(page)
        ticket.instance_variable_set("@full", true)
        ticket
      end

      def get_ticket_by_id(id) #:nodoc:
        uri = "#{self.connection.server}/REST/1.0/ticket/"
        uri << id.to_s
        get_ticket_from_uri(uri)
      end

      def construct_search_uri(options={}) #:nodoc:
        uri = "#{self.connection.server}/REST/1.0/search/ticket?"
        uri << 'orderby=-Created&' if options.delete(:order)
        unless options.empty? && default_queue.nil?
          uri << 'query= '
          query = Array.new

          if options[:queues] || options[:queue]
            add_queue!(query, options[:queues] || options[:queue])
          else
            add_queue!(query, default_queue)
          end
          add_dates!(query, options)
          add_searches!(query, options)
          add_status!(query, options[:status])
          add_custom_fields!(query, options[:custom_fields])

          query << options[:conditions].to_s.chomp if options[:conditions]

          uri << query.join(" AND ")
        end
        uri
      end

      def add_queue!(uri, queue) #:nodoc:
        return false unless queue
        if queue.is_a?(Array)
          queues = Array.new
          queue.each do |name|
            queues << "Queue = '#{name}'"
          end
          uri << '( ' + queues.join(' OR ') + ' )'
        elsif queue.is_a?(String) || queue.is_a?(Symbol)
          uri << "Queue = '#{queue.to_s}'"
        end
      end

      def add_custom_fields!(uri, options) #:nodoc:
        return false unless options
        options.each do |field, value|
          if value.is_a?(Array)
            valpart = Array.new
            for val in value
              valpart << "'CF.{#{field}}' = '#{val.to_s}'"
            end
            uri << '( ' + valpart.join(" OR ") + ' )'
          elsif value.is_a?(String)
            uri << "'CF.{#{field}}' = '#{value.to_s}'"
          end
        end
      end

      def add_status!(uri, options) #:nodoc:
        return false unless options
        parts = Array.new
        if options.is_a?(Array)
          statpart = Array.new
          for status in options
            statpart << "Status = '#{status.to_s}'"
          end
          parts << '( ' + statpart.join(" OR ") + ' )'
        elsif options.is_a?(String) || options.is_a?(Symbol)
          parts << "Status = '#{options.to_s}'"
        end
        uri << parts
      end

      def add_searches!(uri, options) #:nodoc:
	search_fields = %w( subject content content_type file_name owner requestors cc admin_cc)
        options.each do |key, value|
          if search_fields.include?(key.to_s)
            key = key.to_s.camelize
            parts = Array.new
            if value.is_a?(Array)
              value.each do |v|
                parts << "#{key} LIKE '#{v}'"
              end
              uri << '( ' + parts.join(" AND ") + ' )'
            elsif value.is_a?(String)
              uri << "#{key} LIKE '#{value}'"
            end
          end
        end
      end

      def add_dates!(uri, options) #:nodoc:
        date_field = %w( created started resolved told last_updated starts due updated )
        options.each do |key, value|
          if date_field.include?(key.to_s)
            key = key.to_s.camelize
            parts = Array.new
            if value.is_a?(Range) or value.is_a?(Array)
              parts << "#{key} > '#{value.first.is_a?(Time) ? value.first.strftime("%Y-%m-%d %H:%M:%S") : value.first.to_s}'"
              parts << "#{key} < '#{value.last.is_a?(Time) ? value.last.strftime("%Y-%m-%d %H:%M:%S") : value.last.to_s}'"
            elsif value.is_a?(String)
              parts << "#{key} > '#{value.to_s}'"
            elsif value.is_a?(Time)
              parts << "#{key} > '#{value.strftime("%Y-%m-%d %H:%M:%S")}'"
            end
            uri << '( ' + parts.join(" AND ") + ' )'
          end
        end
      end

    end

  end

end
