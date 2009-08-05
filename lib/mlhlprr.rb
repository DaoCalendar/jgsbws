def	mlhlpr(p, isnhl)
#		isnhl		=	!h.nil?
#		raise "isnhl #{isnhl.inspect}"
		hprize		=	0.0
		aprize		=	0.0
		# process moneyline
#		unless isnhl
			return [-1, "No Moneyline", 0.0, nil, 0.0, 0.0, 0.0, false] if p.moneyline_home == -110 and p.moneyline_away == -110 or (p.moneyline_home == 0 or p.moneyline_away == 0)
#		end
		pickhome	=	nil
		pickaway	=	nil
		mlats		=	nil
		if p.moneyline_home > 0
			hbbmlwin	= p.moneyline_home
			hbbmllose	= -100.0
			hwinprize	= p.moneyline_home / 100.0 - 1
			hlose		= -1
		else
			hbbmlwin	= 100.0
			hbbmllose	= p.moneyline_home
			hwinprize	= -100.0/p.moneyline_home #+1.0
			hlose		= -1
		end
		if p.moneyline_away > 0
			abbmlwin	= p.moneyline_away
			abbmllose	= -100.0
			awinprize	= p.moneyline_away / 100.0 - 1
			alose		= -1
		else
			abbmlwin	= 100.0
			abbmllose	= p.moneyline_away
			awinprize	= -100.00/p.moneyline_away #+1.0
			alose		= -1
		end
		# do straight up money line for everyone
		hodds		=			p.moneyline_home / 100.0 if p.moneyline_home > 0
		hodds		=	1	+	-100.0 / p.moneyline_home if p.moneyline_home < 0
		aodds		=			p.moneyline_away / 100.0 if p.moneyline_away > 0
		aodds		=	1	+	-100.0 / p.moneyline_away if p.moneyline_away < 0
		hev		=	hwinprize	*	p.prob_home_win_su	+	(hlose	*	(1.0-p.prob_home_win_su))
		aev		=	awinprize	*	p.prob_away_win_su	+	(alose	*	(1.0-p.prob_away_win_su))
		puts "hev #{hev} hodds #{hodds} p.prob_home_win_su #{p.prob_home_win_su}"
		puts "aev #{aev} aodds #{aodds} p.prob_away_win_su #{p.prob_away_win_su}"
#		sleep 1
#		must still tell it if it's mhl so the criteria for ml picking is different
		pickhome	=	(hev	>	0.3)	if	isnhl
		pickaway	=	(aev	>	0.3)	if	isnhl
#		pickhome	=	(hev	>	0.0)	unless	isnhl
#		pickaway	=	(aev	>	0.0)	unless	isnhl
		pickhome	=	(p.prob_home_win_su	>	p.prob_away_win_su*NBAmlthreshold)	unless	isnhl
		pickaway	=	(p.prob_home_win_su*NBAmlthreshold	<	p.prob_away_win_su)	unless	isnhl
		# do puck line for nhl
#		raise "isnhl #{isnhl.inspect}"
=begin
		if isnhl
			hwp,	hlose	=	getpplfml(h.plhodds)
			awp,	alose	=	getpplfml(h.plaodds)
#			raise "awp #{awp} alose #{alose} h.plaodds #{h.plaodds}"
			plevh		=	hwp	*	h.plhprob	+	(hlose	* (1.0 - h.plhprob))
			pleva		=	awp	*	h.plaprob	+	(alose	* (1.0 - h.plaprob))
			plpickhome	=	(plevh	>	0.0)
			plpickaway	=	(pleva	>	0.0)
			if	plpickhome
				if	(p.actual_home_score	+	h.plhome)	>	p.actual_away_score
					hprize	=	hwp
				else
					hprize	=	hlose
				end
			elsif	plpickaway
				if	(p.actual_away_score	+	h.plaway)	>	p.actual_home_score
					aprize	=	awp
				else
					aprize	=	alose
				end
			end
		end
		raise if aprize.nil?
		raise if hprize.nil?
#		raise "hodds #{hodds}"
=end
	mlats = ((pickhome and p.spread > 0.0) ? p.home_team_id : ((pickaway and p.spread < 0.0) ? p.away_team_id : nil))	unless	isnhl
#	mlats = p.home_team_id													if	isnhl
#	puts "mlats.inspect #{mlats.inspect}"
#	raise "mlats is zero #{p.inspect}" if mlats == 0
	if isnhl
		hhf	=	nil
		ahf	=	nil
		bh	=	nil
	end
#	raise if hprize.nil?
#	raise if aprize.nil?
	return [0, "#{Ydiv}No Opinion #{Ediv}", 0.0, nil, 0.0, 0.0, 0.0, false]  if pickhome == false and pickaway == false
	# picked home and was right 
	return [1, "#{Gdiv} #{nameconv(Team.find(p.home_team_id).name, p.league)}  ->  #{(hwinprize).to_s[0,6]}#{Ediv}", hwinprize, mlats, hbbmlwin, hhf, ahf, bh] if pickhome and p.actual_home_score > p.actual_away_score
	# picked home and was wrong
	return [2, "#{Rdiv} #{nameconv(Team.find(p.home_team_id).name, p.league)}  ->  #{hlose.to_s[0,6]}#{Ediv}", hlose, mlats, hbbmllose, hhf, ahf, bh] if pickhome and p.actual_home_score < p.actual_away_score
	# picked home and was draw
	return [3, "#{Ydiv} #{nameconv(Team.find(p.home_team_id).name, p.league)}  ->  0.0#{Ediv}", 0.0, mlats, 0.0, 0.0, 0.0, false] if pickhome and p.actual_home_score == p.actual_away_score
	# picked away and was right
	return [4, "#{Gdiv} #{nameconv(Team.find(p.away_team_id).name, p.league)}  ->  #{(awinprize).to_s[0,6]}#{Ediv}", awinprize, mlats, abbmlwin, hhf, ahf, bh] if pickaway and p.actual_away_score > p.actual_home_score
	# picked away and was wrong
	return [5, "#{Rdiv} #{nameconv(Team.find(p.away_team_id).name, p.league)}  ->  #{alose.to_s[0,6]}#{Ediv}", alose, mlats, abbmllose, hhf, ahf, bh] if pickaway and p.actual_away_score < p.actual_home_score
	# picked away and was draw
	return [6, "#{Ydiv} #{nameconv(Team.find(p.away_team_id).name, p.league)}  ->  0.0#{Ediv}", 0.0, mlats, 0.0, 0.0, 0.0, false] if pickaway and p.actual_away_score == p.actual_home_score
	raise "why am i here"
end


