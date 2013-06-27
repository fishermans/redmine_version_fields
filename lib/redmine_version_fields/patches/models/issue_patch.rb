require_dependency 'version'
require_dependency 'project'

module RedmineVersionFields
  # Patches Redmine's Issues dynamically. Adds two belongs_to relationships,
  # and makes some other changes required for the two new fields.
  module Patches
	module Models
		module IssuePatch
			def self.included(base) # :nodoc:
			  base.extend(ClassMethods)
			  base.send(:include, InstanceMethods)
			  
			  # Wrap the methods we are extending
			  base.alias_method_chain :validate_issue, :wrapping
			  base.alias_method_chain :move_to_project,  :wrapping
			  base.alias_method_chain :assignable_versions, :wrapping

			  # Exectue this code at the class level (not instance level)
			  base.class_eval do
				unloadable # Send unloadable so it will not be unloaded in development
				
				belongs_to :affected_version, :class_name => 'Version', :foreign_key => 'affected_version_id'
				safe_attributes 'affected_version_id'
			  end #base.class_eval

			end #self.included
			
			module ClassMethods
			end
			
			module InstanceMethods
			  # Versions that the issue can be assigned to
			  def affected_versions
				@affected_versions = (project.shared_versions.open.supported + project.shared_versions.sclosed.supported + [Version.find_by_id(affected_version_id_was)]).compact.uniq.sort
			  end

			 # Versions that the issue can be assigned to
			 def assignable_versions_with_wrapping
				@assignable_versions = (project.shared_versions.open + project.shared_versions.slocked + [Version.find_by_id(fixed_version_id_was)]).compact.uniq.sort
			 end
					
			  # Wrapped validator - calls the original validator then does extra checks
			  def validate_issue_with_wrapping
				validate_issue_without_wrapping						
				if affected_version
				  if !project.shared_versions.include?(affected_version)
					errors.add :affected_version_id, :inclusion
				  end
				end
			  end #validate_with_wrapping

			  # Wrapped move_to - calls the original mover, then ensures the versions are 
			  # still valid.
			  def move_to_project_with_wrapping (new_project, new_tracker = nil, options = {})
				result = move_to_project_without_wrapping(new_project, new_tracker, options)
				
				# Result will either be the moved issue (success), or false (failure)
				if (result != false)
				  unless new_project.shared_versions.include?(result.affected_version)
					result.affected_version = nil
				  end
				  result.save
				end
				result
			  end #move_to_with_wrapping

			end #InstanceMethods

		  end #IssuePatch
		end # Models
	end #Patches
end #RedmineVersionFields

#TODO
#-Extend the following methods:
#  -self.update_versions(conditions=nil)
#  -self.update_versions_from_sharing_change(version)
#  -self.update_versions_from_hierarchy_change(project)
#-Show strings not IDs in journal
