class AddRenderLink < ActiveRecord::Migration
  def self.up
    add_column :repositories, :render_link, :boolean, :null => true
  end
  
  def self.down
    remove_column :repositories, :render_link
  end
end