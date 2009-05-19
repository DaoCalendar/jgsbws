module MigrationHelpers

Cok	=	'^changeok'
Sea	=	'^season'

def	writeseasons(sh2)
	ff2	=	File.new('public/soccer seasons.txt','w')
	sh2.sort!
	sh2.each{|k|
#		ff2.write("#{k.inspect}\n")
		ff2.write([k[0],	k[1].year,	k[2]].join(',')+"\n")
	}
	ff2.close
end
	
def fronthalf(sh,	tta,	sh2,	wh,	save_pred	=	true)
#	$csh2			=	false
#	puts 'set to fase'
	p			=	Prediction.new
	league		=	tta[0]
	date			=	tta[1]
	home		=	tta[2]
	hscore		=	tta[3]
	away			=	tta[4]
	ascore		=	tta[5]
	hwp			=	tta[6].to_f
	awp			=	tta[7].to_f
	dwp			=	tta[8].to_f
	begin
		@l		=	League.find_by_short_league(league)
	rescue
		raise "cant find #{league}"
	end
#	p.league		=	@sl.league.id
#	p.league		=	League.ShortLeague(league).id
#	puts	ShortLeague.methods.sort
#	puts
#	puts	League.methods.sort
	p.league		=	@l.id
#	p.game_date_time		=	convdate(date)
	t			=	date.split("/")
	p.game_date_time			=	Time.local(2000+t[2].to_i, t[1], t[0])	if		t[2].to_i	<	10
	p.game_date_time			=	Time.local(1900+t[2].to_i, t[1], t[0])	unless	t[2].to_i	<	10
	if	wh.has_key?(league)
		if	(p.game_date_time	-	wh[league][0])	>	7.days # count weeks
			wh[league][1]		+=	1
			if wh[league][1]	>=	52 # year has passed
				sh[league+Sea]	+=	1
				sh2			<<	[league,	p.game_date_time,	sh[league+Sea]]
				$csh2		=	true
				wh[league][1]	=	1
			end
			wh[league][0]		=	p.game_date_time # only update after week is changed.
		end
	else
		wh[league]			=	[p.game_date_time,	0]
	end
	if	sh.has_key?(league+Sea)
#		puts p.game_date_time.month
#		if	(p.game_date_time	-	sh[league][0])	>	3.months # count seasons - looking for a three month gap
		if	(p.game_date_time.month	>=	10)	&&	(p.game_date_time.month	<=	12)	&&	!sh[league+Cok]
#			puts "sh[league+Cok]	==	true sh.inspect #{sh.inspect}"
#			sleep 1
			sh[league+Cok]	=	true	
#			puts "sh.inspect #{sh.inspect}"
		end
		if	(p.game_date_time.month	>=	8)	&&	(p.game_date_time.month	<=	9)	&&	sh[league+Cok]
#		if	(p.game_date_time.month	==	8)	&&	(p.game_date_time.month	<=	9)	&&	sh[league+Cok]
#			puts "sh[league+Cok]	=	false"
			sh[league+Cok]	=	false
			sh[league+Sea]	+=	1
			puts "changed season to #{sh[league+Sea]} - #{p.game_date_time} #{league}"
#			sleep 1
			$csh2				=	true
			wh[league][1]			=	1	#	reset week for new season
	#		puts "set to true"
			begin
				sh2	<<	[league,	p.game_date_time,	sh[league+Sea]]
			rescue
				raise "sh2 #{sh2.inspect} league #{league}  p.game_date_time #{p.game_date_time.inspect} sh[league+Sea] #{sh[league+Sea]}"
			end
		end
#		sh[league][0]		=	p.game_date_time
	else
		puts "setting up #{league}"
		sleep 1
		sh[league+Cok]	==	false
#		sh[league]		=	[p.game_date_time,	1]
		sh[league+Sea]	=	1
		sh2				<<	[league,	p.game_date_time,	1]
		$csh2				=	true
	#	puts "true 2"
	end
	p.season				=	sh[league+Sea]
	p.week				=	wh[league][1]
	begin
		tid				=	Team.find_by_name(home).id
	rescue
		tid				=	nil
	end
	if	tid.nil?
		p.home_team_id	=	Team.create(:name=>home, :league_id=>p.league).id
	else
		p.home_team_id	=	tid
	end
	begin
		tid	=	Team.find_by_name(away).id
	rescue
		tid	=	nil
	end
	if	tid.nil?
		p.away_team_id	=	Team.create(:name=>away, :league_id=>p.league).id
	else
		p.away_team_id	=	tid
	end
	p.actual_home_score	=	hscore
	p.actual_away_score		=	ascore
	p.prob_home_win_su	=	hwp
	p.prob_away_win_su		=	awp
	p.prob_push_su		=	dwp
	p.save!	if	save_pred
#	puts sh.inspect
#		raise p.inspect
	return	p,	sh,	sh2,	wh
end

	
def getlid(findme)
	return lid
end
	
  def foreign_key(from_table, from_column, to_table)
    constraint_name = "fk_#{from_table}_#{from_column}"
    execute %{alter table #{from_table}
      add constraint #{constraint_name}
      foreign key (#{from_column})
      references #{to_table}(id)}
  end

  def gs(ig)
    ig.map{|l|l=l.gsub!("Arizona","Arizona Cardinals")}
    ig.map{|l|l=l.gsub!("Atlanta","Atlanta Falcons")}
    ig.map{|l|l=l.gsub!("Baltimore","Baltimore Ravens")}
    ig.map{|l|l=l.gsub!("Buffalo","Buffalo Bills")}
    ig.map{|l|l=l.gsub!("Carolina","Carolina Panthers")}
    ig.map{|l|l=l.gsub!("Chicago","Chicago Bears")}
    ig.map{|l|l=l.gsub!("Cincinnati","Cincinnati Bengals")}
    ig.map{|l|l=l.gsub!("Cleveland","Cleveland Browns")}
    ig.map{|l|l=l.gsub!("Dallas","Dallas Cowboys")}
    ig.map{|l|l=l.gsub!("Denver","Denver Broncos")}
    ig.map{|l|l=l.gsub!("Detroit","Detroit Lions")}
    ig.map{|l|l=l.gsub!("Green Bay","Green Bay Packers")}
    ig.map{|l|l=l.gsub!("Houston Oilers","Houston Texans")}
    ig.map{|l|l=l.gsub!("Houston","Houston Texans")}
    ig.map{|l|l=l.gsub!("Indianapolis","Indianapolis Colts")}
    ig.map{|l|l=l.gsub!("Jacksonville","Jacksonville Jaguars")}
    ig.map{|l|l=l.gsub!("Kansas City","Kansas City Chiefs")}
    ig.map{|l|l=l.gsub!("Miami","Miami Dolphins")}
    ig.map{|l|l=l.gsub!("Minnesota","Minnesota Vikings")}
    ig.map{|l|l=l.gsub!("New England","New England Patriots")}
    ig.map{|l|l=l.gsub!("New Orleans","New Orleans Saints")}
    ig.map{|l|l=l.gsub!("Oakland","Oakland Raiders")}
    ig.map{|l|l=l.gsub!("Philadelphia","Philadelphia Eagles")}
    ig.map{|l|l=l.gsub!("Pittsburgh","Pittsburgh Steelers")}
    ig.map{|l|l=l.gsub!("San Diego","San Diego Chargers")}
    ig.map{|l|l=l.gsub!("San Francisco","San Francisco 49ers")}
    ig.map{|l|l=l.gsub!("San Francisco 49ers  49ers","San Francisco 49ers")}
    ig.map{|l|l=l.gsub!("Seattle","Seattle Seahawks")}
    ig.map{|l|l=l.gsub!("St. Louis","St. Louis Rams")}
    ig.map{|l|l=l.gsub!("Tampa Bay","Tampa Bay Buccaneers")}
    ig.map{|l|l=l.gsub!("Tennessee","Tennessee Titans")}
    ig.map{|l|l=l.gsub!("Washington","Washington Redskins")}
    # nba
    ig.map{|l|l=l.gsub!("oklahoma city","Oklahoma City Thunder")}
    ig.map{|l|l=l.gsub!("portland trailblazers","Portland Trail Blazers")}
    ig.map{|l|l=l.gsub!("los angeles lakers","L.A. Lakers")}
    ig.map{|l|l=l.gsub!("los angeles clippers","L.A. Clippers")}
    return ig
  end
  
  def updatenflweekly(updatea)
    updatea = gs(updatea)
    updatea.each{|l|
     # puts l
      la = l.split(",")
     # puts la.inspect
      #  0      1       2                 3         4  5   6  7    8   9
      # NFL,13/12/07,Houston Texans,Denver Broncos,31,13,-1.5,47,-115,105
      da = la[1].split("/")
#     # puts la[2]
      home_id = Team.find_by_name(la[2]).id
#     # puts la[3]
      away_id = Team.find_by_name(la[3]).id
      sqlstr  = "SELECT * from predictions WHERE predictions.home_team_id = #{home_id} AND predictions.away_team_id = #{away_id}"
      @pred   = Prediction.find_by_sql(sqlstr)
      unless @pred.empty?
     # # puts "@pred not empty "
        @pred.reject!{|g|
           g["game_date_time"].year  != da[2].to_i+2000 or 
           g["game_date_time"].month != da[1].to_i or 
           g["game_date_time"].day   != da[0].to_i
        }
       # puts "@pred.length is "+@pred.length.to_s
        @pred.each{|p|
           p["actual_home_score"]     = la[4].to_i
           p["actual_away_score"]     = la[5].to_i
           p["joe_guys_bet_amount"]   = 20
          # puts "joe_guys_bet is "+p["joe_guys_bet"].to_s
           push   = p["joe_guys_bet"] == 0 or ((la[4].to_i + p["spread"]) == la[5].to_i)
           wonbet = ((la[4].to_i + p["spread"]) > la[5].to_i and p["joe_guys_bet"] == p["home_team_id"] or ((la[4].to_i + p["spread"]) < la[5].to_i and p["joe_guys_bet"] == p["away_team_id"]))
          # puts "push is "+(push ? "true" : "false")
 #          unless push
            # puts "Joe won bet" if wonbet 
            # puts "Joe lost bet" unless wonbet
#           end
          # puts "push" if push
           amountwon = (push ? 0 : (wonbet ? 20 : -22)) # check for push first in case of no opinion
           p["joe_guys_bet_amount_won"] = amountwon
          # puts "setting score to "+la[4].to_s+" to "+la[5].to_s
           p.save
        }
      end # unless @pred.empty?
    } # each update line
  end

  def updatenflweeklypicks(updatea)
    updatea = gs(updatea)
    updatea.each{|l|
     # puts l
      la = l.split(",")
     # puts la.inspect
      #  0      1         2         3   4  5 6    7
      # NFL,23/12/07,Chicago,Green Bay,-1,-1,9,Chicago
      da = la[1].split("/")
#     # puts la[2]
      home_id = Team.find_by_name(la[2]).id
#     # puts la[3]
      away_id = Team.find_by_name(la[3]).id
      sqlstr  = "SELECT * from predictions WHERE predictions.home_team_id = #{home_id} AND predictions.away_team_id = #{away_id}"
      @pred   = Prediction.find_by_sql(sqlstr)
      unless @pred.empty?
     # # puts "@pred not empty "
        @pred.reject!{|g|
           g["game_date_time"].year  != da[2].to_i+2000 or 
           g["game_date_time"].month != da[1].to_i or 
           g["game_date_time"].day   != da[0].to_i
        }
       # puts "@pred.length is "+@pred.length.to_s
        @pred.each{|p|
           p["spread"]       = la[6].to_i
           p["joe_guys_bet_amount"]   = 20
           if la.length == 8
#             puts la.inspect
             pick_id = Team.find_by_name(la[7].chomp).id
             p["joe_guys_bet"] = pick_id
           end
           p.save
        }
      end # unless @pred.empty?
    } # each update line
  end
  def mlconv(ml, p)
	  #return ((p*(ml > 0 ? ml/100.0 : -100.0/ml)) > 2.0)
	  return p > 0.5
  end
end
