require "migration_helpers"
class CreateLeagues < ActiveRecord::Migration
  extend MigrationHelpers
  def self.up
    create_table :leagues do |t|
      t.column :name,			:string
      t.column :short_league,	:string
      t.column :created_at,   	:timestamp
      t.column :updated_at,   	:timestamp
    end
    League.create(:name=>"National Football League")
    League.create(:name=>"National Basketball Association")
    League.create(:name=>"English Premier League",	:short_league=>'E0')
    League.create(:name=>"NCAA Football")
    League.create(:name=>"NCAA Basketball")
    League.create(:name=>"Belgian First Division",		:short_league=>'B1')
    League.create(:name=>"German First Division",	:short_league=>'D1')
    League.create(:name=>"German Second Division",	:short_league=>'D2')
    League.create(:name=>"English First Division",	:short_league=>'E1')
    League.create(:name=>"English Second Division",	:short_league=>'E2')
    League.create(:name=>"English Third Division",	:short_league=>'E3')
    League.create(:name=>"English Championship",	:short_league=>'EC')
    League.create(:name=>"French First Division",	:short_league=>'F1')
    League.create(:name=>"French Second Division",	:short_league=>'F2')
    League.create(:name=>"Greek First Division",	:short_league=>'G1')
    League.create(:name=>"Italian First Division",	:short_league=>'I1')
    League.create(:name=>"Italian Second Division",	:short_league=>'I2')
    League.create(:name=>"Netherlands First Division",	:short_league=>'N1')
    League.create(:name=>"Portuguese First Division",	:short_league=>'P1')
    League.create(:name=>"Scottish Premier League",	:short_league=>'SC0')
    League.create(:name=>"Scottish First Division",	:short_league=>'SC1')
    League.create(:name=>"Scottish Second Division",	:short_league=>'SC2')
    League.create(:name=>"Scottish Third Division",	:short_league=>'SC3')
    League.create(:name=>"Spanish First Division",	:short_league=>'SP1')
    League.create(:name=>"Spanish Second Division",	:short_league=>'SP2')
    League.create(:name=>"Turkish First Division",	:short_league=>'T1')
  end

  def self.down
    drop_table :leagues
  end
end
