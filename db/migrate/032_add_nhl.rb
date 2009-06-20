class AddNhl < ActiveRecord::Migration
	require "migration_helpers"
	extend MigrationHelpers
	def self.up
		l	=	League.find_by_name("National Hockey League")
		League.create(:name=>"National Hockey League")	if l.nil?
		nhla	=	IO.readlines(File.dirname(__FILE__) + '/../../public/nhl 2008.dat')
		ut	=	[]
		nhla.each{|n|
			#       0      1              2                        3                 4                5
			# 1/12/07,62,ottawa senators,4.76587455572964,2,new york rangers,2.10970666785615,5,0.0,0.841807858456952,0.696522031469374,-160.0,1.0,-1,1,Spread bet wrong,N O,TT OU right,N O,Home Moneyline wrong,N O, 1, 0, 0, 1, 1
			ta	=	n.split(',')
			ut	<<	ta[2]	unless	ut.include?(ta[2])
			ut	<<	ta[5]	unless	ut.include?(ta[5])
		}
		ut.sort!
		ut.each{|tt|
			t	=	Team.find_by_name(tt)
			Team.create(:name=>tt)	if	t.nil?
		}
	end

	def self.down
	end
end
