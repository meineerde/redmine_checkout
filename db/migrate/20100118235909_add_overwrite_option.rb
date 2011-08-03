class AddOverwriteOption < ActiveRecord::Migration
  def self.up
    add_column :repositories, :checkout_url_overwrite, :boolean, :default => false, :null => false
    
    # existing repositories are set to overwrite the default settings
    # This is to keep continuity of settings.
    Repository.reset_column_information
    Repository.update_all({:checkout_url_overwrite => true})
  end
  
  def self.down
    remove_column :repositories, :checkout_url_overwrite
  end
end

