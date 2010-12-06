class CreateUsergroupsTable < ActiveRecord::Migration
  def self.up
    create_table :usergroups, :force => true do |t|
      t.string :name, :null => false, :default => '', :limit => 30
      t.timestamps
    end
  end

  def self.down
    drop_table :usergroups
  end
end
