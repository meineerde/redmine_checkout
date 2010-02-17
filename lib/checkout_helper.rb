module CheckoutHelper
  def self.supported_scm
    Object.const_defined?("REDMINE_SUPPORTED_SCM") ? REDMINE_SUPPORTED_SCM : Redmine::Scm::Base.all
  end
end