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

ActiveRecord::Schema.define(:version => 20090322120649) do

  create_table "leagues", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "predictions", :force => true do |t|
    t.datetime "game_date_time"
    t.integer  "league"
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

  create_table "soccers", :force => true do |t|
    t.text     "div"
    t.datetime "game_date_time"
    t.integer  "HomeTeam"
    t.integer  "AwayTeam"
    t.integer  "FTHG"
    t.integer  "FTAG"
    t.text     "FTR"
    t.integer  "HTHG"
    t.integer  "HTAG"
    t.text     "HTR"
    t.text     "Referee"
    t.integer  "HS"
    t.integer  "AS"
    t.integer  "HST"
    t.integer  "AST"
    t.integer  "HF"
    t.integer  "AF"
    t.integer  "HC"
    t.integer  "AC"
    t.integer  "HY"
    t.integer  "AY"
    t.integer  "HR"
    t.integer  "AR"
    t.float    "B365H"
    t.float    "B365D"
    t.float    "B365A"
    t.float    "BWH"
    t.float    "BWD"
    t.float    "BWA"
    t.float    "GBH"
    t.float    "GBD"
    t.float    "GBA"
    t.float    "IWH"
    t.float    "IWD"
    t.float    "IWA"
    t.float    "LBH"
    t.float    "LBD"
    t.float    "LBA"
    t.float    "SBH"
    t.float    "SBD"
    t.float    "SBA"
    t.float    "WHH"
    t.float    "WHD"
    t.float    "WHA"
    t.float    "SJH"
    t.float    "SJD"
    t.float    "SJA"
    t.float    "VCH"
    t.float    "VCD"
    t.float    "VCA"
    t.float    "BSH"
    t.float    "BSD"
    t.float    "BSA"
    t.float    "Bb1X2"
    t.float    "BbMxH"
    t.float    "BbAvH"
    t.float    "BbMxD"
    t.float    "BbAvD"
    t.float    "BbMxA"
    t.float    "BbAvA"
    t.float    "BbOU"
    t.float    "BbMx"
    t.float    "BbAv"
    t.float    "BbAH"
    t.float    "BbAHh"
    t.float    "BbMxAHH"
    t.float    "BbAvAHH"
    t.float    "BbMxAHA"
    t.float    "BbAvAHA"
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
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "remember_token"
    t.datetime "remember_token_expires_at"
    t.string   "pw_reset_code",             :limit => 40
  end

end
