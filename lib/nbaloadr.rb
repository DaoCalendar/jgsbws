  def	nbaloader(dataarray,	update	=	false,	doleague	=	"National Basketball Association")
	  	teamleague		=	League.find_by_name(doleague).id
		isnhl			=	(doleague	==	"National Hockey League")
		raise "no league!" if teamleague.nil?
		#		0		 1				2					3	 4				 5								 6		 7	 8									9															 10									 11								 12		 se						 13	 14		15								16												17				 18		19	20		21	22	23 24	24
		# 14/9/08,2,St. Louis,8.0,13,N.Y. Giants,23.6875,41,9.0,0.0204550479789872,0.228046242969888,42.0,0.0554413784828847,-110,-110,N O,TT Spread bet right,TT OU wrong,N O,N O,N O,	 0,	 -1,	 0, -1,	0
		dataarray			=	gs(dataarray)
		seasonnumber			=	0
		prevdate			=	nil
		dataarray.each{|g|
			d			=	g.split(",")
		#	puts "g.inspect #{g.inspect}"
			begin
				home_id		=	Team.find_by_name(d[2].strip).id
			rescue
				raise "no such team as "+d[2] if home_id.nil?
			end
			begin
				away_id		=	Team.find_by_name(d[5].strip).id
			rescue
				raise "no such team as "+d[5] if away_id.nil?
			end
			p			=	nil
			pmake			=	nil
			addedp			=	false
			if update
				t		=	d[0].split("/")
				pa		=	Prediction.find_all_by_game_date_time(Time.local(2000+t[2].to_i, t[1], t[0]))
#				raise p.inspect
#				if p.length
				pa.delete_if{|dfg|!(dfg["home_team_id"]		==	home_id)}
				pa.delete_if{|dfg|!(dfg["away_team_id"]		==	away_id)}
				raise "pa.length #{pa.length} pa.inspect #{pa.inspect}" if pa.length	>	1
				addedp		=	true		if	pa.length	==	0
				pmake		=	pa.length
				p		=	Prediction.new	if	pa.length	==	0
				p		=	pa.first	if	pa.length	==	1
			else
				p		=	Prediction.new
				pmake		=	-1
				h		=	Hockeybet.new	if	isnhl
				addedp		=	true
			end
#			raise p.inspect if p.id.nil?
			begin
				p['week']		=	d[1].to_i
			rescue Exception => e
#				print e, "\n"
				raise "e #{e.inspect} d[1].to_i #{d[1].to_i} d[1] #{d[1].inspect} d.inspect #{d.inspect} p.inspect #{p.inspect}"
			end
			p['season']		=	seasonnumber
			t			=	d[0].split("/")
			p["game_date_time"]	=	Time.local(2000+t[2].to_i, t[1], t[0])
			seasonnumber		+=	1	if	! prevdate.nil? and ((p["game_date_time"] - prevdate) / Secondsperday)  > 60 # time diff in days
			prevdate						=	p["game_date_time"].dup
			p["league"]					=	teamleague
			p["home_team_id"]				=	home_id
			p["away_team_id"]				=	away_id
			p["actual_home_score"]			= d[6].to_i
			p["actual_away_score"]			= d[7].to_i
			if isnhl
				if addedp
					h			=	HockeyBet.new
					h.pred_id		=	p.id
				else
					tt			=	HockeyBet.find_by_pred_id(p.id)
					if	tt.nil?	# no hb record
						h		=	HockeyBet.new
						h.pred_id	=	p.id
					else
						h		=	tt.dup
					end
				end
#  0        1          2                 3          4           5                   6         7    8    9   10     11             12              13        14         15             16   17    18   19              20
# 12/1/08, 305, florida panthers, 2.71256388018983, 3, tampa bay lightning, 2.53656264427579, 5, -1.5, 200, 1.5, -240, 0.229466233097562, 0.535769449796951, 6.0, 0.244208282466363, -135, 115, -140, 120.0, 0.585775697493162
				h.plhome		=	d[8].to_f
				h.plhodds		=	d[9].to_i
				h.plhprob		=	d[12].to_f
				h.plaway		=	d[10].to_f
				h.plaodds		=	d[11].to_i
				h.plaprob		=	d[13].to_f
				h.ou			=	d[14].to_f
				h.overodds		=	d[16].to_i
				h.overprob		=	d[15].to_f
				h.underodds		=	d[17].to_i
				h.underprob		=	1.0	-	d[15].to_f
				p["moneyline_home"]	=	d[18].to_i
				p["moneyline_away"]	=	d[19].to_i
				p["prob_home_win_su"]	=	d[20].to_f
				p["prob_away_win_su"]	=	1.0-d[20].to_f
				p["prob_push_su"]	=	0.0
			else
				p["spread"]			=	d[8].to_f
				p["game_total"]			= d[11].to_f
				p["prob_game_over_total"]	= d[12].to_f
				p["moneyline_bet"]		= home_id if d[24] .to_i== 1
				p["moneyline_bet"]		= away_id if d[24].to_i == -1
				p["moneyline_home"]		= d[13].to_f
				p["moneyline_away"]		= d[14].to_f
				p["prob_home_win_su"]		= d[9].to_f
				raise if p["prob_home_win_su"] < 0 or p["prob_home_win_su"] > 1.0
				p["prob_away_win_su"]		= 1.0-d[9].to_f
				raise if p["prob_away_win_su"] < 0 or p["prob_away_win_su"] > 1.0
				p["prob_push_su"]		= 0.0
			end
			p["predicted_home_score"]	= (d[3].to_f+0.5).to_i
			p["predicted_away_score"]	= (d[6].to_f+0.5).to_i
			p["actual_home_score"]		= d[4].to_i
			p["actual_away_score"]		= d[7].to_i
			p["joe_guys_bet"]		= nil
			p["joe_guys_bet"]		= home_id if d[22].to_i==1 or d[21].to_i==1
			p["joe_guys_bet"]		= away_id if d[22].to_i==-1 or d[21].to_i==-1
			p["joe_guys_bet_amount"]		= 22
			p["joe_guys_bet_amount_won"]	= 0
			p["prob_home_win_ats"]		= d[10].to_f
			p["prob_away_win_ats"]		= 1.0-d[10].to_f
			p["prob_push_ats"]		= 0.0
			pid				= p.id
			p.save!
			if isnhl
				begin
					h.pred_id		= p.id
				rescue Exception => e
					raise "isnhl #{isnhl}"
					raise "#{e} pmake #{pmake} p.inspect #{p.inspect} h.inspect #{h.inspect}"
				end
				raise "pmake #{pmake} h.inspect #{h.inspect} p #{p.inspect}" if h.pred_id.nil?
				h.save!
			end
	}
end # nba loader

