module Roart
  
  # Callbacks are implemented to do a bit of logic either before or after a part of the object life cycle. These can be overridden in your Ticket class and will be called at the approprate times.
  #
  module Callbacks
    
    # called just before a ticket that has not been saved to the ticketing system is saved.
    #
    def before_create; end
    
    # Called immediately a ticket that has not been saved is saved.
    #
    def before_update; end
    
    # called just before a ticket that has been updated is saved to the ticketing system
    #
    def after_create; end
    
    # called just after a ticket that has been updated is saved to the ticketing system
    #
    def after_update; end
    
  end
  
end