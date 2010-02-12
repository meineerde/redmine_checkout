namespace :redmine do
  namespace :plugins do
    namespace :redmine_checkout do
      desc "Sets all repositories to inherit the default setting for the checkout URL."
      task :set_default => :environment do
        Repository.all.each{|r| r.update_attributes(:checkout_url_overwrite => false)}
      end
    end
  end
end
