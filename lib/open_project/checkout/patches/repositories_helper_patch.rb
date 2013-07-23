require_dependency 'repositories_helper'

module OpenProject::Checkout
  module RepositoriesHelperPatch
    def self.included(base) # :nodoc:
      base.send(:include, InstanceMethods)

      base.class_eval do
        alias_method_chain :repository_field_tags, :checkout
        alias_method_chain :scm_select_tag, :javascript
      end
    end

    module InstanceMethods
      def repository_field_tags_with_checkout(form, repository)
        tags = repository_field_tags_without_checkout(form, repository) || ""
        return tags if repository.class.name == "Repository"

        tags + @controller.send(:render_to_string, :partial => 'projects/settings/repository_checkout', :locals => {:form => form, :repository => repository, :scm => repository.type.demodulize})
      end

      def scm_select_tag_with_javascript(*args)
        content_for :header_tags do
          javascript_include_tag('checkout/subform', :plugin => 'openproject_checkout') +
          stylesheet_link_tag('checkout/checkout', :plugin => 'openproject_checkout')
        end
        scm_select_tag_without_javascript(*args)
      end
    end
  end
end

RepositoriesHelper.send(:include, OpenProject::Checkout::RepositoriesHelperPatch)

