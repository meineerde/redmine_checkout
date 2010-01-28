#!/usr/bin/env ruby
require 'redmine_plugin_support'
 
Dir[File.expand_path(File.dirname(__FILE__)) + "/lib/tasks/**/*.rake"].sort.each { |ext| load ext }
 
RedminePluginSupport::Base.setup do |plugin|
  plugin.project_name = 'redmine_checkout'
  plugin.default_task = [:spec]
  plugin.tasks = [:doc, :release, :clean, :spec, :stats]
end