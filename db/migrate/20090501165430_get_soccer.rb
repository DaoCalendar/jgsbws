class GetSoccer < ActiveRecord::Migration
  def self.up
	ta	=	IO.readlines('public/unique soccer games.txt')
	#	 0       1           2       3      4          5                    6                         7                                 8
	#	D2,31/07/93,F Koln,2,Wolfsburg,0,0.487945405691188,0.252207074068463,0.259847520240348, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0
	sh	=	{}
	ta.each_with_index{|g,	i|
		tta	=	g.chomp.split(',')
		tta.pop	if	tta.last.strip.empty?
		puts tta.length
#		raise tta.inspect
		case tta.length
			when 17,	9
				puts	g.inspect
				p					=	Prediction.new
				league				=	tta[0]
				date					=	tta[1]
				home				=	tta[2]
				hscore				=	tta[3]
				away					=	tta[4]
				ascore				=	tta[5]
				hwp					=	tta[6].to_f
				awp					=	tta[7].to_f
				dwp					=	tta[8].to_f
				p.league				=	ShortLeague.find_by_shortname(league).league_id
			#	p.game_date_time		=	convdate(date)
				t					=	date.split("/")
				p["game_date_time"]	=	Time.local(2000+t[2].to_i, t[1], t[0])	if		t[2].to_i	<	10
				p["game_date_time"]	=	Time.local(1900+t[2].to_i, t[1], t[0])	unless	t[2].to_i	<	10
				if	sh.has_key?(league)
					if	(p["game_date_time"]	-	sh[league][0])	>	3.months
						sh[league][1]	+=	1
						sh[league][0]	=	p["game_date_time"]
					else
						
					end
				else
					sh[league]	=	[p["game_date_time"],	0]
				end
				season	=	sh[league][1]
				begin
					tid	=	Team.find_by_name(home).id
				rescue
					tid	=	nil
				end
				if	tid.nil?
					p.home_team_id	=	Team.create(:name=>home, :league_id=>p.league).id
				else
					p.home_team_id	=	tid
				end
				begin
					tid	=	Team.find_by_name(away).id
				rescue
					tid	=	nil
				end
				if	tid.nil?
					p.away_team_id	=	Team.create(:name=>away, :league_id=>p.league).id
				else
					p.away_team_id	=	tid
				end
				p.actual_home_score	=	hscore
				p.actual_away_score		=	ascore
				p.prob_home_win_su	=	hwp
				p.prob_away_win_su		=	awp
				p.prob_push_su		=	dwp
				p.save!
				puts sh.inspect
#				raise p.inspect
			else
				raise "line #{i.commify} #{g} unknown length #{tta.length}"
			end
	  }
  end

  def self.down
  end
end
