class AddNhl < ActiveRecord::Migration
	require "migration_helpers"
	extend MigrationHelpers
	def self.up
		ut = ["Anaheim Ducks", "Atlanta Thrashers", "Boston Bruins", "Buffalo Sabres", "Calgary Flames", "Carolina Hurricanes", "Chicago Blackhawks", "Colorado Avalanche", "Columbus Blue Jackets", "Dallas Stars", "Detroit Red Wings", "Edmonton Oilers", "Florida Panthers", "Los Angeles Kings", "Minnesota Wild", "Montreal Canadiens", "Nashville Predators", "New Jersey Devils", "New York Islanders", "New York Rangers", "Ottawa Senators", "Philadelphia Flyers", "Phoenix Coyotes", "Pittsburgh Penguins", "San Jose Sharks", "St. Louis Blues", "Tampa Bay Lightning", "Toronto Maple Leafs", "Vancouver Canucks", "Washington Capitals"]
		l	=	League.find_by_name("National Hockey League")
		League.create(:name=>"National Hockey League")	if l.nil?
		ut.each{|tt|
			t = Team.find_by_name(tt)
			Team.create(:name=>tt) if t.nil?
		}
	end

	def self.down
	end
end
