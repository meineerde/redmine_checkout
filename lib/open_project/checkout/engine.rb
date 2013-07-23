module OpenProject::Checkout
  class Engine < ::Rails::Engine
    engine_name :openproject_checkout

    config.autoload_paths += Dir["#{config.root}/lib/"]

    initializer 'checkout.precompile_assets' do
      Rails.application.config.assets.precompile += %w(checkout.css checkout.js)
    end

    initializer "checkout.register_hooks" do
      # don't use require_dependency to not reload hooks in
      # development mode
      require 'open_project/checkout/hooks'
    end

    initializer 'checkout.register_test_paths' do |app|
      app.config.plugins_to_test_paths << self.root
    end

    # add our factories to factory girl's load path
    initializer "checkout.register_factories", :after => "factory_girl.set_factory_paths" do |app|
      FactoryGirl.definition_file_paths << File.expand_path(self.root.to_s + '/spec/factories') if defined?(FactoryGirl)
    end

    config.to_prepare do
      require_dependency 'open_project/checkout/patches/settings_controller_patch'
      require_dependency 'open_project/checkout/patches/repositories_helper_patch'
      require_dependency 'open_project/checkout/patches/repository_patch'
      require_dependency 'open_project/checkout/patches/settings_helper_patch'
      require_dependency 'open_project/checkout/patches/repository_patch'

      unless Redmine::Plugin.registered_plugins.include?(:openproject_checkout)
        Redmine::Plugin.register :openproject_checkout do
          name 'OpenProject Checkout plugin'
          url 'http://dev.holgerjust.de/projects/redmine-checkout'
          author 'Finn GmbH'
          author_url 'http://finn.de'
          description 'Add links to the actual repository to the repository view.'
          version '1.0.1'

          requires_openproject ">= 3.0.0beta1"

          settings_defaults = HashWithIndifferentAccess.new({
            'use_zero_clipboard' => '1',

            'display_checkout_info' =>  'everywhere',
            'description_Abstract' => <<-EOF
The data contained in this repository can be downloaded to your computer using one of several clients.
Please see the documentation of your version control software client for more information.

Please select the desired protocol below to get the URL.
            EOF
          })


          OpenProject::Checkout::CheckoutHelper.supported_scm.each do |scm|
            klazz = Repository.const_get(scm)

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
              :is_default => '1',
              :display_login => '0'
            })]
          end

          settings :default => settings_defaults, :partial => 'settings/openproject_checkout'

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
      end
      # must be loaded after plugin registration
      require_dependency 'open_project/checkout/patches/setting_patch'
    end
  end
end
