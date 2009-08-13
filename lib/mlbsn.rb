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

def makehr(substr='')
	headerrow = []
	headerrow << '<tr>'
	s0	= "Date, Game Number and Dayzzz"
	s0.gsub!('zzz',substr)
	ha = [s0, 'Home', 'Away', 'Home/Away Money Line', 
		'Over Line - Over/Under - Under Line', 'Home/Away Run Line Spread & Odds']
	ha.each{|h|
		headerrow << wrap(h)
	}
	headerrow << '</tr>'
	return headerrow
end

def ssdec(sur, suw, short=false)
	sum	= sur+suw
	nh	= sum / 2.0
	sd	= Math.sqrt(sum * 0.25)
	lc80	= ((nh - 1.282*sd)+0.5).to_i
	hc80	= ((nh + 1.282*sd)+0.5).to_i
	lc95	= ((nh - 1.96*sd)+0.5).to_i
	hc95	= ((nh + 1.96*sd)+0.5).to_i
	lc99	= ((nh - 2.58*sd)+0.5).to_i
	hc99	= ((nh + 2.58*sd)+0.5).to_i
#	compfac = Math.sqrt(0.25/sum)
#	clc = nh - 1.96*sd*compfac
#	chc = nh + 1.96*sd*compfac
	ss95	= (sur < lc95 || sur > hc95)
	ss99	= (sur < lc99 || sur > hc99)
	ss80	= (sur < lc80 || sur > hc80)
	return "" unless (ss95 || ss99 || ss80)
	if short
		return "<br><br>This is statistically signficantly better than chance to 99% confidence." if ss99
		return "<br><br>This is statistically signficantly better than chance to 95% confidence." if ss95
		return "<br><br>This is statistically signficantly better than chance to 80% confidence." if ss80
		raise "How can I possibly be here? 0"
	else
		retstr	= "<br><br>Statistical Hypotheses Test<br><br>Sample size is #{sum.commify}
			<br><br>Null Hypothesis is #{nh.r2.commify}
			<br><br>Std Dev is #{sd.r2}
			<br><br>aaaaa
			<br><br>Number selected correctly is #{sur.commify}
			<br><br>This is statistically signficantly better than chance to bbbbb% confidence."
		return (retstr.gsub('aaaaa',"99% confidence chance interval is #{lc99.commify} to #{hc99.commify}")).gsub('bbbbb','99') if ss99
		return (retstr.gsub('aaaaa',"95% confidence chance interval is #{lc95.commify} to #{hc95.commify}")).gsub('bbbbb','95') if ss95
		return (retstr.gsub('aaaaa',"80% confidence chance interval is #{lc80.commify} to #{hc80.commify}")).gsub('bbbbb','80') if ss80
		raise "How can I possibly be here? 1"
	end
	raise "How can I possibly be here? 2"
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
		bbg.date		= p.game_date_time.localtime
		bbg.day			= p.week
		th[p.home_team_id]	= Team.find(p.home_team_id).name unless th.has_key?(p.home_team_id)
		bbg.home		= th[p.home_team_id]
		th[p.away_team_id]	= Team.find(p.away_team_id).name unless th.has_key?(p.away_team_id)
		bbg.away		= th[p.away_team_id]
#		bbg.datestr		= p.game_date_time.day.to_s+'/'+p.game_date_time.month.to_s+'/'
#					 +p.game_date_time.year.to_s+
#					(p.game_date_time.hour > 0 ? 
#					 ' - '+p.game_date_time.hour.to_s+':'+p.game_date_time.min.to_s : '')
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
	ba 	<< "<th>" # install as header here
	ba 	<< makehr
	ba 	<< '</th><br><br>'
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
	alloupc	= yalloupc 		= 0	# all ou push count
	soupc	= ysoupc 		= 0	# ou push count for games we selected
	gc	= ygc	= 0			# daily and yearly game count
	diddata	= false
	predgame= false
	dayadj	= bba.first.day - 1
	bba.each_with_index{|b, gn|
		raise "bad score #{b.inspect}" unless ((b.homescore == -1 && b.awayscore == -1) || (b.homescore > -1 && b.awayscore > -1))
		predgame = (b.homescore == -1)
		if od == b.day
			ygc 		+= 1
			gc 		+= 1
			diddata		= true
			outstr		= '<tr>'
		#	raise "b.date #{b.date.inspect}" if b.date.hour > 0
			outstr		+= wrap(b.date.strftime("%A %B %d %Y") +
				" - Day #{(b.day-dayadj).commify} - Game # #{ygc.commify}") unless b.date.hour > 0
			outstr		+= wrap(b.date.strftime("%A %B %d %Y - %H:%M") +
				" - Day #{(b.day-dayadj).commify} - Game # #{ygc.commify}") if b.date.hour > 0

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
			oea	= convml(b.overunder) * b.oprob
			uea	= convml(b.overunder) * b.uprob
			eodiv	= odiv = eudiv = udiv = ''
			if ((b.homescore+b.awayscore) == b.overunder) # push code
				alloupc += 1
				if oea	> Betou
					soupc	+= 1
					eodiv	= Ediv
					odiv	= Ydiv
				end
				if uea	> Betou
					soupc	+= 1
					eudiv	= Ediv
					udiv	= Ydiv
				end
			else 
				# not a push
				itsunder= (b.homescore+b.awayscore) < b.overunder
				uc	+= 1 if itsunder
				oc	+= 1 unless itsunder
				ubr	+= (itsunder ? convml(b.uline) - 1.0 : -1)
				obr	+= (itsunder ? -1 : convml(b.oline) - 1.0)
				
#				oea	= convml(b.overunder) * b.oprob
#				uea	= convml(b.overunder) * b.uprob
#				eodiv	= odiv = eudiv = udiv = ''
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
#				eodiv	= odiv = eudiv = udiv = ''	if predgame
				odiv, eodiv	= Ydiv, Ediv if predgame && !odiv.empty?
				udiv, eodiv	= Ydiv, Ediv if predgame && !udiv.empty?
#				br	+= -1 if odiv	== Rdiv
#				br	+= -1 if udiv	== Rdiv
#				br	+= convml(b.oline) - 1.0 if odiv == Gdiv
#				br	+= convml(b.uline) - 1.0 if udiv == Gdiv
	
				oubr	+= -1 if odiv	== Rdiv
				oubr	+= -1 if udiv	== Rdiv
				oubr	+= convml(b.oline) - 1.0 if odiv == Gdiv
				oubr	+= convml(b.uline) - 1.0 if udiv == Gdiv
			
				our	+= 1 if odiv == Gdiv
				ouw	+= 1 if odiv == Rdiv
				our	+= 1 if udiv == Gdiv
				ouw	+= 1 if udiv == Rdiv
			end # push code
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
			
			outstr += wrap(hdiv+b.homerunlinespread.to_s+' '+b.homerunline.to_s+hediv+
				" / "+adiv+b.awayrunlinespread.to_s+' '+b.awayrunline.to_s+aediv+
				" M->#{marginmaker(b.homerunline, b.awayrunline)}%")
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
				tstr	+= "<td>Spread moneyline
					<br><br>#{smlr} Right 
					<br>#{smlw} Wrong today
					<br><br>#{ysmlr} Right 
					<br>#{ysmlw} Wrong this season
					#{ssdec(ysmlr, ysmlw, true)}
					<br><br>#{smlbrstr} units won today #{ysmlbrstr} units won this season 
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
				yalloupc+= alloupc
				ysoupc	+= soupc
				oubrstr	= makediv(oubr)
				youbrstr= makediv(youbr)
				yobrstr	= makediv(yobr)
				yubrstr	= makediv(yubr)
				obrstr	= makediv(obr)
				ubrstr	= makediv(ubr)
				spushstr= soupc > 0 ? "<br>#{soupc} Selected Pushes" : ""
				ypshstr = ysoupc > 0 ? "<br>#{ysoupc.commify} Selected Pushes" : ""
				apushstr= alloupc > 0 ? "<br>#{alloupc} Total Pushes" : ""
				yapshstr= yalloupc > 0 ? "<br>#{yalloupc.commify} Total Pushes" : ""
				tstr	+= "<td>Over/Under<br><br>#{our} Right 
					<br>#{ouw} Wrong #{spushstr} today
					<br><br>#{your} Right
					<br>#{youw} Wrong #{(100.0*(your/((your+youw) > 0 ? (your+youw) : 1.0))).r2}% 
					#{ypshstr} this season
					#{ssdec(your, youw, true)}
					<br><br>#{oubrstr} units won today 
					#{youbrstr} units won this season
					<br><br>#{(100.00*your/(your+youw)).r2} % hit rate
					<br><br>#{oc} over #{uc} under today
					<br><br>#{yoc.commify} over #{yuc.commify} under #{yapshstr} this season
					<br><br>#{obrstr} units won by over #{ubrstr} units won by under today
					<br><br>#{yobrstr} units won by over #{yubrstr} units won by under this season"
				our	= ouw = oc = uc = obr = ubr = 0
				oubr	= 0.0
				alloupc	= 0
				soupc	= 0

				# moneyline	
				ymlr	+=	mlr
				ymlw	+=	mlw
				mlrstr	=	makediv(mlr, true)
				mlwstr	=	makediv(mlw, true)
				mlbrstr	=	makediv(mlbr)
				ymlbrstr=	makediv(ymlbr)
				ymlrstr	=	makediv(ymlr, true)
				ymlwstr	=	makediv(ymlw, true)
				tstr	+=	"<td>Moneyline<br><br>#{mlrstr} right 
						<br>#{mlwstr} wrong #{(100.0*mlr/(mlr+mlw)).r2}%<br><br>
						Won #{mlbrstr} units today #{ymlbrstr} units this season<br><br> 
						Season<br><br>#{ymlrstr} right 
						<br>#{ymlwstr} wrong #{(100.0*ymlr/(ymlr+ymlw)).r2}%</td>"
				mlr	= mlw = 0
				mlbr	=	0.0

				# straight up
				ysur	+=	sur
				ysuw	+=	suw
				surstr	=	makediv(sur, true)
				suwstr	=	makediv(suw, true)
				ysurstr	=	makediv(ysur, true)
				ysuwstr	=	makediv(ysuw, true)
				tstr	+=	"<td>Straight Up 
						<br><br>#{surstr} Right
						<br>#{suwstr} Wrong
						#{(100.0*sur/(sur+suw)).r2}%</td>
						<td>Straight Up
						<br><br>#{ysurstr} Right
						<br>#{ysuwstr} Wrong
						#{(100.0*ysur/(ysur+ysuw)).r2}% #{ssdec(ysur,ysuw)}</td>"
				sur	= suw = 0

				tstr	+= '</tr>'
				repstr	= "<br><br>#{gc.commify} Games This Day"
				gc	= 0
				ss	<< makehr(repstr)
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

