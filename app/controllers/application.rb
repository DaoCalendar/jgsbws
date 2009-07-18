# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
load			'nbaloadr.rb'
load			'mlbloadr.rb'
load			'makms.rb'
load			'mlhlprr.rb'
load			'makesummary.rb'
load			'nc.rb'
load			'cb.rb'
NBAmlthreshold		=	4
Plnhlevthreshold	=	0.04
Makedata		=	false	# make data file for images
Pasttime		=	Time.local(1_962,1,1)
Seasonone		=	Time.local(2_008,4,7)
Futuretime		=	Time.local(2_012,1,1)
Secondsperday		=	24	*	3_600
Secondsinthreedays	=	2.5	*	24	*	3600	#	days*hour/day*seconds/hour
NO			=	"No Opinion"
Gdiv			=	"<div id='green'>"
Rdiv			=	"<div id='red'>"
Ydiv			=	"<div id='yellow'>"
Fpc			=	0.045
Tpf			=	2.5
Td			=	"<td>"
Tde			=	"</td>"
Tr			=	"<tr>"
Tre			=	"</tr>"
Na			=	'<td>No Action</td>'
Betarray		=	%w(B365H B365D B365A BSH BSD BSA BWH BWD BWA GBH GBD GBA IWH IWD IWA LBH LBD LBA SBH SBD SBA WHH WHD WHA SJH SJD SJA VCH VCD VCA BbMxgt2p5 BbMxlt2p5 BbAvgt2p5 BbAvlt2p5 GBgt2p5 GBlt2p5 B365gt2p5 B365lt2p5)
Betnames		=	['Bet365 home win odds -> EV -> $bankroll', 'Bet365 draw odds -> EV -> $bankroll', 'Bet365 away win odds -> EV -> $bankroll',  'Blue Square home win odds -> EV -> $bankroll', 'Blue Square draw odds -> EV -> $bankroll', 'Blue Square away win odds -> EV -> $bankroll',  'Bet&Win home win odds -> EV -> $bankroll', 'Bet&Win draw odds -> EV -> $bankroll', 'Bet&Win away win odds -> EV -> $bankroll',  'Gamebookers home win odds -> EV -> $bankroll', 'Gamebookers draw odds -> EV -> $bankroll', 'Gamebookers away win odds -> EV -> $bankroll',  'Interwetten home win odds -> EV -> $bankroll', 'Interwetten draw odds -> EV -> $bankroll', 'Interwetten away win odds -> EV -> $bankroll',  'Ladbrokes home win odds -> EV -> $bankroll', 'Ladbrokes draw odds -> EV -> $bankroll', 'Ladbrokes away win odds -> EV -> $bankroll',  'Sporting Odds home win odds -> EV -> $bankroll', 'Sporting Odds draw odds -> EV -> $bankroll', 'Sporting Odds away win odds -> EV -> $bankroll',  'Sportingbet home win odds -> EV -> $bankroll', 'Sportingbet draw odds -> EV -> $bankroll', 'Sportingbet away win odds -> EV -> $bankroll',  'Stan James home win odds -> EV -> $bankroll', 'Stan James draw odds -> EV -> $bankroll', 'Stan James away win odds -> EV -> $bankroll',  'Stanleybet home win odds -> EV -> $bankroll', 'Stanleybet draw odds -> EV -> $bankroll', 'Stanleybet away win odds -> EV -> $bankroll',  'VC Bet home win odds -> EV -> $bankroll', 'VC Bet draw odds -> EV -> $bankroll', 'VC Bet away win odds -> EV -> $bankroll',  'William Hill home win odds -> EV -> $bankroll', 'William Hill draw odds -> EV -> $bankroll', 'William Hill away win odds -> EV -> $bankroll']

Bookienamehash		=	{}
Bookienamehash['B3']	=	'Bet365'
Bookienamehash['BS']	=	'Blue Square'
Bookienamehash['BW']	=	'Bet & Win'
Bookienamehash['GB']	=	'Gamebookers'
Bookienamehash['IW']	=	'Interwetten'
Bookienamehash['LB']	=	'Ladbrokes'
Bookienamehash['SO']	=	'Sporting Odds'
Bookienamehash['SB']	=	'Sportingbet'
Bookienamehash['SJ']	=	'Stan James'
Bookienamehash['SY']	=	'Stanleybet'
Bookienamehash['VC']	=	'VC Bet'
Bookienamehash['WH']	=	'William Hill'

class Numeric
  def	commify()
	  retme 	=	self.to_s.reverse.gsub(/(\d\d\d)(?=\d)(?!\d*\.)/,'\1,').reverse
	  if retme.include?('.')
		  retme	=	retme	+	'0' unless (retme.length - retme.index('.'))	==	3
	  end
	  return retme
  end 
  def	currency()
    sstr = to_s+".00"
    sstr.gsub!("..",".") if sstr.include?("..")
    sstr[0..sstr.index(".")+2]
  end
  def	r2()
#	return self
	begin
		return ((((self+0.005)*100.0).to_i) / 100.00)
	rescue
#		raise "r2 failed - self is #{self}"
		return 0.0
	end
  end
  def	r3()
#	return self
	begin
		return ((((self+0.0005)*1000.0).to_i) / 1000.00)
	rescue
#		raise "r3 failed - self is #{self}"
		return 0.0
	end
  end
end
class ApplicationController < ActionController::Base
	# Be sure to include AuthenticationSystem in Application Controller instead
	include AuthenticatedSystem
	# If you want "remember me" functionality, add this before_filter to Application Controller
	before_filter :login_from_cookie
	# Pick a unique cookie name to distinguish our session data from others'
	session :session_key	=>	'_jgsbws_session_id'

	def convml(ml)
		return (1.0 + (ml > 0 ? ml / 100.0 : (-100.0 / ml)))
	end

	def	getthisweeksbets(preds,	thisweek,	sbh,	beta)
		eva			=	[]
		preds.each_with_index{|p,	pi|
			next unless	p.week	==	thisweek
			next unless sbh.has_key?(p.soccer_bet)
			beta.each{|b|
				s,ph,pa,pd	=	sbh[p.soccer_bet]
				unless	s[b].nil?
					bl	=	b[b.length-1,1]
#					raise "ph #{ph} pa #{pa} pd #{pd}"
#					raise "b #{b} bl #{bl} "
#					next if (bl=='H' && ph < 0.5) || (bl=='A' && pa < 0.5) || (bl=='D' && pd < 0.5)
#					eva	<<	[b,	(s[b+'_ev'].nil? ? 0.0 : s[b+'_ev']),	pi]	
					eva	<<	[b,	ph,	(s[b+'_ev'].nil? ? 0.0 : s[b+'_ev']),	pi]	if	bl	==	'H'
					eva	<<	[b,	pa,	(s[b+'_ev'].nil? ? 0.0 : s[b+'_ev']),	pi]	if	bl	==	'A'
					eva	<<	[b,	pd,	(s[b+'_ev'].nil? ? 0.0 : s[b+'_ev']),	pi]	if	bl	==	'D'
				end
			}
		}
		puts	eva.inspect
		puts eva.length
		eva.delete_if{|e|	e[1]	<	0.5}
#		raise	"eva.inspect #{eva.inspect} eva.length #{eva.length}"
		return eva
	end

	def	ysort(a,	b)
#		raise "a #{a.inspect} b #{b.inspect} a[1].chomp.to_i #{a[1].chomp.to_i} a[1].to_i #{a[1].to_i}"
		#	[year,	season]
		return a[1].to_i<=>b[1].to_i	if	a[0].to_i	==	b[0].to_i
		return a[0].to_i<=>b[0].to_i
	end
def	hi
	ysh			=	{}
	wsh			=	{}
	ysh['hd']		=	[0,	0]
	wsh['hd']		=	[0,	0]
	ysh['hf']		=	[0,	0]
	wsh['hf']		=	[0,	0]
	ysh['ad']		=	[0,	0]
	wsh['ad']		=	[0,	0]
	ysh['af']		=	[0,	0]
	wsh['af']		=	[0,	0]
	ysh['suright']		=	0
	wsh['suright']		=	0
	ysh['supush']		=	0
	wsh['supush']		=	0
	ysh['su']		=	0
	wsh['su']		=	0
	ysh['atsright']		=	0
	wsh['atsright']		=	0
	ysh['atsbetpush']	=	0
	wsh['atsbetpush']	=	0
	ysh['ats']		=	0
	wsh['ats']		=	0
	ysh['ouright']		=	0
	wsh['ouright']		=	0
	ysh['ou']		=	0
	wsh['ou']		=	0
	wsh['mlp']		=	0
	ysh['mlp']		=	0
	wsh['mlbb']		=	0
	ysh['mlbb']		=	0
	wsh['mlw']		=	0
	ysh['mlw']		=	0
	wsh['mll']		=	0
	ysh['mll']		=	0
	wsh['plhp']		=	0.0
	ysh['plhp']		=	0.0
	wsh['plhw']		=	0
	ysh['plhw']		=	0
	wsh['plhl']		=	0
	ysh['plhl']		=	0
	wsh['plap']		=	0.0
	ysh['plap']		=	0.0
	wsh['plaw']		=	0
	ysh['plaw']		=	0
	wsh['plal']		=	0
	ysh['plal']		=	0
	return ysh,	wsh
end

def do_season(newpred,	year,	winprob	=	0.7,	header	=	nil, gap	=	Secondsinthreedays,	gaptitle	=	"Week", mm = false, sport	=	nil,	lname	=	nil)
	raise 'need a sport'		if	sport.nil?
	raise 'need a gaptitle'		if	gaptitle.empty?
	raise 'need a league'		if	lname.nil?
	isnhl				=	false
	isnhl				=	(lname	==	'National Hockey League')
	ff				=	File.open('graphdata.txt','a')	if	Makedata
#	puts "in makeswp with #{lid} and #{pid}"			if	Makedata
	fdate				=	newpred.first.game_date_time
	ldate				=	newpred.last.game_date_time
	ff.write("#{sport} -> #{lname}^ #{fdate.strftime("%B %d %Y ")} - #{ldate.strftime("%B %d %Y ")}\n")	if	Makedata
#	raise "Makedata #{Makedata}"
	week				=	0
	bet				=	4
	currentdate			=	nil
	weeklysummary			=	nil
	returnme			=	[]
	returnme			<<	header
	returnme			<<	'<table width="100%"><tr><td><!-- wrapping table --> ' # big table that wraps both games and weekly summary
	returnme			<<	'<table border="1">'
	trm				=	[]
	ysh,	wsh			=	hi()
	header				=	''
	theader				=	''
	gamecount			=	1
	gapcount			=	1
	bankroll			=	0.0
	utl				=	[]	#	unique team list
	utlid				=	[]	#	unique team list ids
	newpred.each{|g|
#		next if g.actual_home_score	<=	0	or g.actual_away_score	<=	0	or	g.game_total	==	0
		h	=	nil
		if isnhl
			h		=	HockeyBet.find_by_pred_id(g.id)
			raise "no hockey bet for #{g.id} " if h.nil?
		end
		next if (g.actual_home_score	<=	0	or g.actual_away_score	<=	0)	and	g.spread == 0 and g.moneyline_home == 0 && g.moneyline_away == 0
		unless utlid.include?(g.home_team_id)
			utl		<<	Team.find(g.home_team_id).name
			utlid		<<	g.home_team_id
		end
		winprob			=	0.65	if	mm	and g.game_date_time	>=	Time.local(2_009,3,20)
		currentdate		=	g.game_date_time	if	currentdate.nil?
		if (g.game_date_time	-	currentdate)	>	gap
			logger.warn("(g.game_date_time	-	currentdate) #{(g.game_date_time	-	currentdate)}")
			#	new week
#			raise
			week			+=	1
			#	render partial here if any data for it
			trma			=	nil
			trma,	bankroll	=	ms(wsh, ysh, week,	nil,	gaptitle,	gapcount)
			trm			<<	trma.dup
			gapcount		+=	1
			dummy,	wsh		=	hi()
		end
		currentdate			=	g.game_date_time
		# now build row of predictions,
		# date, home with moneyline, away with moneyline, spread, ou, spreadpick, ttspreadpick, oupick, ttoupick, moneyline both small and large bet
		# ysh,	wsh,	supick,	suright,	supush,	atsbet,	oubet,	atsbetright,	atsbetpush,	oubetright,	oubetpush
		ysh,	wsh,	supick,	suright,	supush,	atsbet,	oubet,	atsbetright,	atsbetpush,	oubetright,	oubetpush	=	calcatsbet(g,	ysh,	wsh,	winprob, h)
		# date	home	away		spread	ou	atspick	
		thisrow		=	''
		theader		+=	wrap('Game Date')	if	header.empty?
		thisrow		+=	wrap('Game # '+gamecount.commify+' '+g.game_date_time.strftime("%b.%d.%Y"))
		gamecount	+=	1
		# home team with  moneyline and su pick
		theader		+=	wrap('Home')		if	header.empty?
#		raise g.inspect
		thisrow		+=	wrap(nameconv(Team.find(g.home_team_id).name, 1)+" #{(g.moneyline_home == -110 && g.moneyline_away == -110) ?  "" : g.moneyline_home.commify}", (supick	==	g.home_team_id), suright, supush)
		# away team with  moneyline and su pick
		theader		+=	wrap('Away')		if	header.empty?
		thisrow		+=	wrap(nameconv(Team.find(g.away_team_id).name, 1)+" #{(g.moneyline_away == -110 && g.moneyline_home == -110) ?  "" : g.moneyline_away.commify}", (supick	==	g.away_team_id), suright, supush)
		# game score
		theader		+=	wrap('Game Score')	if	header.empty?
		thisrow		+=	wrap(g.actual_home_score.to_s+'-'+g.actual_away_score.to_s)
		hplprize	=	nil
		aplprize	=	nil
		if isnhl
			# do both pucklines and ou both odds
			theader	+=	wrap('Puck Line Home')	if	header.empty?
			unless	g.actual_home_score	==	-1
#				plevh	=	convml(h.plhodds)	*	h.plhprob
#				pleva	=	convml(h.plaodds)	*	h.plaprob
				if h.plhodds	==	0
					h.plhodds	=	-102	if	h.plaodds	>	0
					h.plhodds	=	102	if	h.plaodds	<	0
				end
				raise "h #{h.inspect}" if h.plhodds	==	0
				hwin,	hlose	=	getpplfml(h.plhodds)
				awin,	alose	=	getpplfml(h.plaodds)
				plevh		=	hwin	*	h.plhprob	+	(hlose	* (1.0 - h.plhprob))
				pleva		=	awin	*	h.plaprob	+	(alose	* (1.0 - h.plaprob))
				puts "plevh #{plevh} pleva #{pleva} hplprize #{hplprize} aplprize #{aplprize} g.actual_home_score #{g.actual_home_score} g.actual_away_score #{g.actual_away_score}"
			end
			hpw	=	nil
			hpl	=	nil
			apw	=	nil
			apl	=	nil
			if	plevh	<=	Plnhlevthreshold		||	g.actual_home_score	==	-1
				thisrow	+=	wrap("#{h.plhome}(#{h.plhodds})")
			else
				puts "********* playing home pl"
				hdiv		=	nil
				hdiv		=	Ydiv	if	g.actual_home_score	+	h.plhome	==	g.actual_away_score
				hdiv		=	Gdiv	if	g.actual_home_score	+	h.plhome	>	g.actual_away_score
				hdiv		=	Rdiv	if	g.actual_home_score	+	h.plhome	<	g.actual_away_score
				hplprize	=	0.0	if	g.actual_home_score	+	h.plhome	==	g.actual_away_score
				hplprize	=	hwin	if	g.actual_home_score	+	h.plhome	>	g.actual_away_score
				hplprize	=	hlose	if	g.actual_home_score	+	h.plhome	<	g.actual_away_score
				raise if hdiv.nil?
				begin
					thisrow	+=	wrap("#{hdiv}#{h.plhome}(#{h.plhodds})#{plevh.r3}</div>")
				rescue Exception => e
					raise "#{e} h.inspect #{h.inspect}"
				end
			end
			theader	+=	wrap('Puck Line Away')	if	header.empty?
			if	pleva	<=	Plnhlevthreshold	||	g.actual_home_score	==	-1
				thisrow	+=	wrap("#{h.plaway}(#{h.plaodds})")
			else
				puts "********* playing away pl"
				adiv		=	nil
				adiv		=	Ydiv	if	g.actual_away_score	+	h.plaway	==	g.actual_home_score
				adiv		=	Gdiv	if	g.actual_away_score	+	h.plaway	>	g.actual_home_score
				adiv		=	Rdiv	if	g.actual_away_score	+	h.plaway	<	g.actual_home_score
				aplprize	=	0.0	if	g.actual_away_score	+	h.plaway	==	g.actual_home_score
				aplprize	=	awin	if	g.actual_away_score	+	h.plaway	>	g.actual_home_score
				aplprize	=	alose	if	g.actual_away_score	+	h.plaway	<	g.actual_home_score
				raise if adiv.nil?
				begin
					thisrow	+=	wrap("#{adiv}#{h.plaway}(#{h.plaodds})#{pleva.r3}</div>")
				rescue Exception => e
					raise "#{e} h.inspect #{h.inspect}"
				end
			end
		else
			# spread
			theader	+=	wrap('Spread')	if	header.empty?
			thisrow	+=	wrap(g.spread)
			# ats pick
			theader	+=	wrap('Spread Pick')	if	header.empty?
			spick	=	'Wierd'
			spick	=	" - "+nameconv(Team.find(g.home_team_id).name, 1)+" - "+g.prob_home_win_ats.r2.to_s if g.prob_home_win_ats	>	0.5
			spick	=	" - "+nameconv(Team.find(g.away_team_id).name, 1)+" - "+g.prob_away_win_ats.r2.to_s if g.prob_away_win_ats	>	0.5
			wrapme	=	(!atsbet.nil? ? (atsbet == g.home_team_id ? nameconv(Team.find(g.home_team_id).name, 1) : nameconv(Team.find(g.away_team_id).name, 1))	:	NO) 
			wrapme	+=	spick if wrapme	== NO
			thisrow	+=	wrap(wrapme,	atsbet,	atsbetright,	atsbetpush)
			# ou
			theader	+=	wrap('OU Total')	if	header.empty?
			thisrow	+=	wrap(g.game_total)
			# ou result
			theader	+=	wrap('OU Pick')	if	header.empty?
			thisrow	+=	wrap(NO)	if	oubet.nil?
			# def	wrap(str, picked=nil, pickright=nil, pickpush=nil, ou=false)
			thisrow	+=	wrap((oubet	?	'Over'	:	'Under'),	true,	oubetright,	oubetpush)	unless	oubet.nil?
		end

		# moneyline
		typpe, mlo,	mlm,	mlats,	bbmlprz,	hhf,	ahf,	bh	=	mlhlpr(g, isnhl)
#		raise "typpe #{typpe}" if aplprize.nil?
#		raise "typpe #{typpe}" if hplprize.nil?
#		raise "isnhl 2 #{isnhl} h #{h.inspect}"
		unless	mlm		==	0
			begin
				wsh['mlp']	+=	mlm
			rescue Exception=>e
				raise "#{e} wsh['mlp'] #{wsh['mlp']} mlm #{mlm.inspect} typpe #{typpe}"
			end
			ysh['mlp']	+=	mlm
			wsh['mlbb']	+=	bbmlprz	unless	bbmlprz.nil?
			ysh['mlbb']	+=	bbmlprz	unless	bbmlprz.nil?
			wsh['mlw']	+=	mlm	>	0	?	1	:	0
			ysh['mlw']	+=	mlm	>	0	?	1	:	0
			wsh['mll']	+=	mlm	<	0	?	1	:	0
			ysh['mll']	+=	mlm	<	0	?	1	:	0
		end
		if isnhl
			raise "hplprize #{hplprize}" if hdiv == Ydiv && hplprize != 0.0
			raise "hplprize #{hplprize}" if hdiv == Rdiv && hplprize > 0.0
			raise "hplprize #{hplprize}" if hdiv == Gdiv && hplprize < 0.0
			unless hplprize.nil?
				puts "hplprize #{hplprize}"	unless hplprize == 0 # || hplprize == -1)
#				sleep 5				unless hplprize == 0 # || hplprize == -1)
				wsh['plhp']	+=	hplprize
				ysh['plhp']	+=	hplprize
				wsh['plhw']	+=	hplprize	>	0.0	?	1	:	0
				ysh['plhw']	+=	hplprize	>	0.0	?	1	:	0
				wsh['plhl']	+=	hplprize	<	0.0	?	1	:	0
				ysh['plhl']	+=	hplprize	<	0.0	?	1	:	0
			end
			begin
				raise "aplprize #{aplprize}" if adiv == Ydiv && aplprize != 0.0
				raise "aplprize #{aplprize}" if adiv == Rdiv && aplprize > 0.0
				raise "aplprize #{aplprize}" if adiv == Gdiv && aplprize < 0.0
			rescue Exception=>e
				raise "#{e} aplprize #{aplprize.inspect} hplprize #{hplprize.inspect} h #{h.inspect}"
			end
			unless aplprize.nil?
				puts "aplprize #{aplprize}"	unless aplprize == 0 # || aplprize == -1)
#				sleep 5				unless aplprize == 0 # || aplprize == -1)
				wsh['plap']	+=	aplprize
				ysh['plap']	+=	aplprize
				wsh['plaw']	+=	aplprize	>	0.0	?	1	:	0
				ysh['plaw']	+=	aplprize	>	0.0	?	1	:	0
				wsh['plal']	+=	aplprize	<	0.0	?	1	:	0
				ysh['plal']	+=	aplprize	<	0.0	?	1	:	0
			end
		end
		theader	+=	wrap('Moneyline')	if		header.empty?
		thisrow	+=	wrap(mlo)		if		bbmlprz.nil?	or mlo.include?('No Opinion')	# if	mlo.nil?
		thisrow	+=	wrap(mlo+" big bet >#{bbmlprz.commify}< Running total is #{ysh['mlbb'].commify}")		unless	(bbmlprz.nil? or mlo.include?('No Opinion'))	# if	mlo.nil?

		# end of row
		trm		<<	'<tr>'+thisrow+'</tr>'
		header		=	'<tr>'+theader+'</tr>'	if	header.empty?
	} # newpred
	returnme		<<	header
	trma			=	nil
	trma,	bankroll	=	ms(wsh, ysh, week, 'End of Year Stats', gaptitle,	0)
	trm			<<	trma.dup
	returnme		<<	trm.reverse
	returnme		<<	"</table>"
#	raise "returnme length is #{returnme.length} #{returnme.inspect}"
	rm			=	{}
	rm['rollwith']		=	returnme
	bankroll		=	bankroll.to_f
#	<%	rw			=	@main['rollwith']	%>
#	<%	@heading		=	@main['heading']	if@main.has_key?('heading')		-%>
#	<%	@content		=	@main['content']	-%>
#	<%	@desc		=	@main['desc']		%>
#	@main['heading']	=	"Joe Guy's Soccer Betting - #{lname} - Season #{pid+1} - #{fdate.strftime("%B %d %Y  ")} to #{ldate.strftime("%B %d %Y  ")} Starting bankroll $100 - Ending Bankroll $#{bankroll.r2.commify} - Bet is $#{bet}"
#	@main['desc']		=	"Joe Guy's Soccer Betting - #{lname} - Season #{pid+1} - #{fdate.strftime("%B %d %Y  ")} to #{ldate.strftime("%B %d %Y  ")} Starting bankroll $100 - Ending Bankroll $#{bankroll.r2.commify} - Bet is $#{bet}"
	rm['heading']		=	"Joe Guy's #{sport} Betting - #{lname} - #{year} - #{fdate.strftime("%B %d %Y  ")} to #{ldate.strftime("%B %d %Y  ")} Starting bankroll $1,000 - Ending Bankroll $#{bankroll.r2.commify} - Bet is $#{bet}"
	rm['content']		=	"soccer, football, betting, Joe Guy's #{sport} Betting - #{lname} - #{year} - #{fdate.strftime("%B %d %Y  ")} to #{ldate.strftime("%B %d %Y  ")} Starting bankroll $1,000 - Ending Bankroll $#{bankroll.r2.commify} - Bet is $#{bet} - spread, moneyline , money line - #{utl.sort.join(',')}"
	rm['desc']		=	"Joe Guy's #{sport} Betting - #{lname} - #{year} - #{fdate.strftime("%B %d %Y  ")} to #{ldate.strftime("%B %d %Y  ")} Starting bankroll $1,000 - Ending Bankroll $#{bankroll.r2.commify} - Bet is $#{bet} - spread, moneyline , money line - #{utl.sort.join(',')}"
	@main			=	rm.dup
end	#	do_season

def	wrap(str, picked=nil, pickright=nil, pickpush=nil, ou=false)
	#	if ou
	#		return "<td>#{str}</td>" if picked.nil? # no opinion in ou
	#		return "<td><div id='yellow'>#{str}</div></td>" if pickpush
	#		return "<td><div id='green'>#{str}</div></td>" if pickright
	#		return "<td><div id='red'>#{str}</div></td>" unless pickright
	#	else
	return "<td>#{str}</td>" if (picked.nil? or !picked)
	return "<td>#{Ydiv}#{str}</div></td>" if !picked.nil? && pickpush
	return "<td>#{Gdiv}#{str}</div></td>" if !picked.nil? && pickright
	return "<td>#{Rdiv}#{str}</div></td>" if !picked.nil? && !pickright
	#	end
	raise "str #{str} pick #{picked} pickright #{pickright} pickpush #{pickpush}"
end
=begin
=end

def	summarytime(pweek,	oldweek,	sumhash,	beta,	outstr,	bph,	prevweeksprofit,	forced	=	false)
	# check for summary time
	weekstotalprofits	=	0.0
	if	!(oldweek	==	pweek)	or forced
		puts "doing summary"
#		puts "sumhash.inspect #{sumhash.inspect}"
#		puts "beta.inspect #{beta.inspect}"
#		raise
		puts "oldweek #{oldweek} pweek #{pweek}"
		st		=	0.0
		wc		=	0
		beta.each{|b|
			begin
				wc	+=	sumhash['weekcount'+b]
				st	+=	sumhash['week'+b].r2
			rescue
			end
		}
		div		=	Gdiv	if	st	>	0
		div		=	Rdiv	if	st	<	0
		toutstr	=	Tr+"<td>#{div}Week #{oldweek} - #{wc.commify} bets Total -> $#{st.r2.commify} yyyyWeeks profit -> $xxxxxxxxxx</div></div></td>"
		oldweek	=	pweek
		oldleague	=	''
		beta.each{|b|
			begin
				profit	=	sumhash['week'+b]
				weekstotalprofits	+=	profit
				wc		=	sumhash['weekcount'+b]
				div		=	Gdiv	if	profit	>	0
				div		=	Rdiv	if	profit	<	0
				tstr		=	''
#				puts b
#				sleep	1
				unless	oldleague	==	b[0,	2]
					nl		=	b[0,	2]
#					puts "nl #{nl}"
					tstr		=	"Total Profit from #{Bookienamehash[nl]} -> $#{bph[nl].r2.commify}"	if	bph[nl]	>	0.0
					tstr		=	Rdiv+"Total Loss from #{Bookienamehash[nl]} -> $#{bph[nl].r2.commify}</div>"	if	bph[nl]	<	0.0
					oldleague	=	nl
				end
				toutstr	+=	wrap(div	+	tstr + wc.commify+' '+b+' '+(wc > 1 ? ' bets -> $' : ' bet -> $' )+	profit.r2.commify	+	'</div>')
				profit	=	nil
			rescue
				toutstr	+=	Na
			end
		}
		toutstr			+=	Tre # table row end
		twp				=	weekstotalprofits	-	prevweeksprofit
		toutstr.gsub!('xxxxxxxxxx',	twp.r2.commify)
		toutstr.gsub!('yyyy',	Gdiv)	if	twp	>	0.0
		toutstr.gsub!('yyyy',	Rdiv)	if	twp	<	0.0
		toutstr.gsub!('yyyy',	Ydiv)	if	twp	==	0.0
		outstr	<<	toutstr.dup
		return weekstotalprofits,	sumhash,	outstr,	oldweek
	else
		#	not done
		return prevweeksprofit,	sumhash,	outstr,	oldweek
	end
end	#	summarytime

def	maintsh(sumhash, bookie,	prize)
	begin
		sumhash['year'+bookie]		+=	prize
		sumhash['yearcount'+bookie]	+=	1
	rescue
		sumhash['year'+bookie]		=	prize	
		sumhash['yearcount'+bookie]	=	1
	end
	begin
		sumhash['week'+bookie]			+=	prize
		sumhash['weekcount'+bookie]	+=	1
	rescue
		sumhash['week'+bookie]			=	prize
		sumhash['weekcount'+bookie]	=	1
	end
	return sumhash
end	#maintsh

def	makeswp(lid,	pid,	bet	=	45.0)
#	makedat		=	(ENV['RAILS_ENV']	==	'development')
	ff			=	File.open('graphdata.txt','a')	if	Makedata
	puts "in makeswp with #{lid} and #{pid}"		if	Makedata
	bth			=	{}
	Betarray.each_with_index{|s,	bai|
		bth[s]	=	Betnames[bai]
	}
	puts params
#	raise
#	lid		=	params['league']
#	pid		=	params['id'].to_i
	begin
		sid	=	League.find_by_short_league(lid).id
	rescue
		raise "lid #{lid} pid #{pid}"
	end
	lname	=	League.find_by_short_league(lid).name
	preds	=	nil
	preds	=	Prediction.find_all_by_league(sid)
	raise "no predictions for league >#{sid}< params #{params.inspect} lname #{lname} preds #{preds.inspect}"	if	preds.nil?
	pred		=	[]
	bph		=	{}
	puts 'filtering data for season'
	preds.each{|p|
		pred	<<	p	if	p.season	==	pid	&&	!p.soccer_bet.nil?
	}
	raise "season #{pid} league id #{sid} pred length #{pred.length} preds length #{preds.length}"	if	pred.empty?
#	sleep 5
	puts 'building team name hash, list of played bets and soccer hash'
	beta		=	[]
#	nc	=	0
	sbh		=	{}
	th		=	{}
	pred.each{|p|
#		nc	+=	1	if p.soccer_bet.nil?
		th[p.home_team_id]		=	Team.find(p.home_team_id).name	unless	th.has_key?(p.home_team_id)
		th[p.away_team_id]		=	Team.find(p.away_team_id).name	unless	th.has_key?(p.away_team_id)
		next if p.soccer_bet.nil?
#		puts p.soccer_bet
		s					=	SoccerBet.find(p.soccer_bet)	#	look in soccer bet db and find by id
#		raise s.inspect
		sbh[p.soccer_bet]		=	[s,	p.prob_home_win_su,	p.prob_away_win_su,	p.prob_push_su]	# this is the entire record, with all available bets included
		raise if s.nil?
#		puts s.inspect
#		puts s.to_a.inspect
		Betarray.each{|k,	v|	#	build array of unique bets that this particular league and season have
#			puts b
			beta	<<	k	if	!s[k].nil?	&&	!beta.include?(k)
		}
	}
#	puts nc	if	nc	>	0
#	sleep 10	if	nc	>	0
	puts beta.inspect
#	raise
	# now that we have a list of all used bets - create table for them
	bankroll	=	1_000.0
	bet		=	bankroll	*	Fpc
	fdate	=	pred[0].game_date_time
	ldate		=	pred.last.game_date_time
	ff.write("#{lid}#{pid} -> #{lname}^ #{fdate.strftime("%B %d %Y ")} - #{ldate.strftime("%B %d %Y ")}\n")	if	Makedata
	outerstr	=	"<h2>#{lname} - Season #{pid} - #{fdate.strftime("%B %d %Y  ")} to #{ldate.strftime("%B %d %Y  ")}</h2> Starting bankroll $#{bankroll.commify} - Bet is $#{bet}<br>"
#	outerstr	+=	'<img src="'+"images/#{lid}#{pid}.png"+'" <P ALIGN="CENTER">'
	outerstr	+=	'<table border="1"><th>'
	outstr	=	[]
	thisrow	=	''
	beta.each{|b|
		thisrow	+=	wrap(bth[b])
	}
	thisrow		+=	'</th><br>'
	plen			=	pred.length.commify
	sumhash		=	{}
	dobigbet		=	-1
	oldweek		=	pred.first.week
	sumofprevweeksprofit	=	0.0
	eva			=	[]
	pred.each_with_index{|p,	pi|
		puts "sending sumofprevweeksprofit #{sumofprevweeksprofit}"
		sumofprevweeksprofit,	sumhash,	thisrow,	oldweek	=	summarytime(p.week,	oldweek,	sumhash,	beta,	thisrow,	bph,	sumofprevweeksprofit)
		puts "sumofprevweeksprofit #{sumofprevweeksprofit}"
#		sleep 1
		puts
		puts "done #{pi.commify} of #{plen}"
		puts 'building bets'
		abotg		=	0.0	# amount bet on this game is zero - must bet max 4 % on any one game 
		s,ph,pw,pd	=	sbh[p.soccer_bet] # SoccerBet.find(p.soccer_bet)
		ht			=	th[p.home_team_id]
		awt			=	th[p.away_team_id]
		tmpstr		=	''
		begin
			thisrow	+=	'zzzzzzzzzzzzzzzzz' 	# for replacement later
			tmpstr	=	Tr+wrap("aaaaaaaaaaaaGame #{(pi+1).commify} - "+p.game_date_time.strftime("%B %d %Y  ")+' - '+ht+' '+p.actual_home_score.to_s+' - '+awt+' '+p.actual_away_score.to_s+' -> won $bbbbbbbbbbb' + (bet == 4 ? '' : " Bet is $#{bet.r2}"))
		rescue
			raise "thisrow #{thisrow.inspect}"
		end
		unless	dobigbet	==	oldweek
			dobigbet		=	oldweek
			eva			=	getthisweeksbets(pred,	oldweek,	sbh,	beta)
			eva.sort!{|a,	b|	b[2]<=>a[2]}	#now has all this weeks bets
		end
#		raise eva.inspect
#		sleep 10
		eva2		=	[]

		bet		=	45.0
		bet.freeze
#		bet		=	[bet,	bankroll].min
		bet		=	(bankroll	*	Fpc).to_i
		bet		=	45.0	if	bet	<	45.0
		bet		=	100	if	bet	>	100

		eva.each{|e|	#	now do from best down
			b	=	e[0]
			begin
#				if (s[b+'_ev']	>	1.0) && (abotg == 0 || ((abotg + bet) <= (bankroll * 0.04))) # never bet more than 4 % of bankroll on any one game but always make at least one bet if ev > 1.0
				if (e[2]	>=	2.0) && (abotg == 0 || ((abotg + bet)	<=	(bankroll	*	Fpc))) # never bet more than 4 % of bankroll on any one game but always make at least one bet if ev > 1.0
#				if (abotg == 0 || ((abotg + bet)	<=	(bankroll	*	Fpc))) # never bet more than 4 % of bankroll on any one game but always make at least one bet if ev > 1.0
					eva2		<<	e[0]
					# raise	#	if bankroll	<	bet
					abotg	+=	[bet,	bankroll].min
				else
					break
				end
			rescue
#				raise "b #{b} s.inspect #{s.inspect}"
			end
		}
#		puts
#		puts "eva.inspect #{eva.inspect}"
#		puts
#		puts "eva2.inspect #{eva2.inspect}"
#		puts
#		puts "beta.inspect #{beta.inspect}"
#		raise
		puts 'playing bets'
		gt				=	0.0	#	game total
		oc				=	[]	#	odds count for computation of margin
		beta.each{|b|
			if	s[b].nil?
				thisrow	+=	wrap('')		# spacer
			else
				odiv		=	nil
				margin	=	-1
				margintext	=	''
				oc	<<	s[b]
				if	oc.length	==	3
					# calc margin here
					margin	=	oc.inject(0.0){|margin,	o|	margin	+	1 / o}
					margin	=	((margin	-	1.0)	*	100.0).r2
					oc		=	[]
					margintext	=	" Margin is % #{margin}"
				end
				if	eva2.include?(b)
#				if (s[b+'_ev']	>	1.0) && (abotg == 0 || ((abotg + bet) <= (bankroll * 0.04))) # never bet more than 4 % of bankroll on any one game but always make at least one bet if ev > 1.0
					# bet on this game - how did we do?
					# raise		if bankroll	<	bet
					abotg	+=	[bet,	bankroll].min
					gres		=	0		if	p.actual_home_score	>	p.actual_away_score
					gres		=	1		if	p.actual_home_score	<	p.actual_away_score
					gres		=	2		if	p.actual_home_score	==	p.actual_away_score
					betdraw	=	false
					bethome	=	nil
					bookie	=	b
					odds		=	s[b]
					bl		=	bookie.last
					bethome	=	true		if	bl	==	'H'
					bethome	=	false	if	bl	==	'A'
					betdraw	=	true		if	bl	==	'D'
					if (!betdraw	&&	bethome.nil?)
						# maybe > < 2.5 bet
						raise "bookie #{bookie}" if !bookie.include?('>')	&&	!bookie.include?('<')
						gt25		=	((homescore+awayscore)	>	Tpf)
						prize		=	0.0
						if	(gt25	&&	bookie.include?('>'))	||	(gt25	&&	bookie.include?('<'))
							odiv		=	Gdiv
							prize		=	[bet,	bankroll].min	*	(odds	-	1.0)
#							prize		=	[bet,	bankroll].min	*	odds# (odds	-	1.0)
							sumhash	=	maintsh(sumhash,	bookie,	prize)
						else
							prize		=	-[bet,	bankroll].min
							odiv		=	Rdiv
							sumhash	=	maintsh(sumhash,	bookie,	-bet)
						end
					else
						if	(gres	==	0	&&	bethome &&	!betdraw)	||	(gres	==	1	&&	!bethome &&	!betdraw)	||	(gres	==	2	&&	betdraw)
							odiv		=	Gdiv
							prize		=	[bet,	bankroll].min	*	(odds	-	1.0)
#							prize		=	[bet,	bankroll].min	*	odds# (odds	-	1.0)
							sumhash	=	maintsh(sumhash,	bookie,	prize)
						else
							prize		=	-[bet,	bankroll].min
							odiv		=	Rdiv
							sumhash	=	maintsh(sumhash,	bookie,	-bet)
						end
					end
					bankroll	+=	prize
					gt		+=	prize
					ff.write("#{lid}#{pid} -> #{prize}\n")	if	Makedata
					begin
						bph[bookie[0,2]]	+=	prize
					rescue
						bph[bookie[0,2]]	=	prize
					end
					thisrow	+=	wrap(odiv+s[b].to_s+' -> '+s[b+'_ev'].to_s+"<br> -> $#{bankroll.r2.commify}"+margintext+'</div>')
				else
					thisrow	+=	wrap(s[b].to_s+' -> '+s[b+'_ev'].to_s+"<br> -> $#{bankroll.r2.commify}"+margintext)
				end
			end
		}	#	next bet
		thisrow			+=	'</tr>'
		# now to process the game total
		tmpstr.gsub!('aaaaaaaaaaaa',	Gdiv)	if	gt	>	0.0
		tmpstr.gsub!('aaaaaaaaaaaa',	Rdiv)	if	gt	<	0.0
		tmpstr.gsub!('aaaaaaaaaaaa',	Ydiv)	if	gt	==	0.0
		thisrow.gsub!('zzzzzzzzzzzzzzzzz',	tmpstr)
		thisrow.gsub!('bbbbbbbbbbb',	gt.r2.commify)
		outstr	<<	thisrow.dup
		thisrow	=	''
	}	#	next prediction
	if	Makedata
		ff.close
		puts "leaving makeswp"
		puts
		return
	end
#	raise	"bph.inspect #{bph.inspect}"
	puts "sending sumofprevweeksprofit #{sumofprevweeksprofit}"
	sumofprevweeksprofit,	sumhash,	outstr,	oldweek	=	summarytime(oldweek+1,	oldweek,	sumhash,	beta,	outstr, bph,	sumofprevweeksprofit,	true)
	puts "sumofprevweeksprofit 2 #{sumofprevweeksprofit}"
#	sleep 1
	yt			=	0.0
	yc			=	0
	beta.each{|b|
		begin
			yt	+=	sumhash['year'+b]
		rescue
#			raise "b is #{b}"
		end
		begin
			yc	+=	sumhash['yearcount'+b]
		rescue
#			raise "b is #{b}"
		end
	}
	toutstr			=	Tr+"<td>Season Total - #{yc.commify} bets -> $#{yt.r2.commify} </td>"
	beta.each{|b|
		begin
			div	=	Gdiv	if	sumhash['year'+b]	>	0
			div	=	Rdiv	if	sumhash['year'+b]	<	0
			toutstr	+=	wrap(div	+	sumhash['yearcount'+b].commify	+	((sumhash['yearcount'+b] > 1) ? ' bets -> $' : ' bet -> $' )	+	sumhash['year'+b].r2.commify	+	'</div>')
		rescue
			toutstr	+=	Na
		end
	}
	toutstr			+=	Tre
	outstr			<<	toutstr
	retstr			=	outerstr	+	outstr.reverse.join	+	'</table>'
	@main			=	{}
	@main['image']	=	"images/#{lid}#{pid}.png"
	@main['image']	+=	'" alt="gggggggggggg"'
	@main['pad']		=	false
	@main['bankroll']	=	bankroll
	@main['heading']	=	"Joe Guy's Soccer Betting - #{lname} - Season #{pid+1} - #{fdate.strftime("%B %d %Y  ")} to #{ldate.strftime("%B %d %Y  ")} Starting bankroll $1,000 - Ending Bankroll $#{bankroll.r2.commify} - Bet is $#{bet}"
	@main['image'].gsub!('gggggggggggg',	@main['heading'])
	@main['desc']		=	"Joe Guy's Soccer Betting - #{lname} - Season #{pid+1} - #{fdate.strftime("%B %d %Y  ")} to #{ldate.strftime("%B %d %Y  ")} Starting bankroll $1,000 - Ending Bankroll $#{bankroll.r2.commify} - Bet is $#{bet}"
	uta				=	[]
	th.each{|k,	v|
		uta			<<	v
	}
	bma				=	[]
	beta.each{|b|
		bma			<<	bth[b]
	}
	@main['content']	=	"#{lname} Betting starting bankroll $1,000 - Ending Bankroll $#{bankroll.r2.commify} - Bet is $#{bet} - #{uta.sort.join(',')} - #{bma.sort.join(',')}"
	@main['rollwith']	=	retstr
#	return @main
  end	#	makeswp
end	#	class ApplicationController

class Object
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

def getpplfml(ml)
	ml	=	102	if	ml == 100
	ml	=	-102	if	ml == -100
	raise if ml	==	100	or	ml	==	-100
	if ml	<	100	&&	ml	>	-100
		# already decimal value
		tml	=	ml
		raise "ml #{ml}" if ml < 1.0
		tml	=	ml - 1.0	# if ml > 1.0
		return [tml,	-1]
	else
		if	ml	<	-100
			return	[-100.0 / ml,	-1]
		else
			return [(ml / 100.0) -1.0, -1]
		end
	end
end
end

