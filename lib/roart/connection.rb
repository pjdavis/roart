require 'yaml'
require 'mechanize'

module Roart

  module Connections
    RequiredConfig = %w(server)
    RequiredToLogin = %w(server user pass)

  end

  class Connection

    attr_reader :agent
    attr_reader :conf

    def initialize(conf)
      if conf.is_a?(String)
        raise "Loading Config File not yet implemented"
      elsif conf.is_a?(Hash)
        @conf = conf
      end
      if Roart::check_keys(conf, Roart::Connections::RequiredToLogin)
        @agent = login
        add_methods!
      end
    end

    def authenticate(conf)
      @conf.merge!(conf)
      @agent = login
      add_methods!
      self
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