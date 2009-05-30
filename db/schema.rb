# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 30) do

  create_table "leagues", :force => true do |t|
    t.string   "name"
    t.string   "short_league"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "predictions", :force => true do |t|
    t.datetime "game_date_time"
    t.integer  "league"
    t.integer  "soccer_bet"
    t.integer  "week",                    :default => 0
    t.integer  "season",                  :default => 0
    t.integer  "home_team_id"
    t.integer  "away_team_id"
    t.float    "spread"
    t.integer  "predicted_home_score",    :default => -1
    t.integer  "predicted_away_score",    :default => -1
    t.integer  "actual_home_score",       :default => -1
    t.integer  "actual_away_score",       :default => -1
    t.integer  "joe_guys_bet"
    t.integer  "joe_guys_bet_amount",     :default => 10
    t.integer  "joe_guys_bet_amount_won"
    t.integer  "moneyline_home",          :default => -110
    t.integer  "moneyline_away",          :default => -110
    t.integer  "moneyline_bet",           :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "prob_home_win_su",        :default => 0.0
    t.float    "prob_away_win_su",        :default => 0.0
    t.float    "prob_push_su",            :default => 0.0
    t.float    "prob_home_win_ats",       :default => 0.0
    t.float    "prob_away_win_ats",       :default => 0.0
    t.float    "prob_push_ats",           :default => 0.0
    t.float    "game_total",              :default => 0.0
    t.float    "prob_game_over_total",    :default => 0.0
  end

  create_table "sessions", :force => true do |t|
    t.string   "session_id"
    t.text     "data"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "soccer_bets", :force => true do |t|
    t.float    "B365H"
    t.float    "B365H_ev"
    t.float    "B365D"
    t.float    "B365D_ev"
    t.float    "B365A"
    t.float    "B365A_ev"
    t.float    "BWH"
    t.float    "BWH_ev"
    t.float    "BWD"
    t.float    "BWD_ev"
    t.float    "BWA"
    t.float    "BWA_ev"
    t.float    "GBH"
    t.float    "GBH_ev"
    t.float    "GBD"
    t.float    "GBD_ev"
    t.float    "GBA"
    t.float    "GBA_ev"
    t.float    "IWH"
    t.float    "IWH_ev"
    t.float    "IWD"
    t.float    "IWD_ev"
    t.float    "IWA"
    t.float    "IWA_ev"
    t.float    "LBH"
    t.float    "LBH_ev"
    t.float    "LBD"
    t.float    "LBD_ev"
    t.float    "LBA"
    t.float    "LBA_ev"
    t.float    "SBH"
    t.float    "SBH_ev"
    t.float    "SBD"
    t.float    "SBD_ev"
    t.float    "SBA"
    t.float    "SBA_ev"
    t.float    "WHH"
    t.float    "WHH_ev"
    t.float    "WHD"
    t.float    "WHD_ev"
    t.float    "WHA"
    t.float    "WHA_ev"
    t.float    "SJH"
    t.float    "SJH_ev"
    t.float    "SJD"
    t.float    "SJD_ev"
    t.float    "SJA"
    t.float    "SJA_ev"
    t.float    "VCH"
    t.float    "VCH_ev"
    t.float    "VCD"
    t.float    "VCD_ev"
    t.float    "VCA"
    t.float    "VCA_ev"
    t.float    "BSH"
    t.float    "BSH_ev"
    t.float    "BSD"
    t.float    "BSD_ev"
    t.float    "BSA"
    t.float    "BSA_ev"
    t.float    "BbMxgt2p5"
    t.float    "BbMxgt2p5_ev"
    t.float    "BbMxlt2p5"
    t.float    "BbMxlt2p5_ev"
    t.float    "BbAvgt2p5"
    t.float    "BbAvgt2p5_ev"
    t.float    "BbAvlt2p5"
    t.float    "BbAvlt2p5_ev"
    t.float    "GBgt2p5"
    t.float    "GBgt2p5_ev"
    t.float    "GBlt2p5"
    t.float    "GBlt2p5_ev"
    t.float    "B365gt2p5"
    t.float    "B365gt2p5_ev"
    t.float    "B365lt2p5"
    t.float    "B365lt2p5_ev"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "strengths", :force => true do |t|
    t.integer  "week"
    t.integer  "team_id"
    t.float    "off_strength"
    t.float    "def_strength"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "strengths", ["team_id"], :name => "fk_strengths_team_id"

  create_table "sums", :force => true do |t|
    t.string   "key"
    t.float    "amount",     :default => 0.0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "teams", :force => true do |t|
    t.string   "name"
    t.integer  "league_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "teams", ["league_id"], :name => "fk_teams_league_id"

  create_table "users", :force => true do |t|
    t.string   "login"
    t.string   "email"
    t.string   "crypted_password",          :limit => 40
    t.string   "salt",                      :limit => 40
    t.string   "remember_token"
    t.datetime "remember_token_expires_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "pw_reset_code",             :limit => 40
  end

end
