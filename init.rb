require 'redmine'

require 'dispatcher'
Dispatcher.to_prepare do
  # Patches
  require_dependency 'checkout_repositories_helper_patch'
  require_dependency 'checkout_repository_patch'
end

# Hooks
require 'checkout_repository_hooks'

Redmine::Plugin.register :redmine_checkout do
  name 'Redmine Checkout plugin'
  url 'http://dev.holgerjust.de/projects/redmine-checkout'
  author 'Holger Just'
  author_url 'http://meine-er.de'
  description 'Adds a link to the actual repository to the GUI.'
  version '0.2'
  
  requires_redmine :version_or_higher => '0.9'
  
  settings :default => {
    'checkout_url_type' => "none",
    'display_login' => 'username',
    'render_link' => 1,
    'checkout_url_regex' => "",
    'checkout_url_regex_replacement' => "",
  }, :partial => 'settings/redmine_checkout'
  
end
