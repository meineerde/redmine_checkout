require_dependency 'repositories_helper'

module RepositoriesHelperPatch
  def self.included(base) # :nodoc:
    base.send(:include, InstanceMethods)

    base.class_eval do
      alias_method_chain :subversion_field_tags, :checkout
      alias_method_chain :repository_field_tags, :checkout
    end
  end
  
  module InstanceMethods
    def repository_field_tags_with_checkout(form, repository)    
      if repository.is_a? Repository::Subversion
         subversion_field_tags(form, repository)
      else
        tags = repository_field_tags_without_checkout(form, repository) || ""
        tags + 
        content_tag('p',
          form.select(:checkout_url_type, [
              [l(:label_checkout_type_none), 'none'],
              [l(:label_checkout_type_overwritten), 'overwritten']
            ],
            {},
            :onchange => "if ($A(['none']).include(value)){$('checkout_url').hide();} else {show_checkout_url();}"
          )
        ) +
        content_tag('p',
          form.text_field(:checkout_url, :size => 60),
          :id => "checkout_url",
          :style => ("display:none" unless ['overwritten'].include? form.object.checkout_url_type)
        )
      end
    end

    def subversion_field_tags_with_checkout(form, repository)
      tags = subversion_field_tags_without_checkout(form, repository) || ""
      
      tags +
      javascript_tag("
        function show_checkout_url() {
          var txt = $('repository_checkout_url')
          if (txt.value.empty()) {txt.value = $('repository_url').value}
          $('checkout_url').show();
        }
      ") +
      content_tag('p',
        form.select(:checkout_url_type, [
            [l(:label_checkout_type_original), 'original'],
            [l(:label_checkout_type_none), 'none'],
            [l(:label_checkout_type_overwritten), 'overwritten']
          ],
          {},
          :onchange => "if ($A(['original', 'none']).include(value)){$('checkout_url').hide();} else {$('checkout_url').show();}"
        )
      ) +
      content_tag('p',
        form.text_field(:checkout_url, :size => 60),
        :id => "checkout_url",
        :style => ("display:none" unless ['overwritten'].include? form.object.checkout_url_type)
      )
    end
  end
end

RepositoriesHelper.send(:include, RepositoriesHelperPatch)

