class Prediction < ActiveRecord::Base
	has_many	:teams
	has_many	:leagues
end
