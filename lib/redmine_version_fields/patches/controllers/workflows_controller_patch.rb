module RedmineVersionFields
  # Patches Redmine's Query dynamically to include the two new fields in the filter list.
    module Patches
		module Controllers	
		  module WorkflowsControllerPatch

			def self.included(base) # :nodoc:
			  base.send(:include, InstanceMethods)
			  base.alias_method_chain :permissions, :wrapping
			end

			# This module wraps the original available_filters method, adding two new 
			# filters to the returned list.
			module InstanceMethods
			  def permissions_with_wrapping
				@role = Role.find_by_id(params[:role_id]) if params[:role_id]
				@tracker = Tracker.find_by_id(params[:tracker_id]) if params[:tracker_id]

				if request.post? && @role && @tracker
				  WorkflowPermission.replace_permissions(@tracker, @role, params[:permissions] || {})
				  redirect_to workflows_permissions_path(:role_id => @role, :tracker_id => @tracker, :used_statuses_only => params[:used_statuses_only])
				  return
				end

				@used_statuses_only = (params[:used_statuses_only] == '0' ? false : true)
				if @tracker && @used_statuses_only && @tracker.issue_statuses.any?
				  @statuses = @tracker.issue_statuses
				end
				@statuses ||= IssueStatus.sorted.all

				if @role && @tracker
				  @fields = (Tracker::CORE_FIELDS_ALL_EXT - @tracker.disabled_core_fields).map {|field| [field, l("field_"+field.sub(/_id$/, ''))]}
				  @custom_fields = @tracker.custom_fields

				  @permissions = WorkflowPermission.where(:tracker_id => @tracker.id, :role_id => @role.id).all.inject({}) do |h, w|
					h[w.old_status_id] ||= {}
					h[w.old_status_id][w.field_name] = w.rule
					h
				  end
				  @statuses.each {|status| @permissions[status.id] ||= {}}
				end
			  end
			end
		  end
		end
    end
end
