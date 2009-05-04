require "migration_helpers"
class NflDivisionalChampionships < ActiveRecord::Migration
  extend MigrationHelpers
  def self.up
   #               0      1        2    3         4        5         6               7                      8                      9                    10                     11                 12                      13                 14         15       16            17           18           19            20
   #            year,month,day,hour, home, away, spread, probhomewin, esthomescore, probhomelose, estawayscore, probhometie, probhomecover, probawaycover, probpush, total, probover, homeml, awayml,homescore,awayscore
   dataa        = [[2009,01,10,16,"Tennessee Titans","Baltimore Ravens",-3.0,0.414318434067344,16.5283734963852,0.519662350666964,19.2580417903476,0.0660192152656921,0.29347733524087,0.652619849786915,0.0539028149722161,34.5,0.617158249091747,-171,161,10,13],[
   2009,01,10,20,"Carolina Panthers","Arizona Cardinals",-9.5,0.745624062580215,33.798440248839,0.207947307063885,25.2008765234963,0.0464286303558999,0.372763650249514,0.627236349750486,0.0,47.5,0.74579067608019,-400,320,13,33],[
   2009,01,11,16,"Pittsburgh Steelers","San Diego Chargers",-6.0,0.624769437519479,22.7072832552789,0.315759196349243,18.3852892654391,0.0594713661312779,0.370256682162799,0.588684196765391,0.0410591210718126,39,0.578634818309706,-255,235,35,24],[
   2009,01,11,13,"N.Y. Giants","Philadelphia Eagles",-4.0,0.389309595641793,20.2921040780014,0.548437923462573,23.2900930032597,0.0622524808956349,0.227736605357107,0.728649659425421,0.0436137352174723,40,0.630144642129421,-175,165,11,23]]
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
      p["week"]                    = 19
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
