class AddMlb < ActiveRecord::Migration
	require "migration_helpers"
	extend MigrationHelpers
	def self.up
		league = "Major League Baseball"
		ut = ["Arizona Diamondbacks", "Atlanta Braves", "Baltimore Orioles", "Boston Red Sox", "Chicago Cubs", "Chicago White Sox", "Cincinnati Reds", "Cleveland Indians", "Colorado Rockies", "Detroit Tigers", "Florida Marlins", "Houston Astros", "Kansas City Royals", "Los Angeles Angels", "Los Angeles Dodgers", "Milwaukee Brewers", "Minnesota Twins", "New York Mets", "New York Yankees", "Oakland Athletics", "Philadelphia Phillies", "Pittsburgh Pirates", "San Diego Padres", "San Francisco Giants", "Seattle Mariners", "St. Louis Cardinals", "Tampa Bay Devil Rays", "Texas Rangers", "Toronto Blue Jays", "Washington Nationals"]
		l	=	League.find_by_name(league)
		League.create(:name=>league)	if l.nil?
		ut.each{|tt|
			t = Team.find_by_name(tt)
			Team.create(:name=>tt) if t.nil?
		}
	end

	def self.down
	end
end
