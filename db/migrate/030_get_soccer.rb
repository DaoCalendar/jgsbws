class GetSoccer < ActiveRecord::Migration
	require "migration_helpers"
	extend MigrationHelpers
  def self.up
#	  return unless ENV['RAILS_ENV'] == 'production'
#	  puts ApplicationController.methods.sort
#	  raise
	ta		=	IO.readlines(File.dirname(__FILE__) + '/../../public/unique soccer games.txt')
	#	 0       1           2       3      4          5                    6                         7                                 8
	#	D2,31/07/93,F Koln,2,Wolfsburg,0,0.487945405691188,0.252207074068463,0.259847520240348, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0
	sh		=	{}
	wh		=	{}
	sh2		=	[]
	$csh2	=	false
	prize		=	0.0
#	puts	'set to false'
	st		=	Time.now
	glen		=	ta.length.commify
	brh		=	{}	#	bankroll hash based on league and season
	ta.each_with_index{|g,	i|	#	process all games
#		next	if	i	<	56052	#	42374 # temp to get us to the bookie games fast
		if (Time.now	-	st)	>	10
			puts "#{i.commify} / #{glen}"
			st	=	Time.now	
	#		puts "$csh2.inspect #{$csh2.inspect}"
			writeseasons(sh2) if $csh2
			$csh2	=	false
		end
		g.chomp! # remove \n
		while g[-1,	1]	==	' ' || g[-1,	1]	==	',' do
#			puts g+'<' 
#			sleep 1
			g.chop!
		end
#		puts g
#		raise
		tta		=	g.chomp.split(',')
#		puts g.inspect
#		sleep 5
		homescore	=	tta[3].to_i
		awayscore	=	tta[5].to_i
		gres			=	'H'	if homescore	>	awayscore
		gres			=	'A'	if homescore	<	awayscore
		gres			=	'D'	if homescore	==	awayscore
		if tta.include?(' ')
#			puts	tta.inspect
			tta.delete(' ')
#			puts	tta.inspect
#			sleep 5
		end
#		tta.pop	if	tta.last.strip.empty?
#		puts tta.length
#		raise tta.inspect
		#	process this game
		case tta.length
			when (11..16),	(18..34),	36,	37,	40
				raise unless g.include?('->')
				p,	sh,	sh2,	wh	=	fronthalf(sh,	tta,	sh2,	wh,	false)
				brh[[tta[0],	p.season]]	=	100.0	unless	brh.has_key?([tta[0],	p.season])
				sb				=	SoccerBet.new
#				puts sb.inspect
#				sleep 5
#				sb.prediction_id	=	p.id	# note - there is a better way to do this
				bankroll	=	1_000.0
				bet		=	bankroll	*	Fpc
				tta.each{|t|	#	process each betting opportunity in this game
					next unless	t.include?('->')
					next if		t.include?('->->')
					# D2,27/04/09,Osnabruck,0,Hansa Rostock,0,0.309049752014374,0.433344489670393,0.257605758315232, B365H->2.6->0.8, B365D->3.1->0.79, B365A->2.6->1.12, BWH->2.65->0.81, BWD->3.1->0.79, BWA->2.5->1.08, GBH->2.6->0.8, GBD->3.2->0.82, GBA->2.55->1.1, IWH->2.6->0.8, IWD->3.2->0.82, IWA->2.6->1.12, LBH->2.5->0.77, LBD->3.1->0.79, LBA->2.5->1.08, SBH->2.65->0.81, SBD->3.2->0.82, SBA->2.45->1.06, WHH->2.5->0.77, WHD->3.1->0.79, WHA->2.5->1.08, VCH->2.6->0.8, VCD->3.2->0.82, VCA->2.5->1.08, BbMx>2.5->1.92->0.95, BbMx<2.5->2.05->1.03, BbAv>2.5->1.79->0.88, BbAv<2.5->1.94->0.97
					ta		=	t.split('->')
					bookie	=	ta[0].strip
					odds		=	ta[1].to_f
					ev		=	ta[2].to_f
					prize		=	0.0
					if	ev	>	1.0
						#	bet has positive expected value
						betdraw	=	false
						bethome	=	nil
						bethome	=	true		if	bookie.last	==	'H'
						bethome	=	false	if	bookie.last	==	'A'
						betdraw	=	true		if	bookie.last	==	'D'
						if (!betdraw	&&	bethome.nil?)
							# maybe > < 2.5 bet
							raise "bookie #{bookie}" if !bookie.include?('>')	&&	!bookie.include?('<')
							gt25	=	((homescore+awayscore)	>	2.5)
							if	(gt25	&&	bookie.include?('>'))	||	(gt25	&&	bookie.include?('<'))
								prize		=	bet	*	odds	
							else
								prize		=	-bet
							end
						else
							if	(gres	==	'H'	&&	bethome)	||	(gres	==	'A'	&&	!bethome)	||	(gres	==	'D'	&&	betdraw)
								prize		=	bet	*	odds	
							else
								prize		=	-bet
							end
						end
						bankroll					+=	prize
						brh[[tta[0],	p.season]]	+=	prize
					end
#					puts ">#{bookie}<"
#					puts odds
					begin
#						puts "sb[bookie] b4 #{sb[bookie].inspect}"
						sb[bookie]		=	odds
#						puts "sb[bookie] after #{sb[bookie].inspect}"
						sb[bookie+'_ev']	=	ev
					rescue
						raise "No such bookie as #{bookie}"
					end
				}
#				puts "ss.inspect #{ss.inspect}"
#				sleep 1
				sb.save!
				p.soccer_bet	=	sb.id
#				raise if 
#				puts p.inspect
#				sleep 5
				p.save!
#				puts sb.inspect
#				sleep 5
			when 17,	9
				p,	sh,	sh2,	wh	=	fronthalf(sh,	tta,	sh2,	wh)
#			when 29
				#  0         1           2         3    4      5         6                                 7                                      8 
				# F1,28/07/00,Marseille,3,Troyes,1,0.625369598137193,0.202987853070863,0.171642548791942, 1.65->1.03, 3.3->0.56, 4.3->0.87, 1.45->0.9, 3.5->0.6, 5.0->1.01, 1.53->0.95, 3.5->0.6, 5.5->1.11, 1.45->0.9, 3.5->0.6, 6.0->1.21, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0
#			when 21
				#  0         1           2         3    4      5         6                                 7                                      8 
				# F1,28/07/00,Marseille,3,Troyes,1,0.625369598137193,0.202987853070863,0.171642548791942, 1.65->1.03, 3.3->0.56, 4.3->0.87, 1.45->0.9, 3.5->0.6, 5.0->1.01, 1.53->0.95, 3.5->0.6, 5.5->1.11, 1.45->0.9, 3.5->0.6, 6.0->1.21, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0
			else
				raise "line #{i.commify} #{tta.inspect} unknown length #{tta.length}"
			end
	}	#	process all games
	ac	=	ApplicationController.new
	brh.each{|k,	v|
		keyy			=	k[0]+'^'+k[1].to_s
		puts	"building sum for #{k[0]} season #{k[1]}"
#		ac.makeswp(k[0],	k[1])
		ss			=	Sum.find_by_key(keyy)
		if	ss.nil?
			ss		=	Sum.new
			ss.key	=	keyy
		end
		puts	"sum is #{v.r2.commify}"
		ss.amount		=	v	#	@main['bankroll']
		ss.save!
	}
	  writeseasons(sh2)
  end

  def self.down
  end
end
