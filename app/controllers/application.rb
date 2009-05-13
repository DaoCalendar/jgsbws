# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
Pasttime			=	Time.local(1_962,1,1)
Seasonone		=	Time.local(2_008,4,7)
Futuretime		=	Time.local(2_012,1,1)
Secondsperday		=	24	*	3_600
Secondsinthreedays	=	2.5	*	24	*	3600	#	days*hour/day*seconds/hour
NO				=	"No Opinion"
Gdiv				=	"<div id='green'>"
Rdiv				=	"<div id='red'>"
Fpc				=	0.04
Tpf				=	2.5
Td				=	"<td>"
Tde				=	"</td>"
Tr				=	"<tr>"
Tre				=	"</tr>"
Na				=	'<td>No Action</td>'
class ApplicationController < ActionController::Base
	# Be sure to include AuthenticationSystem in Application Controller instead
	include AuthenticatedSystem
	# If you want "remember me" functionality, add this before_filter to Application Controller
	before_filter :login_from_cookie
	# Pick a unique cookie name to distinguish our session data from others'
	session :session_key => '_jgsbws_session_id'
	def mlhlpr(p)
		# process moneyline
		return ["No Moneyline", 0.0, nil, 0.0, 0.0, 0.0, false] if p.moneyline_home == -110 and p.moneyline_away == -110 or (p.moneyline_home == 0 or p.moneyline_away == 0)
		hml = nil
		hml = p.moneyline_home/100.0 if p.moneyline_home > 0
		hml = -100.0/p.moneyline_home if p.moneyline_home < 0
		raise "hml problem p is #{p.inspect}" if hml.nil?
		aml = nil
		aml = p.moneyline_away/100.0 if p.moneyline_away > 0
		aml = -100.0/p.moneyline_away if p.moneyline_away < 0
		# raise "aml problem" if aml.nil?
		aml = 0.0 if aml.nil?
		pickhome = nil
		pickaway = nil
		homepo   = p.prob_home_win_su # *hml
		awaypo    = p.prob_away_win_su # *aml
		raise "homepo is nil" if homepo.nil?
		raise "awaypo is nil" if awaypo.nil?
#		return ["<div id='yellow'>No Opinion </div>", 0.0]  if homepo<1.0 and awaypo<1.0
		pickhome = (homepo > awaypo) unless p.league == 5
		pickaway = (awaypo > homepo) unless p.league == 5
		pickhome = (homepo > 0.92) # if p.league > 3
		pickaway = (awaypo > 0.92) # if p.league > 3
		pickhome = (homepo > 0.85) if p.league  == 2
		pickaway = (awaypo > 0.85)  if p.league == 2
#		return ["<div id='yellow'>No Opinion </div>", 0.0]  if (pickhome and hml<1.0) or (pickaway and aml<1.0)
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
		mlats = nil
		raise "hbbmlwin is nil" if hbbmlwin.nil?
			raise "hbbmllose is nil" if hbbmllose.nil?
		raise "abbmlwin is nil" if abbmlwin.nil?
			raise "abbmllose is nil" if abbmllose.nil?
		mlats = ((pickhome and p.spread > 0.0) ? p.home_team_id : ((pickaway and p.spread < 0.0) ? p.away_team_id : nil))
#		puts "mlats.inspect #{mlats.inspect}"
		raise "mlats is zero #{p.inspect}" if mlats == 0
		return ["<div id='yellow'>No Opinion </div>", 0.0, nil, 0.0, 0.0, 0.0, false]  if pickhome == false and pickaway == false
		return ["<div id='green'> #{nameconv(Team.find(p.home_team_id).name, p.league)}  ->  #{(hwinprize).to_s[0,6]}</div>", hwinprize, mlats, hbbmlwin, hhf, ahf, bh] if pickhome and p.actual_home_score > p.actual_away_score
		return ["<div id='red'> #{nameconv(Team.find(p.home_team_id).name, p.league)}  ->  #{hlose.to_s[0,6]}</div>", hlose, mlats, hbbmllose, hhf, ahf, bh] if pickhome and p.actual_home_score < p.actual_away_score
		return ["<div id='yellow'> #{nameconv(Team.find(p.home_team_id).name, p.league)}  ->  0.0</div>", 0.0, mlats, 0.0, 0.0, 0.0, false] if pickhome and p.actual_home_score == p.actual_away_score

		return ["<div id='green'> #{nameconv(Team.find(p.away_team_id).name, p.league)}  ->  #{(awinprize).to_s[0,6]}</div>", awinprize, mlats, abbmlwin, hhf, ahf, bh] if pickaway and p.actual_away_score > p.actual_home_score
		return ["<div id='red'> #{nameconv(Team.find(p.away_team_id).name, p.league)}  ->  #{alose.to_s[0,6]}</div>", alose, mlats, abbmllose, hhf, ahf, bh] if pickaway and p.actual_away_score < p.actual_home_score
		return ["<div id='yellow'> #{nameconv(Team.find(p.away_team_id).name, p.league)}  ->  0.0</div>", 0.0, mlats, 0.0, 0.0, 0.0, false] if pickaway and p.actual_away_score == p.actual_home_score
		raise "why am i here"
	end
def hi
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
def ms(wsh, ysh, week, header=nil, gaptitle	=	'Week', gc	=	0)
		ta	=	[]
		#week first
#		ta	<<	'</table></td></tr>' # turn off previous table - tr is for wrapping table
#		ta	<<	'<tr><table border="1">' # start new table
		ta	<<	"<tr><td>#{gaptitle} #{week} Statistics</td>" if header.nil?
		ta	<<	"<tr><td>#{header} #{gc.commify} Statistics</td>" unless header.nil?
		wsuw	=	wsh['suright']
		wsut		=	wsh['su']
		wsul		=	wsut	-	wsuw	#	+	wsh['supush']
		wsudiv	=	"<div id='green'>"	if	wsuw	>	wsul
		wsudiv	=	"<div id='red'>"	if	wsuw	<	wsul
		wsudiv	=	"<div id='yellow'>"	if	wsuw	==	wsul
		ysuw		=	ysh['suright']
		ysut		=	ysh['su']
		ysul		=	ysut	-	ysuw
		ysudiv	=	"<div id='green'>"	if	ysuw	>	ysul
		ysudiv	=	"<div id='red'>"	if	ysuw	<	ysul
		ysudiv	=	"<div id='yellow'>"	if	ysuw	==	ysul
		wpcw	=	(100.0 * wsuw / wsut).r2
		wpcw	=	0.0	if	wpcw.nan?
		ypcw	=	(100.0 * ysuw / ysut).r2
		ypcw	=	0.0	if	ypcw.nan?

		watsw	=	wsh['atsright']
		watst	=	wsh['ats']
		watsl	=	watst	-	watsw	#	+	wsh['atsbetpush']
		watsdiv	=	"<div id='green'>"	if	watsw	>	watsl * 1.1
		watsdiv	=	"<div id='red'>"	if	watsw	<	watsl * 1.1
		watsdiv	=	"<div id='yellow'>"	if	watsw	==	watsl * 1.1
		yatsw	=	ysh['atsright']
		yatst		=	ysh['ats']
		yatsl		=	yatst	-	yatsw
		yatsdiv	=	"<div id='green'>"	if	yatsw	>	yatsl * 1.1
		yatsdiv	=	"<div id='red'>"	if	yatsw	<	yatsl * 1.1
		yatsdiv	=	"<div id='yellow'>"	if	yatsw	==	yatsl * 1.1

		wout		=	wsh['ou']
		yout		=	ysh['ou']
		wouright	=	wsh['ouright']
		youright	=	ysh['ouright']
		woul		=	wout	-	wouright
		woudiv	=	"<div id='green'>"	if	wouright	>	woul * 1.1
		woudiv	=	"<div id='red'>"	if	wouright	<	woul * 1.1
		woudiv	=	"<div id='yellow'>"	if	wouright	==	woul * 1.1
		youl		=	yout	-	youright
		youdiv	=	"<div id='green'>"	if	youright	>	youl * 1.1
		youdiv	=	"<div id='red'>"	if	youright	<	youl * 1.1
		youdiv	=	"<div id='yellow'>"	if	youright	==	youl * 1.1

		wmlp	=	wsh['mlp'].r2
		wmldiv	=	"<div id='green'>"	if	wmlp	>	0
		wmldiv	=	"<div id='red'>"	if	wmlp	<	0
		wmldiv	=	"<div id='yellow'>"	if	wmlp	==	0
		ymlp		=	ysh['mlp'].r2
		ymldiv	=	"<div id='green'>"	if	ymlp	>	0
		ymldiv	=	"<div id='red'>"	if	ymlp	<	0
		ymldiv	=	"<div id='yellow'>"	if	ymlp	==	0
		wmlw	=	wsh['mlw']
		ymlw	=	ysh['mlw']
		wmll		=	wsh['mll']
		ymll		=	ysh['mll']

		# week
		ta	<<	"<td>#{wsudiv}SU wins -> #{wsuw} loses -> #{wsul} % win is #{wpcw}</div></td>"
		ta	<<	"<td>#{watsdiv}ATS wins -> #{watsw} loses -> #{watsl} % win is #{(100.0 * watsw / (watst == 0 ? 1 : watst)).r2} profit is #{(watsw - 1.1 * watsl).r2}</div></td>"
		ta	<<	"<td>#{woudiv}OU wins -> #{wouright} loses -> #{woul} % win is #{(100.0 * wouright / (wout == 0 ? 1 : wout)).r2} profit is #{(wouright - 1.1 * woul).r2}</div></td>"
		ta	<<	"<td>#{wmldiv}Money Line wins -> #{wmlw} loses -> #{wmll} % win is #{(100.0 * wmlw / ((wmlw + wmll) == 0 ? 1 : wmlw + wmll)).r2} profit is #{wmlp.r2}</div></td>"

		# year
		ta	<<	"<td>#{ysudiv}Year #{week} SU wins -> #{ysuw} loses -> #{ysul} % win is #{ypcw}</div></td>"
		ta	<<	"<td>#{yatsdiv}ATS wins -> #{yatsw} loses -> #{yatsl} % win is #{(100.0 * yatsw / (yatst == 0 ? 1 : yatst)).r2} profit is #{(yatsw - 1.1 * yatsl).r2}</div></td>"
		ta	<<	"<td>#{youdiv}OU wins -> #{youright} loses -> #{youl} % win is #{(100.0 * youright / (yout == 0 ? 1 : yout)).r2} profit is #{(youright - 1.1 * youl).r2}</div></td>"
		ta	<<	"<td>#{ymldiv}Money Line wins -> #{ymlw} loses -> #{ymll} % win is #{(100.0 * ymlw / ((ymlw+ymll) == 0 ? 1 : (ymlw+ymll))).r2} profit is #{ymlp.r2}</div></td>"
#		ta	<<	'</table></tr>' # turn off this table
#		ta	<<	'<tr><table border="1">' # restart old table
		ta	<<	'</tr>'
		# now new home dog etc stats
		outstr	=	"<tr><td>Home and Away Dog and Favorite Stats</td>"
		p		=	(wsh['hd'][0]-wsh['hd'][1]*1.1).r2
		sd		=	p	>	0.0	?	"<div id='green'>" : (p	==	0.0	?	"<div id='yellow'>" : "<div id='red'>")
		outstr	+=	"<td>#{sd}Weekly Home Dog Stats - #{wsh['hd'][0].commify} wins #{wsh['hd'][1].commify} loses - Profit is #{p.commify}</div></td>"
		p		=	(wsh['ad'][0]-wsh['ad'][1]*1.1).r2
		sd		=	p	>	0.0	?	"<div id='green'>" : (p	==	0.0	?	"<div id='yellow'>" : "<div id='red'>")
		outstr	+=	"<td>#{sd}Weekly Road Dog Stats - #{wsh['ad'][0].commify} wins #{wsh['ad'][1].commify} loses - Profit is #{p.commify}</div></td>"
		p		=	(wsh['hf'][0]-wsh['hf'][1]*1.1).r2
		sd		=	p	>	0.0	?	"<div id='green'>" : (p	==	0.0	?	"<div id='yellow'>" : "<div id='red'>")
		outstr	+=	"<td>#{sd}Weekly Home Fav Stats - #{wsh['hf'][0].commify} wins #{wsh['hf'][1].commify} loses - Profit is #{p.commify}</div></td>"
		p		=	(wsh['af'][0]-wsh['af'][1]*1.1).r2
		sd		=	p	>	0.0	?	"<div id='green'>" : (p	==	0.0	?	"<div id='yellow'>" : "<div id='red'>")
		outstr	+=	"<td>#{sd}Weekly Road Fav Stats - #{wsh['af'][0].commify} wins #{wsh['af'][1].commify} loses - Profit is #{p.commify}</div></td>"
		p		=	(ysh['hd'][0]-ysh['hd'][1]*1.1).r2
		sd		=	p	>	0.0	?	"<div id='green'>" : (p	==	0.0	?	"<div id='yellow'>" : "<div id='red'>")
		outstr	+=	"<td>#{sd}Yearly Home Dog Stats - #{ysh['hd'][0].commify} wins #{ysh['hd'][1].commify} loses - Profit is #{p.commify}</div></td>"
		p		=	(ysh['ad'][0]-ysh['ad'][1]*1.1).r2
		sd		=	p	>	0.0	?	"<div id='green'>" : (p	==	0.0	?	"<div id='yellow'>" : "<div id='red'>")
		outstr	+=	"<td>#{sd}Yearly Road Dog Stats - #{ysh['ad'][0].commify} wins #{ysh['ad'][1].commify} loses - Profit is #{p.commify}</div></td>"
		p		=	(ysh['hf'][0]-ysh['hf'][1]*1.1).r2
		sd		=	p	>	0.0	?	"<div id='green'>" : (p	==	0.0	?	"<div id='yellow'>" : "<div id='red'>")
		outstr	+=	"<td>#{sd}Yearly Home Fav Stats - #{ysh['hf'][0].commify} wins #{ysh['hf'][1].commify} loses - Profit is #{p.commify}</div></td>"
		p		=	(ysh['af'][0]-ysh['af'][1]*1.1).r2
		sd		=	p	>	0.0	?	"<div id='green'>" : (p	==	0.0	?	"<div id='yellow'>" : "<div id='red'>")
		outstr	+=	"<td>#{sd}Yearly Road Fav Stats - #{ysh['af'][0].commify} wins #{ysh['af'][1].commify} loses - Profit is #{p.commify}</div></td>"
		outstr	+=	"</tr>"
		ta	<<	outstr
		return ta
	end

	def nameconv(name, league)
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
			return 'Cincinatti Bearcats'
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
end # def nameconv

def	do_season(newpred,	year,	winprob	=	0.7,	header	=	nil, gap	=	Secondsinthreedays,	gaptitle	=	"Week", mm = false)
	week			=	0
	currentdate		=	nil
	weeklysummary	=	nil
	returnme			=	[]
	returnme			<<	header
	returnme			<<	'<table width="100%"><tr><td><!-- wrapping table --> ' # big table that wraps both games and weekly summary
	returnme			<<	'<table border="1">'
	trm				=	[]
	ysh,	wsh			=	hi()
	header			=	''
	theader			=	''
	gamecount		=	1
	gapcount			=	1
	newpred.each{|g|
		next if g.actual_home_score	<=	0	or g.actual_away_score	<=	0	or	g.game_total	==	0
		winprob	=	0.65	if	mm	and g.game_date_time	>=	Time.local(2_009,3,20)
		currentdate	=	g.game_date_time	if	currentdate.nil?
		if (g.game_date_time	-	currentdate)	>	gap
			logger.warn("(g.game_date_time	-	currentdate) #{(g.game_date_time	-	currentdate)}")
			#	new week
#			raise
			week	+=	1
			#	render partial here if any data for it
			trm		<<	ms(wsh, ysh, week,	gaptitle,nil,	gapcount)
			gapcount	+=	1
			dummy,	wsh		=	hi()
		end
		currentdate	=	g.game_date_time
		# now build row of predictions,
		# date, home with moneyline, away with moneyline, spread, ou, spreadpick, ttspreadpick, oupick, ttoupick, moneyline both small and large bet
		# ysh,	wsh,	supick,	suright,	supush,	atsbet,	oubet,	atsbetright,	atsbetpush,	oubetright,	oubetpush
		   ysh,	wsh,	supick,	suright,	supush,	atsbet,	oubet,	atsbetright,	atsbetpush,	oubetright,	oubetpush	=	calcatsbet(g,	ysh,	wsh,	winprob)
		# date	home	away		spread	ou	atspick	
		thisrow		=	''
		theader		+=	wrap('Game Date')	if	header.empty?
		thisrow		+=	wrap('Game # '+gamecount.commify+' '+g.game_date_time.strftime("%b.%d.%Y"))
		gamecount	+=	1
		# home team with  moneyline and su pick
		theader	+=	wrap('Home')	if	header.empty?
		thisrow	+=	wrap(nameconv(Team.find(g.home_team_id).name, 1)+" #{(g.moneyline_home == -110 && g.moneyline_away == -110) ?  "" : g.moneyline_home.commify}", (supick	==	g.home_team_id), suright, supush)
		# away team with  moneyline and su pick
		theader	+=	wrap('Away')	if	header.empty?
		thisrow	+=	wrap(nameconv(Team.find(g.away_team_id).name, 1)+" #{(g.moneyline_away == -110 && g.moneyline_home == -110) ?  "" : g.moneyline_away.commify}", (supick	==	g.away_team_id), suright, supush)
		# game score
		theader	+=	wrap('Game Score')	if	header.empty?
		thisrow	+=	wrap(g.actual_home_score.to_s+'-'+g.actual_away_score.to_s)
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
		# def wrap(str, picked=nil, pickright=nil, pickpush=nil, ou=false)
		thisrow	+=	wrap((oubet	?	'Over'	:	'Under'),	true,	oubetright,	oubetpush)	unless	oubet.nil?

		# moneyline
		mlo,	mlm,	mlats,	bbmlprz,	hhf,	ahf,	bh	=	mlhlpr(g)
		unless	mlm	==	0
			wsh['mlp']	+=	mlm
			ysh['mlp']		+=	mlm
			wsh['mlbb']	+=	bbmlprz	unless	bbmlprz.nil?
			ysh['mlbb']	+=	bbmlprz	unless	bbmlprz.nil?
			wsh['mlw']	+=	mlm	>	0	?	1	:	0
			ysh['mlw']	+=	mlm	>	0	?	1	:	0
			wsh['mll']		+=	mlm	<	0	?	1	:	0
			ysh['mll']		+=	mlm	<	0	?	1	:	0
		end
		theader	+=	wrap('Moneyline')	if		header.empty?
		thisrow	+=	wrap(mlo)		if		bbmlprz.nil?	or mlo.include?('No Opinion')	# if	mlo.nil?
		thisrow	+=	wrap(mlo+" big bet >#{bbmlprz.commify}< Running total is #{ysh['mlbb'].commify}")		unless	(bbmlprz.nil? or mlo.include?('No Opinion'))	# if	mlo.nil?

		
		# end of row
		trm	<<	'<tr>'+thisrow+'</tr>'
		header	=	'<tr>'+theader+'</tr>'	if 	header.empty?
	}
	returnme	<<	header
	trm		<<	ms(wsh, ysh, week, 'End of Year Stats')
	returnme	<<	trm
	returnme	<<	"</table>"
#	raise "returnme length is #{returnme.length} #{returnme.inspect}"
end
def calcatsbet(g,	ysh,	wsh, winprob)
	supick		=	nil
	supick		=	g.home_team_id	if	g.prob_home_win_su			>=	winprob
	supick		=	g.away_team_id	if	g.prob_away_win_su				>=	winprob
	suright		=	nil
	suright		=	(supick	==	g.home_team_id && (g.actual_home_score > g.actual_away_score)) || (supick	==	g.away_team_id && (g.actual_home_score < g.actual_away_score))
	ysh['suright']	+=	(suright	?	1	:	0) unless suright.nil?
	wsh['suright']	+=	(suright	?	1	:	0) unless suright.nil?
	ysh['su']		+=	1 unless supick.nil?
	wsh['su']		+=	1 unless supick.nil?
	supush		=	(g.actual_home_score == g.actual_away_score)
	wsh['supush']	+=	1 if supush

	atsbet		=	nil
	atsbet		=	g.home_team_id	if	g.prob_home_win_ats			>=	winprob
	atsbet		=	g.away_team_id	if	g.prob_away_win_ats			>=	winprob
	atsbetright	=	nil
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
	atsbetright	=	(atsbet	==	g.home_team_id && (g.actual_home_score + g.spread) > g.actual_away_score) || (atsbet	==	g.away_team_id && (g.actual_home_score + g.spread) < g.actual_away_score)
	atsbetpush	=	((g.actual_home_score + g.spread) == g.actual_away_score)
	ysh['atsright']	+=	(atsbetright	?	1	:	0)
	wsh['atsright']	+=	(atsbetright	?	1	:	0)
	if atsbetpush
		wsh['atsbetpush']	+=	1 
	else
		ysh['ats']		+=	1 unless atsbet.nil?
		wsh['ats']		+=	1 unless atsbet.nil?
	end

	oubet		=	nil
	oubetright	=	nil
	oubetpush	=	 nil
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
	return ysh,	wsh,	supick,	suright,	supush,	atsbet,	oubet,	atsbetright,	atsbetpush,	oubetright,	oubetpush
	end

	def wrap(str, picked=nil, pickright=nil, pickpush=nil, ou=false)
		#	if ou
		#		return "<td>#{str}</td>" if picked.nil? # no opinion in ou
		#		return "<td><div id='yellow'>#{str}</div></td>" if pickpush
		#		return "<td><div id='green'>#{str}</div></td>" if pickright
		#		return "<td><div id='red'>#{str}</div></td>" unless pickright
		#	else
		return "<td>#{str}</td>" if (picked.nil? or !picked)
		return "<td><div id='yellow'>#{str}</div></td>" if !picked.nil? && pickpush
		return "<td><div id='green'>#{str}</div></td>" if !picked.nil? && pickright
		return "<td><div id='red'>#{str}</div></td>" if !picked.nil? && !pickright
		#	end
		raise "str #{str} pick #{picked} pickright #{pickright} pickpush #{pickpush}"
	end
=begin
=end

def summarytime(pweek,	oldweek,	sumhash,	beta,	outstr)
	# check for summary time
	unless oldweek	==	pweek
		puts "sumhash.inspect #{sumhash.inspect}"
		puts "beta.inspect #{beta.inspect}"
#		raise
		puts "oldweek #{oldweek} pweek #{pweek}"
		oldweek		=	pweek
		st			=	0.0
		beta.each{|b|
			begin
				st	+=	sumhash['week'+b].r2
			rescue
			end
		}
		div		=	Gdiv	if	st	>	0
		div		=	Rdiv	if	st	<	0
		outstr		+=	Tr+"<td>#{div}Week #{oldweek} Total -> $#{st.r2.commify}</div></td>"
		beta.each{|b|
			begin
				div		=	Gdiv	if	sumhash['week'+b]	>	0
				div		=	Rdiv	if	sumhash['week'+b]	<	0
				outstr	+=	wrap(div	+	sumhash['week'+b].r2.commify	+	'</div>')
				sumhash['week'+b]	=	nil
			rescue
				outstr	+=	Na
			end
		}
		outstr			+=	Tre
	end
	return sumhash,	outstr,	oldweek
end	#	summarytime

def maintsh(sumhash, bookie,	prize)
	begin
		sumhash['year'+bookie]	+=	prize
	rescue
		sumhash['year'+bookie]	=	prize	
	end
	begin
		sumhash['week'+bookie]	+=	prize
	rescue
		sumhash['week'+bookie]	=	prize
	end
	return sumhash
end	#maintsh

end # class application

class Numeric
  def commify()
	  retme 	=	self.to_s.reverse.gsub(/(\d\d\d)(?=\d)(?!\d*\.)/,'\1,').reverse
	  if retme.include?('.')
		  retme	=	retme	+	'0' unless (retme.length - retme.index('.'))	==	3
	  end
	  return retme
  end 
  def currency()
    sstr = to_s+".00"
    sstr.gsub!("..",".") if sstr.include?("..")
    sstr[0..sstr.index(".")+2]
  end
  def r2()
#	return self
	begin
		(((self+0.005)*100.0).to_i) / 100.00
	rescue
#		raise "r2 failed - self is #{self}"
		return 0.0
	end
  end
end
