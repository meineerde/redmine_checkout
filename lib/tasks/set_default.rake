namespace :redmine do
  namespace :plugins do
    namespace :redmine_checkout do
      desc "Sets all repositories to inherit the default setting for the checkout URL."
      task :set_default => :environment do
        Repository.all.each do |r|
          r.checkout_overwrite = '0'
          r.save!
        end
      end

      desc "Reset the plugin's settings. Use this if something isn't working anymore."
      task :reset => :environment do
        global = Setting.find_by_name 'plugin_redmine_checkout'
        global.destroy if global
        Rails.cache.delete "chiliproject/setting/plugin_redmine_checkout"
        Repository.all.each do |r|
          r.checkout_settings = {}
          r.save!
        end
      end
    end
  end
end
