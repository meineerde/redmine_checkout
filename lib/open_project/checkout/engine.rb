module OpenProject::Checkout
  class Engine < ::Rails::Engine
    engine_name :openproject_checkout

    config.autoload_paths += Dir["#{config.root}/lib/"]

    def self.settings
      settings_defaults = HashWithIndifferentAccess.new({
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
     settings_defaults
    end

    initializer 'checkout.precompile_ssets' do
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

    initializer :append_migrations do |app|
      unless app.root.to_s.match root.to_s
        config.paths["db/migrate"].expanded.each do |expanded_path|
          app.config.paths["db/migrate"] << expanded_path
        end
      end
    end

    spec = Bundler.environment.specs['openproject-checkout'][0]
    initializer "checkout.register_plugin" do
      require_dependency 'open_project/checkout/patches/repository_patch'

      Redmine::Plugin.register :openproject_checkout do
        name 'OpenProject Checkout plugin'
        url spec.homepage
        author ((spec.authors.kind_of? Array) ? spec.authors[0] : spec.authors)
        author_url 'http://www.finn.de'
        description spec.description
        version spec.version

        requires_openproject ">= 3.0.0pre21"

        settings :default => Engine.settings, :partial => 'settings/openproject_checkout'

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
            cmd.html_safe
            cmd + link_to(proto_obj.url, proto_obj.url)
          end
        end
      end

      config.to_prepare do
        require_dependency 'open_project/checkout/patches/repository_patch'
        require_dependency 'open_project/checkout/patches/settings_controller_patch'
        require_dependency 'open_project/checkout/patches/repositories_helper_patch'
        require_dependency 'open_project/checkout/patches/settings_helper_patch'
        require_dependency 'open_project/checkout/patches/setting_patch'

        # TODO: avoid this dirty hack necessary to prevent settings method getting lost after reloading
        Setting.create_setting("plugin_openproject_checkout", {'default' => Engine.settings, 'serialized' => true})
        Setting.create_setting_accessors("plugin_openproject_checkout")
      end
    end
  end
end
