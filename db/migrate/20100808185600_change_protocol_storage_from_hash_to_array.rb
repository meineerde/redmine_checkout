class ChangeProtocolStorageFromHashToArray < ActiveRecord::Migration
  class Repository < ActiveRecord::Base
    serialize :checkout_settings, Hash

    # disable single table inheritance
    def self.inheritance_column() nil end
    # to fix some strange error where the type did return the class...
    def type() attributes["type"] end
  end

  def self.up
    ## First migrate the individual repositories
    Repository.all.each do |r|
      next unless r.checkout_settings['checkout_protocols'].is_a? Hash
      r.checkout_settings['checkout_protocols'] = r.checkout_settings['checkout_protocols'].sort{|(ak,av),(bk,bv)|ak<=>bk}.collect{|id,protocol| protocol}
      r.save!
    end

    ## Then the global settings
    settings = Setting.plugin_redmine_checkout
    settings.keys.grep(/^protocols_/).each do |protocols|
      next unless settings[protocols].is_a? Hash
      settings[protocols] = settings[protocols].sort{|(ak,av),(bk,bv)|ak<=>bk}.collect{|id,protocol| protocol}
    end
    Setting.plugin_redmine_checkout = settings
  end

  def self.down
    ## First migrate the individual repositories
    Repository.all.each do |r|
      next unless r.checkout_settings['checkout_protocols'].is_a? Hash
      r.checkout_settings['checkout_protocols'] = r.checkout_settings['checkout_protocols'].inject(HashWithIndifferentAccess.new) do |result, p|
        result[result.length.to_s] = p
      end
      r.save!
    end

    ## Then the global settings
    settings = Setting.plugin_redmine_checkout
    settings.keys.grep(/^protocols_/).each do |protocols|
      next unless r.checkout_settings['checkout_protocols'].is_a? Hash
      settings[protocols] = settings[protocols].inject(HashWithIndifferentAccess.new) do |result, p|
        result[result.length.to_s] = p
      end
    end
    Setting.plugin_redmine_checkout = settings
  end
end