module RedmineVersionFields
  # Patches Redmine's Query dynamically to include the two new fields in the filter list.
    module Patches
		module Models	
		  module WorkflowPermissionPatch

			def self.included(base) # :nodoc:
			  base.send(:include, InstanceMethods)
			  base.alias_method_chain :validate_field_name, :wrapping
			end

			# This module wraps the original available_filters method, adding two new 
			# filters to the returned list.
			module InstanceMethods
			  def validate_field_name_with_wrapping
				unless Tracker::CORE_FIELDS_ALL_EXT.include?(field_name) || field_name.to_s.match(/^\d+$/)
				  errors.add :field_name, :invalid
				end
			  end
			end
		  end
		end
    end
end
