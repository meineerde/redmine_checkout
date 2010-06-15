require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Repository do
  fixtures :settings, :repositories
  
  describe "initialize" do
    before(:each) do
      @repo = Repository.new()
    end

    it "should properly set default values" do
      @repo.checkout_overwrite?.should be_false
      @repo.checkout_description.should match /Please select the desired protocol below to get the URL/
      @repo.checkout_display_login?.should be_false # no subversion repo
      @repo.allow_subtree_checkout?.should be_false
      @repo.checkout_protocols.should eql []
    end
  end
  
  describe "subtree checkout" do
    before(:each) do
      @svn = Repository::Subversion.new
      @git = Repository::Git.new
    end
    it "should be allowed on subversion" do
      @svn.allow_subtree_checkout?.should eql true
    end
    it "should only be possible if checked" do
      
    end
    
    it "should be forbidden on gít" do
      @git.allow_subtree_checkout?.should eql false
    end
  end
end