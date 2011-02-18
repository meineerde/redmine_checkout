class MoreDisplayOptions < ActiveRecord::Migration
  def self.up
    settings = Setting.plugin_redmine_checkout
    
    if settings[:display_checkout_info].to_i > 0
      settings[:display_checkout_info] = 'everywhere'
    else
      settings[:display_checkout_info] = 'none'
    end
    
    Setting.plugin_redmine_checkout = settings
  end
  
  def self.down
    settings = Setting.plugin_redmine_checkout
    
    if settings[:display_checkout_info] == 'none'
      settings[:display_checkout_info] = '0'
    else
      settings[:display_checkout_info] = '1'
    end
    
    Setting.plugin_redmine_checkout = settings
  end
end