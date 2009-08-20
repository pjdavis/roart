require 'yaml'
require 'mechanize'

module Roart
  
  module Connections
    RequiredConfig = %w(server user pass adapter)
  
  end
  
  class Connection
  
    attr_reader :agent
  
    def initialize(conf)
    
      if conf.is_a?(String)
        raise "Loading Config File not yet implemented"
      elsif conf.is_a?(Hash)
        Roart::check_keys!(conf, Roart::Connections::RequiredConfig)
        @conf = conf
      end
      
      add_methods!
      @connection = ConnectionAdapter.new(@conf)
    end
    
    def rest_path
      self.server + '/REST/1.0/'
    end
    
    def get(uri)
      @connection.get(uri)
    end
    
    def post(uri, payload)
      @connection.post(uri, payload)
    end
    
    protected

    
    def add_methods!
      @conf.each do |key, value|
        (class << self; self; end).send :define_method, key do
          return value
        end
      end
    end
    
  end
  
end