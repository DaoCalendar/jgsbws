class CreateShortLeagues < ActiveRecord::Migration
	require "migration_helpers"
	extend MigrationHelpers
	def self.up # this is the intersection table between the small D1 type descs and the big German First Division type decs
		begin
			create_table :short_leagues do |t|
				t.column :league_id,		:integer
				t.column :shortname,	:text
				t.timestamps
			end
			foreign_key(:short_leagues, :league_id, :leagues)
		rescue
		end
		la	=	["Belgian First Division","German First Division","German Second Division","English Premier League","English First Division","English Second Division","English Third Division","English Championship","French First Division","French Second Division","Greek First Division","Italian First Division","Italian Second Division","Netherlands First Division","Portuguies First Division","Scottish Premier League","Scottish First Division","Scottish Second Division","Scottish Third Division","Spanish First Division","Spanish Second Division","Turkish First Division"]
		sla	=	['B1','D1','D2','E0','E1','E2','E3','EC','F1','F2','G1','I1','I2','N1','P1','SC0','SC1','SC2','SC3','SP1','SP2','T1']
		la.each_with_index{|l,	i|
			raise	if	sla[i].nil?
			lid			=	getlid(l)
			sl			=	ShortLeague.new
#			puts	sl.methods
#			puts "l #{l} lid #{lid}"
#			puts sl.type
#			puts sl.inspect
			sl["league_id"]	=	lid
			sl.shortname	=	sla[i]
			sl.save!
		}
  end

  def self.down
	  drop_table :short_leagues
  end

end
