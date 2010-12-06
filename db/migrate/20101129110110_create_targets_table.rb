class CreateTargetsTable < ActiveRecord::Migration
  def self.up
    create_table :targets, :force => true do |t|
      t.string  :name,             :null => false, :default => '', :limit => 50
      t.string  :private_key_file, :null => false, :default => ''
      t.string  :public_key_file,  :null => false, :default => ''
      t.integer :ssh_port,         :null => false, :default => 22
      t.integer :scp_port,         :null => false, :default => 22
      t.integer :ssh_enable_x11,   :null => false, :default => 0
      t.timestamps
    end
  end

  def self.down
    drop_table :targets
  end
end
