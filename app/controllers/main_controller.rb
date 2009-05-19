#require 'ruby-prof'
class MainController < ApplicationController
# caches_page :index, :nfl, :notdone

def wrap(str, wrapper='td')
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

#	RubyProf.start
	makeswp(params['league'],	params['id'].to_i)

#	result = RubyProf.stop

	# Print a flat profile to text
#	printer = RubyProf::FlatPrinter.new(result)
#	printer.print("profout.txt", 0)
	render :template=>"main/main.rhtml"
end

def soccer
	sa		=	IO.readlines("public/soccer seasons.txt")
	#	build table with season numbers across the top and league names down the left side
	#	puts sa.inspect
	#	raise
	#	build year list
	#	E0,2000,1
	yh		=	{}	#	year hash
	years	=	[]
	sa.each{|y|
		ta	=	y.split(',')
		yh[[ta[0],	ta[2]]]	=	ta[2]
		years	<<	[ta[1],	ta[2]]
	}
	puts "yh.inspect #{yh.inspect}"
#	raise
	years.uniq!
	years.sort!
	puts years.inspect
#	raise
	outstr	=	'<h2>Soccer Matrix<h2><br><h3>The Rules:</h3><br>Start with $100, compute prob of home win, away win or draw via my propriatary method, compute EV (expected value of bet - just prob of event times odds - anything over 1.0 is good) bet 4 percent of bankroll in $4 increments (OR one $4 bet if bankroll is less than $100) on bets sorted by best EV on down!<br><table border = "1">'
	outstr	+=	"<th>"
	years.each{|y|outstr	+=	wrap("Season "+y[1]+' '+y[0])}
	outstr	+=	"</th>"
	
	lh	=	{}
	
	sa.each{|s|
		ta				=	s.split(',')
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
	puts la.inspect
#	raise
	la.each{|l|
		outstr	+=	"<tr>#{wrap(l[1][0])}"
#		puts l
#		raise
		years.each{|y|
			puts "y.inspect #{y.inspect}"
			keyy	=	[l[0],	y[1].to_s]
			puts "keyy #{keyy.inspect}"
			if yh.has_key?(keyy)
				puts yh[keyy].inspect
				keyy2	=	l[0]+'^'+y[1].to_s.chomp
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
				ls		=	'<a href="/main/makscr/'+"#{yh[keyy].chomp}?league=#{l[0]}"+'"'+">"+outstr2+'</a>'
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
	year		=	params[:id].to_i
	logger.warn params.inspect
	leagueid	=	params[:league].to_i
	pred		=	Prediction.find_all_by_league(leagueid)
#	logger.warn pred.inspect
	pred.sort!{|a,b|a["game_date_time"]<=>b["game_date_time"]}
	proba	=	[]
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
	case leagueid
		when 1 # nfl
			# games run from sept to febuary
			startdate	=	Time.local(year, 'sep', 1) 
			enddate	=	Time.local(year + 1, 'sep', 1) 
			header	=	"<h3>Joe Guy's #{year} National Football League Season - betting threshold is #{winprob}</h3>"
			gap		=	Secondsinthreedays
			gaptitle	=	'Week'
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
		when 4 # ncaa football
			# games run from aug to feb
			startdate	=	Time.local(year, 'aug', 1) 
			enddate	=	Time.local(year + 1, 'feb', 1)
			winprob	=	0.8 if year == 2007
			winprob	=	0.8 if year == 2008
			header	=	"<h3>Joe Guy's #{year} NCAA Football Season - betting threshold is #{winprob}</h3>"
			gap		=	Secondsinthreedays - 1
			gaptitle	=	'Week'
		when 5 # ncaa bb
			# games run from Nov to April
			startdate	=	Time.local(year, 'nov', 1) 
			enddate	=	Time.local(year + 1, 'may', 1)
			winprob	=	0.85	unless	year	==	2008
			winprob	=	0.85	if		year	==	2008
			header	=	"<h3>Joe Guy's #{year} NCAA Basketball Season - betting threshold is #{winprob}</h3>"
			gap		=	Secondsperday - 1
			gaptitle	=	'Day'
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
	@main	=	do_season(newpred,	year,	winprob,	header,	gap,	gaptitle, (leagueid	==	5))
end
=begin
=end
end
