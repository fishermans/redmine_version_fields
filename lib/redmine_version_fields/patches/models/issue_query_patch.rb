require_dependency 'version'
require_dependency 'project'

module RedmineVersionFields
  # Patches Redmine's Query dynamically to include the two new fields in the filter list.
    module Patches
		module Models	
		  module IssueQueryPatch

			def self.included(base) # :nodoc:
			  base.send(:include, InstanceMethods)
			  base.alias_method_chain :initialize_available_filters, :wrapping
			  base.add_available_column(QueryColumn.new(:affected_version, :sortable => "(select name from versions where versions.id = t0_r0)"))
			end

			# This module wraps the original available_filters method, adding two new 
			# filters to the returned list.
			module InstanceMethods
			  def initialize_available_filters_with_wrapping
				# Generate the original list, by calling the original function
				initialize_available_filters_without_wrapping

				# If we have a project, grab all available versions and use them to build
				# filter options for found in and release notes target
				if project
				  # Add Found in and Release notes target to filter list.
				  unless project.affected_versions.empty?
					add_available_filter "affected_version_id",
					  :type => :list, 
					  :values => project.affected_versions.collect{|s| ["#{s.project.name} - #{s.name}", s.id.to_s] }
				  end
				end
			  end
			end
		  end
		end
    end
end
