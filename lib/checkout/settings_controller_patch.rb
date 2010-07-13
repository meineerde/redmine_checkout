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
            settings = (params[:settings] || {}).dup.symbolize_keys
            settings.each do |name, value|
              # remove blank values in array settings
              value.delete_if {|v| v.blank? } if value.is_a?(Array)
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
