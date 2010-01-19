require 'forwardable'

module Roart

  class ConnectionAdapter
    extend Forwardable

    def initialize(config)
      @adapter = Roart::ConnectionAdapters.const_get(config[:adapter].capitalize).new(config)
      @adapter.login(config) if config[:user] && config[:pass]
    end

    def authenticate(config)
      @adapter.login(config)
    end

    def_delegators :@adapter, :get, :post

  end

end