# -- load spec_helper from OpenProject core
require "spec_helper"

def setup_subversion_protocols
  Setting.stub(:checkout_protocols_Subversion) { [
    HashWithIndifferentAccess.new({
      command: 'svn checkout',
      regex: 'foo',
      append_path: '1',
      is_default: '1',
      display_login: '1',
      protocol: 'Subversion',
      access: 'permission',
      regex_replacement: 'bar'
    }),
    HashWithIndifferentAccess.new({
      command: 'svn co',
      regex: '^.*?([^/]+)/?$',
      append_path: '1',
      is_default: '0',
      display_login: '1',
      protocol: 'SVN+SSH',
      access: 'read-only',
      regex_replacement: 'svn+ssh://svn.foo.bar/svn/\1'
    }),
    HashWithIndifferentAccess.new({
      command: 'svn checkout',
      append_path: '0',
      is_default: '1',
      display_login: '1',
      regex: '',
      protocol: 'Root',
      access: 'read+write',
      regex_replacement: ''
    })
  ]
  }
end

# Returns the path to the test +vendor+ repository
def repository_path(vendor)
  File.join(Rails.root.to_s.gsub(%r{config\/\.\.}, ''), "/tmp/test/#{vendor.downcase}_repository")
end

# Returns the url of the subversion test repository
def subversion_repository_url
  path = repository_path('subversion')
  path = '/' + path unless path.starts_with?('/')
  "file://#{path}"
end
