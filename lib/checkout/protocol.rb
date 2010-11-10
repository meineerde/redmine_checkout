module Checkout
  class <<self
    def awesome?
      # Yes, this plugin is awesome!
      true
    end
  end
  
  class Protocol
    attr_accessor :protocol, :regex, :regex_replacement, :access, :display_login, :repository
    attr_writer :default, :command, :fixed_url, :append_path
    %w(default append_path display_login).each do |bool|
      src = <<-END_SRC
        def #{bool}?
          @#{bool}.to_i > 0
        end
      END_SRC
      class_eval src, __FILE__, __LINE__
    end
    
    
    def initialize(args={})
      args = args.dup
      
      @protocol = args.delete :protocol
      @command = args.delete :command # optional, if not set the default from the repo is used
      
      # either a fixed url
      @fixed_url = args.delete :fixed_url
      # or a regex
      @regex = args.delete :regex
      @regex_replacement = args.delete :regex_replacement
      
      @access = args.delete :access
      
      # boolean values
      @default = args.delete :is_default
      @append_path = args.delete :append_path
      @display_login = args.delete :display_login
      
      # some reference
      @repository = args.delete :repository
    end
    
    def full_command(path = "")
      cmd = ""
      if repository.checkout_display_command?
        cmd = self.command.present? ? self.command.strip + " " : ""
      end
      cmd + URI.escape(self.url(path))
    end
    
    def command
      @command || self.repository && self.repository.checkout_default_command || ""
    end
    
    def access_rw(user)
      # reduces the three available access levels 'read+write', 'read-only' and 'permission'
      # to 'read+write' and 'read-only' and nil (not allowed)

      @access_rw ||= {}
      return @access_rw[user] if @access_rw.key? user
      @access_rw[user] = case access
      when 'permission'
        case
        when user.allowed_to?(:commit_access, repository.project) && user.allowed_to?(:browse_repository, repository.project)
          'read+write'
        when user.allowed_to?(:browse_repository, repository.project)
          'read-only'
        else
          nil
        end
      else
        @access
      end
    end
    
    def access_label(user)
      case access_rw(user)
        when 'read+write': :label_access_read_write
        when 'read-only': :label_access_read_only
      end
    end
  
    def fixed_url
      @fixed_url.present? ? @fixed_url : begin
        if (regex.blank? || regex_replacement.blank?)
          repository.url
        else
          repository.url.gsub(Regexp.new(regex), regex_replacement)
        end
      end
    rescue RegexpError
      repository.url || ""
    end

    def url(path = "")
      return "" unless repository
      
      url = fixed_url.sub(/\/+$/, "")
      if repository.allow_subtree_checkout? && self.append_path? && path.present?
        url = "#{url}/#{path}"
      end
      
      if display_login?
        begin
          uri = URI.parse url
          unless uri.scheme == 'file'
            # file URIs can't possibly contain any username / password info
            # And URI.parse does not properly reconstruct the URL...
            uri.user = User.current.login
            url = uri.to_s
          end
        rescue URI::InvalidURIError
        end
      end
      url
    end
  end
end