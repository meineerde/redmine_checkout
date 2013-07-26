require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe RepositoriesController do

  let(:project) { FactoryGirl.create(:project) }
  let(:svn_repository) { FactoryGirl.create(:svn_repository, project: project) }
  let(:admin) { FactoryGirl.create(:admin) }

  render_views

  before(:each) do
    Setting.default_language = 'en'
    setup_subversion_protocols
    project.enabled_module_names = project.enabled_module_names << "repository"
    project.repository = svn_repository
    project.save!
    User.current = admin
  end

  after(:each) do
    User.current = nil
  end

  def get_repo
    get :show, :id => project.id
  end

  it 'should render 403 on unauthorized access' do
    @controller.stub(:user_setup)
    User.current = User.new

    get_repo
    response.code.should == '403'
    response.should render_template('common/error')

    User.current = nil
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
