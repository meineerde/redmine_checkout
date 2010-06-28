require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "Macros" do
  fixtures :settings, :repositories, :projects, :enabled_modules
  
  include ApplicationHelper
  include ActionView::Helpers::TextHelper

  before(:each) do
    @project = projects :projects_001
  end
  
  
  it "should display default checkout url" do
    text = "{{repository}}"
    textilizable(text).should eql "<p><a href=\"file:///#{RAILS_ROOT.gsub(%r{config\/\.\.}, '')}/tmp/test/subversion_repository\">Subversion checkout</a></p>"
  end

  it "should display forced checkout url" do
    text = "{{repository(svn+ssh)}}"
    textilizable(text).should eql "<p><a href=\"svn+ssh://subversion_repository@svn.foo.bar/svn\">SVN+SSH checkout</a></p>"
  end

  it "should fail without set project" do
    @project = nil
    
    text = "{{repository(svn+ssh)}}"
    textilizable(text).should eql "<p><div class=\"flash error\">Error executing the <strong>repository</strong> macro (Checkout protocol svn+ssh not found)</div></p>"
  end

  it "should display checkout url from stated project" do
    @project = nil
    
    text = "{{repository(ecookbook:svn+ssh)}}"
    textilizable(text).should eql "<p><a href=\"svn+ssh://subversion_repository@svn.foo.bar/svn\">SVN+SSH checkout</a></p>"
  end
end
