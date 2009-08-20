module Roart
  module ConnectionAdapters
    class Mechanize
      
      def initialize(config)
        @conf = config
        @agent = login
      end

      def login()
        agent = WWW::Mechanize.new
        page = agent.get(@conf[:server])
        form = page.form('login')
        form.user = @conf[:user]
        form.pass = @conf[:pass]
        page = agent.submit form
        agent
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
