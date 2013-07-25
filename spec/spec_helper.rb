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
      protocol: 'svn+ssh',
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
