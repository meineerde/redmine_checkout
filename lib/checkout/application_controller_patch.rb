require_dependency 'application_controller'

module Checkout
  module ApplicationControllerPatch
    def self.included(base) # :nodoc:
      base.send(:include, InstanceMethods)

      base.class_eval do
        unloadable
      
        alias_method_chain :render_error, :trunk
      end
    end
    
    module InstanceMethods
      def render_error_with_trunk(arg)
        # this is the version of the method in trunk as of r4450
        arg = {:message => arg} unless arg.is_a?(Hash)

        @message = arg[:message]
        @message = l(@message) if @message.is_a?(Symbol)
        @status = arg[:status] || 500

        respond_to do |format|
          format.html {
            render :template => 'common/error', :layout => !request.xhr?, :status => @status
          }
          format.atom { head @status }
          format.xml { head @status }
          format.js { head @status }
          format.json { head @status }
        end
      end
    end
  end
end

ApplicationController.send(:include, Checkout::ApplicationControllerPatch)
