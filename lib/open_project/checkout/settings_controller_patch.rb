require_dependency 'settings_controller'

module Checkout
  module SettingsControllerPatch
    def self.included(base) # :nodoc:
      base.send(:include, InstanceMethods)

      base.class_eval do
        unloadable
      
        alias_method_chain :edit, :checkout
      end
    end
    
    module InstanceMethods
      def edit_with_checkout
        if request.post? && params['tab'] == 'checkout'
          if params[:settings] && params[:settings].is_a?(Hash)
            settings = HashWithIndifferentAccess.new
            (params[:settings] || {}).each do |name, value|
              if name = name.to_s.slice(/checkout_(.+)/, 1)
                case value
                when Array
                  # remove blank values in array settings
                  value.delete_if {|v| v.blank? }
                when Hash
                  # change protocols hash to array.
                  value = value.sort{|(ak,av),(bk,bv)|ak<=>bk}.collect{|id,protocol| protocol} if name.start_with? "protocols_"
                end
                settings[name.to_sym] = value
              end
            end
                        
            Setting.plugin_redmine_checkout = settings
            params[:settings] = {}
          end
        end
        edit_without_checkout
      end
    end
  end
end

SettingsController.send(:include, Checkout::SettingsControllerPatch)
