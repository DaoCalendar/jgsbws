class CreateBb < ActiveRecord::Migration
  def self.up
	begin
	create_table :baseball_bets do |t|
	t.column :pred_id,	:integer
	t.column :rlhome,	:float
	t.column :rlhodds,	:integer
	t.column :rlhprob,	:float
	t.column :rlaway,	:float
	t.column :rlaodds,	:integer
	t.column :rlaprob,	:float
	t.column :ou,		:float
	t.column :overodds,	:integer
	t.column :overprob,	:float
	t.column :underodds,	:integer
	t.column :underprob,	:float
	t.timestamps
	end
	rescue
	end
  end

  def self.down
	begin
		drop_table :baseball_bets	if	ENV['RAILS_ENV'] == 'production'
	rescue
	end
  end
end
