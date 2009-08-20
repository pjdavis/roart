require 'forwardable'

module Roart
  
  class ConnectionAdapter
    extend Forwardable
   
    def initialize(config)
      @adapter = Roart::ConnectionAdapters.const_get(config[:adapter].capitalize).new(config)
    end
    
    def_delegators :@adapter, :get, :post
    
  end
  
end 