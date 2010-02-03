require_dependency 'repository'

module RepositoryPatch
  def self.included(base) # :nodoc:
    base.send(:include, InstanceMethods)
    
    base.class_eval do
      unloadable
      
      validates_inclusion_of :checkout_url_type, :in => %w(none original overwritten generated), :allow_nil => true
      validates_inclusion_of :display_login, :in => %w(none username password), :allow_nil => true
    end
  end
  
  module InstanceMethods
    def after_initialize
      self.checkout_url_overwrite ||= false
    end
    
    def checkout_url_type
      self.checkout_url_overwrite && read_attribute("checkout_url_type") || begin
        Setting.plugin_redmine_checkout['checkout_url_type']
      end
    end

    def display_login
      self.checkout_url_overwrite && read_attribute("display_login") || begin
        Setting.plugin_redmine_checkout['display_login']
      end
    end
    
    def render_link
      self.checkout_url_overwrite && read_attribute("render_link") || begin
        Setting.plugin_redmine_checkout['render_link'] == "true"
      end
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
      regex = Setting.plugin_redmine_checkout['checkout_url_regex']
      replacement = Setting.plugin_redmine_checkout['checkout_url_regex_replacement']
      
      if (regex.blank? || replacement.blank?)
        self.url
      else
        self.url && self.url.gsub(Regexp.new(regex), replacement)
      end
    rescue RegexpError
      self.url || ""
    end
  end
end

Repository.send(:include, RepositoryPatch)
