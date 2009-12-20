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
      
      unless url.blank?
        # A bit hackish but gets the path component of the currently displayed dir/path
        path = context[:controller].instance_variable_get("@path")
        
        # remove trailing slashes
        url.gsub!(/\/+$/, "")
        url = "#{url}/#{path}"
      end
      
      url ||= "#"
      
      context.merge!({:url => url})
      options = {:partial => "redmine_checkout_hooks/view_repositories_show_contextual"}
      
      context[:controller].send(:render_to_string, {:locals => context}.merge(options))
    end
  end
end