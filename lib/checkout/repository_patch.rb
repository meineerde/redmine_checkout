require_dependency 'repository'
require_dependency 'checkout_helper'

module Checkout
  module RepositoryPatch
    def self.included(base) # :nodoc:
      base.send(:include, InstanceMethods)

      base.class_eval do
        unloadable
      
        serialize :checkout_settings, Hash
      end
    end
  
    module InstanceMethods
      def after_initialize
        self.checkout_settings ||= {}
      end
    
      def checkout_scm
        scm = self.scm_name
        unless CheckoutHelper.supported_scm.include?(scm) &&
        Setting.send("checkout_overwrite_description_#{scm}?")
          scm = "default"
        end
        scm
      end
    
      def checkout_overwrite=(value)
        checkout_settings['checkout_overwrite'] = value
      end
    
      def checkout_overwrite
        checkout_settings['checkout_overwrite']
      end

      def checkout_overwrite?
        checkout_overwrite.to_i > 0
      end
    
      def checkout_description=(value)
        checkout_settings['checkout_description'] = value
      end
    
      def checkout_description
        checkout_overwrite? && checkout_settings['checkout_description'] ||
        Setting.send("checkout_description_#{checkout_scm}")
      end
    
      def checkout_protocols
        @checkout_protocols ||= begin
          protocols = 
            checkout_overwrite? && checkout_settings['checkout_protocols'] || begin
              Setting.send("checkout_protocols_#{self.scm_name}")
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
        self.scm_name == "Subversion" && checkout_settings['checkout_display_login']
      end
    
      def checkout_display_login?
        checkout_display_login.to_i > 0
      end
    
      def checkout_display_login=(value)
        value = nil unless self.scm_name == "Subversion"
        checkout_settings['checkout_display_login'] = value
      end
    
      def self.allow_subtree_checkout?
        # default implementation
        false
      end
    
      def allow_subtree_checkout?
        self.class.allow_subtree_checkout?
      end
    end
  end
end

Repository.send(:include, Checkout::RepositoryPatch)

subtree_checkout_repos = ["Subversion", "Cvs"]
CheckoutHelper.supported_scm.each do |scm|
  require_dependency "repository/#{scm.underscore}"
  cls = Repository.const_get(scm)
  
  unless cls.singleton_methods.include?('allow_subtree_checkout?')
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
          #{subtree_checkout_repos.include?(scm)}
        end
      end
    EOF
    )
    cls.send(:include, class_mod)
  end
end
