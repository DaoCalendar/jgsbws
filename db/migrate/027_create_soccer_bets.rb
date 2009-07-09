require 'migration_helpers'

class CreateSoccerBets < ActiveRecord::Migration
	extend MigrationHelpers
#	Ba	=	%w(B365H B365D B365A BWH BWD BWA GBH GBD GBA IWH IWD IWA LBH LBD LBA SBH SBD SBA WHH WHD WHA SJH SJD SJA VCH VCD VCA BSH BSD BSA)
#	Oua	=	%w(BbMxgt2p5 BbMxlt2p5 BbAvgt2p5 BbAvlt2p5 GBgt2p5 GBlt2p5 B365gt2p5 B365lt2p5)
def self.up
	begin
	create_table :soccer_bets do |t|
#		t.column :prediction_id,	:integer
		t.column :B365H, :float
		t.column :B365H_ev, :float
		t.column :B365D, :float
		t.column :B365D_ev, :float
		t.column :B365A, :float
		t.column :B365A_ev, :float
		t.column :BWH, :float
		t.column :BWH_ev, :float
		t.column :BWD, :float
		t.column :BWD_ev, :float
		t.column :BWA, :float
		t.column :BWA_ev, :float
		t.column :GBH, :float
		t.column :GBH_ev, :float
		t.column :GBD, :float
		t.column :GBD_ev, :float
		t.column :GBA, :float
		t.column :GBA_ev, :float
		t.column :IWH, :float
		t.column :IWH_ev, :float
		t.column :IWD, :float
		t.column :IWD_ev, :float
		t.column :IWA, :float
		t.column :IWA_ev, :float
		t.column :LBH, :float
		t.column :LBH_ev, :float
		t.column :LBD, :float
		t.column :LBD_ev, :float
		t.column :LBA, :float
		t.column :LBA_ev, :float
		t.column :SBH, :float
		t.column :SBH_ev, :float
		t.column :SBD, :float
		t.column :SBD_ev, :float
		t.column :SBA, :float
		t.column :SBA_ev, :float
		t.column :WHH, :float
		t.column :WHH_ev, :float
		t.column :WHD, :float
		t.column :WHD_ev, :float
		t.column :WHA, :float
		t.column :WHA_ev, :float
		t.column :SJH, :float
		t.column :SJH_ev, :float
		t.column :SJD, :float
		t.column :SJD_ev, :float
		t.column :SJA, :float
		t.column :SJA_ev, :float
		t.column :VCH, :float
		t.column :VCH_ev, :float
		t.column :VCD, :float
		t.column :VCD_ev, :float
		t.column :VCA, :float
		t.column :VCA_ev, :float
		t.column :BSH, :float
		t.column :BSH_ev, :float
		t.column :BSD, :float
		t.column :BSD_ev, :float
		t.column :BSA, :float
		t.column :BSA_ev, :float
		t.column :BbMxgt2p5, :float
		t.column :BbMxgt2p5_ev, :float
		t.column :BbMxlt2p5, :float
		t.column :BbMxlt2p5_ev, :float
		t.column :BbAvgt2p5, :float
		t.column :BbAvgt2p5_ev, :float
		t.column :BbAvlt2p5, :float
		t.column :BbAvlt2p5_ev, :float
		t.column :GBgt2p5, :float
		t.column :GBgt2p5_ev, :float
		t.column :GBlt2p5, :float
		t.column :GBlt2p5_ev, :float
		t.column :B365gt2p5, :float
		t.column :B365gt2p5_ev, :float
		t.column :B365lt2p5, :float
		t.column :B365lt2p5_ev, :float
		t.column :created_at,   :timestamp
		t.column :updated_at,   :timestamp
	end
	#	def foreign_key(from_table, from_column, to_table)
#	foreign_key(:soccer_bets,	:prediction_id,	:predictions)
	rescue
	end
  end

  def self.down
	drop_table :soccer_bets	# if	ENV['RAILS_ENV'] == 'production'
  end
end
