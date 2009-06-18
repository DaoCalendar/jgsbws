# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
Makedata			=	false	# make data file for images
Oldway			=	false	# try new moneyline way
Pasttime			=	Time.local(1_962,1,1)
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

Bookienamehash	= {}
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
	def	mlhlpr(p,	h)
		# process moneyline
		return ["No Moneyline", 0.0, nil, 0.0, 0.0, 0.0, false] if p.moneyline_home == -110 and p.moneyline_away == -110 or (p.moneyline_home == 0 or p.moneyline_away == 0)
		pickhome	=	nil
		pickaway	=	nil
		mlats	=	nil
		if Oldway
			hml = nil
			hml = p.moneyline_home/100.0 if p.moneyline_home > 0
			hml = -100.0/p.moneyline_home if p.moneyline_home < 0
			raise "hml problem p is #{p.inspect}" if hml.nil?
			aml = nil
			aml = p.moneyline_away/100.0 if p.moneyline_away > 0
			aml = -100.0/p.moneyline_away if p.moneyline_away < 0
			# raise "aml problem" if aml.nil?
			aml = 0.0 if aml.nil?
			homepo   = p.prob_home_win_su # *hml
			awaypo    = p.prob_away_win_su # *aml
			raise "homepo is nil" if homepo.nil?
			raise "awaypo is nil" if awaypo.nil?
#			return ["#{Ydiv}No Opinion </div>", 0.0]  if homepo<1.0 and awaypo<1.0
			pickhome = (homepo > awaypo) unless p.league == 5
			pickaway = (awaypo > homepo) unless p.league == 5
			pickhome = (homepo > 0.92) # if p.league > 3
			pickaway = (awaypo > 0.92) # if p.league > 3
			pickhome = (homepo > 0.85) if p.league  == 2
			pickaway = (awaypo > 0.85)  if p.league == 2
#			return ["#{Ydiv}No Opinion </div>", 0.0]  if (pickhome and hml<1.0) or (pickaway and aml<1.0)
			raise "???" if pickhome.nil? or pickaway.nil?
			hlose	 = nil
			alose		 = nil
			hbbmlwin	 = nil
			hbbmllose = nil
			abbmlwin  = nil
			abbmllose  = nil
			if p.moneyline_home > 0
				hbbmlwin = p.moneyline_home
				hbbmllose = -100.0
				hwinprize = p.moneyline_home / 100.0
				hlose         = -1
			else
				hbbmlwin = 100.0
				hbbmllose = p.moneyline_home
				hwinprize = -100.0/p.moneyline_home #+1.0
				hlose         = -1
			end
			if p.moneyline_away > 0
				abbmlwin = p.moneyline_away
				abbmllose = -100.0
				awinprize = p.moneyline_away / 100.0
				alose         = -1
			else
				abbmlwin = 100.0
				abbmllose = p.moneyline_away
				awinprize = -100.00/p.moneyline_away #+1.0
				alose         = -1
			end
			# experimental hedge factor
			#		hhf = p.prob_home_win_ats * (awinprize-1.0) / (awinprize*())
			hhf = 1.0
			#		ahf = 1.0 - hhf
			
			#		hhf = p.prob_home_win_ats * ()
			hhf = (1.0-2.0*p.prob_away_win_su) / (p.prob_away_win_su*(awinprize-1)+31.0/11.0*p.prob_home_win_su)
			ahf = (1.0-2.0*p.prob_home_win_su) / (p.prob_home_win_su*(hwinprize-1)+31.0/11.0*p.prob_away_win_su)
			# ahf = 1.0 / hhf
			puts "hhf #{hhf} ahf #{ahf} "
			bh = nil
			if hhf >= 0.0 and hhf <= 1.0
				ahf = 1.0-hhf
				bh = true
			else
				hhf = 1.0-ahf
				bh = false
			end
			puts " after hhf #{hhf} ahf #{ahf} "
			raise "hlose is nil " if hlose.nil?
			raise "alose is nil" if alose.nil?
			raise "hbbmlwin is nil" if hbbmlwin.nil?
			raise "hbbmllose is nil" if hbbmllose.nil?
			raise "abbmlwin is nil" if abbmlwin.nil?
			raise "abbmllose is nil" if abbmllose.nil?
		else
		# new way
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
		hodds			=			p.moneyline_home/100.0 if p.moneyline_home > 0
		hodds			=	1	+	-100.0/p.moneyline_home if p.moneyline_home < 0
		aodds			=			p.moneyline_away/100.0 if p.moneyline_away > 0
		aodds			=	1	+	-100.0/p.moneyline_away if p.moneyline_away < 0
#		hev			=	(hodds-0.0)	*	p.prob_home_win_su
#		aev			=	(aodds-0.0)	*	p.prob_away_win_su
		hev			=	hwinprize	*	p.prob_home_win_su	+	(hlose	*	(1.0-p.prob_home_win_su))
		aev			=	awinprize	*	p.prob_away_win_su	+	(alose	*	(1.0-p.prob_away_win_su))
		puts "hev #{hev} hodds #{hodds} p.prob_home_win_su #{p.prob_home_win_su}"
		puts "aev #{aev} aodds #{aodds} p.prob_away_win_su #{p.prob_away_win_su}"
#		sleep 1
		pickhome		=	(hev	>	0.3)
		pickaway		=	(aev	>	0.3)
#		raise "hodds #{hodds}"
	end
	mlats = ((pickhome and p.spread > 0.0) ? p.home_team_id : ((pickaway and p.spread < 0.0) ? p.away_team_id : nil))	unless	isnhl
	mlats = p.home_team_id													if	isnhl
#	puts "mlats.inspect #{mlats.inspect}"
#	raise "mlats is zero #{p.inspect}" if mlats == 0
	return ["#{Ydiv}No Opinion </div>", 0.0, nil, 0.0, 0.0, 0.0, false]  if pickhome == false and pickaway == false
	return ["#{Gdiv} #{nameconv(Team.find(p.home_team_id).name, p.league)}  ->  #{(hwinprize).to_s[0,6]}</div>", hwinprize, mlats, hbbmlwin, hhf, ahf, bh] if pickhome and p.actual_home_score > p.actual_away_score
	return ["#{Rdiv} #{nameconv(Team.find(p.home_team_id).name, p.league)}  ->  #{hlose.to_s[0,6]}</div>", hlose, mlats, hbbmllose, hhf, ahf, bh] if pickhome and p.actual_home_score < p.actual_away_score
	return ["#{Ydiv} #{nameconv(Team.find(p.home_team_id).name, p.league)}  ->  0.0</div>", 0.0, mlats, 0.0, 0.0, 0.0, false] if pickhome and p.actual_home_score == p.actual_away_score
	return ["#{Gdiv} #{nameconv(Team.find(p.away_team_id).name, p.league)}  ->  #{(awinprize).to_s[0,6]}</div>", awinprize, mlats, abbmlwin, hhf, ahf, bh] if pickaway and p.actual_away_score > p.actual_home_score
	return ["#{Rdiv} #{nameconv(Team.find(p.away_team_id).name, p.league)}  ->  #{alose.to_s[0,6]}</div>", alose, mlats, abbmllose, hhf, ahf, bh] if pickaway and p.actual_away_score < p.actual_home_score
	return ["#{Ydiv} #{nameconv(Team.find(p.away_team_id).name, p.league)}  ->  0.0</div>", 0.0, mlats, 0.0, 0.0, 0.0, false] if pickaway and p.actual_away_score == p.actual_home_score
	raise "why am i here"
end

def	hi
	ysh				=	{}
	wsh				=	{}
	ysh['hd']			=	[0,	0]
	wsh['hd']			=	[0,	0]
	ysh['hf']			=	[0,	0]
	wsh['hf']			=	[0,	0]
	ysh['ad']			=	[0,	0]
	wsh['ad']			=	[0,	0]
	ysh['af']			=	[0,	0]
	wsh['af']			=	[0,	0]
	ysh['suright']		=	0
	wsh['suright']		=	0
	ysh['supush']		=	0
	wsh['supush']		=	0
	ysh['su']			=	0
	wsh['su']			=	0
	ysh['atsright']		=	0
	wsh['atsright']		=	0
	ysh['atsbetpush']	=	0
	wsh['atsbetpush']	=	0
	ysh['ats']			=	0
	wsh['ats']			=	0
	ysh['ouright']		=	0
	wsh['ouright']		=	0
	ysh['ou']			=	0
	wsh['ou']			=	0
	wsh['mlp']		=	0
	ysh['mlp']			=	0
	wsh['mlbb']		=	0
	ysh['mlbb']		=	0
	wsh['mlw']		=	0
	ysh['mlw']		=	0
	wsh['mll']			=	0
	ysh['mll']			=	0
	return ysh,	wsh
end
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
		wpcw		=	0.0	if	wpcw.nan?
		ypcw		=	(100.0 * ysuw / ysut).r2
		ypcw		=	0.0	if	ypcw.nan?

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

		wmlp	=	wsh['mlp'].r2
		wmldiv	=	Gdiv	if	wmlp	>	0
		wmldiv	=	Rdiv	if	wmlp	<	0
		wmldiv	=	Ydiv	if	wmlp	==	0
		ymlp		=	ysh['mlp'].r2
		ymldiv	=	Gdiv	if	ymlp	>	0
		ymldiv	=	Rdiv	if	ymlp	<	0
		ymldiv	=	Ydiv	if	ymlp	==	0
		wmlw	=	wsh['mlw']
		ymlw	=	ysh['mlw']
		wmll		=	wsh['mll']
		ymll		=	ysh['mll']

		# week
		ta	<<	"<td>#{wsudiv}SU wins -> #{wsuw} loses -> #{wsul} % win is #{wpcw}</div></td>"
		ta	<<	"<td>#{watsdiv}ATS wins -> #{watsw} loses -> #{watsl} % win is #{(100.0 * watsw / (watst == 0 ? 1 : watst)).r2} profit is #{(watsw - 1.1 * watsl).r2.commify}</div></td>"
		ta	<<	"<td>#{woudiv}OU wins -> #{wouright} loses -> #{woul} % win is #{(100.0 * wouright / (wout == 0 ? 1 : wout)).r2} profit is #{(wouright - 1.1 * woul).r2.commify}</div></td>"
		ta	<<	"<td>#{wmldiv}Money Line wins -> #{wmlw} loses -> #{wmll.commify} % win is #{(100.0 * wmlw / ((wmlw + wmll) == 0 ? 1 : wmlw + wmll)).r2} profit is #{wmlp.r2.commify}</div></td>"

		# year
		ta	<<	"<td>#{ysudiv}Year #{week} SU wins -> #{ysuw} loses -> #{ysul} % win is #{ypcw}</div></td>"
		ta	<<	"<td>#{yatsdiv}ATS wins -> #{yatsw} loses -> #{yatsl} % win is #{(100.0 * yatsw / (yatst == 0 ? 1 : yatst)).r2} profit is #{(yatsw - 1.1 * yatsl).r2.commify}</div></td>"
		summ	+=	yatsw - 1.1 * yatsl
		ta	<<	"<td>#{youdiv}OU wins -> #{youright} loses -> #{youl} % win is #{(100.0 * youright / (yout == 0 ? 1 : yout)).r2} profit is #{(youright - 1.1 * youl).r2.commify}</div></td>"
		summ	+=	youright - 1.1 * youl
		ta	<<	"<td>#{ymldiv}Money Line wins -> #{ymlw} loses -> #{ymll.commify} % win is #{(100.0 * ymlw / ((ymlw+ymll) == 0 ? 1 : (ymlw+ymll))).r2} profit is #{ymlp.r2.commify}</div></td>"
		summ	+=	ymlp
#		ta	<<	'</table></tr>' # turn off this table
#		ta	<<	'<tr><table border="1">' # restart old table
		ta	<<	'</tr>'
		# now new home dog etc stats
		outstr	=	"<tr><td>Home and Away Dog and Favorite Stats</td>"
		p		=	(wsh['hd'][0]-wsh['hd'][1]*1.1).r2
		sd		=	p	>	0.0	?	Gdiv : (p	==	0.0	?	Ydiv : Rdiv)
		outstr	+=	"<td>#{sd}Weekly Home Dog Stats - #{wsh['hd'][0].commify} wins #{wsh['hd'][1].commify} loses - Profit is #{p.commify}</div></td>"
		p		=	(wsh['ad'][0]-wsh['ad'][1]*1.1).r2
		sd		=	p	>	0.0	?	Gdiv : (p	==	0.0	?	Ydiv : Rdiv)
		outstr	+=	"<td>#{sd}Weekly Road Dog Stats - #{wsh['ad'][0].commify} wins #{wsh['ad'][1].commify} loses - Profit is #{p.commify}</div></td>"
		p		=	(wsh['hf'][0]-wsh['hf'][1]*1.1).r2
		sd		=	p	>	0.0	?	Gdiv : (p	==	0.0	?	Ydiv : Rdiv)
		outstr	+=	"<td>#{sd}Weekly Home Fav Stats - #{wsh['hf'][0].commify} wins #{wsh['hf'][1].commify} loses - Profit is #{p.commify}</div></td>"
		p		=	(wsh['af'][0]-wsh['af'][1]*1.1).r2
		sd		=	p	>	0.0	?	Gdiv : (p	==	0.0	?	Ydiv : Rdiv)
		outstr	+=	"<td>#{sd}Weekly Road Fav Stats - #{wsh['af'][0].commify} wins #{wsh['af'][1].commify} loses - Profit is #{p.commify}</div></td>"
		p		=	(ysh['hd'][0]-ysh['hd'][1]*1.1).r2
		sd		=	p	>	0.0	?	Gdiv : (p	==	0.0	?	Ydiv : Rdiv)
		outstr	+=	"<td>#{sd}Yearly Home Dog Stats - #{ysh['hd'][0].commify} wins #{ysh['hd'][1].commify} loses - Profit is #{p.commify}</div></td>"
		p		=	(ysh['ad'][0]-ysh['ad'][1]*1.1).r2
		sd		=	p	>	0.0	?	Gdiv : (p	==	0.0	?	Ydiv : Rdiv)
		outstr	+=	"<td>#{sd}Yearly Road Dog Stats - #{ysh['ad'][0].commify} wins #{ysh['ad'][1].commify} loses - Profit is #{p.commify}</div></td>"
		p		=	(ysh['hf'][0]-ysh['hf'][1]*1.1).r2
		sd		=	p	>	0.0	?	Gdiv : (p	==	0.0	?	Ydiv : Rdiv)
		outstr	+=	"<td>#{sd}Yearly Home Fav Stats - #{ysh['hf'][0].commify} wins #{ysh['hf'][1].commify} loses - Profit is #{p.commify}</div></td>"
		p		=	(ysh['af'][0]-ysh['af'][1]*1.1).r2
		sd		=	p	>	0.0	?	Gdiv : (p	==	0.0	?	Ydiv : Rdiv)
		outstr	+=	"<td>#{sd}Yearly Road Fav Stats - #{ysh['af'][0].commify} wins #{ysh['af'][1].commify} loses - Profit is #{p.commify}</div></td>"
		outstr	+=	"</tr>"
#		raise "summ #{summ} outstr #{outstr.inspect}"
		ta	<<	outstr
		return [ta,	summ]
	end

	def	nameconv(name, league)
		case '*'+name+'*'
		when '*air force*'
			return 'Air Force Falcons'
		when 'alabama'
			return 'Alabama Crimson Tide'
		when '*akron*'
			return 'Akron Zips'
		when '*arizona state*'
			return 'Arizona State Sun Devils'
		when '*arizona u*'
			return 'Arizona Wildcats'
		when '*arkansas state*'
			return 'arkansas State  Indians'
		when '*arkansas*'
			return "Arkansas Razorback Hogs"
		when '*army*'
			return 'Army  Black Knights'
		when '*auburn*'
			return 'Auburn Tigers'
		when '*ball state*'
			return 'Ball State Cardinals'
		when '*baylor*'
			return "Baylor Bears"
		when '*boise state*'
			return 'Boise State Broncos'
		when '*boston college*'
			return 'Boston College Eagles'
		when '*bowling green*'
			return 'Bowling Green Falcons'
		when '*buffalo*'
			return 'Buffalo Bills'
		when '*byu*'
			return 'BYU Cougars'
		when '*california*'
			return 'California Golden Bears'
      		when '*central florida*'
			return 'Central Florida Golden Knights'
		when '*central michigan*'
			return 'Central Michigan Chippewas'
		when '*cincinnati u*'
			return 'Cincinnati Bearcats'
		when '*clemson*'
			return 'Clemson Tigers'
		when '*colorado state*'
			return 'Colorado State Rams'
		when '*colorado*'
			return 'Colorado Buffaloes'
		when '*depaul*'
			return 'DePaul Blue Demons'
		when '*duke*'
			return 'Duke Blue Devils'
		when '*east carolina*'
			return 'East Carolina Pirates'
		when '*eastern michigan*'
			return 'Eastern Michigan Eagles'
		when '*florida atlantic*'
			return 'Florida Atlantic Owls'
		when '*florida international*'
			return 'Florida International Golden Panthers'
		when '*florida state*'
			return 'Florida State Seminoles'
		when '*florida*'
			return "Florida Gators #{(league == 4 ? 'with Tim Tebow' : '')} "
		when '*fresno state*'
			return 'Fresno State Bulldogs'
		when '*georgetown*'
			return 'Georgetown Hoyas'
		when '*georgia tech*'
			return 'Georgia Tech Yellow Jackets'
		when '*georgia*'
			return 'Georgia Bulldogs'
		when '*hawaii*'
			return "Hawaii Warriors"
		when '*houston u*'
			return 'Houston Cougars'
		when '*idaho*'
			return 'Idaho Vandals'
		when '*illinois fighting*'
			return 'Illinois Fighting Illini'
		when '*indiana*'
			return 'Indiana Hoosiers'
		when '*iowa*'
			return 'Iowa Hawkeyes'
		when '*iowa state*'
			return 'Iowa State Cyclones'
		when '*kansas state*'
			return 'Kansas State Wildcats'
		when '*kansas*'
			return 'Kansas Jayhawks'
		when '*kent state*'
			return 'Kent State Golden Flashes'
		when '*kentucky*'
			return 'Kentucky Wildcats'
		when '*louisiana tech*'
			return 'Louisiana Tech Bulldogs'
		when '*louisville*'
			return 'Louisville Cardinals'
		when '*lsu*'
			return 'LSU Tigers'
		when '*marquette*'
			return 'Marquette Golden Eagles'
		when '*marshall*'
			return 'Marshall Thundering Herd'
		when '*maryland*'
			return 'Maryland Terrapin'
		when '*memphis*'
			return 'Memphis Tigers'
		when '*miami*'
			return 'Miami Hurricanes'
		when '*miami ohio*'       
			return 'Miami Red Hawks'
		when '*michigan state*'
			return 'Michigan State Spartans'
		when '*michigan*'
			return 'Michigan Wolverines'
		when '*middle tennessee state*'
			return 'Middle Tennessee State Blue Raiders'
		when '*minnesota golden*'
			return 'Minnesota Golden Gophers'
		when '*mississipi*'
			return 'Ole Miss Rebels'
		when '*mississippi state*'
			return 'Mississippi State Bulldogs'
		when '*missouri*'
			return 'Missouri Tigers'
		when '*nevada*'
			return "Nevada Wolf Pack"
		when '*navy*'
			return "Navy Midshipmen"
		when '*nc state*'
			return 'NC State Wolfpack'
		when '*nebraska*'
			return "Nebraska Cornhuskers"
		when '*nevada wolf pack*'
			return 'Nevada Wolf Pack'
		when '*new mexico*'
			return 'New Mexico Lobos'
		when '*new mexico state aggies*'
			return 'New Mexico State Aggies'
		when '*north carolina*'
			return 'North Carolina Tar Heels'
		when '*north texas*'
			return 'North Texas Mean Green'
		when '*northern illinois*'
			return 'Northern Illinois Huskies'
		when '*northwestern*'
			return 'Northwestern Wildcats'
		when '*notre dame*'
			return 'Notre Dame Fighting Irish'
		when '*ohio*'
			return 'Ohio Bobcats'
		when '*ohio state*'
			return 'Ohio State Buckeyes'
		when '*oklahoma state*'
			return 'Oklahoma State Cowboys'
		when '*oklahoma*'
			return "Oklahoma Sooners"
		when '*oregon*'
			return 'Oregon Ducks'
		when '*oregon state*'
			return 'Oregon State Beavers'
		when '*penn state*'
			return 'Penn State Nittany Lions'
		when '*pittsburgh*'
			return 'Pittsburgh Panthers'
      		when '*princeton*'
			return 'Princeton Tigers'
		when '*providence*'
			return 'Providence Friars'
		when '*purdue*'
			return "Purdue Boilermakers"
		when '*rice*'
			return 'Rice Owls'
		when '*rutgers*'
			return 'Rutgers Scarlet Knights'
		when '*san diego state*'
			return 'San Diego State Aztecs'
		when '*san jose state*'
			return 'San Jose State Spartans'
		when '*seton hall*'
			return 'Seton Hall Pirates'
		when '*smu*'
			return 'SMU Mustangs'
		when '*south carolina*'
			return 'South Carolina Gamecocks'
		when '*so mississippi*'
			return 'Southern Miss Golden Eagles'
		when '*st. johns*'
			return 'St. Johns Red Storm'
		when '*stanford*'
			return 'Stanford Cardinals'
		when '*syracuse*'
			return 'Syracuse Orangemen'
		when '*tcu*'
			return 'TCU Horned Frogs'
		when '*temple*'
			return "Temple Owls"
		when '*tennessee u*'
			return 'Tennessee Volunteers'
		when '*texas am*'
			return "Texas A&M Aggies"
		when '*texas tech*'
			return "Texas Tech Red Raiders #{(league == 4 ? 'with Coach Leech' : '')}"
		when '*toledo*'
			return 'Toledo Rockets'
		when '*troy*'
			return 'Troy Trojans'
		when '*tulane*'
			return 'Tulane Green Wave'
		when '*tulsa*'
			return 'Tulsa Golden Hurricane'
		when '*uab*'
			return 'UAB Blazers'
		when '*ucf*'
			return 'UCF Golden Knights'
		when '*ucla*'
			return "UCLA Bruins"
		when '*uconn*'
			return 'UConn Huskies'
		when '*ul - lafayette*'
			return 'UL Lafayette Ragin Cajuns'
		when '*ul monroe*'                                                                                                                          
			return 'UL Monroe Indians'
		when '*unc*'
			return 'North Carolina Tarheels'
		when '*unlv*'
			return 'UNLV Rebels'
		when '*usc*'
			return "USC Trojans"
		when '*usf*'
			return 'USF Bulls'
		when '*utah state*'
			return 'Utah State Aggies'
		when '*utah*'
			return 'Utah Utes'
		when '*utep*'
			return 'UTEP Miners'
		when '*vanderbilt*'
			return 'Vanderbilt Commodores'
		when '*villanova*'
			return 'Villanova Wildcats'
		when '*virginia*'
			return 'Virginia Cavaliers'
		when '*virginia tech*'
			return 'Virginia Tech Hokies'
		when '*wake forest*'
			return "Wake Forest Demon Deacons"
		when '*washington u*'
			return 'Washington Huskies'
		when '*washington state*'
			return 'Washington State Cougars'
		when '*west virginia*'
			return 'West Virginia Mountaineers'
		when '*western michigan*'
			return 'Western Michigan Broncos'
		when '*wisconsin*'
			return 'Wisconsin Badgers'
		when '*wyoming*'
			return 'Wyoming Cowboys'
		when '*xavier*'
			return 'Xavier X-Men'
		else
         return name
	end # case
end # def	nameconv

def	do_season(newpred,	year,	winprob	=	0.7,	header	=	nil, gap	=	Secondsinthreedays,	gaptitle	=	"Week", mm = false, sport	=	nil,	lname	=	nil)
	raise 'need a sport'		if	sport.nil?
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
			week		+=	1
			#	render partial here if any data for it
			trma		=	nil
			trma,	bankroll	=	ms(wsh, ysh, week,	gaptitle,nil,	gapcount)
			trm		<<	trma.dup
			gapcount	+=	1
			dummy,	wsh	=	hi()
		end
		currentdate		=	g.game_date_time
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
		theader	+=	wrap('Home')		if	header.empty?
#		raise g.inspect
		thisrow	+=	wrap(nameconv(Team.find(g.home_team_id).name, 1)+" #{(g.moneyline_home == -110 && g.moneyline_away == -110) ?  "" : g.moneyline_home.commify}", (supick	==	g.home_team_id), suright, supush)
		# away team with  moneyline and su pick
		theader	+=	wrap('Away')		if	header.empty?
		thisrow	+=	wrap(nameconv(Team.find(g.away_team_id).name, 1)+" #{(g.moneyline_away == -110 && g.moneyline_home == -110) ?  "" : g.moneyline_away.commify}", (supick	==	g.away_team_id), suright, supush)
		# game score
		theader	+=	wrap('Game Score')	if	header.empty?
		thisrow	+=	wrap(g.actual_home_score.to_s+'-'+g.actual_away_score.to_s)
		if isnhl
			# do both pucklines and ou both odds
			theader	+=	wrap('Puck Line Home')	if	header.empty?
			unless	g.actual_home_score	==	-1
#				plevh	=	convml(h.plhodds)	*	h.plhprob
#				pleva	=	convml(h.plaodds)	*	h.plaprob
				hprize,	hlose	=	getpplfml(h.plhodds)
				aprize,	alose	=	getpplfml(h.plaodds)
				plevh	=	hprize	*	h.plhprob	+	(hlose	* (1.0 - h.plhprob))
				pleva	=	aprize	*	h.plaprob	+	(alose	* (1.0 - h.plaprob))
				puts "plevh #{plevh} pleva #{pleva} hprize #{hprize} aprize #{aprize} g.actual_home_score #{g.actual_home_score} g.actual_away_score #{g.actual_away_score}"
			end
			if	plevh	<	0.0		||	g.actual_home_score	==	-1
				thisrow	+=	wrap("#{h.plhome}(#{h.plhodds})")
			else
				puts "********* playing home pl"
				hdiv	=	nil
				hdiv	=	Ydiv	if	g.actual_home_score	+	h.plhome	==	g.actual_away_score
				hdiv	=	Gdiv	if	g.actual_home_score	+	h.plhome	>	g.actual_away_score
				hdiv	=	Rdiv	if	g.actual_home_score	+	h.plhome	<	g.actual_away_score
				raise if hdiv.nil?
				begin
					thisrow	+=	wrap("#{hdiv}#{h.plhome}(#{h.plhodds})</div>")
				rescue Exception => e
					raise "#{e} h.inspect #{h.inspect}"
				end
			end
			theader	+=	wrap('Puck Line Away')	if	header.empty?
			if	pleva	<	0.0	||	g.actual_home_score	==	-1
				thisrow	+=	wrap("#{h.plaway}(#{h.plaodds})")
			else
				puts "********* playing away pl"
				adiv	=	nil
				adiv	=	Ydiv	if	g.actual_away_score	+	h.plaway	==	g.actual_home_score
				adiv	=	Gdiv	if	g.actual_away_score	+	h.plaway	>	g.actual_home_score
				adiv	=	Rdiv	if	g.actual_away_score	+	h.plaway	<	g.actual_home_score
				raise if adiv.nil?
				begin
					thisrow	+=	wrap("#{adiv}#{h.plaway}(#{h.plaodds})</div>")
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
			wrapme	+=	spick if wrapme	==	NO
			thisrow	+=	wrap(wrapme,	atsbet,	atsbetright,	atsbetpush)
			# ou
			theader	+=	wrap('OU Total')	if	header.empty?
			thisrow	+=	wrap(g.game_total)
			# ou result
			theader	+=	wrap('OU Pick')	if	header.empty?
			thisrow	+=	wrap(NO)			if	oubet.nil?
			# def	wrap(str, picked=nil, pickright=nil, pickpush=nil, ou=false)
			thisrow	+=	wrap((oubet	?	'Over'	:	'Under'),	true,	oubetright,	oubetpush)	unless	oubet.nil?
		end

		# moneyline
		mlo,	mlm,	mlats,	bbmlprz,	hhf,	ahf,	bh	=	mlhlpr(g,	h)
		unless	mlm		==	0
			wsh['mlp']	+=	mlm
			ysh['mlp']	+=	mlm
			wsh['mlbb']	+=	bbmlprz	unless	bbmlprz.nil?
			ysh['mlbb']	+=	bbmlprz	unless	bbmlprz.nil?
			wsh['mlw']	+=	mlm	>	0	?	1	:	0
			ysh['mlw']	+=	mlm	>	0	?	1	:	0
			wsh['mll']	+=	mlm	<	0	?	1	:	0
			ysh['mll']	+=	mlm	<	0	?	1	:	0
		end
		theader	+=	wrap('Moneyline')	if		header.empty?
		thisrow	+=	wrap(mlo)		if		bbmlprz.nil?	or mlo.include?('No Opinion')	# if	mlo.nil?
		thisrow	+=	wrap(mlo+" big bet >#{bbmlprz.commify}< Running total is #{ysh['mlbb'].commify}")		unless	(bbmlprz.nil? or mlo.include?('No Opinion'))	# if	mlo.nil?

		# end of row
		trm		<<	'<tr>'+thisrow+'</tr>'
		header	=	'<tr>'+theader+'</tr>'	if 	header.empty?
	} # newpred
	returnme	<<	header
	trma		=	nil
	trma,	bankroll		=	ms(wsh, ysh, week, 'End of Year Stats')
	trm		<<	trma.dup
	returnme	<<	trm.reverse
	returnme	<<	"</table>"
#	raise "returnme length is #{returnme.length} #{returnme.inspect}"
	rm			=	{}
	rm['rollwith']	=	returnme
	bankroll		=	bankroll.to_f
#	<%	rw			=	@main['rollwith']	%>
#	<%	@heading		=	@main['heading']	if@main.has_key?('heading')		-%>
#	<%	@content		=	@main['content']	-%>
#	<%	@desc		=	@main['desc']		%>
#	@main['heading']	=	"Joe Guy's Soccer Betting - #{lname} - Season #{pid+1} - #{fdate.strftime("%B %d %Y  ")} to #{ldate.strftime("%B %d %Y  ")} Starting bankroll $100 - Ending Bankroll $#{bankroll.r2.commify} - Bet is $#{bet}"
#	@main['desc']		=	"Joe Guy's Soccer Betting - #{lname} - Season #{pid+1} - #{fdate.strftime("%B %d %Y  ")} to #{ldate.strftime("%B %d %Y  ")} Starting bankroll $100 - Ending Bankroll $#{bankroll.r2.commify} - Bet is $#{bet}"
	rm['heading']	=	"Joe Guy's #{sport} Betting - #{lname} - #{year} - #{fdate.strftime("%B %d %Y  ")} to #{ldate.strftime("%B %d %Y  ")} Starting bankroll $1,000 - Ending Bankroll $#{bankroll.r2.commify} - Bet is $#{bet}"
	rm['content']	=	"soccer, football, betting, Joe Guy's #{sport} Betting - #{lname} - #{year} - #{fdate.strftime("%B %d %Y  ")} to #{ldate.strftime("%B %d %Y  ")} Starting bankroll $1,000 - Ending Bankroll $#{bankroll.r2.commify} - Bet is $#{bet} - spread, moneyline , money line - #{utl.sort.join(',')}"
	rm['desc']	=	"Joe Guy's #{sport} Betting - #{lname} - #{year} - #{fdate.strftime("%B %d %Y  ")} to #{ldate.strftime("%B %d %Y  ")} Starting bankroll $1,000 - Ending Bankroll $#{bankroll.r2.commify} - Bet is $#{bet} - spread, moneyline , money line - #{utl.sort.join(',')}"
	@main		=	rm.dup
end	#	do_season

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
	atsbet		=	g.home_team_id	if	g.prob_home_win_ats	>=	winprob
	atsbet		=	g.away_team_id	if	g.prob_away_win_ats	>=	winprob
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
			oubet	=	false	if 	(1.0	-	g.prob_game_over_total)	>=	winprob
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
					ysh['ou']		+=	1
					wsh['ou']		+=	1
				end
			end
		end
		logger.warn( "oubet #{oubet.inspect} ou total #{g.game_total} over prob #{g.prob_game_over_total} ")
	else
		# is nhl - do puck lines and ou with seperate odds
		
	end
	return ysh,	wsh,	supick,	suright,	supush,	atsbet,	oubet,	atsbetright,	atsbetpush,	oubetright,	oubetpush
	end

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
				toutstr	+=	wrap(div	+	tstr+	wc.commify+' '+b+' '+(wc > 1 ? ' bets -> $' : ' bet -> $' )+	profit.r2.commify	+	'</div>')
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
			div		=	Gdiv	if	sumhash['year'+b]	>	0
			div		=	Rdiv	if	sumhash['year'+b]	<	0
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
				p["prob_away_win_su"]		= 1.0-d[9].to_f
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
	end # class object
	def getpplfml(ml)
		ml	=	102	if	ml == 100
		ml	=	-102	if	ml == -100
		raise if ml	==	100	or	ml	==	-100
		if ml	<	100	&&	ml	>	-100
			# already decimal value
			tml	=	ml
			tml	=	ml - 1.0	if ml > 1.0
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

