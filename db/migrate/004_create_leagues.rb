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
    League.create(:name=>"National Football League") # september to febuary
    League.create(:name=>"National Basketball Association") # end of october to june
    League.create(:name=>"English Premier League",	:short_league=>'E0') # start of august through to end of May
    League.create(:name=>"NCAA Football") # august to January
    League.create(:name=>"NCAA Basketball") 
    League.create(:name=>"Belgian First Division",		:short_league=>'B1') # start of august through to end of May
    League.create(:name=>"Bundesliga",	:short_league=>'D1') # start of august through to end of May
    League.create(:name=>"2nd Bundesliga",	:short_league=>'D2') # start of august through to end of May
    League.create(:name=>"English First Division",	:short_league=>'E1')
    League.create(:name=>"English Second Division",	:short_league=>'E2')
    League.create(:name=>"English Third Division",	:short_league=>'E3')
    League.create(:name=>"English Championship",	:short_league=>'EC')
    League.create(:name=>"French First Division",	:short_league=>'F1') # start of august through to end of May
    League.create(:name=>"French Second Division",	:short_league=>'F2')
    League.create(:name=>"Greek Super League",	:short_league=>'G1') # start of august through to end of May
    League.create(:name=>"Italian Serie A",	:short_league=>'I1') # start of august through to end of May
    League.create(:name=>"Italian Second Division",	:short_league=>'I2')
    League.create(:name=>"Netherlands Eredivisie",	:short_league=>'N1') # start of august through to end of May
    League.create(:name=>"Portuguese Sagres League",	:short_league=>'P1') # start of august through to end of May
    League.create(:name=>"Scottish Premier League",	:short_league=>'SC0')
    League.create(:name=>"Scottish Football League",	:short_league=>'SC1') # start of august through to end of May
    League.create(:name=>"Scottish Second Division",	:short_league=>'SC2')
    League.create(:name=>"Scottish Third Division",	:short_league=>'SC3')
    League.create(:name=>"Spanish La Lega",	:short_league=>'SP1') # start of august through to end of May
    League.create(:name=>"Spanish Second Division",	:short_league=>'SP2')
    League.create(:name=>"Turkish Super League",	:short_league=>'T1') # start of august through to end of May
  end

  def self.down
    drop_table :leagues
  end
end
