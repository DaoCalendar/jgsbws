def 	makeprecord(p, gstruct, prevdate, teamleague)
	p.game_date_time	=  gstruct.gametime
	seasonnumber		+= 1 if ! prevdate.nil? and ((p.game_date_time - prevdate) / Secondsperday)  > 60 # time diff in days
	prevdate		=  p.game_date_time.dup
	p.league		=  teamleague
	p.home_team_id		=  gstruct.home
	p.away_team_id		=  gstruct.away
	p.actual_home_score	=  gstruct.homescore
	p.actual_away_score	=  gstruct.awayscore
	p.predicted_home_score	=  gstruct.hlambda
	p.predicted_away_score	=  gstruct.alambda
	pid			=  p.id
	pidwn			=  pid.nil?
	blah			=  p.save
	puts "prediction saved #{blah.inspect} pid is #{pid}"
	puts "pid was nil #{p.inspect} pid is now #{p.id}" if pidwn
	return p
end

def	makebbrecord(nbp, gstruct)
	nbp.rlhome	= gstruct.homerunlinespread
	nbp.rlhodds	= gstruct.homerunline
	nbp.rlhprob	= gstruct.probhrlcover
	nbp.homeml	= gstruct.homemoneyline
	nbp.probhsuw	= gstruct.probhomewin
	nbp.rlaway	= gstruct.awayrunlinespread
	nbp.rlaodds	= gstruct.awayrunline
	nbp.rlaprob	= gstruct.probarlcover
	nbp.awayml	= gstruct.awaymoneyline
	nbp.probasuw	= (1.0 - gstruct.probhomewin)
	nbp.ou		= gstruct.overunder
	nbp.overodds	= gstruct.oline
	nbp.overprob	= gstruct.probtotalover
	nbp.underodds	= gstruct.uline
	nbp.underprob	= (1.0 - gstruct.probtotalover)
	bbid		= nbp.id
	blah2		= nbp.save
	puts "nbp #{nbp.inspect}"
	puts "save of bb bet is #{blah2.inspect} bb id is #{bbid.inspect}"
	# sleep 3
	puts
end

def	mlbloader(dataarray)
#	raise dataarray.inspect
	teamleague		=	League.find_by_name('Major League Baseball').id
	raise "no league!" if teamleague.nil?
	# outdate - day+1 - g.home - res['hlambda'] - g.homescore - g.away - res['alambda'] - g.awayscore - g.homemoneyline - g.awaymoneyline - res['probhomewin'] - g.overunder - oline - uline - res['probtotalover'] - homerunlinespread - homerunline - res['probhrlcover'] - 	awayrunlinespread - awayrunline - res['probarlcover']
	# 25/3/08, 222, oakland athletics, 6.23259380548537, 5, boston red sox, 5.05579225568101, 6, 0, 0, 0.645280472133291, 9.0, 180, 0, 0.614310382313807, 1.5, -115, 0.670041830452548, -1.5, -105, 0.187108629559478
	dataarray		=	gs(dataarray) # proc names
	seasonnumber		=	0
	prevdate		=	nil
	mlbstruc		=	Struct.new(:date, :gametime, :day, :home, :hlambda, :homescore, :away, :alambda, 
		:awayscore, :homemoneyline, :awaymoneyline, :probhomewin, :overunder, :oline, :uline, 
		:probtotalover, :homerunlinespread, :homerunline, :probhrlcover, :awayrunlinespread, 
		:awayrunline, :probarlcover)
	dataarray.each{|g|
		next if g.include?('outdate')
		gstruct		=	makrmlbstruc(g, mlbstruc)
		puts "dataarray.length #{dataarray.length} g.inspect #{g.inspect} gstruct #{gstruct.inspect}"
		p		=	nil
		pmake		=	nil
#		addedp		=	false
#		t		=	d[0].split("/")
#		pa		=	Prediction.find_all_by_game_date_time(Time.local(2000+t[2].to_i, t[1], t[0]))
#		puts "looking for date #{gstruct.date.inspect}"
#		pa		=	Prediction.find_all_by_game_date_time(gstruct.date)
		sqlstr		= "SELECT * from predictions WHERE predictions.home_team_id = #{gstruct.home} AND predictions.away_team_id = #{gstruct.away}"
		puts "seeking on this sql str #{sqlstr}"
		pa		= Prediction.find_by_sql(sqlstr)
		puts "pa length before date filter is #{pa.length}"
		pa.delete_if{|g|
			g["game_date_time"].year     != gstruct.gametime.year or 
			g["game_date_time"].month    != gstruct.gametime.month or 
			g["game_date_time"].day      != gstruct.gametime.day
	        }
		puts "pa length after date filter is #{pa.length}"
#		raise p.inspect
#		if p.length
#		puts "pa length before home team filter is #{pa.length}"
#		pa.delete_if{|dfg|!(dfg["home_team_id"]		==	gstruct.home)}
#		puts "pa length after home team filter is #{pa.length}"
#		pa.delete_if{|dfg|!(dfg["away_team_id"]		==	gstruct.away)}
#		puts "pa length after away team filter is #{pa.length}"
		raise "pa.length #{pa.length} pa.inspect #{pa.inspect}" if pa.length	>	1
#		addedp		=	true		if	pa.length	==	0
#		puts "added prediction" if addedp
#		puts "prediction already there" unless addedp
		# sleep 2
		pmake		=	pa.length
		newprec		=	nil
		newprec		=	(pa.length == 0)
		raise "newprec is nil" if newprec.nil?
		p		=	Prediction.new	if	newprec
		p		=	pa.first	unless	newprec
#		raise "pa.length #{pa.length} p.inspect #{p.inspect}" if p.id.nil?
		begin
			p.week	=	gstruct.day
		rescue Exception => e
#			print e, "\n"
			raise "e #{e.inspect} d[1].to_i #{d[1].to_i} d[1] #{d[1].inspect} d.inspect #{d.inspect} p.inspect #{p.inspect}"
		end
		p.season	=	seasonnumber
		puts "newprec is #{newprec.inspect}"
		if newprec
			# create new record
			p	=	makeprecord(p, gstruct, prevdate, teamleague)
		else
			# update current one
			unless (p.actual_home_score == gstruct.homescore && p.actual_away_score == gstruct.awayscore)
				p.update_attribute(:actual_home_score, gstruct.homescore)
				p.update_attribute(:actual_away_score, gstruct.awayscore)
			end
		end
		pid		=	p.id
		# sleep 3
		# now create or update the baseball bet table
		bbb		= BaseballBet.find_by_pred_id(pid)
#		raise "bbb.type #{bbb.type} bbb.nil? #{bbb.nil?}"
		newbbrec	=	nil
		puts "newbbrec is #{newbbrec.inspect}"
		if bbb.nil?  # not found
			nbp	= BaseballBet.new
			puts "made new bb bet"
			newbbrec= true
		else
			nbp	= bbb.dup
			puts "bb bet already there #{bbb.inspect}"
			puts "bb bet created because predid is #{nbp.pred_id}"  unless nbp.pred_id == pid
			nbp	= BaseballBet.new unless nbp.pred_id == pid
			newbbrec= false
		end
		raise "newbbrec is nil" if newbbrec.nil?
		nbp.pred_id	= pid # copy over 
		if newbbrec
			# create new record
			makebbrecord(nbp, gstruct)
		else
			# update current one
#			nbp.update_attributes
		end
	}
end # nba loader
