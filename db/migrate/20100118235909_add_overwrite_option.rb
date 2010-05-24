class AddOverwriteOption < ActiveRecord::Migration
  class Repository < ActiveRecord::Base
    def self.inheritance_column
      # disable single table inheritance
      nil
    end
    
    # Need to mock because later code removes the attribute
    def checkout_settings
      {}
    end
  end
  
  def self.up
    add_column :repositories, :checkout_url_overwrite, :boolean, :default => false, :null => false
    
    # existing repositories are set to overwrite the default settings
    # This is to keep continuity of settings.
    Repository.reset_column_information
    Repository.all.each{|r| r.update_attribute(:checkout_url_overwrite, true)}
  end
  
  def self.down
    remove_column :repositories, :checkout_url_overwrite
  end
end

