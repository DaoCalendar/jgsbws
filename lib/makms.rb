def getotherline(line, juice = 20)
	# nc - negative component - amount of line below -100 in negative line - is negative
	# pc - positive component - amount of line above 100 in positive line - is positive
	# nc plus pc equals juice which is always positive and defaults to -20
	#
	diff	=	line	+	100	if	line	<	-100
	diff	=	line	-	100	unless	line	<	-100
	adiff	=	-20	-	diff
	return	-100	+	adiff		if	adiff	<	0
	return	100	+	adiff		unless	adiff	<	0
end

def	makrmlbstruc(g, gs)
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
  outdate - day+1 - g.home - res['hlambda'] - g.homescore - g.away - res['alambda'] - g.awayscore - g.homemoneyline - g.awaymoneyline - res['probhomewin'] - g.overunder - oline - uline - res['probtotalover'] - homerunlinespread - homerunline - res['probhrlcover'] - 	awayrunlinespread - awayrunline - res['probarlcover']
  25/3/08, 222, oakland athletics, 6.23259380548537, 5, boston red sox, 5.05579225568101, 6, 0, 0, 0.645280472133291, 9.0, 180, 0, 0.614310382313807, 1.5, -115, 0.670041830452548, -1.5, -105, 0.187108629559478
  mlbstruc	=	Struct.new(:date :home, :hlambda, :homescore, :away, :alambda, 
			:awayscore, :homemoneyline, :awaymoneyline, :probhomewin, :overunder, :oline, :uline, 
			:probtotalover, :homerunlinespread, :homerunline, :probhrlcover, :awayrunlinespread, 
			:awayrunline, :probarlcover)
=end
	d				=	g.split(",")
	gstruct				=	gs.new
	t				=	d[0].split("/")
	gstruct.date			=	Time.local(2000+t[2].to_i, t[1], t[0])
	#	puts "g.inspect #{g.inspect}"
	gstruct.day			=	d[1].to_i
	begin
		gstruct.home		=	Team.find_by_name(d[2].strip).id
	rescue
		raise "no such team as "+d[2] if home_id.nil?
	end
	gstruct.hlambda			=	d[3].to_f
	gstruct.homescore		=	d[4].to_i
	begin
		gstruct.away		=	Team.find_by_name(d[5].strip).id
	rescue
		raise "no such team as "+d[5] if away_id.nil?
	end
	gstruct.alambda			=	d[6].to_f
	gstruct.awayscore		=	d[7].to_i
	gstruct.homemoneyline		=	d[8].to_f
	gstruct.awaymoneyline		=	d[9].to_f
	gstruct.probhomewin		=	d[10].to_f
	gstruct.overunder		=	d[11].to_f
	gstruct.oline			=	d[12].to_i
	gstruct.uline			=	d[13].to_i
	gstruct.uline			=	getotherline(gstruct.oline) if gstruct.uline == 0
	gstruct.probtotalover		=	d[14].to_f
	gstruct.homerunlinespread	=	d[15].to_f
	gstruct.homerunline		=	d[16].to_i
	gstruct.probhrlcover		=	d[17].to_f
	gstruct.awayrunlinespread	=	d[18].to_i
	gstruct.awayrunline		=	d[19].to_i
	gstruct.probarlcover		=	d[20].to_f
#	puts
#	puts "#{d.inspect}"
#	puts
#	raise "#{g.inspect} \n#{d.inspect} \ngs #{gstruct.inspect}"
	return gstruct
end # nba loader

