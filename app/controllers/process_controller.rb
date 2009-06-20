class ProcessController < ApplicationController
require "migration_helpers"
extend MigrationHelpers
Keystring					=	"05b76c924d8d2ebc2f9771c5195a9790e8b5135fad77e9b11eac2848f781c25b53316dc727efef2a7b354c980b5524f499da2237e5a6daa7a9abbd032ca1cad6add5d365d7a189"
def index
		passed_key			=	params[:id]
		# process data from the net if it's ok
		tl				=	Time.now
		key				=	Digest::SHA1.hexdigest("#{tl.year}-#{tl.month}-#{tl.day}-#{Keystring}")
		return unless key == passed_key
		da				=	IO.readlines(File.dirname(__FILE__) + '/../../app/procdata/procdata.dat')
		return unless key == da.first.chomp
		ula				=	[]	# build unique league array
		da.each_with_index{|l,	i|
			next if	i	==	0
			league	=	l.split(',')[0]
			ula	<<	league	unless	ula.include?(league)
		}
		#	home and away scores are -1 for future games
		#	date league home away homescore awayscore spread homeml awayml drawml probhomewinSU probawaywinSU probdrawSU probhomecoverATS probawaycoverATS probpushATS
		#	for individual bookie odds post like this xxx->1.23 - check all items for -> for this.
		ula.each{|l|
			case	l
				when	'NBA'
					nba		=	da.dup
					nnba		=	[]
					nba.delete_if{|g|
						ga	=	g.split(',')
						!(ga[0]	==	'NBA')
					}
					nba.each{|n|
						#remove nba at the beginning of each line
						nnba	<<	n.gsub('NBA,','')
					}
#					raise "nnba #{nnba.inspect}"
					nbaloader(nnba,	true)
				when	'NHL'
					nhl		=	da.dup
					nnhl		=	[]
					nhl.delete_if{|g|
						ga	=	g.split(',')
						!(ga[0]	==	'NHL')
					}
					nhl.each{|n|
						#remove nhl at the beginning of each line
						nnhl	<<	n.gsub('NHL,','')
					}
#					raise "nnhl #{nnhl.inspect}"
					nbaloader(nnhl,	true,	"National Hockey League")
			end
		}
#		render :nothing
	end
end
