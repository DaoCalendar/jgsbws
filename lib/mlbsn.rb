Mlbgame = Struct.new(:date, :datestr, :day, :home, :away, :probhomewsu, :probawaywsu, :homepitcher, 
	:awaypitcher, :homemoneyline, :awaymoneyline, :overunder, :uline, :oline, :uprob, :oprob, 
	:homerunlinespread, :homerunline, :probhrlcover, :awayrunlinespread, :awayrunline, 
	:probarlcover, :homescore, :awayscore, :daysback, :discount, :adjhomescore, :adjawayscore, :div)

Betml		= 1.5
Rlthreshold	= 1.15
Betou		= 1.0
Streakcriteria	= 1
Streakbethwin	= 1
Streakbethlose	= -1
Streakbetawin	= 2
Streakbetalose	= -2

def marginmaker(a, b)
	return (((1.0/convml(a)+1.0/convml(b))-1.0)*100.0).r2
end

def makediv(mstr, oppsie = false)
	return mstr.r2.commify if oppsie
	(mstr.r2 > 0 ? Gdiv : (mstr.r2 == 0.0 ? Ydiv : Rdiv)) + "#{mstr.r2.commify}#{Ediv}"
end


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
		bbg.probhrlcover	= bbb.rlhprob
		bbg.awayrunlinespread	= bbb.rlaway
		bbg.awayrunline		= bbb.rlaodds
		bbg.probarlcover	= bbb.rlaprob
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
#	raise "#{bba[0]} #{bba[1].inspect} "
	fdate	= bba.first.date
	ldate	= bba.last.date
#	raise bba.inspect
	# now create a big array to send to the view
	ba = []
	ba << '<table "border"=1>'
	headerrow = []
	headerrow << '<tr>'
	ha = ['Date, Game Number and Day', 'Home', 'Away', 'Home/Away Money Line', 
		'Over Line - Over/Under - Under Line', 'Home/Away Run Line Spread & Odds']
	ha.each{|h|
		headerrow << wrap(h)
	}
	headerrow << '</tr>'
	ba 	<< "<th>" # install as header here
	ba 	<< headerrow
	ba 	<< '</th><br>'
	uta 	= []
	ss	= []
	sh	= {} # streak hash
	od	= bba.first.day
	ybr				= 0.0
	sur	= suw	= ysur	= ysuw	= 0
	mlr	= mlw	= ymlr	= ymlw	= 0
	mlbr	= ymlbr			= 0.0
	our	= ouw	= your	= youw	= 0
	oubr	= youbr			= 0.0
	smlr	= smlw	= ysmlr	= ysmlw	= 0
	smlbr	= ysmlbr		= 0.0
	stbr	= ystbr			= 0.0
	yuc	= uc 	= yoc	= oc	= 0
	yobr	= obr	= yubr	= ubr	= 0.0
	diddata	= false
	predgame= false
	dayadj	= bba.first.day - 1
	bba.each_with_index{|b, gn|
		raise "bad score #{b.inspect}" unless ((b.homescore == -1 && b.awayscore == -1) || (b.homescore > -1 && b.awayscore > -1))
		predgame = (b.homescore == -1)
		if od == b.day
			diddata		= true
			outstr		= '<tr>'
			outstr		+= wrap(b.date.strftime("%A %B %d %Y") +" - Day #{(b.day-dayadj).commify} - Game # #{(gn+1).commify}")

			# dealing with home and away straight up wins and losses
			hw		= (b.homescore > b.awayscore)
			
			# do streak bet before updating streak
			sbet 	= nil
			sbetstr	= ''
			if sh.has_key?(b.home) && sh.has_key?(b.away)
				sbh = (sh[b.home] > Streakcriteria || sh[b.home] < -Streakcriteria)
				sba = (sh[b.away] > Streakcriteria || sh[b.away] < -Streakcriteria)
				unless (sbh && sba) # don't bet when both are on streaks
					if sbh
						sbet = sh[b.home] > Streakcriteria ? Streakbethwin : Streakbethlose
					else
						sbet = sh[b.away] > Streakcriteria ? Streakbetawin : Streakbetalose
					end
				end
			end
			
			# maintain streak hash
			# set up if not there
			sh[b.home]	=	0	unless sh.has_key?(b.home)
			sh[b.away]	=	0	unless sh.has_key?(b.away)

			unless predgame
				# streak over?
				sh[b.home]	=	0	if sh[b.home] > 0 && !hw
				sh[b.home]	=	0	if sh[b.home] < 0 && hw
				sh[b.away]	=	0	if sh[b.away] > 0 && hw
				sh[b.away]	=	0	if sh[b.away] < 0 && !hw

				# maintain streak
				sh[b.home]	+=	1	if hw
				sh[b.home]	-=	1	unless hw
				sh[b.away]	+=	1	unless hw
 				sh[b.away]	-=	1	if hw
			end

			ph	= (b.probhomewsu > b.probawaywsu)
			ehdiv	= hdiv	= ''
			eadiv	= adiv	= ''
			if ph # picked home to win
				hdiv, ehdiv	= Gdiv, Ediv	if hw
				hdiv, ehdiv	= Rdiv, Ediv	unless hw
			else
				# picked away to win
				adiv, eadiv	= Gdiv, Ediv	unless hw
				adiv, eadiv	= Rdiv, Ediv	if hw
			end
			hdiv, ehdiv	= Ydiv, Ediv if predgame && !hdiv.empty?
			adiv, eadiv	= Ydiv, Ediv if predgame && !adiv.empty?
			sur	+=	1 if hdiv == Gdiv
			suw	+=	1 if hdiv == Rdiv
			streakstring	= ''
			hsstr	=	b.homescore == -1 ? '' : b.homescore.to_s
#			streakstring	= " - Streak is #{sh[b.home]} win " if sh[b.home] == 1
#			streakstring	= " - Streak is #{sh[b.home]} wins " if sh[b.home] > 1
#			streakstring	= " - Streak is #{-sh[b.home]} loss " if sh[b.home] == -1
#			streakstring	= " - Streak is #{-sh[b.home]} losses " if sh[b.home] < -1
			outstr += wrap(hdiv + b.home+' '+hsstr + streakstring + ehdiv)

			sur	+=	1 if adiv == Gdiv
			suw	+=	1 if adiv == Rdiv
			streakstring	= ''
			asstr	=	b.awayscore == -1 ? '' : b.awayscore.to_s
#			streakstring	= " - Streak is #{sh[b.away]} win " if sh[b.away] == 1
#			streakstring	= " - Streak is #{sh[b.away]} wins " if sh[b.away] > 1
#			streakstring	= " - Streak is #{-sh[b.away]} loss " if sh[b.away] == -1
#			streakstring	= " - Streak is #{-sh[b.away]} losses " if sh[b.away] < -1
			outstr += wrap(adiv + b.away+' '+asstr + streakstring + eadiv)
			# done
			
			uta << b.home # unique team array for keywords
			uta << b.away                                        
			
			# moneylines
			
			bethome = ((convml(b.homemoneyline) * b.probhomewsu) > Betml)
			betaway = ((convml(b.awaymoneyline) * b.probawaywsu) > Betml)
			
			hdiv	= hediv = ''
			if bethome
				hdiv, ehdiv = Gdiv, Ediv if hw
				hdiv, ehdiv = Rdiv, Ediv unless hw
			end
			
#			outstr += wrap(hdiv+b.homemoneyline.to_s+ehdiv)
			
			adiv	= aediv = ''
			if betaway
				adiv, eadiv = Gdiv, Ediv unless hw
				adiv, eadiv = Rdiv, Ediv if hw
			end
			
			hdiv, ehdiv	= Ydiv, Ediv if predgame && !hdiv.empty?
			adiv, eadiv	= Ydiv, Ediv if predgame && !adiv.empty?
			
			if hdiv == Gdiv
				mlr	+= 1
				mlbr	+= convml(b.homemoneyline) - 1.0
				unless sbet.nil?
					if sbet == 1 # streakbet home to win
						stbr += convml(b.homemoneyline) - 1.0 
						sbetstr = "#{Gdiv}#{b.home} to win#{Ediv}"
					end
					if sbet == -1 # streakbet home to lose
						stbr -= 1.0 
						sbetstr = "#{Rdiv}#{b.home} to lose#{Ediv}"
					end
				end
			end
			if hdiv == Rdiv
				mlw	+= 1
				mlbr	-= 1.0
				unless sbet.nil?
					if sbet == -1 # streakbet home to lose
						stbr += convml(b.homemoneyline) - 1.0 
						sbetstr = "#{Gdiv}#{b.home} to lose#{Ediv}"
					end
					if sbet == 1 # streakbet home to win
						stbr -= 1.0 
						sbetstr = "#{Rdiv}#{b.home} to win#{Ediv}"
					end
				end
			end

			if adiv == Gdiv
				mlr	+= 1
				mlbr	+= convml(b.awaymoneyline) - 1.0
				unless sbet.nil?
					if sbet == Streakcriteria # streakbet away to win
						stbr += convml(b.awaymoneyline) - 1.0 
						sbetstr = "#{Gdiv}#{b.away} to win#{Ediv}"
					end
					if sbet == -Streakcriteria # streakbet away to lose
						stbr -= 1.0 
						sbetstr = "#{Rdiv}#{b.away} to lose#{Ediv}"
					end
				end
			end
			if adiv == Rdiv
				mlw	+= 1
				mlbr	-= 1.0
				unless sbet.nil?
					if sbet == -Streakcriteria # streakbet away to lose
						stbr += convml(b.awaymoneyline) - 1.0 
						sbetstr = "#{Gdiv}#{b.away} to lose#{Ediv}"
					end
					if sbet == Streakcriteria # streakbet away to win
						stbr -= 1.0 
						sbetstr = "#{Rdiv}#{b.away} to win#{Ediv}"
					end
				end
			end

			m	= marginmaker(b.homemoneyline, b.awaymoneyline)
			outstr += wrap(hdiv+b.homemoneyline.to_s+ehdiv+"/#{adiv+b.awaymoneyline.to_s+eadiv} M-> #{m} %")

			# ou lines
			itsunder= (b.homescore+b.awayscore) < b.overunder
			uc	+= 1 if itsunder
			oc	+= 1 unless itsunder
			ubr	+= (itsunder ? convml(b.uline) - 1.0 : -1)
			obr	+= (itsunder ? -1 : convml(b.oline) - 1.0)
			
			oea	= convml(b.overunder) * b.oprob
			uea	= convml(b.overunder) * b.uprob
			eodiv	= odiv = eudiv = udiv = ''
			if oea	> Betou
				eodiv	= Ediv
				odiv	= Gdiv	unless itsunder
				odiv	= Rdiv	if itsunder
			end
			if uea	> Betou
				eudiv	= Ediv
				udiv	= Gdiv	if itsunder
				udiv	= Rdiv	unless itsunder
			end
#			eodiv	= odiv = eudiv = udiv = ''	if predgame
			odiv, eodiv	= Ydiv, Ediv if predgame && !odiv.empty?
			udiv, eodiv	= Ydiv, Ediv if predgame && !udiv.empty?
#			br	+= -1 if odiv	== Rdiv
#			br	+= -1 if udiv	== Rdiv
#			br	+= convml(b.oline) - 1.0 if odiv == Gdiv
#			br	+= convml(b.uline) - 1.0 if udiv == Gdiv

			oubr	+= -1 if odiv	== Rdiv
			oubr	+= -1 if udiv	== Rdiv
			oubr	+= convml(b.oline) - 1.0 if odiv == Gdiv
			oubr	+= convml(b.uline) - 1.0 if udiv == Gdiv

			our	+= 1 if odiv == Gdiv
			ouw	+= 1 if odiv == Rdiv
			our	+= 1 if udiv == Gdiv
			ouw	+= 1 if udiv == Rdiv
			outstr	+= wrap(odiv+b.oline.to_s+eodiv+' '+b.overunder.to_s+' '+
				udiv+b.uline.to_s+eudiv+" M->#{marginmaker(b.oline, b.uline)}%")
			
			# runlines
			hrlev	= convml(b.homerunline) * b.probhrlcover
			arlev	= convml(b.awayrunline) * b.probarlcover
			hrlcovr	= ((b.homescore + b.homerunlinespread) > b.awayscore)
			arlcovr	= ((b.awayscore + b.awayrunlinespread) > b.homescore)
			
			hdiv	= hediv = ''
			if hrlev > Rlthreshold
				hdiv, hediv = Gdiv, Ediv if hrlcovr
				hdiv, hediv = Rdiv, Ediv unless hrlcovr
			end
			
			adiv	= aediv = ''
			if arlev > Rlthreshold
				adiv, aediv = Gdiv, Ediv if arlcovr
				adiv, aediv = Rdiv, Ediv unless arlcovr
			end
#			hdiv	= hediv = adiv	= aediv = '' if predgame
			hdiv,  hediv	= Ydiv, Ediv if predgame && !hdiv.empty?
			adiv,  aediv	= Ydiv, Ediv if predgame && !adiv.empty?
			
			if hdiv == Gdiv
				smlbr	+= convml(b.homerunline) - 1.0
				smlr	+= 1
			end
			if hdiv == Rdiv
				smlbr	-= 1.0
				smlw	+= 1
			end
			if adiv == Gdiv
				smlbr	+= convml(b.awayrunline) - 1.0
				smlr	+= 1
			end
			if adiv == Rdiv
				smlbr	-= 1.0
				smlw	+= 1
			end
			
			outstr += wrap(hdiv+b.homerunlinespread.to_s+' '+b.homerunline.to_s+hediv+" / "+adiv+b.awayrunlinespread.to_s+' '+b.awayrunline.to_s+aediv+" M->#{marginmaker(b.homerunline, b.awayrunline)}%")
#			outstr += wrap()
#			outstr += wrap(sbetstr)
			outstr += '</tr>'
			ss << outstr.dup
		else
			if diddata
				# stats
				diddata	= false
				tstr =  "<tr><td>Day #{(od-dayadj).commify} Statistics</td>"

				# bankroll
				ymlbr	+=	mlbr
				todaybr	=	mlbr + oubr + smlbr # + obr + ubr
				#			ybr	+=	stbr  # streak bet
				ybr	+=	mlbr  # money line
				ybr	+=	oubr  # over under
				ybr	+=	smlbr # spread money line
#				ybr	+=	obr + ubr # over and under
				todaybrstr	= makediv(todaybr)
				ybrstr		= makediv(ybr)
				tstr	+= 	"<td>Won #{todaybrstr} units this day 
						Won #{ybrstr} units this season so far"
				# streak bet
				ystbr	+=	stbr
				#		tstr	+=	"<td>Streak Bet Won $#{stbr.r2} today Won $#{ystbr.r2} this season</td>"
				stbr	=	0.0

				# sml
				ysmlr	+= smlr
				ysmlw	+= smlw
				ysmlbr	+= smlbr
				smlbrstr= makediv(smlbr)
				ysmlbrstr = makediv(ysmlbr)
				tstr	+= "<td>Spread moneyline - #{smlr} Right #{smlw} Wrong today - 
					#{ysmlr} Right #{ysmlw} Wrong this year - 
					#{smlbrstr} units won today #{ysmlbrstr} units won this season 
					#{(100.00*ysmlr/(ysmlr+ysmlw)).r2} % hit rate"
				smlr	= smlw = 0
				smlbr	= 0.0
				
				# dr traal 905 826 2881
				
				# ou
				your	+= our
				youw	+= ouw
				youbr	+= oubr
				yoc	+= oc
				yuc	+= uc
				yobr	+= obr
				yubr	+= ubr
				oubrstr	= makediv(oubr)
				youbrstr= makediv(youbr)
				yobrstr	= makediv(yobr)
				yubrstr	= makediv(yubr)
				obrstr	= makediv(obr)
				ubrstr	= makediv(ubr)
				tstr	+= "<td>Over/Under - #{our} Right #{ouw} Wrong today - #{your} Right #{youw} Wrong this year - #{oubrstr} units won today #{youbrstr} units won this season - #{(100.00*your/(your+youw)).r2} % hit rate - #{oc} over #{uc} under today - #{yoc.commify} over #{yuc.commify} under this season - 
					#{obrstr} units won by over #{ubrstr} units won by under today - 
					#{yobrstr} units won by over #{yubrstr} units won by under this year "
				our	= ouw = oc = uc = obr = ubr = 0
				oubr	= 0.0

				# moneyline	
				ymlr	+=	mlr
				ymlw	+=	mlw
				mlrstr	=	makediv(mlr, true)
				mlwstr	=	makediv(mlw, true)
				mlbrstr	=	makediv(mlbr)
				ymlbrstr=	makediv(ymlbr)
				ymlrstr	=	makediv(ymlr, true)
				ymlwstr	=	makediv(ymlw, true)
				tstr	+=	"<td>Moneyline - #{mlrstr} right #{mlwstr} wrong #{(100.0*mlr/(mlr+mlw)).r2}% - 
						Won #{mlbrstr} units today #{ymlbrstr} units this year<br> 
						Season - #{ymlrstr} right #{ymlwstr} wrong #{(100.0*ymlr/(ymlr+ymlw)).r2}%</td>"
				mlr	= mlw = 0
				mlbr	=	0.0

				# straight up
				ysur	+=	sur
				ysuw	+=	suw
				surstr	=	makediv(sur, true)
				suwstr	=	makediv(suw, true)
				ysurstr	=	makediv(ysur, true)
				ysuwstr	=	makediv(ysuw, true)
				tstr	+=	"<td>#{surstr} Straight Up Right #{suwstr} Straight Up Wrong #{(100.0*sur/(sur+suw)).r2}%</td><td>Season 
						#{ysurstr} Straight Up Right #{ysuwstr} Straight Up Wrong #{(100.0*ysur/(ysur+ysuw)).r2}%</td>"
				sur	= suw = 0

				tstr	+= '</tr>'
				ss	<< headerrow
				ss	<< tstr
			end
			od = b.day
		end
	}
	puta = uta.uniq.sort.join(', ')
	@main			=	{}
	@main['pad']		=	false
	@main['heading']	=	"Joe Guy's #{lname} Betting - #{year} - #{fdate.strftime("%B %d %Y  ")} to #{ldate.strftime("%B %d %Y  ")} "
	@main['desc']		=	"Joe Guy's Baseball #{year} #{puta}"
	@main['content']	=	"Joe Guy's Baseball #{year} #{puta}"
	@main['rollwith']	=	[header]
	@main['rollwith']	<<	ba + ss.reverse + ['</table>']
	render :template=>"main/main.rhtml"
end

