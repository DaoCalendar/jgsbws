class CreateSums < ActiveRecord::Migration
  def self.up
    create_table :sums do |t|
	t.column :key,		:string
	t.column :amount,	:float,	:default	=>	0
	t.timestamps
    end
  end

  def self.down
    drop_table :sums
  end
end
