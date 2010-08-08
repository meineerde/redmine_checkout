require 'redmine'

require 'dispatcher'
Dispatcher.to_prepare do
  # Patches
  require_dependency 'checkout/settings_controller_patch'
  
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
  description 'Add links to the actual repository to the repository view.'
  version '0.5'
  
  requires_redmine :version_or_higher => '0.9'
  
  settings_defaults = HashWithIndifferentAccess.new({
    'display_login' => nil,
    'use_zero_clipboard' => '1',
    
    'display_checkout_info' =>  '1',
    'description_Abstract' => <<-EOF
The data contained in this repository can be downloaded to your computer using one of several clients.
Please see the documentation of your version control software client for more information.

Please select the desired protocol below to get the URL.
EOF
  })
  
  # this is needed for setting the defaults
  require 'checkout/repository_patch'
  
  CheckoutHelper.supported_scm.each do |scm|
    klazz = "Repository::#{scm}".constantize
    
    settings_defaults["description_#{scm}"] = ''
    settings_defaults["overwrite_description_#{scm}"] = '0'
    settings_defaults["display_command_#{scm}"] = '0'
    
    # access can be one of
    #   read+write => this protocol always allows read/write access
    #   read-only => this protocol always allows read access only
    #   permission => Access depends on redmine permissions
    settings_defaults["protocols_#{scm}"] = [HashWithIndifferentAccess.new({
      :protocol => scm,
      :command => klazz.checkout_default_command,
      :regex => '',
      :regex_replacement => '',
      :fixed_url => '',
      :access => 'permission',
      :append_path => (klazz.allow_subtree_checkout? ? '1' : '0'),
      :is_default => '1'
    })]
  end
  
  settings :default => settings_defaults, :partial => 'settings/redmine_checkout'
  
  Redmine::WikiFormatting::Macros.register do
    desc <<-EOF
Creates a checkout link to the actual repository. Example:

  use the default checkout protocol !{{repository}}
  or use a specific protocol !{{repository(SVN)}}
  or use the checkout protocol of a specific specific project: !{{repository(projectname:SVN)}}"
EOF

    macro :repository do |obj, args|
      proto = args.first
      if proto.to_s =~ %r{^([^\:]+)\:(.*)$}
        project_identifier, proto = $1, $2
        project = Project.find_by_identifier(project_identifier) || Project.find_by_name(project_identifier)
      else
        project = @project
      end
      
      if project && project.repository
        protocols = project.repository.checkout_protocols.select{|p| p.access_rw(User.current)}
        
        if proto.present?
          proto_obj = protocols.find{|p| p.protocol.downcase == proto.downcase}
        else
          proto_obj = protocols.find(&:default?) || protocols.first
        end
      end
      raise "Checkout protocol #{proto} not found" unless proto_obj
      
      cmd = (project.repository.checkout_display_command? && proto_obj.command.present?) ? proto_obj.command.strip + " " : ""
      cmd + link_to(proto_obj.url, proto_obj.url)
    end
  end
end