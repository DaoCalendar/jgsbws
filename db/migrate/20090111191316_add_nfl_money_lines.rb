require "migration_helpers"
class AddNflMoneyLines < ActiveRecord::Migration
  extend MigrationHelpers
  def self.up
	  dataa = IO.readlines("../../scrape/nflml.dat")
	  teamleague   = League.find_by_name("National Football League").id
	  #      0                1                                      2                  3    4
	  # 01/05/2008,seattle seahawks,washington redskins,-175,155
	  dataa.each{|dl|
		  d = dl.split(",")
		  begin
			  home_id = Team.find_by_name(d[1]).id
		  rescue
			  raise "no such team as #{d[1]}" if home_id.nil?
		  end
		  begin
			  away_id = Team.find_by_name(d[2]).id
		  rescue
			  raise "no such team as #{d[2]}" if away_id.nil?
		  end
#      home_id = Team.find_by_name(la[3]).id
   #  puts "home_id"
   #  puts home_id.inspect
  #    away_id = Team.find_by_name(la[4]).id
   #  puts "away_id"
   #  puts away_id.inspect
   sqlstr  = "SELECT * from predictions WHERE league =#{teamleague} AND predictions.home_team_id = #{home_id} AND predictions.away_team_id = #{away_id}"
   #  puts sqlstr
      @pred   = Prediction.find_by_sql(sqlstr)
   #  puts @pred.inspect
      unless @pred.empty?
      #  puts "@pred not empty "
      la = d[0].split("/")
      		@pred.reject!{|g|g["game_date_time"].year  != la[2].to_i or g["game_date_time"].month != la[0].to_i or g["game_date_time"].day   != la[1].to_i}
		unless @pred.empty? or @pred.length > 1
			@pred.each{|p|
				p["moneyline_home"] = d[3]
				p["moneyline_away"] = d[4]
				p["moneyline_bet"] = home_id if mlconv(p["moneyline_home"],p["prob_home_win_su"])
				p["moneyline_bet"] = away_id if mlconv(p["moneyline_away"],p["prob_away_win_su"])
				p.save!
			}
		else
			puts "no game found for #{dl}"
		end
	  end
	  }
  end

  def self.down
  end
end
