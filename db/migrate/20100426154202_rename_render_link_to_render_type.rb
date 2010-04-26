class RenameRenderLinkToRenderType < ActiveRecord::Migration
  def self.up
    render_link = Setting.plugin_redmine_checkout.delete 'render_link'
    unless  render_link.nil?
      Setting.plugin_redmine_checkout['render_type'] = (render_link == 'true' ? 'link' : 'url')
      Setting.plugin_redmine_checkout = Setting.plugin_redmine_checkout
    end
    
    add_column :repositories, :render_type, :string, :default => 'url', :null => false
    
    Repository.update_all({:render_type => 'link'}, :render_link => true)
    Repository.update_all({:render_type => 'url'}, ["render_link != ?", true])
    
    remove_column :repositories, :render_link
  end
  
  def self.down
    render_type = Setting.plugin_redmine_checkout.delete 'render_type'
    unless  render_type.nil?
      Setting.plugin_redmine_checkout['render_link'] = (render_type == 'link' ? 'true' : 'false')
      Setting.plugin_redmine_checkout = Setting.plugin_redmine_checkout
    end
    
    add_column :repositories, :render_link, :boolean, :null => true
    
    Repository.update_all({:render_link => true}, :render_type => 'link')
    Repository.update_all({:render_link => false}, ["render_type != ?", 'link'])
    
    remove_column :repositories, :render_type
  end
end
