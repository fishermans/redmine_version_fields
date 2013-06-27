require 'redmine'
require_dependency 'version'
require_dependency 'issue'
require_dependency 'issue_query'
require_dependency 'project'
require_dependency 'tracker'
require_dependency 'workflow_permission'
require_dependency 'workflows_controller'

# Patches to the Redmine core.
require 'redmine_version_fields/hooks/helper_issues_show_detail_after_setting_hook'

ActionDispatch::Callbacks.to_prepare do
  # Only include the patch if it hasn't been included already
  unless Version.included_modules.include? RedmineVersionFields::Patches::Models::VersionPatch
	Version.send(:include, RedmineVersionFields::Patches::Models::VersionPatch)
  end
  unless Issue.included_modules.include? RedmineVersionFields::Patches::Models::IssuePatch
	Issue.send(:include, RedmineVersionFields::Patches::Models::IssuePatch)
  end
  unless IssueQuery.included_modules.include? RedmineVersionFields::Patches::Models::IssueQueryPatch
	IssueQuery.send(:include, RedmineVersionFields::Patches::Models::IssueQueryPatch)
  end
  unless Project.included_modules.include? RedmineVersionFields::Patches::Models::ProjectPatch
	Project.send(:include, RedmineVersionFields::Patches::Models::ProjectPatch)
  end
  unless Tracker.included_modules.include? RedmineVersionFields::Patches::Models::TrackerPatch
	Tracker.send(:include, RedmineVersionFields::Patches::Models::TrackerPatch)
  end
  unless WorkflowPermission.included_modules.include? RedmineVersionFields::Patches::Models::WorkflowPermissionPatch
	WorkflowPermission.send(:include, RedmineVersionFields::Patches::Models::WorkflowPermissionPatch)
  end
  unless WorkflowsController.included_modules.include? RedmineVersionFields::Patches::Controllers::WorkflowsControllerPatch
	WorkflowsController.send(:include, RedmineVersionFields::Patches::Controllers::WorkflowsControllerPatch)
  end
end

# Register hooks
class MyHook < Redmine::Hook::ViewListener
  render_on :view_issues_show_details_bottom, :partial => "show_extra_version_fields"
#  render_on :view_issues_context_menu_start, :partial => 'redmine_version_fields/view_issues_context_menu_start'
end

# Register the plugin with Redmine
Redmine::Plugin.register :redmine_version_fields do
  name 'Affected Version Field'
  author 'Tiemo Vorschuetz'
  description 'This plugin adds one field to the Issue: affected version. The list of available values is generated dynamically by the list of all versions for the given project'
  version '0.0.3'
  requires_redmine :version_or_higher => '2.3.1'
end
