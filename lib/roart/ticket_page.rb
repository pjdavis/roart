module Roart

  module TicketPage

    IntKeys = %w[id]

    CUSTOM_FIELD_REGEXP = /^(?!\s)(?:CF-([^:.]+)|CF\.\{([^}^:.]+)\}):(.*)$/.freeze

    REGULAR_FIELD_REGEXP = /^(?!\s)([^:.]+):(.*)$/.freeze

    def to_hash
      hash = HashWithIndifferentAccess.new

      return false if self.size == 0

      current_key = nil

      self.each do |line|
        case line
        when CUSTOM_FIELD_REGEXP
          data = $3
          current_key = "cf_#{($1 || $2)}".gsub(/ /, '_')
        when REGULAR_FIELD_REGEXP
          data = $2
          current_key = $1.strip.underscore
        else
          data = line
        end

        if current_key
          hash[current_key] ||= ""
          hash[current_key] << data << "\n"
        end
      end

      return false if hash.empty?

      # strip values
      hash.each { |k, v| hash[k].strip! if hash[k] }

      # id is integer
      hash["id"] = hash["id"].split("/").last.to_i

      hash
    end

    def to_search_list_array
      array = Array.new
      self.each do |ticket|
        ticket.extend(Roart::TicketPage)
        ticket_hash = ticket.to_hash
        array << ticket_hash if ticket_hash
      end
      array
    end

    def to_search_array
      array = Array.new
      self.delete_if{|x| !x.include?(":")}
      raise TicketNotFoundError, "No tickets matching search criteria found." if self.size == 0
      self.each do |ln|
        hash = Hash.new
        ln = ln.split(":")
        id = ln.delete_at(0).strip.underscore
        sub = ln.join(":").strip
        hash[:id] = id.to_i
        hash[:subject] = sub
        hash[:full] = false
        hash[:history] = false
        array << hash
      end
      array
    end

# TODO: Don't throw away attachments (/^ {13})
    def to_history_hash
      hash = HashWithIndifferentAccess.new
      self.delete_if{|x| !x.include?(":") && !x.match(/^ {9}/) && !x.match(/^ {13}/)}
      self.each do |ln|
        if ln.match(/^ {9}/) && !ln.match(/^ {13}/)
          hash[:content] << "\n" + ln.strip if hash[:content]
        elsif ln.match(/^ {13}/)
          hash[:attachments] << "\n" + ln.strip if hash[:attachments]
        else
          ln = ln.split(":")
          unless ln.size == 1 || ln.first == 'Ticket' # we don't want to override the ticket method.
            key = ln.delete_at(0).strip.underscore
            value = ln.join(":").strip
            hash[key] = IntKeys.include?(key) ? value.to_i : value
          end
        end
      end
      hash
    end

  end

end
