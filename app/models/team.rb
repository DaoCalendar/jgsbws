class Team < ActiveRecord::Base
  belongs_to :league
  belongs_to :predictions
  has_many :strengths
end
