require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

# This spec requires the test svn repository to be set up:
# rake test:scm:setup:subversion
describe RepositoriesController do

  let(:project) { FactoryGirl.create(:project, is_public: true) }
  let(:user) { FactoryGirl.create(:user, login: "repouser", mail: "repouser@test.com") }
  let(:role) { FactoryGirl.create(:role, permissions: [:browse_repository]) }
  let!(:member) { FactoryGirl.create(:member, user: user, project: project, roles: [role]) }

  render_views

  before(:each) do
    Setting.default_language = 'en'
    Setting.autofetch_changesets = false

    @repository = Repository::Subversion.create(:project => project,
             :url => subversion_repository_url)
    @controller.stub(:user_setup)

    setup_subversion_protocols

    @project = project
    @project.enabled_module_names << "repository"
    @project.repository = @repository
    @project.save!

    User.current = user
  end

  after(:each) do
    User.current = nil
  end

  def get_repo
    get :show, :id => project.id
  end

  it 'should render 403 on unauthorized access' do
    User.current = User.new

    get_repo
    response.code.should == '403'
    response.should render_template('common/error')
  end

  it "should display the protocol selector" do
    get_repo
    response.should be_success
    response.should render_template('show')

    response.body.should have_selector('ul#checkout_protocols') do
      with_tag('a[id=?][href=?]', 'checkout_protocol_subversion', "file:///#{Rails.root.to_s.gsub(%r{config\/\.\.}, '')}/tmp/test/subversion_repository")
      with_tag('a[id=?][href=?]', 'checkout_protocol_svn+ssh', 'svn+ssh://repouser@svn.foo.bar/svn/subversion_repository')
    end
  end

  it "should display the description" do
    get_repo
    response.should be_success
    response.should render_template('show')

    response.body.should have_selector('div.repository-info', /Please select the desired protocol below to get the URL/)
  end

  describe 'display_checkout_info' do
    it 'should display nothing when "none" is selected' do
      Setting.checkout_display_checkout_info = 'none'

      get_repo
      response.should be_success
      response.should render_template('show')
      response.body.should_not have_selector('div.repository-info')

      get :entry, :id => @project.id, :path => "subversion_test/folder/helloworld.rb"
      response.should be_success
      response.should render_template('entry')
      response.body.should_not have_selector('div.repository-info')
    end

    it 'should display on directory views only when "browse" is selected' do
      Setting.checkout_display_checkout_info = 'browse'

      get_repo
      response.should be_success
      response.should render_template('show')
      response.body.should have_selector('div.repository-info', /Please select the desired protocol below to get the URL/)

      get :entry, :id => @project.id, :path => "subversion_test/folder/helloworld.rb"
      response.should be_success
      response.should render_template('entry')
      response.body.should_not have_selector('div.repository-info')
    end

    it 'should display on all pages when "everywhere" is selected' do
      Setting.checkout_display_checkout_info = 'everywhere'

      get_repo
      response.should be_success
      response.should render_template('show')
      response.body.should have_selector('div.repository-info', /Please select the desired protocol below to get the URL/)

      get :entry, :id => @project.id, :path => "subversion_test/folder/helloworld.rb"
      response.should be_success
      response.should render_template('entry')
      response.body.should have_selector('div.repository-info')
    end
  end
end
