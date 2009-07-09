class CreateSums < ActiveRecord::Migration
  def self.up
	begin
		create_table :sums do |t|
			t.column :key,		:string
			t.column :amount,	:float,	:default	=>	0
			t.timestamps
		end
	rescue
	end
  end

  def self.down
    drop_table :sums	# if	ENV['RAILS_ENV'] == 'production'
  end
end
