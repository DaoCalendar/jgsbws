class DoWsFile < ActiveRecord::Migration
  def self.up
    #      0             1            2           3                  4                  5          6           7          8            9             10          11              12            13      14        15           16                       17                   18                       19               20
    # g.date.year, g.date.month, g.date.day, procname(g.home), procname(g.away), g.homescore, g.awayscore, g.spread, probhomewin, probhomelose, probhometie, probhomecover, probawaycover, probpush, alambda, hlambda, z[g.home].offstrength, z[g.away].defstrength, z[g.away].offstrength, z[g.home].defstrength, weeklimit
    # 2007,09,16,Arizona Cardinals,Seattle Seahawks,23,20,3.0,0.448619090170321,0.482822106393617,0.0685588034360615,0.594010368296107,0.346364665268925,0.0596249664349684,21.187630818098,20.4000317535224,43.0749521828723,-22.5575734905744,40.8841309421334,-19.6965001240354,1
    updatea = IO.readlines(File.dirname(__FILE__) + '/../../public/ws.dat')
    betthreshold = 11.0/21.0
    updatea.each_with_index{|l, i|
      next if i == 0
     # puts l
      la = l.split(",")
 #     puts la[3]
      home_id = Team.find_by_name(la[3]).id
   #   puts "  "+la[4]
      away_id = Team.find_by_name(la[4]).id
      sqlstr  = "SELECT * from predictions WHERE predictions.home_team_id = #{home_id} AND predictions.away_team_id = #{away_id}"
      @pred   = Prediction.find_by_sql(sqlstr)
      unless @pred.empty?
        @pred.reject!{|g|
          g["game_date_time"].year     != la[0].to_i or 
          g["game_date_time"].month    != la[1].to_i or 
          g["game_date_time"].day      != la[2].to_i
        }
        @pred.each{|p|
           p["actual_home_score"]       = la[5]
           p["actual_away_score"]       = la[6]
           p["spread"]                  = la[7].to_f
           p["predicted_away_score"]    = (la[14].to_f + 0.5).to_i
           p["predicted_home_score"]    = (la[15].to_f + 0.5).to_i
           p["joe_guys_bet"]            = nil
           p["joe_guys_bet"]            = home_id if la[11].to_f >= betthreshold
           p["joe_guys_bet"]            = away_id if la[12].to_f >= betthreshold
           p["joe_guys_bet"]            = nil if la[7].to_f == 0 # if no line no bet
           p["joe_guys_bet_amount"]     = 22
           p["joe_guys_bet_amount_won"] = -22 # default lose
           p["joe_guys_bet_amount_won"] = 20 if p["joe_guys_bet"] == home_id and (la[5].to_f+la[7].to_f) > la[6].to_f
           p["joe_guys_bet_amount_won"] = 20 if p["joe_guys_bet"] == away_id and (la[5].to_f+la[7].to_f) < la[6].to_f
           p["joe_guys_bet_amount_won"] = 0  if p["joe_guys_bet"].nil? or (la[5].to_f+la[7].to_f) == la[6].to_f
           p["prob_home_win_su"]        = la[8].to_f
           p["prob_away_win_su"]        = la[9].to_f
           p["prob_push_su"]            = la[10].to_f
           p["prob_home_win_ats"]       = la[11].to_f
           p["prob_away_win_ats"]       = la[12].to_f
           p["prob_push_ats"]           = la[13].to_f
           p.save
        }
      end # unless @pred.empty?
    }
  end

  def self.down
  end
end
