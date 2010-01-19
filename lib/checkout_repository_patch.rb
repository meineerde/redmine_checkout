require_dependency 'repository'

module RepositoryPatch
  def self.included(base) # :nodoc:
    base.send(:include, InstanceMethods)
  end
  
  module InstanceMethods
    def after_initialize
      self.checkout_url_overwrite ||= false
      
      unless self.checkout_url_overwrite
        self.checkout_url_type = (Setting.plugin_redmine_checkout['checkout_url_type'])
        self.display_login = (Setting.plugin_redmine_checkout['display_login'])
        self.render_link = (Setting.plugin_redmine_checkout['render_link'])
        if self.checkout_url_type == "overwritten"
          self.checkout_url = generated_checkout_url
        end
      end
    end
    
    def generated_checkout_url
      regex = Setting.plugin_redmine_checkout['checkout_url_regex']
      replacement = Setting.plugin_redmine_checkout['checkout_url_regex_replacement']
      
      return "" if (regex.blank? ||  replacement.blank?)
      regex = Regexp.new(regex)
      
      self.root_url.gsub(regex, replacement)
    rescue RegexpError
      return ""
    end
  end
end

Repository.send(:include, RepositoryPatch)
