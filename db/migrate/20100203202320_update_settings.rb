class UpdateSettings < ActiveRecord::Migration
  def self.up
    settings = Setting.plugin_redmine_checkout
    if settings['checkout_url_type'] == "overwritten"
      settings['checkout_url_type'] = "generated"
    end
    
    if settings.has_key? "checkout_url_regex"
      settings['checkout_url_regex_default'] = settings.delete("checkout_url_regex")
    end

    if settings.has_key? "checkout_url_regex_replacement"
      settings['checkout_url_regex_replacement_default'] = settings.delete("checkout_url_regex_replacement")
    end
    
    Setting.plugin_redmine_checkout = settings
  end
  
  def self.down
    settings = Setting.plugin_redmine_checkout
    if settings['checkout_url_type'] == "generated"
      settings['checkout_url_type'] = "overwritten"
    end
    
    if settings.has_key? "checkout_url_regex_default"
      settings['checkout_url_regex'] = settings.delete("checkout_url_regex_default")
    end

    if settings.has_key? "checkout_url_regex_replacement_default"
      settings['checkout_url_regex_replacement'] = settings.delete("checkout_url_regex_replacement_default")
    end
    
    Setting.plugin_redmine_checkout = settings
  end
end

