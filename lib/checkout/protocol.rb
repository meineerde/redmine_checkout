module Checkout
  class Protocol
    attr_accessor :protocol, :regex, :regex_replacement, :access, :repository
    attr_writer :default, :fixed_url, :append_path
    
    
    def initialize(args={})
      @protocol = args.delete :protocol
      
      # either a fixed url
      @fixed_url = args.delete :fixed_url

      # or a regex
      @regex = args.delete :regex
      @regex_replacement = args.delete :regex_replacement
      
      @access = args.delete :access
      @append_path = args.delete :append_path
      @default = args.delete :is_default
      
      @repository = args.delete :repository
    end
    
    def default?
      @default.to_i > 0
    end
    
    def append_path?
      @append_path.to_i > 0
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
    
    def access_rw
      if @access == 'permission'
        User.current.allowed_to?(:commit_access, repository.project) ? 'read+write' : 'read-only'
      else
        @access
      end
    end
    
    def access_label
      access == 'read+write' ? :label_access_read_write : :label_access_read_only
    end
  
    def url(path = "")
      return "" unless repository
      
      url = fixed_url.sub(/\/+$/, "")
      if repository.allow_subtree_checkout? && self.append_path? && path.present?
        url = "#{url}/#{path}"
      end
      
      if repository.checkout_display_login?
        begin
          uri = URI.parse url
          (uri.user = repository.login) if repository.login
          (uri.password = repository.password) if (repository.checkout_display_login == 'password' && repository.login && repository.password)
          url = uri.to_s
        rescue URI::InvalidURIError
        end
      end
      url
    end
  end
end