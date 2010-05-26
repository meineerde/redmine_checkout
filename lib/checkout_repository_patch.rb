require_dependency 'repository'
require_dependency 'checkout_helper'

module RepositoryPatch
  def self.included(base) # :nodoc:
    base.send(:include, InstanceMethods)

    base.class_eval do
      unloadable
      
      validates_inclusion_of :checkout_url_type, :in => %w(none original overwritten generated), :allow_nil => true
      validates_inclusion_of :display_login, :in => %w(none username password), :allow_nil => true
      validates_inclusion_of :render_type, :in => %w(url cmd link), :allow_nil => true
      
      serialize :checkout_settings, Hash
    end
  end
  
  module InstanceMethods
    def after_initialize
      self.checkout_settings ||= {}
    end

    # if the value is false, only a writer is generated
    # if value is true, then a reader is also generated
    checkout_setting_list = {
      :checkout_url_overwrite => false,
      :checkout_url_type => true,
      :checkout_url => false,
      :display_login => true,
      :render_type => true,
      :checkout_cmd => false
    }
    
    checkout_setting_list.each do |method, add_reader|
      module_eval(
        "def #{method}=(value)
          checkout_settings['#{method}'] = value
        end")
      module_eval(
        "def #{method}
          checkout_url_overwrite && checkout_settings['#{method}'] || begin
            Setting.plugin_redmine_checkout['#{method}']
          end
        end") if add_reader
    end

    def checkout_url_overwrite
      checkout_settings['checkout_url_overwrite'].to_s == 'true'
    end

    
    def checkout_cmd
      checkout_url_overwrite && checkout_settings['checkout_cmd'] || begin
        setting = Setting.plugin_redmine_checkout["checkout_cmd_#{self.scm_name}"]
        setting.blank? ? self.default_checkout_cmd : setting
      end
    end
    
    def checkout_url
      case checkout_url_type
      when "none": ""
      when "original": self.url || ""
      when "overwritten"
        if self.checkout_url_overwrite
          checkout_settings["checkout_url"]
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
    
    def allow_subtree_checkout
      # default implementation
      false
    end
    
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

subtree_checkout_repos = ["Subversion", "Cvs"]

checkout_strings.each_pair do |scm, cmd|
  require_dependency "repository/#{scm.underscore}"
  cls = Repository.const_get(scm)
  
  default_checkout_cmd = ""
  unless cls.methods.include?('default_checkout_cmd')
    default_checkout_cmd = "def default_checkout_cmd; '#{cmd}' end"
  end
  
  allow_subtree_checkout = ""
  unless cls.methods.include?('allow_subtree_checkout')
    allow_subtree_checkout = "
      def allow_subtree_checkout
        #{subtree_checkout_repos.include?(scm)}
      end"
  end
  
  class_mod = Module.new
  class_mod.module_eval("
    def self.included(base)
      base.send(:include, ChildInstanceMethods)
      
      base.class_eval do
        unloadable
      end
    end
    
    module ChildInstanceMethods
      #{default_checkout_cmd}
      #{allow_subtree_checkout}
    end"
  )
  
  cls.send(:include, class_mod)
end
