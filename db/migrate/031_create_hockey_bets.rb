class CreateHockeyBets < ActiveRecord::Migration
  def self.up
	  begin
	create_table :hockey_bets do |t|
		t.column :pred_id,	:integer
		t.column :plhome,	:float
		t.column :plhodds,	:integer
		t.column :plhprob,	:float
		t.column :plaway,	:float
		t.column :plaodds,	:integer
		t.column :plaprob,	:float
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
		drop_table :hockey_bets	if	ENV['RAILS_ENV'] == 'production'
	rescue
	end
  end
end
