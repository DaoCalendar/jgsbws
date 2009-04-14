require "migration_helpers"

class CreateStrengths < ActiveRecord::Migration
  extend MigrationHelpers
  def self.up
    create_table :strengths do |t|
      t.column :week,                      :integer
      t.column :team_id,                   :integer
      t.column :off_strength,              :float
      t.column :def_strength,              :float
      t.column :created_at,                :datetime
      t.column :updated_at,                :datetime
    end
    foreign_key(:strengths, :team_id, :teams)
    #      0             1            2           3                  4                  5          6           7          8            9             10          11              12            13      14        15           16                       17                   18                       19               20
    # g.date.year, g.date.month, g.date.day, procname(g.home), procname(g.away), g.homescore, g.awayscore, g.spread, probhomewin, probhomelose, probhometie, probhomecover, probawaycover, probpush, alambda, hlambda, z[g.home].offstrength, z[g.away].defstrength, z[g.away].offstrength, z[g.home].defstrength, weeklimit
    # 2007,09,16,Arizona Cardinals,Seattle Seahawks,23,20,3.0,0.448619090170321,0.482822106393617,0.0685588034360615,0.594010368296107,0.346364665268925,0.0596249664349684,21.187630818098,20.4000317535224,43.0749521828723,-22.5575734905744,40.8841309421334,-19.6965001240354,1
    sa       = IO.readlines(File.dirname(__FILE__) + '/../../public/ws.dat')
    teamweek = {}
    sa.each{|tt|
      ta = tt.split(",")
      begin
        home_id = Team.find_by_name(ta[3]).id
      rescue
        raise "no such team as "+ta[3]
      end
      teamweek[home_id]      = 2 unless teamweek.has_key?(home_id)
      week                   = teamweek[home_id]
      teamweek[home_id]      = week + 1
      strength               = Strength.new
      strength.week          = week
      strength.team_id       = home_id
      strength.off_strength  = ta[16].to_f
      strength.def_strength  = ta[19].to_f
      strength.save
      begin
        away_id = Team.find_by_name(ta[4]).id
      rescue
        raise "no such team as "+ta[4]
      end
      teamweek[away_id]      = 2 unless teamweek.has_key?(away_id)
      week                   = teamweek[away_id]
      teamweek[away_id]      = week + 1
      strength               = Strength.new
      strength.week          = week
      strength.team_id       = away_id
      strength.off_strength  = ta[18].to_f
      strength.def_strength  = ta[17].to_f
      strength.save
      }
  end

  def self.down
    drop_table :strengths
  end
end
