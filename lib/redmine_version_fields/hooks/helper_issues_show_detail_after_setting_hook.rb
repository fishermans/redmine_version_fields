require_dependency 'issues_helper'

module RedmineVersionFields
  module Hooks
    class HelperIssuesShowDetailAfterSettingHook < Redmine::Hook::ViewListener
	  def find_name_by_reflection(field, id)
		association = Issue.reflect_on_association(field.to_sym)
		if association
		  record = association.class_name.constantize.find_by_id(id)
		  return record.name if record
		end
	  end
	
      def helper_issues_show_detail_after_setting(context = { })
        # TODO Later: Overwritting the caller is bad juju
        if context[:detail].prop_key == 'affected_version_id'
          context[:detail].reload
		  
          field = context[:detail].prop_key.to_s.gsub(/\_id$/, "")
		  label = l(("field_" + field).to_sym)

		  context[:detail].value = find_name_by_reflection(field, context[:detail].value)
		  context[:detail].old_value = find_name_by_reflection(field, context[:detail].old_value)
        end
        ''
      end
    end
  end
end
