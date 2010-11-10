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
  
  after(:each) do
    User.current = User.anonymous
  end
  
  it "should use regexes for generated URL" do
    protocol = @repo.checkout_protocols.find{|r| r.protocol == "SVN+SSH"}
    protocol.url.should eql "svn+ssh://svn.foo.bar/svn/testrepo"
  end
  
  it "should resolve access properties" do
    protocol = @repo.checkout_protocols.find{|r| r.protocol == "Subversion"}
    protocol.access.should eql "permission"
    protocol.access_rw(@admin).should eql "read+write"
    
    User.current = @user
    protocol.access_rw(@user).should eql "read-only"
  end
  
  it "should display the checkout command" do
    subversion = @repo.checkout_protocols.find{|r| r.protocol == "Subversion"}
    svn_ssh = @repo.checkout_protocols.find{|r| r.protocol == "SVN+SSH"}

    subversion.command.should eql "svn checkout"
    svn_ssh.command.should eql "svn co"
  end
  
  it "should respect display login settings" do
    protocols = @repo.checkout_protocols
    
    User.current.login = "der_baer"
    @repo.checkout_overwrite = "1"
    @repo.checkout_protocols = protocols

    protocol = @repo.checkout_protocols.find{|r| r.protocol == "Root"}
    
    protocol.display_login = '0'
    protocol.url.should eql "http://example.com/svn/testrepo"

    protocol.display_login = '1'
    protocol.url.should eql "http://der_baer@example.com/svn/testrepo"
  end
  
end
