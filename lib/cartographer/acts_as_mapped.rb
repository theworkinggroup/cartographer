module Cartographer
  module ActsAsMapped
    
    def self.included(base) # :nodoc:
      base.extend ClassMethods
    end
    
    module ClassMethods
      def acts_as_mapped
        has_one :square_codes, :dependent => :destroy
        has_one :location, :dependent => :destroy
        delegate :address, :to => :location
        send :include, Cartographer::ActsAsMapped::InstanceMethods
      end
    end
    
    module InstanceMethods
      def to_js
        
      end
    end
  end
end 