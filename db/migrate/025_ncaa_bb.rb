class NcaaBb < ActiveRecord::Migration
require "migration_helpers"
extend MigrationHelpers
def self.up                                                                                                      
	ncaabba = IO.readlines(File.dirname(__FILE__) + '/../../public/jgsbws ncaabb2008.dat')
  #  puts ncaabba.length
#    sleep 3
    ncaabba.reject!{|g|g.include?('*')}
    ncaabba.reject!{|g|g.empty?}
    teamleague   = League.find_by_name("NCAA Basketball").id
    raise "no league!" if teamleague.nil?
    #    0     1        2          3   4         5                 6     7   8                  9                               10                   11                 12                  13   14    15                16                        17         18    19  20    21  22  23 24  24
    # 14/9/08,2,St. Louis,8.0,13,N.Y. Giants,23.6875,41,9.0,0.0204550479789872,0.228046242969888,42.0,0.0554413784828847,-110,-110,N O,TT Spread bet right,TT OU wrong,N O,N O,N O,   0,   -1,   0, -1,  0
    ncaabba	=	gs(ncaabba)
    thisseason	=	1
    ncaabba.each{|g|
	d	=	g.split(",")
	tt	=	d[0].split("/")
	gdt	=	Time.local(2000+tt[2].to_i, tt[1], tt[0])
	case gdt 
		when Pasttime..Seasonone then thisseason = 1
		when Seasonone..Futuretime then thisseason = 2
		else raise "wonky date #{g.inspect}"
	end
    #  puts "g.inspect #{g.inspect}"
      begin
        home_id = Team.find_by_name(d[2]).id
      rescue
#        raise "no such team as "+d[2] if home_id.nil?
	# add teanms
	t = Team.new
	t.name = d[2]
	t.league_id = teamleague
	t.save!
	begin
		home_id = Team.find_by_name(d[2]).id
	rescue
		raise "d.inspect #{d.inspect}"
	end
      end
      begin
        away_id = Team.find_by_name(d[5]).id
      rescue
#        raise "no such team as "+d[5] if away_id.nil?
	t = Team.new
	t.name = d[5]
	t.league_id = teamleague
	t.save!
	begin
		away_id = Team.find_by_name(d[5]).id
	rescue
		raise "d.inspect #{d.inspect}"
	end
      end
      p = Prediction.new
      p['week']=d[1].to_i
      p['season']=thisseason
#      p['season']=1 # if d[1].to_i>85
      p["game_date_time"]          = gdt
      p["league"]                         = teamleague
      p["home_team_id"]            = home_id
      p["away_team_id"]            = away_id
      p["actual_home_score"]       = d[6].to_i
      p["actual_away_score"]       = d[7].to_i
      p["spread"]                     = d[8].to_f
      p["predicted_home_score"]    = (d[3].to_f+0.5).to_i
      p["predicted_away_score"]    = (d[6].to_f+0.5).to_i
      p["actual_home_score"]       = d[4].to_i
      p["actual_away_score"]       = d[7].to_i
      p["joe_guys_bet"]            = nil
      p["joe_guys_bet"]            = home_id if d[22].to_i==1 or d[21].to_i==1
      p["joe_guys_bet"]            = away_id if d[22].to_i==-1 or d[21].to_i==-1
      p["joe_guys_bet_amount"]     = 22
      p["joe_guys_bet_amount_won"] = 0
      p["prob_home_win_su"]        = d[9].to_f
      p["prob_away_win_su"]        = 1.0-d[9].to_f
      p["prob_push_su"]                = 0.0
      p["prob_home_win_ats"]       = d[10].to_f
      p["prob_away_win_ats"]       = 1.0-d[10].to_f
      p["prob_push_ats"]           = 0.0
      p["game_total"]              = d[11].to_f
      p["prob_game_over_total"]    = d[12].to_f
      p["moneyline_bet"]    = home_id if d[24] .to_i== 1
      p["moneyline_bet"]    = away_id if d[24].to_i == -1
      p["moneyline_home"]    = d[13].to_f
      p["moneyline_away"]    = d[14].to_f
      p.save!
  }
  end

  def self.down
  end
end
