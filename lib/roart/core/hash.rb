class Hash
  def to_content_format
    fields = self.map do |key,value| 
      unless value.nil?
        if key.to_s.match(/^cf_.+/)
          "CF-#{key.to_s[3..key.to_s.length].camelize.humanize}: #{value}"
        else
          "#{key.to_s.camelize}: #{value}"
        end
      end
    end
    content = fields.compact.join("\n")
  end
  
end