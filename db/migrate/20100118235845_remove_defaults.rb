class RemoveDefaults < ActiveRecord::Migration
  def self.up
    change_column :repositories, :checkout_url_type, :string, :default => nil, :null => true
    change_column :repositories, :checkout_url, :string, :default => nil, :null => true
    change_column :repositories, :display_login, :string, :default => nil, :null => true
  end
  
  def self.down
    change_column :repositories, :checkout_url_type, :string, :default => 'none', :null => false
    change_column :repositories, :checkout_url, :string, :default => '', :null => false
    change_column :repositories, :display_login, :string, :default => 'none', :null => false
  end
end

