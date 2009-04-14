require "migration_helpers"

class CreateTeams < ActiveRecord::Migration
  extend MigrationHelpers
  
  def self.up
    create_table :teams do |t|
      t.column :name,       :string
      t.column :league_id,  :integer
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
    end
    foreign_key(:teams, :league_id, :leagues)
    teama            = IO.readlines(File.dirname(__FILE__) + '/../../public/nflteams.txt')
    teamleague       = League.find_by_name("National Football League")
    teama.each{|line|
      newteam        = Team.new
      aa             = line
      newteam.name   = aa.chomp
      newteam.league = teamleague
      newteam.save
    }
    teama            = IO.readlines(File.dirname(__FILE__) + '/../../public/nbateams.txt')
    teamleague       = League.find_by_name("National Basketball League")
    teama.each{|line|
      newteam        = Team.new
      aa             = line
      newteam.name   = aa.chomp
      newteam.league = teamleague
      newteam.save
    }
    teama            = IO.readlines(File.dirname(__FILE__) + '/../../public/eplteams.txt')
    teamleague       = League.find_by_name("English Premier League")
    teama.each{|line|
      newteam        = Team.new
      aa             = line
      newteam.name   = aa.chomp
      newteam.league = teamleague
      newteam.save
    }
  end

  def self.down
    drop_table :teams
  end
end


