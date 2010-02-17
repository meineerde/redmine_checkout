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
  version '0.3'
  
  requires_redmine :version_or_higher => '0.9'
  
  settings_defaults = {
    'checkout_url_type' => "none",
    'display_login' => 'username',
    'render_link' => "false"
  }
  (["default"] + REDMINE_SUPPORTED_SCM).each do |scm|
    settings_defaults["checkout_url_regex_#{scm}"] = ""
    settings_defaults["checkout_url_regex_replacement_#{scm}"] = ""
    settings_defaults["checkout_url_regex_overwrite_#{scm}"] = false
  end
  
  settings :default => settings_defaults, :partial => 'settings/redmine_checkout'
end
