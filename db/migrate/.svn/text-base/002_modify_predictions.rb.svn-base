class ModifyPredictions < ActiveRecord::Migration
  def self.up
    add_column :predictions, :prob_home_win_su,  :float, :default => 0.0
    add_column :predictions, :prob_away_win_su,  :float, :default => 0.0
    add_column :predictions, :prob_push_su,      :float, :default => 0.0
    add_column :predictions, :prob_home_win_ats, :float, :default => 0.0
    add_column :predictions, :prob_away_win_ats, :float, :default => 0.0
    add_column :predictions, :prob_push_ats,     :float, :default => 0.0
    Prediction.reset_column_information
  end

  def self.down
    remove_column :predictions, :prob_home_win_su
    remove_column :predictions, :prob_away_win_su
    remove_column :predictions, :prob_push_su
    remove_column :predictions, :prob_home_win_ats
    remove_column :predictions, :prob_away_win_ats
    remove_column :predictions, :prob_push_ats
  end
end
