require "migration_helpers"
class CreateLeagues < ActiveRecord::Migration
  extend MigrationHelpers
  def self.up
    create_table :leagues do |t|
      t.column :name,  :string
	t.column :short_league_id,		:integer
      t.column :created_at,   :timestamp
      t.column :updated_at,   :timestamp
    end
    League.create(:name=>"National Football League")
    League.create(:name=>"National Basketball Association")
    League.create(:name=>"English Premier League")
    League.create(:name=>"NCAA Football")
    League.create(:name=>"NCAA Basketball")
    League.create(:name=>"Belgian First Division")
    League.create(:name=>"German First Division")
    League.create(:name=>"German Second Division")
    League.create(:name=>"English First Division")
    League.create(:name=>"English Second Division")
    League.create(:name=>"English Third Division")
    League.create(:name=>"English Championship")
    League.create(:name=>"French First Division")
    League.create(:name=>"French Second Division")
    League.create(:name=>"Greek First Division")
    League.create(:name=>"Italian First Division")
    League.create(:name=>"Italian Second Division")
    League.create(:name=>"Netherlands First Division")
    League.create(:name=>"Portuguies First Division")
    League.create(:name=>"Scottish Premier League")
    League.create(:name=>"Scottish First Division")
    League.create(:name=>"Scottish Second Division")
    League.create(:name=>"Scottish Third Division")
    League.create(:name=>"Spanish First Division")
    League.create(:name=>"Spanish Second Division")
    League.create(:name=>"Turkish First Division")
  end

  def self.down
    drop_table :leagues
  end
end
