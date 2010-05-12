require_dependency 'repository'
require_dependency 'checkout_helper'

module RepositoryPatch
  def self.included(base) # :nodoc:
    base.extend(ClassMethods)
    base.send(:include, InstanceMethods)

    base.class_eval do
      unloadable
      
      validates_inclusion_of :checkout_url_type, :in => %w(none original overwritten generated), :allow_nil => true
      validates_inclusion_of :display_login, :in => %w(none username password), :allow_nil => true
      validates_inclusion_of :render_type, :in => %w(url cmd link), :allow_nil => true
    end
  end
  
  module InstanceMethods
    def after_initialize
      self.checkout_url_overwrite ||= false
    end
    
    %w(checkout_url_type display_login render_type).each do |method|
      module_eval( "def #{method}
                      self.checkout_url_overwrite && read_attribute('#{method}') || begin
                        Setting.plugin_redmine_checkout['#{method}']
                      end
                    end")
    end
    
    
    
    def checkout_cmd
      setting = Setting.plugin_redmine_checkout["checkout_cmd_#{self.scm_name}"]
      setting.blank? ? self.default_checkout_cmd : setting
    end

    def checkout_url
      case checkout_url_type
      when "none": ""
      when "original": self.url || ""
      when "overwritten"
        if self.checkout_url_overwrite
          read_attribute("checkout_url")
        else
          generated_checkout_url
        end
      when "generated"
        generated_checkout_url
      end
    end

    def generated_checkout_url
      return "" unless self.url
      
      scm = self.scm_name
      unless CheckoutHelper.supported_scm.include?(scm) &&
      Setting.plugin_redmine_checkout["checkout_url_regex_overwrite_#{scm}"]
        scm = "default"
      end
      
      regex = Setting.plugin_redmine_checkout["checkout_url_regex_#{scm}"]
      replacement = Setting.plugin_redmine_checkout["checkout_url_regex_replacement_#{scm}"]
      
      if (regex.blank? || replacement.blank?)
        self.url
      else
        self.url && self.url.gsub(Regexp.new(regex), replacement)
      end
    rescue RegexpError
      self.url || ""
    end
  end

  module ClassMethods
    def default_checkout_cmd
      # default implementation
      ""
    end
  end
end

Repository.send(:include, RepositoryPatch)

checkout_strings = {
  "Bazaar" => "bzr checkout",
  "Cvs" => "cvs checkout",
  "Darcs" => "darcs get",
  "Git" => "git clone",
  "Mercurial" => "hg clone",
  "Subversion" => "svn checkout"
}

allow_subtree_checkout = ["Subversion", "Cvs"]

checkout_strings.each_pair do |scm, cmd|
  require_dependency "repository/#{scm.underscore}"
  cls = Repository.const_get(scm)

  class_mod = Module.new
  class_mod.module_eval("
    def self.included(base)
      base.send(:include, InstanceMethods)
      
      base.class_eval do
        unloadable
      end
    end
    
    module InstanceMethods
      def default_checkout_cmd
        '#{cmd}'
      end
      def allow_subtree_checkout
        #{allow_subtree_checkout.include? scm}
      end
    end"
  )
  
  cls.send(:include, class_mod)
end
