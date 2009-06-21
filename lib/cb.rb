def	calcatsbet(g,	ysh,	wsh, winprob,	h)
	supick		=	nil
	supick		=	g.home_team_id	if	g.prob_home_win_su	>=	winprob
	supick		=	g.away_team_id	if	g.prob_away_win_su	>=	winprob
	suright		=	nil
	suright		=	(supick	==	g.home_team_id && (g.actual_home_score > g.actual_away_score)) || (supick	==	g.away_team_id && (g.actual_home_score < g.actual_away_score))
	ysh['suright']	+=	(suright	?	1	:	0) unless suright.nil?
	wsh['suright']	+=	(suright	?	1	:	0) unless suright.nil?
	ysh['su']	+=	1 unless supick.nil?
	wsh['su']	+=	1 unless supick.nil?
	supush		=	(g.actual_home_score == g.actual_away_score)
	wsh['supush']	+=	1 if supush

	atsbet		=	nil
	hatsev		=	g.prob_home_win_ats - (1.1 * (1.0 - g.prob_home_win_ats))
	aatsev		=	g.prob_away_win_ats - (1.1 * (1.0 - g.prob_away_win_ats))
	atsbet		=	g.home_team_id	if	hatsev	>	0.8
	atsbet		=	g.away_team_id	if	aatsev	>	0.8
#	atsbet		=	g.home_team_id	if	g.prob_home_win_ats	>=	winprob
#	atsbet		=	g.away_team_id	if	g.prob_away_win_ats	>=	winprob
	atsbetright	=	nil
	if h.nil?	# not nhl
		if g.spread	>	0
			wsh['hd'][0]	+=	1	if	(g.actual_home_score + g.spread) > g.actual_away_score # home dog won 
			wsh['hd'][1]	+=	1	if	(g.actual_home_score + g.spread) < g.actual_away_score # home dog lost 
			ysh['hd'][0]	+=	1	if	(g.actual_home_score + g.spread) > g.actual_away_score # home dog won 
			ysh['hd'][1]	+=	1	if	(g.actual_home_score + g.spread) < g.actual_away_score # home dog lost 
			wsh['af'][0]	+=	1	if	(g.actual_home_score + g.spread) < g.actual_away_score # away fav won 
			wsh['af'][1]	+=	1	if	(g.actual_home_score + g.spread) > g.actual_away_score # away fav lost 
			ysh['af'][0]	+=	1	if	(g.actual_home_score + g.spread) < g.actual_away_score # away fav won 
			ysh['af'][1]	+=	1	if	(g.actual_home_score + g.spread) > g.actual_away_score # away fav lost 
		else
			wsh['hf'][0]	+=	1	if	(g.actual_home_score + g.spread) > g.actual_away_score # home fav won 
			wsh['hf'][1]	+=	1	if	(g.actual_home_score + g.spread) < g.actual_away_score # home fav lost 
			ysh['hf'][0]	+=	1	if	(g.actual_home_score + g.spread) > g.actual_away_score # home fav won 
			ysh['hf'][1]	+=	1	if	(g.actual_home_score + g.spread) < g.actual_away_score # home fav lost 
			wsh['ad'][0]	+=	1	if	(g.actual_home_score + g.spread) < g.actual_away_score # away dog won 
			wsh['ad'][1]	+=	1	if	(g.actual_home_score + g.spread) > g.actual_away_score # away dog lost 
			ysh['ad'][0]	+=	1	if	(g.actual_home_score + g.spread) < g.actual_away_score # away dog won 
			ysh['ad'][1]	+=	1	if	(g.actual_home_score + g.spread) > g.actual_away_score # away dog lost 
		end
		atsbetright		=	(atsbet	==	g.home_team_id && (g.actual_home_score + g.spread) > g.actual_away_score) || (atsbet	==	g.away_team_id && (g.actual_home_score + g.spread) < g.actual_away_score)
		atsbetpush		=	((g.actual_home_score + g.spread) == g.actual_away_score)
		ysh['atsright']		+=	(atsbetright	?	1	:	0)
		wsh['atsright']		+=	(atsbetright	?	1	:	0)
		if atsbetpush
			wsh['atsbetpush']	+=	1
		else
			ysh['ats']	+=	1 unless atsbet.nil?
			wsh['ats']	+=	1 unless atsbet.nil?
		end
		
		oubet		=	nil
		oubetright	=	nil
		oubetpush	=	nil
		unless	g.game_total	==	0
			oubet	=	true		if 	g.prob_game_over_total			>=	winprob
			oubet	=	false		if	(1.0	-	g.prob_game_over_total)	>=	winprob
			unless oubet.nil?
				if oubet # bet the over
					oubetright	=	((g.actual_home_score	+	g.actual_away_score)	>	g.game_total)
				else
					oubetright	=	((g.actual_home_score	+	g.actual_away_score)	<	g.game_total)
				end
			end
			oubetpush			=	((g.actual_home_score	+	g.actual_away_score)	==	g.game_total)
			unless oubetpush
				unless oubetright.nil?
					ysh['ouright']	+=	(oubetright	?	1	:	0)
					wsh['ouright']	+=	(oubetright	?	1	:	0)
					ysh['ou']	+=	1
					wsh['ou']	+=	1
				end
			end
		end
		logger.warn( "oubet #{oubet.inspect} ou total #{g.game_total} over prob #{g.prob_game_over_total} ")
	else
		# is nhl - do puck lines and ou with seperate odds
		
	end
	return ysh,	wsh,	supick,	suright,	supush,	atsbet,	oubet,	atsbetright,	atsbetpush,	oubetright,	oubetpush
	end

