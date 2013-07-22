FactoryGirl.define do
  factory :svn_repository, class: Repository::Subversion do
    project
    url "file:///<%= RAILS_ROOT.gsub(%r{config\/\.\.}, '') %>/tmp/test/subversion_repository"
    root_url "file:///<%= RAILS_ROOT.gsub(%r{config\/\.\.}, '') %>/tmp/test/subversion_repository"
    password ""
    login ""
  end
end
