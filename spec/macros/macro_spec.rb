require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "Macros" do
  include ERB::Util
  include ApplicationHelper
  include ActionView::Helpers::TextHelper
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::UrlHelper

  let(:project) { FactoryGirl.create(:project) }

  before(:each) do
    project.enabled_module_names = project.enabled_module_names << "repository"
    setup_subversion_protocols
    Setting.checkout_display_command_Subversion = '0'
  end


  it "should display default checkout url" do
    text = "{{repository}}"

    url = "file:///#{RAILS_ROOT.gsub(%r{config\/\.\.}, '')}/tmp/test/subversion_repository"
    textilizable(text).should eql "<p><a href=\"#{url}\">#{url}</a></p>"
  end

  it "should display forced checkout url" do
    text = "{{repository(svn+ssh)}}"

    url = 'svn+ssh://svn.foo.bar/svn/subversion_repository'
    textilizable(text).should eql "<p><a href=\"#{url}\">#{url}</a></p>"
  end

  it "should fail without set project" do
    project = nil

    text = "{{repository(svn+ssh)}}"
    textilizable(text).should eql "<p><div class=\"flash error\">Error executing the <strong>repository</strong> macro (Checkout protocol svn+ssh not found)</div></p>"
  end

  it "should display checkout url from stated project" do
    project = nil
    text = "{{repository(#{project.name}:svn+ssh)}}"

    url = 'svn+ssh://svn.foo.bar/svn/subversion_repository'
    textilizable(text).should eql "<p><a href=\"#{url}\">#{url}</a></p>"
  end

  it "should display command" do
    Setting.checkout_display_command_Subversion = '1'

    text = "{{repository(svn+ssh)}}"
    url = 'svn+ssh://svn.foo.bar/svn/subversion_repository'
    textilizable(text).should eql "<p>svn co <a href=\"#{url}\">#{url}</a></p>"
  end
end
