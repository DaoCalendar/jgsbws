class GetSoccer < ActiveRecord::Migration
	require "migration_helpers"
	extend MigrationHelpers
  def self.up
	ta	=	IO.readlines('public/unique soccer games.txt')
	#	 0       1           2       3      4          5                    6                         7                                 8
	#	D2,31/07/93,F Koln,2,Wolfsburg,0,0.487945405691188,0.252207074068463,0.259847520240348, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0
	sh	=	{}
	ta.each_with_index{|g,	i|
		next if i < 42_374 # temp to get us to the bookie games fast
		g.chomp! # remove \n
		while g[-1,	1]	==	' ' || g[-1,	1]	==	',' do
#			puts g+'<' 
#			sleep 1
			g.chop!
		end
		puts g
#		raise
		tta					=	g.chomp.split(',')
		tta.delete(' ') if tta.include?(' ')
		tta.pop	if	tta.last.strip.empty?
		puts tta.length
#		raise tta.inspect
		case tta.length
			when 12,	15,	18,	24
				raise unless g.include?('->')
				p,	sh		=	fronthalf(sh,	tta)
				sb			=	SoccerBet.new
				sb.prediction_id	=	p.id	# note - there is a better way to do this
				tta.each{|t|
					next unless t.include?('->')
					# D2,27/04/09,Osnabruck,0,Hansa Rostock,0,0.309049752014374,0.433344489670393,0.257605758315232, B365H->2.6->0.8, B365D->3.1->0.79, B365A->2.6->1.12, BWH->2.65->0.81, BWD->3.1->0.79, BWA->2.5->1.08, GBH->2.6->0.8, GBD->3.2->0.82, GBA->2.55->1.1, IWH->2.6->0.8, IWD->3.2->0.82, IWA->2.6->1.12, LBH->2.5->0.77, LBD->3.1->0.79, LBA->2.5->1.08, SBH->2.65->0.81, SBD->3.2->0.82, SBA->2.45->1.06, WHH->2.5->0.77, WHD->3.1->0.79, WHA->2.5->1.08, VCH->2.6->0.8, VCD->3.2->0.82, VCA->2.5->1.08, BbMx>2.5->1.92->0.95, BbMx<2.5->2.05->1.03, BbAv>2.5->1.79->0.88, BbAv<2.5->1.94->0.97
					ta		=	t.split('->')
					bookie	=	ta[0].strip
					odds		=	ta[1].to_f
					ev		=	ta[2].to_f
					puts ">#{bookie}<"
					puts odds
					begin
						puts "sb[bookie] b4 #{sb[bookie].inspect}"
						sb[bookie]		=	odds
						puts "sb[bookie] after #{sb[bookie].inspect}"
						sb[bookie+'_ev']	=	ev
					rescue
						raise "No such bookie as #{bookie}"
					end
				}
				sb.save!
				puts sb.inspect
#				sleep 5
			when 17,	9
				p,	sh		=	fronthalf(sh,	tta)
			when 29
				#  0         1           2         3    4      5         6                                 7                                      8 
				# F1,28/07/00,Marseille,3,Troyes,1,0.625369598137193,0.202987853070863,0.171642548791942, 1.65->1.03, 3.3->0.56, 4.3->0.87, 1.45->0.9, 3.5->0.6, 5.0->1.01, 1.53->0.95, 3.5->0.6, 5.5->1.11, 1.45->0.9, 3.5->0.6, 6.0->1.21, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0
			when 21
				#  0         1           2         3    4      5         6                                 7                                      8 
				# F1,28/07/00,Marseille,3,Troyes,1,0.625369598137193,0.202987853070863,0.171642548791942, 1.65->1.03, 3.3->0.56, 4.3->0.87, 1.45->0.9, 3.5->0.6, 5.0->1.01, 1.53->0.95, 3.5->0.6, 5.5->1.11, 1.45->0.9, 3.5->0.6, 6.0->1.21, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0
			else
				raise "line #{i.commify} #{tta.inspect} unknown length #{tta.length}"
			end
	  }
  end

  def self.down
  end
end
