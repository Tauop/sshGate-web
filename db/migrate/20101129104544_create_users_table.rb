class CreateUsersTable < ActiveRecord::Migration
  def self.up
    create_table :users, :force => true do |t|
      t.string  :name,            :null => false, :default => '', :limit => 30
      t.string  :mail,            :null => false, :default => '', :limit => 100
      t.string  :public_key_file, :null => false, :default => ''
      t.integer :is_admin,        :null => false, :default => 0
      t.integer :is_restricted,   :null => false, :default => 1
      t.timestamps
    end
  end

  def self.down
    drop_table :users
  end
end
