class CreateMembershipsTable < ActiveRecord::Migration
  def self.up
    create_table :memberships, :force => true do |t|
      t.integer :user_id
      t.integer :usergroup_id
      t.timestamps
    end
  end

  def self.down
    drop_table :memberships
  end
end
