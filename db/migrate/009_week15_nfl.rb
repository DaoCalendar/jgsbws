require "migration_helpers"
class Week15Nfl < ActiveRecord::Migration
  extend MigrationHelpers
  def self.up
    updatea = IO.readlines(File.dirname(__FILE__) + '/../../public/nfl week 15.txt')
    updatenflweekly(updatea)
  end

  def self.down
  end
end
