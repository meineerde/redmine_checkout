# -- load spec_helper from OpenProject core
require "spec_helper"

def setup_subversion_protocols
  Setting.checkout_protocols_Subversion = [
    {
      command: 'svn checkout',
      regex: 'foo',
      append_path: '1',
      is_default: '1',
      display_login: '1',
      protocol: 'Subversion',
      access: 'permission',
      regex_replacement: 'bar'
    },
    {
      command: 'svn co',
      regex: '^.*?([^/]+)/?$',
      append_path: '1',
      is_default: '0',
      display_login: '1',
      protocol: 'SVN+SSH',
      access: 'read-only',
      regex_replacement: 'svn+ssh://svn.foo.bar/svn/\1'
    },
    {
      command: 'svn checkout',
      append_path: '0',
      is_default: '0',
      display_login: '1',
      regex: '',
      protocol: 'Root',
      access: 'read+write',
      regex_replacement: ''
    }
  ]
end
