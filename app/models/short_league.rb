class ShortLeague < ActiveRecord::Base
	has_many	:leagues, :foreign_key=>'league_id'
end
