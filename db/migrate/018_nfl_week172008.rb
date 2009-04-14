require "migration_helpers"
class NflWeek172008 < ActiveRecord::Migration
  extend MigrationHelpers
  def self.up
    updatea = IO.readlines(File.dirname(__FILE__) + '/../../public/nfl week 17 2008.txt')
    updatenflweekly(updatea)
  end


  def self.down
  end
end
