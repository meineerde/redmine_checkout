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
  
  it 'should render 403 on unauthorized access' do
    @controller.stub(:user_setup)
    User.current = User.new

    non_member = Role.find_by_name('Non member')
    non_member.permissions -= [:view_changesets, :browse_repository]
    non_member.save!

    get_repo
    response.code.should == '403'
    response.should render_template('common/error')
  end

  it "should display the protocol selector" do
    get_repo
    response.should be_success
    response.should render_template('show')
    
    response.should have_tag('ul#checkout_protocols') do
      with_tag('a[id=?][href=?]', 'checkout_protocol_subversion', "file:///#{RAILS_ROOT.gsub(%r{config\/\.\.}, '')}/tmp/test/subversion_repository")
      with_tag('a[id=?][href=?]', 'checkout_protocol_svn+ssh', 'svn+ssh://svn.foo.bar/svn/subversion_repository')
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
  
  describe 'display_checkout_info' do
    it 'should display nothing when "none" is selected' do
      Setting.checkout_display_checkout_info = 'none'
      
      get_repo
      response.should be_success
      response.should render_template('show')
      response.should_not have_tag('div.repository-info')

      get :entry, :id => 1, :path => %w(subversion_test folder helloworld.rb)
      response.should be_success
      response.should render_template('entry')
      response.should_not have_tag('div.repository-info')
    end
    
    it 'should display on directory views only when "browse" is selected' do
      Setting.checkout_display_checkout_info = 'browse'
      
      get_repo
      response.should be_success
      response.should render_template('show')
      response.should have_tag('div.repository-info', /Please select the desired protocol below to get the URL/)
      
      get :entry, :id => 1, :path => %w(subversion_test folder helloworld.rb)
      response.should be_success
      response.should render_template('entry')
      response.should_not have_tag('div.repository-info')
    end
    
    it 'should display on all pages when "everywhere" is selected' do
      Setting.checkout_display_checkout_info = 'everywhere'
      
      get_repo
      response.should be_success
      response.should render_template('show')
      response.should have_tag('div.repository-info', /Please select the desired protocol below to get the URL/)
      
      get :entry, :id => 1, :path => %w(subversion_test folder helloworld.rb)
      response.should be_success
      response.should render_template('entry')
      response.should have_tag('div.repository-info')
    end
  end
end
