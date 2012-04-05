class Hash
   def to_content_format
    fields = []

    self.each do |key, values|
      next if values.nil?

      key_name = 
        if key.to_s.match(/^cf_.+/)
          "CF-#{key.to_s[3..key.to_s.length].gsub(/_/, " ").camelize.humanize}"
        elsif key.to_s.match(/^CF-.+/)
          "#{key.to_s}"
        else
          "#{key.to_s.camelize}"
        end

      values = [values] unless values.is_a?(Array)
      values.each do |value|
        value = Roart::ContentFormatter.format_string(value.to_s)
        fields << "#{key_name}: #{value}"
      end
    end
    content = fields.compact.sort.join("\n")
  end

  def with_indifferent_access
    hash = HashWithIndifferentAccess.new(self)
    hash.default = self.default
    hash
  end

end
