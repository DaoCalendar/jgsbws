class CreatePredictions < ActiveRecord::Migration
  def self.up
    create_table :predictions do |t|
      t.column :game_date_time,          :timestamp
      t.column :league,                  :integer
      t.column :week,                    :integer, :default=>0
      t.column :season,                  :integer, :default=>0
      t.column :home_team_id,            :integer
      t.column :away_team_id,            :integer
      t.column :spread,                  :float
      t.column :predicted_home_score,    :integer, :default=>-1
      t.column :predicted_away_score,    :integer, :default=>-1
      t.column :actual_home_score,       :integer, :default=>-1
      t.column :actual_away_score,       :integer, :default=>-1
      t.column :joe_guys_bet,            :integer
      t.column :joe_guys_bet_amount,     :integer, :default=>10
      t.column :joe_guys_bet_amount_won, :integer
      t.column :moneyline_home, :integer, :default=>-110
      t.column :moneyline_away, :integer, :default=>-110
      t.column :moneyline_bet, :integer, :default=>0
      t.column :created_at,              :timestamp
      t.column :updated_at,              :timestamp
    end
  end

  def self.down
    drop_table :predictions
  end
end
