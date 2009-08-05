def	ms(wsh, ysh, week, header=nil, gaptitle	=	'Week', gc	=	0)
		summ	=	0.0
		ta	=	[]
		#week first
#		ta	<<	'</table></td></tr>' # turn off previous table - tr is for wrapping table
#		ta	<<	'<tr><table border="1">' # start new table
		ta	<<	"<tr><td>#{gaptitle} #{week} Statistics</td>" if header.nil?
		ta	<<	"<tr><td>#{header} #{gc.commify} Statistics</td>" unless header.nil?
		wsuw		=	wsh['suright']
		wsut		=	wsh['su']
		wsul		=	wsut	-	wsuw	#	+	wsh['supush']
		wsudiv		=	Gdiv	if	wsuw	>	wsul
		wsudiv		=	Rdiv	if	wsuw	<	wsul
		wsudiv		=	Ydiv	if	wsuw	==	wsul
		ysuw		=	ysh['suright']
		ysut		=	ysh['su']
		ysul		=	ysut	-	ysuw
		ysudiv		=	Gdiv	if	ysuw	>	ysul
		ysudiv		=	Rdiv	if	ysuw	<	ysul
		ysudiv		=	Ydiv	if	ysuw	==	ysul
		wpcw		=	(100.0 * wsuw / wsut).r2
#		wpcw		=	0.0	if	wpcw.nan?
		ypcw		=	(100.0 * ysuw / ysut).r2
#		ypcw		=	0.0	if	ypcw.nan?

		watsw	=	wsh['atsright']
		watst	=	wsh['ats']
		watsl	=	watst	-	watsw	#	+	wsh['atsbetpush']
		watsdiv	=	Gdiv	if	watsw	>	watsl * 1.1
		watsdiv	=	Rdiv	if	watsw	<	watsl * 1.1
		watsdiv	=	Ydiv	if	watsw	==	watsl * 1.1
		yatsw	=	ysh['atsright']
		yatst		=	ysh['ats']
		yatsl		=	yatst	-	yatsw
		yatsdiv	=	Gdiv	if	yatsw	>	yatsl * 1.1
		yatsdiv	=	Rdiv	if	yatsw	<	yatsl * 1.1
		yatsdiv	=	Ydiv	if	yatsw	==	yatsl * 1.1

		wout		=	wsh['ou']
		yout		=	ysh['ou']
		wouright	=	wsh['ouright']
		youright	=	ysh['ouright']
		woul		=	wout	-	wouright
		woudiv	=	Gdiv	if	wouright	>	woul * 1.1
		woudiv	=	Rdiv	if	wouright	<	woul * 1.1
		woudiv	=	Ydiv	if	wouright	==	woul * 1.1
		youl		=	yout	-	youright
		youdiv	=	Gdiv	if	youright	>	youl * 1.1
		youdiv	=	Rdiv	if	youright	<	youl * 1.1
		youdiv	=	Ydiv	if	youright	==	youl * 1.1
		ymlp	=	ysh['mlp'].r2
		ymldiv	=	Gdiv	if	ymlp	>	0
		ymldiv	=	Ydiv	if	ymlp	==	0
		ymldiv	=	Rdiv	if	ymlp	<	0
		wmlw	=	wsh['mlw']
		ymlw	=	ysh['mlw']
		wmll	=	wsh['mll']
		ymll	=	ysh['mll']

		# nhl puck line
		wmlp	=	wsh['mlp'].r2
		wmldiv	=	Gdiv	if	wmlp	>	0
		wmldiv	=	Rdiv	if	wmlp	<	0
		wmldiv	=	Ydiv	if	wmlp	==	0
		wplhw	=	wsh['plhw']
		wplhl	=	wsh['plhl']
		wplht	=	wplhw	+	wplhl
		wplaw	=	wsh['plaw']
		wplal	=	wsh['plal']
		wplat	=	wplaw	+	wplal
		ymldiv	=	Gdiv	if	ymlp	>	0
		ymldiv	=	Rdiv	if	ymlp	<	0
		ymldiv	=	Ydiv	if	ymlp	==	0
		yplhw	=	ysh['plhw']
		yplhl	=	ysh['plhl']
		yplht	=	yplhw	+	yplhl
		yplaw	=	ysh['plaw']
		yplal	=	ysh['plal']
		yplat	=	yplaw	+	yplal
		wplhp	=	wsh['plhp'].r2
		wplhdiv	=	Gdiv	if	wplhp	>	0
		wplhdiv	=	Ydiv	if	wplhp	==	0
		wplhdiv	=	Rdiv	if	wplhp	<	0
		wplap	=	wsh['plap'].r2
		wpladiv	=	Gdiv	if	wplap	>	0
		wpladiv	=	Ydiv	if	wplap	==	0
		wpladiv	=	Rdiv	if	wplap	<	0
		yplhp	=	ysh['plhp'].r2
		yplhdiv	=	Gdiv	if	yplhp	>	0
		yplhdiv	=	Ydiv	if	yplhp	==	0
		yplhdiv	=	Rdiv	if	yplhp	<	0
		yplap	=	ysh['plap'].r2
		ypladiv	=	Gdiv	if	yplap	>	0
		ypladiv	=	Ydiv	if	yplap	==	0
		ypladiv	=	Rdiv	if	yplap	<	0
		

		# week
		ta	<<	"<td>#{gaptitle}#{wsudiv} #{wsuw} SU wins #{wsul} loses #{wpcw} % win#{Ediv}</td>"
		if (wplhw + wplaw + wplhl + wplal)	>	0
			ta	<<	"<td>#{gaptitle}#{wplhdiv} PL Home #{wplhw} wins #{wplhl} loses #{(100.0 * wplhw / (wplht == 0 ? 1 : wplht)).r2} % win #{wplhp.r2.commify} profit#{Ediv}</td>"
			ta	<<	"<td>#{gaptitle}#{wpladiv} PL Away #{wplaw} wins #{wplal} loses #{(100.0 * wplaw / (wplat == 0 ? 1 : wplat)).r2} % win #{wplap.r2.commify} profit#{Ediv}</td>"
		else
			ta	<<	"<td>#{gaptitle}#{watsdiv} #{watsw} ATS wins #{watsl} loses #{(100.0 * watsw / (watst == 0 ? 1 : watst)).r2} % win #{(watsw - 1.1 * watsl).r2.commify} profit#{Ediv}</td>"
		end
		ta	<<	"<td>#{gaptitle}#{woudiv} #{wouright} OU wins #{woul} loses #{(100.0 * wouright / (wout == 0 ? 1 : wout)).r2} % win #{(wouright - 1.1 * woul).r2.commify} profit #{Ediv}</td>"
		ta	<<	"<td>#{gaptitle}#{wmldiv} Money Line #{wmlw} wins #{wmll.commify} loses #{(100.0 * wmlw / ((wmlw + wmll) == 0 ? 1 : wmlw + wmll)).r2} % win #{wmlp.r2.commify} profit #{Ediv}</td>"

		# year
		ta	<<	"<td>Year#{ysudiv} #{week} #{ysuw} SU wins #{ysul} loses #{ypcw} % win #{Ediv}</td>"
		if (yplhw+wplhl+wplaw+yplal) > 0
			ta	<<	"<td>Year #{yplhdiv}PL Home #{yplhw} wins #{yplhl} loses #{(100.0 * yplhw / (yplht == 0 ? 1 : yplht)).r2} % win #{yplhp.r2.commify} profit#{Ediv}</td>"
			ta	<<	"<td>Year #{ypladiv}PL Away #{yplaw} wins #{yplal} loses #{(100.0 * yplaw / (yplat == 0 ? 1 : yplat)).r2} % win #{yplap.r2.commify} profit#{Ediv}</td>"
		else
			ta	<<	"<td>#{yatsdiv}ATS #{yatsw} wins #{yatsl} loses #{(100.0 * yatsw / (yatst == 0 ? 1 : yatst)).r2} % win #{(yatsw - 1.1 * yatsl).r2.commify} profit#{Ediv}</td>"
		end
		summ	+=	yatsw - 1.1 * yatsl
		ta	<<	"<td>Year #{youdiv}OU #{youright} wins #{youl} loses % #{(100.0 * youright / (yout == 0 ? 1 : yout)).r2} win #{(youright - 1.1 * youl).r2.commify} profit#{Ediv}</td>"
		summ	+=	youright - 1.1 * youl
		ta	<<	"<td>Year #{ymldiv}Money Line #{ymlw} wins #{ymll.commify} loses #{(100.0 * ymlw / ((ymlw+ymll) == 0 ? 1 : (ymlw+ymll))).r2} % win #{ymlp.r2.commify} profit #{Ediv}</td>"
		summ	+=	ymlp
#		ta	<<	'</table></tr>' # turn off this table
#		ta	<<	'<tr><table border="1">' # restart old table
		ta	<<	'</tr>'
		# now new home dog etc stats
		outstr	=	"<tr><td>Home and Away Dog and Favorite Stats</td>"
		p		=	(wsh['hd'][0]-wsh['hd'][1]*1.1).r2
		sd		=	p	>	0.0	?	Gdiv : (p	==	0.0	?	Ydiv : Rdiv)
		outstr	+=	"<td>#{sd}#{gaptitle}ly Home Dog Stats - #{wsh['hd'][0].commify} wins #{wsh['hd'][1].commify} loses - Profit is #{p.commify}#{Ediv}</td>"
		p		=	(wsh['ad'][0]-wsh['ad'][1]*1.1).r2
		sd		=	p	>	0.0	?	Gdiv : (p	==	0.0	?	Ydiv : Rdiv)
		outstr	+=	"<td>#{sd}#{gaptitle}ly Road Dog Stats - #{wsh['ad'][0].commify} wins #{wsh['ad'][1].commify} loses - Profit is #{p.commify}#{Ediv}</td>"
		p		=	(wsh['hf'][0]-wsh['hf'][1]*1.1).r2
		sd		=	p	>	0.0	?	Gdiv : (p	==	0.0	?	Ydiv : Rdiv)
		outstr	+=	"<td>#{sd}#{gaptitle}ly Home Fav Stats - #{wsh['hf'][0].commify} wins #{wsh['hf'][1].commify} loses - Profit is #{p.commify}#{Ediv}</td>"
		p		=	(wsh['af'][0]-wsh['af'][1]*1.1).r2
		sd		=	p	>	0.0	?	Gdiv : (p	==	0.0	?	Ydiv : Rdiv)
		outstr	+=	"<td>#{sd}#{gaptitle}ly Road Fav Stats - #{wsh['af'][0].commify} wins #{wsh['af'][1].commify} loses - Profit is #{p.commify}#{Ediv}</td>"
		outstr.gsub!('Dayly','Daily') if outstr.include?('Dayly')
		p		=	(ysh['hd'][0]-ysh['hd'][1]*1.1).r2
		sd		=	p	>	0.0	?	Gdiv : (p	==	0.0	?	Ydiv : Rdiv)
		outstr	+=	"<td>#{sd}Yearly Home Dog Stats - #{ysh['hd'][0].commify} wins #{ysh['hd'][1].commify} loses - Profit is #{p.commify}#{Ediv}</td>"
		p		=	(ysh['ad'][0]-ysh['ad'][1]*1.1).r2
		sd		=	p	>	0.0	?	Gdiv : (p	==	0.0	?	Ydiv : Rdiv)
		outstr	+=	"<td>#{sd}Yearly Road Dog Stats - #{ysh['ad'][0].commify} wins #{ysh['ad'][1].commify} loses - Profit is #{p.commify}#{Ediv}</td>"
		p		=	(ysh['hf'][0]-ysh['hf'][1]*1.1).r2
		sd		=	p	>	0.0	?	Gdiv : (p	==	0.0	?	Ydiv : Rdiv)
		outstr	+=	"<td>#{sd}Yearly Home Fav Stats - #{ysh['hf'][0].commify} wins #{ysh['hf'][1].commify} loses - Profit is #{p.commify}#{Ediv}</td>"
		p		=	(ysh['af'][0]-ysh['af'][1]*1.1).r2
		sd		=	p	>	0.0	?	Gdiv : (p	==	0.0	?	Ydiv : Rdiv)
		outstr	+=	"<td>#{sd}Yearly Road Fav Stats - #{ysh['af'][0].commify} wins #{ysh['af'][1].commify} loses - Profit is #{p.commify}#{Ediv}</td>"
		outstr	+=	"</tr>"
#		raise "summ #{summ} outstr #{outstr.inspect}"
		ta	<<	outstr
		return [ta,	summ]
	end

