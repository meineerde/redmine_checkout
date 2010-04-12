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
  (["default"] + CheckoutHelper.supported_scm).each do |scm|
    settings_defaults["checkout_url_regex_#{scm}"] = ""
    settings_defaults["checkout_url_regex_replacement_#{scm}"] = ""
    settings_defaults["checkout_url_regex_overwrite_#{scm}"] = false
  end
  
  settings :default => settings_defaults, :partial => 'settings/redmine_checkout'
  
  Redmine::WikiFormatting::Macros.register do
    desc "Creates a link to the configured repository."

    macro :repository do |obj, args|
      # instance_variables.each do |v|
      #   p v
      #   p instance_variable_get(v)
      #   puts "------------------"
      # end
      
      p obj

      url = nil
      if @project && @project.repository
        case @project.repository.checkout_url_type
        when 'original'
          url = @project.repository.root_url
        when 'overwritten', 'generated'
          url = @project.repository.checkout_url
        end
        
        title = @project.repository.render_link ? l(:field_checkout_url) : url
      end
      "<a href=\"#{h(url)}\">#{h(title)}</a>" if url
    end
  end
end
