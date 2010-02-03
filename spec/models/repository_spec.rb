require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Repository do
  fixtures :settings, :repositories
  
  describe "initialize" do
    before(:each) do
      @repo = Repository.new()
    end

    it "should properly set default values" do
      @repo.checkout_url_type.should eql "generated"
      @repo.display_login.should eql "username"
      @repo.render_link.should be_false
      @repo.checkout_url.should eql ""
      @repo.checkout_url_overwrite.should be_false
    end
  end
  
  describe "checkout_url" do
    before(:each) do
      @repo = repositories :svn

      @repo.url = "svn://example.com/svn/testrepo"
      @repo.checkout_url = "svn+ssh://example.com/svn/testrepo"
    end
    
    it "should be generated from url" do
      @repo.checkout_url_type = "overwritten"
      @repo.checkout_url_overwrite = false
            
      @repo.checkout_url.should eql "http://example.com/svn/testrepo"
    end
    
    it "should respect overwritten setting" do
      @repo.checkout_url_type = "overwritten"
      @repo.checkout_url_overwrite = true

      @repo.checkout_url.should eql "svn+ssh://example.com/svn/testrepo"
    end
    
    it "should be generated if selected" do
      @repo.checkout_url_type = "generated"
      @repo.checkout_url_overwrite = true

      @repo.checkout_url.should eql "http://example.com/svn/testrepo"
    end
  end
end