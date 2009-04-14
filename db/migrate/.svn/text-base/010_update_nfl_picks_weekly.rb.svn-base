require "migration_helpers"
class UpdateNflPicksWeekly < ActiveRecord::Migration
  extend MigrationHelpers
  def self.up
    updatea = IO.readlines(File.dirname(__FILE__) + '/../../public/nfl week 16 pick.txt')
    updatenflweeklypicks(updatea)
  end

  def self.down
  end
end
