require 'yaml'
require 'mechanize'

module Roart
  
  module Connections
    RequiredConfig = %w(server)
  
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
    end
    
    def authenticate(user, pass)
      @conf[:user] = user
      @conf[:pass] = pass
      
      @agent = login
      add_methods!
    end
    
    def rest_path
      self.server + '/REST/1.0/'
    end
    
    def get(uri)
      @agent.get(uri).body
    end
    
    def post(uri, payload)
      @agent.post(uri, payload).body
    end
    
    protected
    
    def login
      agent = WWW::Mechanize.new
      page = agent.get(@conf[:server])
      form = page.form('login')
      form.user = @conf[:user]
      form.pass = @conf[:pass]
      page = agent.submit form
      agent
    end
    
    def add_methods!
      @conf.each do |key, value|
        (class << self; self; end).send :define_method, key do
          return value
        end
      end
    end
    
  end
  
end