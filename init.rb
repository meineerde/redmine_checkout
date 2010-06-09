require 'redmine'

require 'dispatcher'
Dispatcher.to_prepare do
  # Patches
  require_dependency 'checkout/repositories_helper_patch'
  require_dependency 'checkout/repository_patch'
  
  require_dependency 'checkout/settings_helper_patch'
  require_dependency 'checkout/setting_patch'
end

# Hooks
require 'checkout/repository_hooks'

Redmine::Plugin.register :redmine_checkout do
  name 'Redmine Checkout plugin'
  url 'http://dev.holgerjust.de/projects/redmine-checkout'
  author 'Holger Just'
  author_url 'http://meine-er.de'
  description 'Adds a link to the actual repository to the GUI.'
  version '0.4.1'
  
  requires_redmine :version_or_higher => '0.9'
  
  settings_defaults = {
    'display_login' => nil,
    
    'display_checkout_info' => 1,
    'description_default' => <<-EOF
The data contained in this repository can be downloaded to your computer using one of several clients.
Please see the documentation of your version control software client for more information.

Please select the desired protocol below to get the URL.
EOF
  }
  
  # this is needed for setting the defaults
  require 'checkout/repository_patch'
  
  (["default"] + CheckoutHelper.supported_scm).each do |scm|
    settings_defaults["checkout_url_regex_#{scm}"] = ""
    settings_defaults["checkout_url_regex_replacement_#{scm}"] = ""
    unless scm == 'default'
      klazz = "Repository::#{scm}".constantize
      
      settings_defaults["description_#{scm}"] = ""
      settings_defaults["overwrite_description_#{scm}"] = 0
      
      settings_defaults["protocols_#{scm}"] = {
        # access can be one of
        #   read+write => this protocol always allows read/write access
        #   read-only => this protocol always allows read access only
        #   permission => Access depends on redmine permissions
        "0" => {:protocol => scm,
                :regex => "",
                :regex_replacement => "",
                :access => 'read+write',
                :append_path => (klazz.allow_subtree_checkout? ? 1 : 0),
                :is_default => 1
               }
      }
    end
  end
  
  settings :default => settings_defaults, :partial => 'settings/redmine_checkout'
  
  Redmine::WikiFormatting::Macros.register do
    desc "Creates a link to the configured repository."

    macro :repository do |obj, args|
      url = nil
      if @project && @project.repository
        case @project.repository.checkout_url_type
        when 'original'
          url = @project.repository.root_url
        when 'overwritten', 'generated'
          url = @project.repository.checkout_url
        end
        
        title = case @project.repository.render_type
        when 'link'
          l(:field_checkout_url)
        when 'cmd', 'url'
          url
        end
      end
      "<a href=\"#{URI.escape(url)}\">#{h(title)}</a>" if url
    end
  end
end