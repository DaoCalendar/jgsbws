require "migration_helpers"
class Add2008ASuperbowl < ActiveRecord::Migration
  extend MigrationHelpers
  def self.up
   #            date,                           home, away, spread, probhomewin, esthomescore, probhomelose, estawayscore, probhometie, probhomecover, probawaycover, probpush
   #               0      1        2    3         4        5         6               7                      8                      9                    10                     11                 12                      13                 14         15       16            17           18           19            20
   #            year,month,day,hour, home, away, spread, probhomewin, esthomescore, probhomelose, estawayscore, probhometie, probhomecover, probawaycover, probpush, total, probover, homeml, awayml,homescore,awayscore
   dataa        = [[2009,02,01,6,"Arizona Cardinals","Pittsburgh Steelers",7.0,0.132335187112454,15.2586225307552,0.830258434630436,28.7647694360114,0.0374063782571101,0.390442455483914,0.545237113512707,0.0643204310033804,46.5,0.354007938443743,225,-265,23,27]]
   # 				           date, home, away, spread, probhomewin, esthomescore, probhomelose, estawayscore, probhometie, probhomecover, probawaycover, probpush
   # Sun Feb 01 00:00:00 -0500 2009,Arizona,Pittsburgh,7.0,0.132335187112454,15.2586225307552,0.830258434630436,28.7647694360114,0.0374063782571101,0.390442455483914,0.545237113512707,0.0643204310033804
   teamleague   = League.find_by_name("National Football League")
   betthreshold = 11.0 / 21.0
    dataa.each{|d|
      begin
        home_id = Team.find_by_name(d[4]).id
      rescue
        raise "no such team as "+d[4] if home_id.nil?
      end
      begin
        away_id = Team.find_by_name(d[5]).id
      rescue
        raise "no such team as "+d[5] if away_id.nil?
      end
      p = Prediction.new
      p["game_date_time"]   = Time.local(d[0], d[1], d[2], d[3])
      p["league"]                  = teamleague
      p["season"]                  = 1
      p["week"]                    = 21
      p["home_team_id"]      = home_id
      p["away_team_id"]       = away_id
      p["spread"]                  = d[6]
      p["predicted_home_score"]    = d[8]
      p["predicted_away_score"]    = d[10]
      p["actual_home_score"]       =  d[19]
      p["actual_away_score"]       = d[20]
      p["joe_guys_bet"]            = nil
      p["joe_guys_bet"]            = home_id if d[12] > betthreshold
      p["joe_guys_bet"]            = away_id if d[13] > betthreshold
      p["joe_guys_bet_amount"]     = 0
      p["joe_guys_bet_amount"]     = 22 unless p["joe_guys_bet"].nil? 
      p["joe_guys_bet_amount_won"] = 0
      p["prob_home_win_su"]        = d[7]
      p["prob_away_win_su"]        = d[8]
      p["prob_push_su"]            = d[9]
      p["prob_home_win_ats"]       = d[12]
      p["prob_away_win_ats"]       = d[13]
      p["prob_push_ats"]           = d[14]
      p["game_total"]              = d[15]
      p["prob_game_over_total"]    = d[16]
      p["moneyline_home"] = d[17]
      p["moneyline_away"] = d[18]
      p["moneyline_bet"] = home_id if mlconv(d[17],d[7])
      p["moneyline_bet"] = away_id if mlconv(d[18],d[8])
      p.save!
    }
end

  def self.down
  end
end
