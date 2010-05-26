class ConsolidateRepositoryOptions < ActiveRecord::Migration
  class Repository < ActiveRecord::Base
    def self.inheritance_column
      # disable single table inheritance
      nil
    end
    
    serialize :checkout_settings, Hash
  end

  def self.up
    add_column :repositories, :checkout_settings, :text
    
    Repository.all.each do |r|
      r.checkout_settings = {
        "checkout_url_type" => r.checkout_url_type,
        "checkout_url" => r.checkout_url,
        "display_login" => r.display_login,
        "render_type" => r.render_type,
        "checkout_url_overwrite" => r.checkout_url_overwrite
      }
      r.save!
    end
    remove_column :repositories, :checkout_url_type
    remove_column :repositories, :checkout_url
    remove_column :repositories, :display_login
    remove_column :repositories, :render_type
    remove_column :repositories, :checkout_url_overwrite
  end
  
  def self.down
    add_column :repositories, :checkout_url_type, :string, :default => nil, :null => true
    add_column :repositories, :checkout_url, :string, :default => nil, :null => true
    add_column :repositories, :display_login, :string, :default => nil, :null => true
    add_column :repositories, :render_type, :string, :default => 'url', :null => false
    add_column :repositories, :checkout_url_overwrite, :boolean, :default => false, :null => false
    
    Repository.all.each do |r|
      r.checkout_url_type = r.checkout_settings["checkout_url_type"]
      r.checkout_url = r.checkout_settings["checkout_url"]
      r.display_login = r.checkout_settings["display_login"]
      r.render_link = r.checkout_settings["render_link"]
      r.checkout_url_overwrite = r.checkout_settings["checkout_url_overwrite"]
      r.save!
    end
    
    remove_column :repositories, :checkout_settings
  end
end
