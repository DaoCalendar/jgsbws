#require 'ruby-prof'
class MainController < ApplicationController
	caches_page :index, :nfl, :notdone, :soccer, :makscr, :main

def mc_wrap(str, wrapper='td')
	return "<#{wrapper}>#{str}</#{wrapper}>"
end

def index
end

def makscr
#	puts "preds.inspect #{preds.inspect}"
	puts
#	puts "pred.last.inspect #{pred.last.inspect}"
#	raise
#	Profile the code

	# l112 <- combo league and season

#	RubyProf.start
#	makeswp(params['league'],	params['id'].to_i)
	t		=	params['id'].split('_')
	league	=	t[0]
	season	=	t[1].to_i
#	puts params['id']
#	raise "league >#{league}< season >#{season}<"
	makeswp(league,	season)

#	result = RubyProf.stop

	# Print a flat profile to text
#	printer = RubyProf::FlatPrinter.new(result)
#	printer.print("profout.txt", 0)
	render :template=>"main/main.rhtml"
end

def soccer
	sa	=	IO.readlines("public/soccer seasons.txt")
	#	build table with season numbers across the top and league names down the left side
	#	puts sa.inspect
	#	raise
	#	build year list
	#	E0,2000,1
	yh		=	{}	#	year hash
	years	=	[]
	nsa		=	[]
	sa.each{|y|
		ta	=	y.split(',')
		nsa	<<	y	if	ta[1].to_i	>=	1_999
	}
	sa	=	nsa
	sa.each{|y|
		ta	=	y.split(',')
		yh[[ta[1],	ta[0]]]	=	ta[2] #	key is year and league and data is season
		years	<<	[ta[1],	ta[2]]
	}
	puts "yh.inspect #{yh.inspect}"
#	raise
	uyt	=	yh.keys.sort
	uy	=	[]
	uyt.each{|k|
		uy	<<	k[0]	unless	uy.include?(k[0])
	}
#	raise uy.inspect
	years.uniq!
	years.sort!{|a,b|ysort(a,	b)}
#	raise years.inspect
#	raise
	bankroll	=	1_000.0
	bet		=	bankroll	*	Fpc
	outstr	=	"<h2>Soccer Matrix<h2><br><h3>The Rules:</h3><br>Start with $#{bankroll.commify}, compute prob of home win, away win or draw via my propriatary method, compute EV (expected value of bet - just prob of event times odds - anything over 1.0 is good) bet 4 percent of bankroll in $#{bet} increments (OR one $#{bet} bet if bankroll is less than $#{bankroll.commify}) on bets sorted by best EV on down! (Provided it is greater then 1.0 - when there is no good EV - there is no bet!)<br>"+'<table border = "1">'
	outstr	+=	"<th>"
#	years.each{|y|outstr	+=	wrap("Season "+y[1]+' '+y[0])}
	uy.each{|y|outstr	+=	wrap(y)}
	outstr	+=	"</th>"

	lh		=	{}
#	ch		=	{}

	#	raise sa.inspect
	sa.each{|s|
		ta				=	s.split(',')
#		ch[ta[0],ta[1] .to_i]	=	ta[2].to_i	# D1,1997,5
		lname			=	''
		lid				=	0
		if lh.has_key?(ta[0])
			lname		=	lh[ta[0]][0]
			lid			=	lh[ta[0]][1]
		else
			@slo		=	League.find_by_short_league(ta[0])
			lname		=	@slo.name
			lid			=	@slo.id
			slo			=	nil
			lh[ta[0]]		=	[lname,	lid]
		end
	}
	puts lh.inspect
#	raise

	la	=	lh.sort{|a,	b|a[0]<=>b[0]}
#	raise la.inspect
#	raise
	la.each{|l|
#		raise l.inspect
		outstr	+=	"<tr>#{wrap(l[1][0])}"
#		puts l
#		raise
#		years.each{|y|
		uy.each{|y|
			# y0 is year y1 is season
			puts "y.inspect #{y.inspect}"
			keyy	=	[y.to_s,	l[0]]	#	keyy	is year and league
#			keyy	=	[y[0].to_s]	#	keyy	is year
#			keyy	=	[y.to_s]	#	keyy	is year
			puts "keyy #{keyy.inspect}"
#			if yh.has_key?(keyy)
#			raise "keyy #{keyy.inspect} yh[keyy] #{yh[keyy].inspect} [l[0],	y[1]] #{[l[0],	y[1]].inspect} yh #{yh.inspect}"
#			if yh[keyy]	==	[l[0],	y[1]]	#	league and year match season?
			if yh.has_key?(keyy)	#	[keyy][0]	==	y		#	league and year match season?
				puts yh[keyy].inspect
				season	=	yh[keyy].to_i
				keyy2	=	l[0]+'^'+season.to_s
				puts "keyy2 >#{keyy2}<"
#				sleep 1
				ss		=	Sum.find_by_key(keyy2)
				puts "ss.inspect #{ss.inspect}"
				outstr2	=	"<div id='yellow'>No Betting Info</div>"
				div		=	"<div id='yellow'>$"
				div		=	"<div id='red'>$"	if	!ss.nil?	&&	ss.amount	<	0.0
				div		=	"<div id='green'>$"	if	!ss.nil?	&&	ss.amount	>	0.0
				outstr2	=	div+ss.amount.r2.commify+'</div>'	unless	ss.nil?
				#		<a href="/main/main/2008?league=5">Joe Guy's 2008 NCAA Basketball Season</a><br>
				title		=	"#{l[1][0]} - Season #{yh[keyy].chomp} - #{y}"
#				ls		=	'<a href="/main/makscr/'+"#{season}?league=#{l[0]}"+'"'+"title='#{title}'>"+outstr2+'</a>'	unless	ss.nil?
				ls		=	'<a href="/main/makscr/'+"#{l[0]}_#{season}"+'"'+"title='#{title}'>"+outstr2+'</a>'	unless	ss.nil?
				makeswp(l[0],	season, [bet,	bankroll].min)	if	Makedata	&&	!ss.nil?
				ls		=	outstr2		if	ss.nil?
				outstr	+=	wrap(ls)
			else
				outstr	+=	wrap('')
			end
		}
		outstr	+=	"</tr><br>\n"
	}
	outstr		+=	"</table>"
	puts yh.inspect
	puts outstr.inspect
#	raise
	@main			=	{}
	@main['pad']		=	false
	@main['desc']		=	"Joe Guy's Amazing Soccer Predictions"
	@main['content']	=	"Joe Guy's Amazing Soccer Predictions"
	@main['rollwith']	=	outstr
	render :template=>"main/main.rhtml"
end

def main
	# params[:id] is now like 012007 - 01 is the league
	year		=	params[:id][2,4].to_i
	logger.warn params.inspect
	leagueid	=	params[:id][0,2].to_i
#	raise "year #{year} leagueid #{leagueid}"
	pred		=	Prediction.find_all_by_league(leagueid)
#	logger.warn pred.inspect
	pred.sort!{|a,b|a["game_date_time"]<=>b["game_date_time"]}
	proba	=	[]
	lname	=	nil
	pred.each{|g|
		proba	<<	g.prob_home_win_ats.r2 unless proba.include?(g.prob_home_win_ats.r2)
		proba	<<	g.prob_away_win_ats.r2 unless proba.include?(g.prob_away_win_ats.r2)
		proba	<<	g.prob_game_over_total.r2 unless proba.include?(g.prob_game_over_total.r2)
		proba	<<	(1.0	-	g.prob_home_win_ats).r2 unless proba.include?((1.0	-	g.prob_home_win_ats).r2)
		proba	<<	(1.0	-	g.prob_away_win_ats).r2 unless proba.include?((1.0	-	g.prob_away_win_ats).r2)
		proba	<<	(1.0	-	g.prob_game_over_total).r2 unless proba.include?((1.0	-	g.prob_game_over_total).r2)
	}
#	logger.warn proba.sort.inspect
#	raise
	@main	=	[]
	winprob	=	0.7
	header	=	''
	sport	=	nil
	case leagueid
		when 1 # nfl
			# games run from sept to febuary
			startdate	=	Time.local(year, 'sep', 1) 
			enddate	=	Time.local(year + 1, 'sep', 1) 
			header	=	"<h3>Joe Guy's #{year} National Football League Season - betting threshold is #{winprob}</h3>"
			gap		=	Secondsinthreedays
			gaptitle	=	'Week'
			sport	=	'National Football League'
			lname	=	'National Football League'
		when 2 # nba
			# games run from Nov to April
			startdate	=	Time.local(year, 'nov', 1) 
			enddate	=	Time.local(year + 1, 'may', 1)
			winprob	=	0.62			if year == 2008
#			winprob	=	11.0 / 21.0	if year == 2008
			winprob	=	11.0 / 21.0	if year == 2007
			header	=	"<h3>Joe Guy's #{year} National Basketball Association Season - betting threshold is #{winprob}</h3>"
			gap		=	Secondsperday - 1
			gaptitle	=	'Day'
			sport	=	'National Basketball Association'
			lname	=	'National Basketball Association'
		when 4 # ncaa football
			# games run from aug to feb
			startdate	=	Time.local(year, 'aug', 1) 
			enddate	=	Time.local(year + 1, 'feb', 1)
			winprob	=	0.8 if year == 2007
			winprob	=	0.8 if year == 2008
			header	=	"<h3>Joe Guy's #{year} NCAA Football Season - betting threshold is #{winprob}</h3>"
			gap		=	Secondsinthreedays - 1
			gaptitle	=	'Week'
			sport	=	'NCAA Football'
			lname	=	'NCAA Football'
		when 5 # ncaa bb
			# games run from Nov to April
			startdate	=	Time.local(year, 'nov', 1) 
			enddate	=	Time.local(year + 1, 'may', 1)
			winprob	=	0.85	unless	year	==	2008
			winprob	=	0.85	if		year	==	2008
			header	=	"<h3>Joe Guy's #{year} NCAA Basketball Season - betting threshold is #{winprob}</h3>"
			gap		=	Secondsperday - 1
			gaptitle	=	'Day'
			sport	=	'NCAA Basketball'
			lname	=	'NCAA Basketball'
		else
#			logger.warn "main inspect"
#			logger.warn(@main.inspect)
#			logger.warn "main inspect done"
#			raise
		raise "no such league as #{leagueid}"
	end
	newpred	=	[]
	pred.each{|g|
		newpred	<<	g	if	g.game_date_time	>=	startdate	&&	g.game_date_time	<=	enddate
	}
#	raise
	@main	=	do_season(newpred,	year,	winprob,	header,	gap,	gaptitle, (leagueid	==	5),	sport,	lname)
end
=begin
=end
end
