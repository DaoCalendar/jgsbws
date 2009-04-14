class AddTotalstoPred < ActiveRecord::Migration
  def self.up
    # need to add total, prob of game covering total
    begin
      add_column :predictions, :game_total,           :float, :default => 0.0
    rescue
      # already there
    end
    begin
      add_column :predictions, :prob_game_over_total, :float, :default => 0.0
    rescue
      # already there
    end
    Prediction.reset_column_information
    updatea = IO.readlines(File.dirname(__FILE__) + '/../../public/ws.dat')
    betthreshold = 11.0/21.0
    updatea.each_with_index{|l, i|
      next if i == 0
     # puts l
      la = l.split(",")
      puts la[3]
      home_id = Team.find_by_name(la[3]).id
      puts "  "+la[4]
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
           # update the new fields only.
           #      0             1            2             3                  4                5           6          7          8             9            10            11             12           13       14      15             16                      17                      18                      19              20           21          22      
           # g.date.year, g.date.month, g.date.day, procname(g.home), procname(g.away), g.homescore, g.awayscore, g.spread, probhomewin, probhomelose, probhometie, probhomecover, probawaycover, probpush, alambda, hlambda, z[g.home].offstrength, z[g.away].defstrength, z[g.away].offstrength, z[g.home].defstrength, weeklimit, g.overunder, probtotalover
           # next if la.length < 22 # only week 7 and onward have totals.
           next if la[21].to_f == 0 # they all have totals now but they're zero for all games before week 7
           p["game_total"]           = la[21].to_f
           p["prob_game_over_total"] = la[22].to_f
           p.save
        }
      end # unless @pred.empty?
   }
  end

  def self.down
    remove_column :predictions, :game_total
    remove_column :predictions, :prob_game_over_total
    Prediction.reset_column_information
  end
end
