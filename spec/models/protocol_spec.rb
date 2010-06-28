require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Checkout::Protocol do
  fixtures :settings, :repositories, :projects, :enabled_modules
  
  before(:each) do
    @admin = User.new
    @admin.admin = true
    @user = User.new
    
    @repo = repositories :svn
    @repo.url = "http://example.com/svn/testrepo"
  end
  
  it "should use regexes for generated URL" do
    protocol = @repo.checkout_protocols.find{|r| r.protocol == "SVN+SSH"}
    protocol.url.should eql "svn+ssh://testrepo@svn.foo.bar/svn"
  end
  
  it "should resolve access properties" do
    protocol = @repo.checkout_protocols.find{|r| r.protocol == "Subversion"}
    protocol.access.should eql "permission"
    protocol.access_rw(@admin).should eql "read+write"
    
    User.current = @user
    protocol.access_rw(@user).should eql "read-only"
  end
end
