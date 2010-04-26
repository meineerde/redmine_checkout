class AddDisplayLogin < ActiveRecord::Migration
  def self.up
    add_column :repositories, :display_login, :string, :default => 'none', :null => false
  end

  def self.down
    remove_column :repositories, :display_login
  end
end
