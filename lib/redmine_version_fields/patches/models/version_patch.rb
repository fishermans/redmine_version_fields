module RedmineVersionFields
  # Patches Redmine's Versions dynamically. Adds two has_many relationships
  module Patches
	module Models
	  module VersionPatch
		def self.included(base) # :nodoc: 
		  base.class_eval do
			unloadable # Send unloadable so it will not be unloaded in development
			scope :slocked, lambda { where(:status => 'locked') }
			scope :sclosed, lambda { where(:status => 'closed') }			
			scope :supported, :conditions => {:isNotSupported => 0}
			has_many :affected_version_issues, :class_name => 'Issue', :foreign_key => 'affected_version_id'
			safe_attributes 'isNotSupported'
		  end 
		end
		
	  end
	 end
  end
end
