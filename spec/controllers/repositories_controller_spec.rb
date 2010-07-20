require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe RepositoriesController do
  fixtures :settings, :repositories, :projects, :roles, :users, :enabled_modules
  integrate_views
  
  before(:each) do
    Setting.default_language = 'en'
    User.current = nil
  end
  
  def get_repo
    get :show, :id => 1
  end
  
  it "should display the protocol selector" do
    get_repo
    response.should be_success
    response.should render_template('show')
    
    response.should have_tag('ul#checkout_protocols') do
      with_tag('a[id=?][href=?]', 'checkout_protocol_subversion', "file:///#{RAILS_ROOT.gsub(%r{config\/\.\.}, '')}/tmp/test/subversion_repository")
      with_tag('a[id=?][href=?]', 'checkout_protocol_svn+ssh', 'svn+ssh://subversion_repository@svn.foo.bar/svn')
    end
  end
  
  it "should display the description" do
    get_repo
    response.should be_success
    response.should render_template('show')
    
    response.should have_tag('div.repository-info', /Please select the desired protocol below to get the URL/)
  end
  
  it 'should respect the use zero clipboard option' do
    Setting.checkout_use_zero_clipboard = '1'
    get_repo
    response.should be_success
    response.should render_template('show')
    response.should have_tag('script[src*=?]', 'ZeroClipboard')

    Setting.checkout_use_zero_clipboard = '0'
    get_repo
    response.should be_success
    response.should render_template('show')
    response.should_not have_tag('script[src*=]', 'ZeroClipboard')
  end
end
