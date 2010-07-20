require_dependency 'settings_helper'

module Checkout
  module SettingsHelperPatch
    def self.included(base) # :nodoc:
      base.send(:include, InstanceMethods)

      base.class_eval do
        alias_method_chain :administration_settings_tabs, :checkout
      end
    end
  
    module InstanceMethods
      def administration_settings_tabs_with_checkout
        tabs = administration_settings_tabs_without_checkout
        tabs << {:name => 'checkout', :partial => 'settings/checkout', :label => :label_checkout}
      end
    end
  end
end

SettingsHelper.send(:include, Checkout::SettingsHelperPatch)

