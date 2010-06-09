require_dependency 'repositories_helper'

module RepositoriesHelperPatch
  def self.included(base) # :nodoc:
    base.send(:include, InstanceMethods)

    base.class_eval do
      alias_method_chain :repository_field_tags, :checkout
    end
  end
  
  module InstanceMethods
    def repository_field_tags_with_checkout(form, repository)    
      tags = repository_field_tags_without_checkout(form, repository) || ""
      return tags if repository.class.name == "Repository"
      
      tags + @controller.send(:render_to_string, :partial => 'projects/settings/repository_checkout', :locals => {:form => form, :repository => repository, :scm => repository.scm_name})
    end
  end
end

RepositoriesHelper.send(:include, RepositoriesHelperPatch)

