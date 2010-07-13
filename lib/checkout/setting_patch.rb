require_dependency 'setting'

module Checkout
  module SettingPatch
    def self.included(base) # :nodoc:
      base.extend(ClassMethods)
      
      base.class_eval do
        unloadable
        
        # Defines getter and setter for each setting
        # Then setting values can be read using: Setting.some_setting_name
        # or set using Setting.some_setting_name = "some value"
        Redmine::Plugin.find(:redmine_checkout).settings[:default].keys.each do |name|
          src = <<-END_SRC
          def self.checkout_#{name}
            self.plugin_redmine_checkout['#{name}'] || begin
              default = Setting.available_settings['plugin_redmine_checkout']['default']['#{name}']
              # perform a deep copy of the default
              Marshal::load(Marshal::dump(default))
            end
          end

          def self.checkout_#{name}?
            self.plugin_redmine_checkout['#{name}'].to_i > 0
          end

          def self.checkout_#{name}=(value)
            setting = Setting.plugin_redmine_checkout
            setting['#{name}'] = value
            Setting.plugin_redmine_checkout == setting
          end
          END_SRC
          class_eval src, __FILE__, __LINE__
        end
        
        def self.checkout_save=(value)
          # set any value here to save the settings
          setting = Setting.plugin_redmine_checkout
          Setting.plugin_redmine_checkout = setting
        end
        
        class <<self
          alias_method :store_without_checkout, :[]=
          alias_method :[]=, :store_with_checkout
        end
      end
    end
    
    module ClassMethods
      def store_with_checkout(name, value)
        if name.to_s.starts_with? "checkout_"
          self.send("#{name}=", value)
        else
          store_without_checkout(name, value)
        end
      end
    end
  end
end

Setting.send(:include, Checkout::SettingPatch)