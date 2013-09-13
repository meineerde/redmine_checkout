$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "open_project/checkout/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "openproject-checkout"
  s.version     = OpenProject::Checkout::VERSION
  s.authors     = "Finn GmbH, Holger Just"
  s.email       = "info@finn.de"
  s.homepage    = "https://www.openproject.org/projects/checkout"
  s.summary     = "Add links to the actual repository to the repository view."
  s.description = "Add links to the actual repository to the repository view."
  s.files       = Dir["{app,config,db,lib}/**/*", "README.rdoc", "CHANGELOG.md"]
  s.test_files  = Dir["spec/**/*"]

  s.add_development_dependency "factory_girl_rails", "~> 4.0"
end
