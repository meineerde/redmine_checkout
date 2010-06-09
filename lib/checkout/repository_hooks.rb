module Checkout
  class RepositoryHooks < Redmine::Hook::ViewListener
    # Renders the checkout URL
    #
    # Context:
    # * :project => Current project
    # * :repository => Current Repository
    #
    def view_repositories_show_contextual(context={})
      unless context[:repository].blank? || !Setting.checkout_display_checkout_info
        protocols = context[:repository].checkout_protocols.select do |p|
          p.access_rw == 'read-only' ||
          p.access_rw == 'read+write' && User.current.allowed_to?(:commit_access, context[:repository].project)
        end
      
        path = context[:controller].instance_variable_get("@path")
        if path && context[:controller].instance_variable_get("@entry")
          # a single file is showing, so we return only the directory
          path = File.dirname(path)
        end
      
        default_protocol = protocols.find(&:default?) || protocols.first
      
        context.merge!({
          :checkout_protocols => protocols,
          :default_checkout_protocol => default_protocol,
          :checkout_path => path
        })
      
        options = {:partial => "redmine_checkout_hooks/view_repositories_show_contextual"}
        context[:controller].send(:render_to_string, {:locals => context}.merge(options))
      end
    end
  end
end