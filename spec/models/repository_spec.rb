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
      @repo.render_type.should eql 'url'
      @repo.checkout_url.should eql ""
      @repo.checkout_url_overwrite.should be_false
    end
  end
  
  describe "checkout_url" do
    before(:each) do
      @repo = repositories :svn

      @repo.url = "svn://example.com/svn/testrepo"
      @repo.checkout_url = "http://svn.example.com/testrepo"
    end
    
    it "should be generated from url" do
      @repo.checkout_url_type = "overwritten"
      @repo.checkout_url_overwrite = false
            
      @repo.checkout_url.should eql "http://example.com/svn/testrepo"
    end
    
    it "should respect overwritten setting" do
      @repo.checkout_url_type = "overwritten"
      @repo.checkout_url_overwrite = true

      @repo.checkout_url.should eql "http://svn.example.com/testrepo"
    end
    
    it "should be generated if selected" do
      @repo.checkout_url_type = "generated"
      @repo.checkout_url_overwrite = true

      @repo.checkout_url.should eql "http://example.com/svn/testrepo"
    end
    
    it "should respect individual repository type specifications" do
      Setting.plugin_redmine_checkout["checkout_url_regex_overwrite_Subversion"] = "1"
      Setting.plugin_redmine_checkout = Setting.plugin_redmine_checkout
      
      @repo.checkout_url_type = "generated"
      @repo.checkout_url_overwrite = true

      @repo.checkout_url.should eql "svn+ssh://example.com/svn/testrepo"
    end
  end

  describe "checkout_cmd" do
    before(:each) do
      @repo = repositories :svn
    end
    
    it "should provide sensible defaults" do
      @repo.checkout_cmd.should eql "svn checkout"
    end
    
    it "should respect overwritten setting" do
      Setting.plugin_redmine_checkout["checkout_cmd_Subversion"] = "git clone"
      @repo.checkout_cmd.should eql "git clone"
    end
  end
end