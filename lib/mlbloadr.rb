def	mlbloader(dataarray)
	teamleague		=	League.find_by_name('Major League Baseball').id
	raise "no league!" if teamleague.nil?
	# outdate - day+1 - g.home - res['hlambda'] - g.homescore - g.away - res['alambda'] - g.awayscore - g.homemoneyline - g.awaymoneyline - res['probhomewin'] - g.overunder - oline - uline - res['probtotalover'] - homerunlinespread - homerunline - res['probhrlcover'] - 	awayrunlinespread - awayrunline - res['probarlcover']
	# 25/3/08, 222, oakland athletics, 6.23259380548537, 5, boston red sox, 5.05579225568101, 6, 0, 0, 0.645280472133291, 9.0, 180, 0, 0.614310382313807, 1.5, -115, 0.670041830452548, -1.5, -105, 0.187108629559478
	dataarray		=	gs(dataarray) # proc names
	seasonnumber		=	0
	prevdate		=	nil
	mlbstruc		=	Struct.new(:date, :day, :home, :hlambda, :homescore, :away, :alambda, 
		:awayscore, :homemoneyline, :awaymoneyline, :probhomewin, :overunder, :oline, :uline, 
		:probtotalover, :homerunlinespread, :homerunline, :probhrlcover, :awayrunlinespread, 
		:awayrunline, :probarlcover)
	dataarray.each{|g|
		next if g.include?('outdate')
		gstruct		=	makrmlbstruc(g, mlbstruc)
		puts "dataarray.length #{dataarray.length} g.inspect #{g.inspect} gstruct #{gstruct.inspect}"
		p		=	nil
		pmake		=	nil
		addedp		=	false
#		t		=	d[0].split("/")
#		pa		=	Prediction.find_all_by_game_date_time(Time.local(2000+t[2].to_i, t[1], t[0]))
		pa		=	Prediction.find_all_by_game_date_time(gstruct.date)
#		raise p.inspect
#		if p.length
		pa.delete_if{|dfg|!(dfg["home_team_id"]		==	gstruct.home)}
		pa.delete_if{|dfg|!(dfg["away_team_id"]		==	gstruct.away)}
		raise "pa.length #{pa.length} pa.inspect #{pa.inspect}" if pa.length	>	1
		addedp		=	true		if	pa.length	==	0
		pmake		=	pa.length
		p		=	Prediction.new	if	pa.length	==	0
		p		=	pa.first	if	pa.length	==	1
#		raise "pa.length #{pa.length} p.inspect #{p.inspect}" if p.id.nil?
		begin
			p.week		=	gstruct.day
		rescue Exception => e
#			print e, "\n"
			raise "e #{e.inspect} d[1].to_i #{d[1].to_i} d[1] #{d[1].inspect} d.inspect #{d.inspect} p.inspect #{p.inspect}"
		end
		p['season']			=	seasonnumber
		p["game_date_time"]		=	gstruct.date
		seasonnumber			+=	1	if	! prevdate.nil? and ((p["game_date_time"] - prevdate) / Secondsperday)  > 60 # time diff in days
		prevdate			=	p["game_date_time"].dup
		p["league"]			=	teamleague
		p["home_team_id"]		=	gstruct.home
		p["away_team_id"]		=	gstruct.away
		p["actual_home_score"]		=	gstruct.homescore
		p["actual_away_score"]		=	gstruct.awayscore
		p["predicted_home_score"]	=	gstruct.hlambda
		p["predicted_away_score"]	=	gstruct.alambda
		pid				=	p.id
		p.save!
		# now create or update the baseball bet table
=begin
  create_table "baseball_bets", :force => true do |t|
    t.integer  "pred_id"
    t.float    "rlhome"
    t.integer  "rlhodds"
    t.float    "rlhprob"
    t.float    "rlaway"
    t.integer  "rlaodds"
    t.float    "rlaprob"
    t.float    "ou"
    t.integer  "overodds"
    t.float    "overprob"
    t.integer  "underodds"
    t.float    "underprob"
    t.datetime "created_at"
    t.datetime "updated_at"
  end
	:date, :day, :home, :hlambda, :homescore, :away, :alambda, 
	:awayscore, :homemoneyline, :awaymoneyline, :probhomewin, :overunder, :oline, :uline, 
	:probtotalover, :homerunlinespread, :homerunline, :probhrlcover, :awayrunlinespread, 
	:awayrunline, :probarlcover)
=end
		bbb		= BaseballBet.find_by_pred_id(pid)
#		raise "bbb.type #{bbb.type} bbb.nil? #{bbb.nil?}"
		if bbb.nil?  # not found
			nbp		= BaseballBet.new
		else
			nbp		= bbb.dup
		end
		nbp.pred_id	= pid
		nbp.rlhome	= gstruct.homerunlinespread
		nbp.rlhodds	= gstruct.homerunline
		nbp.rlhprob	= gstruct.probhrlcover
		nbp.rlaway	= gstruct.awayrunlinespread
		nbp.rlaodds	= gstruct.awayrunline
		nbp.rlaprob	= gstruct.probarlcover
		nbp.ou		= gstruct.overunder
		nbp.overodds	= gstruct.oline
		nbp.overprob	= gstruct.probtotalover
		nbp.underodds	= gstruct.uline
		nbp.underprob	= (1.0 - gstruct.probtotalover)
		nbp.save!
	}
end # nba loader

