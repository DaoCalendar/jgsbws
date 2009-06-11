class AddNba < ActiveRecord::Migration
require "migration_helpers"
extend MigrationHelpers
# NBA season is october to june
def self.up
	nba2008a	=	IO.readlines(File.dirname(__FILE__) + '/../../public/jgsbws nba2008.dat')
#	puts nba2008a.length
#	sleep 3
	nba2008a.reject!{|g|g.include?('*')}
	nba2008a.reject!{|g|g.empty?}
	nbaloader(nba2008a)
end

def self.down
end
end
