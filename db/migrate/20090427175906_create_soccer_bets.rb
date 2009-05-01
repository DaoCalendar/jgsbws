require 'migration_helpers'

class CreateSoccerBets < ActiveRecord::Migration
	extend MigrationHelpers
#	Ba	=	%w(B365H B365D B365A BWH BWD BWA GBH GBD GBA IWH IWD IWA LBH LBD LBA SBH SBD SBA WHH WHD WHA SJH SJD SJA VCH VCD VCA BSH BSD BSA)
#	Oua	=	%w(BbMxgt2p5 BbMxlt2p5 BbAvgt2p5 BbAvlt2p5 GBgt2p5 GBlt2p5 B365gt2p5 B365lt2p5)
def self.up
	create_table :soccerbets do |t|
		t.column :prediction_id,	:integer
		t.column :B365H, :float
		t.column :B365D, :float
		t.column :B365A, :float
		t.column :BWH, :float
		t.column :BWD, :float
		t.column :BWA, :float
		t.column :GBH, :float
		t.column :GBD, :float
		t.column :GBA, :float
		t.column :IWH, :float
		t.column :IWD, :float
		t.column :IWA, :float
		t.column :LBH, :float
		t.column :LBD, :float
		t.column :LBA, :float
		t.column :SBH, :float
		t.column :SBD, :float
		t.column :SBA, :float
		t.column :WHH, :float
		t.column :WHD, :float
		t.column :WHA, :float
		t.column :SJH, :float
		t.column :SJD, :float
		t.column :SJA, :float
		t.column :VCH, :float
		t.column :VCD, :float
		t.column :VCA, :float
		t.column :BSH, :float
		t.column :BSD, :float
		t.column :BSA, :float
		t.column :BbMxgt2p5, :float
		t.column :BbMxlt2p5, :float
		t.column :BbAvgt2p5, :float
		t.column :BbAvlt2p5, :float
		t.column :GBgt2p5, :float
		t.column :GBlt2p5, :float
		t.column :B365gt2p5, :float
		t.column :B365lt2p5, :float
		t.column :created_at,   :timestamp
		t.column :updated_at,   :timestamp
	end
	#	def foreign_key(from_table, from_column, to_table)
	foreign_key(:soccerbets,	:prediction_id,	:predictions)
  end

  def self.down
	  drop_table :soccerbets
  end
end
