require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Setting do
  before(:each) do
    Setting.default_language = 'en'
    Setting.checkout_display_checkout_info = 'everywhere'
  end

  it "should recognize checkout methods" do
    Setting.checkout_display_checkout_info.should eql Setting.plugin_openproject_checkout['display_checkout_info']
    Setting.checkout_display_checkout_info.should eql Setting.plugin_openproject_checkout[:display_checkout_info]
  end
end
