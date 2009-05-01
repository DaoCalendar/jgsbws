class League < ActiveRecord::Base
   has_many :teams
   belongs_to :predictions
   belongs_to	:short_leagues
end
