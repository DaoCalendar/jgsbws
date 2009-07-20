Mlbgame = Struct.new(:date, :datestr, :day, :home, :away, :probhomewsu, :probawaywsu, :homepitcher, 
	:awaypitcher, :homemoneyline, :awaymoneyline, :overunder, :uline, :oline, :uprob, :oprob, 
	:homerunlinespread, :homerunline, :awayrunlinespread, :awayrunline, :homescore, :awayscore, 
	:daysback, :discount, :adjhomescore, :adjawayscore, :div)

#<Prediction id: 5405, game_date_time: "2009-04-05 04:00:00", league: 28, soccer_bet: nil, week: 426, 
#		season: 0, home_team_id: 134, away_team_id: 115, spread: nil, predicted_home_score: 6, 
#		predicted_away_score: 3, actual_home_score: 1, actual_away_score: 4, joe_guys_bet: nil, 
#		joe_guys_bet_amount: 10, joe_guys_bet_amount_won: nil, moneyline_home: -110, 
#		moneyline_away: -110, moneyline_bet: 0, created_at: "2009-07-09 20:28:24", 
#		updated_at: "2009-07-09 20:28:24", prob_home_win_su: 0.0, prob_away_win_su: 0.0, 
#		prob_push_su: 0.0, prob_home_win_ats: 0.0, prob_away_win_ats: 0.0, prob_push_ats: 0.0, 
#		game_total: 0.0, prob_game_over_total: 0.0> 
#<BaseballBet id: 2452, pred_id: 5405, rlhome: -1.5, rlhodds: 160, rlhprob: 0.670035, homeml: -130, 
#		probhsuw: 0.885935, rlaway: 1.5, rlaodds: -180, rlaprob: 0.236095, awayml: 110, 
#		probasuw: 0.114065, ou: 8.5, overodds: -105, overprob: 0.540176, underodds: -115, 
#		underprob: 0.459824, created_at: "2009-07-09 20:28:24", updated_at: "2009-07-09 20:28:24">

def mlbseason(newpred,	year,	winprob,	header,	gap,	gaptitle,	sport,	lname)
#	raise "#{newpred[0].inspect}"
	bba	= []
	th	= {}
	newpred.each{|p|
		# note - doing all these individual seeks is bad m'kay?
		bbb			= BaseballBet.find_by_pred_id(p.id)
		raise "No bb data for id #{p.id}" if bbb.nil?
#		raise "#{p.inspect} 
		#{bbb.inspect}"
		bbg			= Mlbgame.new
		bbg.date		= p.game_date_time
		bbg.day			= p.week
		th[p.home_team_id]	= Team.find(p.home_team_id).name unless th.has_key?(p.home_team_id)
		bbg.home		= th[p.home_team_id]
		th[p.away_team_id]	= Team.find(p.away_team_id).name unless th.has_key?(p.away_team_id)
		bbg.away		= th[p.away_team_id]
		bbg.datestr		= p.game_date_time.day.to_s+'/'+p.game_date_time.month.to_s+'/'+p.game_date_time.year.to_s
#		bbg.homepitcher		= bbb.homepitcher
#		bbg.awaypitcher		= bbb.awaypitcher
		bbg.homemoneyline	= bbb.homeml
		bbg.awaymoneyline	= bbb.awayml
		bbg.probhomewsu		= bbb.probhsuw
		bbg.probawaywsu		= bbb.probasuw
		bbg.overunder		= bbb.ou
		bbg.oline		= bbb.overodds
		bbg.oprob		= bbb.overprob
		bbg.uline		= bbb.underodds
		bbg.uprob		= bbb.underprob
		bbg.homerunlinespread	= bbb.rlhome
		bbg.homerunline		= bbb.rlhodds
		bbg.awayrunlinespread	= bbb.rlaway
		bbg.awayrunline		= bbb.rlaodds
		bbg.homescore		= p.actual_home_score
		bbg.awayscore		= p.actual_away_score
		bbg.daysback		= 0
		bbg.discount		= 1.0
		bbg.adjhomescore	= p.actual_home_score
		bbg.adjawayscore	= p.actual_away_score
		bbg.div			= 'MLB'
		puts
		puts bbg.inspect
#		sleep 5
		bba << bbg.dup
		bbg = nil
	}
#	raise bba.inspect
	# now create a big array to send to the view
	ba=[]
	ba << '<table "border"=1>'
	ba << '<th>'
	ha = ['Game Number', 'Day', 'Date', 'Home', 'Away', 'Home Money Line', 'Away Money Line', 
	'Over Line - Over/Under - Under Line', 'Home Run Line Spread & Odds', 'Away Run Line Spread & Odds']
	ha.each{|h|
		ba << wrap(h)
	}
	ba << '</th>'
	ba << '<br>'
	uta 	= []
	ss	= []
	od	= bba.first.day
	sur	= suw	= ysur	= ysuw	= 0
	mlr	= mlw	= ymlr	= ymlw	= 0
	br	= ybr			= 0.0
	bba.each_with_index{|b, gn|
		if od == b.day
			outstr =  '<tr><td></td>'
			outstr += wrap((gn+1).commify)
			outstr += wrap(b.day.commify)
			outstr += wrap(b.date.strftime("%A %B %d %Y"))
			
			# dealing with home and away straight up wins and losses
			hw 	= (b.homescore > b.awayscore)
			ph	= (b.probhomewsu > b.probawaywsu)
			ehdiv	= hdiv	= ''
			eadiv	= adiv	= ''
			if ph # picked home to win
				hdiv, ehdiv	= Gdiv, '</div>'	if hw
				hdiv, ehdiv	= Rdiv, '</div>'	unless hw
			else
				# picked away to win
				adiv, eadiv	= Gdiv, '</div>'	unless hw
				adiv, eadiv	= Rdiv, '</div>'	if hw
			end
			ehdiv	= hdiv	= '' if b.homescore == -1
			eadiv	= adiv	= '' if b.homescore == -1
			sur	+=	1 if hdiv == Gdiv
			suw	+=	1 if hdiv == Rdiv
			outstr += wrap(hdiv + b.home+' '+b.homescore.to_s + ehdiv)

			sur	+=	1 if adiv == Gdiv
			suw	+=	1 if adiv == Rdiv
			outstr += wrap(adiv + b.away+' '+b.awayscore.to_s + eadiv)
			# done
			
			uta << b.home # unique team array for keywords
			uta << b.away
			
			# moneylines
			
			bethome = ((convml(b.homemoneyline) * b.probhomewsu) > 1.5)
			betaway = ((convml(b.awaymoneyline) * b.probawaywsu) > 1.5)
			
			hdiv	= hediv = ''
			if bethome
				hdiv, ehdiv = Gdiv, '</div>' if hw
				hdiv, ehdiv = Rdiv, '</div>' unless hw
			end
			
			outstr += wrap(hdiv+b.homemoneyline.to_s+ehdiv)
			
			adiv	= aediv = ''
			if betaway
				adiv, eadiv = Gdiv, '</div>' unless hw
				adiv, eadiv = Rdiv, '</div>' if hw
			end
			
			ehdiv	= hdiv	= '' if b.homescore == -1
			eadiv	= adiv	= '' if b.homescore == -1
			
			if hdiv == Gdiv
				mlr	+= 1
				br	+= convml(b.homemoneyline) - 1.0
			end
			if hdiv == Rdiv
				mlw	+= 1
				br	-= 1.0
			end

			if adiv == Gdiv
				mlr	+= 1
				br	+= convml(b.awaymoneyline) - 1.0
			end
			if adiv == Rdiv
				mlw	+= 1
				br	-= 1.0
			end

			m	= (((1.0/convml(b.homemoneyline) + 1.0/convml(b.awaymoneyline))-1.0)*100.0).r2
			outstr += wrap("#{adiv+b.awaymoneyline.to_s+eadiv} M-> #{m} %")

			# ou lines
			outstr += wrap(b.oline.to_s+' '+b.overunder.to_s+' '+b.uline.to_s)
			
			# runlines
			outstr += wrap(b.homerunlinespread.to_s+' '+b.homerunline.to_s)
			outstr += wrap(b.awayrunlinespread.to_s+' '+b.awayrunline.to_s)
			outstr += '</tr>'
			ss << outstr.dup
		else
			# stats
			tstr = ''
			tstr +=  "<tr>"
			
			# bankroll
			ybr	+=	br
			tstr +=  "<td>Won #{br.r2.commify} this day Won #{ybr.r2.commify} this season so far"
			br	=	0.0
			
			# moneyline	
			ymlr	+=	mlr
			ymlw	+=	mlw
			tstr +=  "<td>#{mlr} MLR #{mlw} MLW #{(100.0*mlr/(mlr+mlw)).r2}%</td><td>Season #{ymlr.commify} MLR #{ymlw.commify} MLW #{(100.0*ymlr/(ymlr+ymlw)).r2}%</td>"
			mlr = mlw = 0
			
			# straight up
			ysur	+=	sur
			ysuw	+=	suw
			tstr +=  "<td>#{sur} SUR #{suw} SUW #{(100.0*sur/(sur+suw)).r2}%</td><td>Season #{ysur.commify} SUR #{ysuw.commify} SUW #{(100.0*ysur/(ysur+ysuw)).r2}%</td>"
			sur = suw = 0

			tstr +=  '</tr>'
			ss << tstr
			od = b.day
		end
	}
	puta = uta.uniq.sort.join(', ')
	@main			=	{}
	@main['pad']		=	false
	@main['desc']		=	"Joe Guy's Baseball #{puta}"
	@main['content']	=	"Joe Guy's Baseball"
	@main['rollwith']	=	ba + ss.reverse + ['</table>']
	render :template=>"main/main.rhtml"
end

