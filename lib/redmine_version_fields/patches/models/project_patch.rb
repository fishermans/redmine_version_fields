require_dependency 'version'
require_dependency 'project'

module RedmineVersionFields
  # Patches Redmine's Issues dynamically. Adds two belongs_to relationships,
  # and makes some other changes required for the two new fields.
  module Patches
	module Models
	  module ProjectPatch
		def self.included(base) # :nodoc:
		  base.send(:include, InstanceMethods)
		end #self.included
			
		module InstanceMethods
		  # Versions that the issue can be assigned to
		  def affected_versions
			@affected_versions = (project.shared_versions.open.supported + project.shared_versions.sclosed.supported).compact.uniq.sort
		  end

		 # Versions that the issue can be assigned to
		 def assignable_versions
			@assignable_versions = (project.shared_versions.open + project.shared_versions.slocked).compact.uniq.sort
		 end
		end #InstanceMethods

	  end #ProjectPatch
	end
  end #Patches
end #RedmineVersionFields
