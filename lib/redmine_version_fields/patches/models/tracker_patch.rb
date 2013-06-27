require_dependency 'version'
require_dependency 'tracker'

module RedmineVersionFields
  # Patches Redmine's Versions dynamically. Adds two has_many relationships
  module Patches
	module Models  
	  module TrackerPatch
		def self.included(base) # :nodoc:
		  base.extend(ClassMethods)
		  #base.send(:include, InstanceMethods)
	 	  base.class_eval do
			unloadable # Send unloadable so it will not be unloaded in development
			
		  end 
		end
		
		module ClassMethods
			Tracker::CORE_FIELDS_EXT = (Tracker::CORE_FIELDS.dup.insert(Tracker::CORE_FIELDS.index('fixed_version_id'), 'affected_version_id')).freeze
			Tracker::CORE_FIELDS_ALL_EXT = (Tracker::CORE_FIELDS_UNDISABLABLE + Tracker::CORE_FIELDS_EXT).freeze
		end
	  end
	 end
  end
end
