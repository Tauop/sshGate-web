class CreateAliasesTable < ActiveRecord::Migration
  def self.up
    create_table :aliases, :force => true do |t|
      t.string  :name,      :null => false, :default => '', :limit => 50
      t.integer :target_id, :null => false, :default => 0
    end
  end

  def self.down
    drop_table :aliases
  end
end
