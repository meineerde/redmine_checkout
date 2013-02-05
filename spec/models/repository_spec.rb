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

    it "should be forbidden on git" do
      @git.allow_subtree_checkout?.should eql false
    end
  end

  describe "extensions" do
    before(:each) do
      @repo = Repository::Subversion.new
    end

    it "should provide protocols" do
      protocols = @repo.checkout_protocols
      protocols[0].protocol.should eql "Subversion"
      protocols[1].protocol.should eql "SVN+SSH"
      protocols[2].protocol.should eql "Root"
    end
  end

  describe "to_xml" do
    let(:repo) { Repository::Subversion.new }

    it "should not have a yaml typed attribute checkout-settings" do
      # using something like nokogiri would be cleaner
      # but I don't want to introduce the dependency

      repo.to_xml.match(/<checkout-settings[^>]*?type=['"]yaml['"].*?>/).should be_nil
    end
  end
end
