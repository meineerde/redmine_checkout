class RepositoryHooks < Redmine::Hook::ViewListener

  # Renders the checkout URL
  #
  # Context:
  # * :project => Current project
  # * :repository => Current Repository
  #
  def view_repositories_show_contextual(context={})
    unless context[:repository].blank? || context[:repository].checkout_url_type == "none"
      case context[:repository].checkout_url_type
      when 'original'
        url = context[:repository].root_url
      when 'overwritten'
        url = context[:repository].checkout_url
      end
      url ||= "#"
      

      context.merge!({:url => url})
      options = {:partial => "redmine_checkout_hooks/view_repositories_show_contextual"}
      
      context[:controller].send(:render_to_string, {:locals => context}.merge(options))
    end
  end
end