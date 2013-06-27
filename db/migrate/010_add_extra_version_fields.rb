class AddExtraVersionFields < ActiveRecord::Migration
  def self.up 
    add_column :issues, :affected_version_id, :integer, {:default => nil, :null => true}
	add_column :versions, :isNotSupported, :integer, {:default => 0, :null => false}
  end

  def self.down
    remove_column :issues, :affected_version_id
	remove_column :versions, :isNotSupported
  end
end
