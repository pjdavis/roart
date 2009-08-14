module Roart
  
  class RoartError < StandardError; end
  
  class ArgumentError < RoartError; end
  
  class TicketSystemError < RoartError; end
  
  class TicketSystemInterfaceError < RoartError; end
  
end