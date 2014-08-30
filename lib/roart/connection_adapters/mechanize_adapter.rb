require 'mechanize'

module Roart
  module ConnectionAdapters
    class MechanizeAdapter

      def initialize(config)
        @conf = config
      end

      def login(config)
        @conf.merge!(config)
        agent = Mechanize.new

        if config[:ssl_verify] == :none.to_sym
          agent.agent.http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        end

        if config[:auth_method] == :basic.to_sym
          agent.add_auth(@conf[:server], @conf[:user], @conf[:pass])
        else
          page = agent.get(@conf[:server])
          form = page.form('login')
          form.user = @conf[:user]
          form.pass = @conf[:pass]
          page = agent.submit form
        end

        @agent = agent
      end

      def get(uri)
        @agent.get(uri).body
      end

      def post(uri, payload)
        @agent.post(uri, payload).body
      end

    end
  end
end
