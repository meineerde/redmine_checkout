require_dependency 'repository'
require_dependency 'checkout_helper'

module Checkout
  module RepositoryPatch
    def self.included(base) # :nodoc:
      base.extend(ClassMethods)
      base.send(:include, InstanceMethods)

      base.class_eval do
        unloadable
      
        serialize :checkout_settings, Hash
      end
    end
    
    module ClassMethods
      def allow_subtree_checkout?
        # default implementation
        false
      end
    end
    
    module InstanceMethods
      def after_initialize
        self.checkout_settings ||= {}
      end
    
      def checkout_overwrite=(value)
        checkout_settings['checkout_overwrite'] = value
      end
    
      def checkout_overwrite
        checkout_settings['checkout_overwrite']
      end

      def checkout_overwrite?
        self.scm_name != 'Abstract' && checkout_overwrite.to_i > 0
      end
    
      def checkout_description=(value)
        checkout_settings['checkout_description'] = value
      end
    
      def checkout_description
        if checkout_overwrite?
          checkout_settings['checkout_description']
        else
          if CheckoutHelper.supported_scm.include?(scm_name) && Setting.send("checkout_overwrite_description_#{scm_name}?")
            Setting.send("checkout_description_#{scm_name}")
          else
            Setting.send("checkout_description_Abstract")
          end
        end
      end
    
      def checkout_protocols
        @checkout_protocols ||= begin
          if CheckoutHelper.supported_scm.include? scm_name
            if checkout_overwrite?
              protocols = checkout_settings['checkout_protocols']
            else
              protocols = Setting.send("checkout_protocols_#{scm_name}")
            end
          else
            protocols = []
          end

          protocols.sort{|(ak,av),(bk,bv)|ak<=>bk}.collect do |k,p|
            Checkout::Protocol.new p.merge({:repository => self})
          end
        end
      end
    
      def checkout_protocols=(value)
        checkout_settings['checkout_protocols'] = value
      end

      def checkout_display_login
        if checkout_overwrite? && self.scm_name == "Subversion"
          checkout_settings['checkout_display_login']
        else
          Setting.checkout_display_login
        end
      end
    
      def checkout_display_login?
        checkout_display_login.to_i > 0
      end
    
      def checkout_display_login=(value)
        value = nil unless self.checkout_scm == "Subversion"
        checkout_settings['checkout_display_login'] = value
      end
      
      def allow_subtree_checkout?
        self.class.allow_subtree_checkout?
      end
    end
  end
end

Repository.send(:include, Checkout::RepositoryPatch)

subtree_checkout_repos = ["Subversion", "Cvs"]
CheckoutHelper.supported_scm.select{|r| subtree_checkout_repos.include? r}.each do |scm|
  require_dependency "repository/#{scm.underscore}"
  cls = Repository.const_get(scm)
  
  class_mod = Module.new
  class_mod.module_eval(<<-EOF
    def self.included(base)
      base.extend ChildClassMethods

      base.class_eval do
        unloadable
      end
    end

    module ChildClassMethods
      def allow_subtree_checkout?
        true
      end
    end
  EOF
  )
  cls.send(:include, class_mod)
end
