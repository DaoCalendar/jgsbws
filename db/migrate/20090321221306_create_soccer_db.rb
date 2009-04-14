class CreateSoccerDb < ActiveRecord::Migration
  def self.up
	create_table :soccers do |t|
#	Div
		t.column :div,				:text
#	Date
		t.column :game_date_time,	:timestamp
#	HomeTeam
		t.column :HomeTeam,	:integer
#	AwayTeam
		t.column :AwayTeam,	:integer
#	FTHG = Full Time Home Team Goals
		t.column :FTHG,	:integer
#	FTAG = Full Time Away Team Goals
		t.column :FTAG,	:integer
#	FTR = Full Time Result (H=Home Win, D=Draw, A=Away Win)
		t.column :FTR,	:text
#	HTHG = Half Time Home Team Goals
		t.column :HTHG,	:integer
#	HTAG = Half Time Away Team Goals
		t.column :HTAG,	:integer
#	HTR = Half Time Result (H=Home Win, D=Draw, A=Away Win)
		t.column :HTR,	:text
#	Referee = Match Referee
		t.column :Referee,	:text
#	HS = Home Team Shots
		t.column :HS,	:integer
#	AS = Away Team Shots
		t.column :AS,	:integer
#	HST = Home Team Shots on Target
		t.column :HST,	:integer
#	AST = Away Team Shots on Target
		t.column :AST,	:integer
#	HF = Home Team Fouls Committed
		t.column :HF,	:integer
#	AF = Away Team Fouls Committed
		t.column :AF,	:integer
#	HC = Home Team Corners
		t.column :HC,	:integer
#	AC = Away Team Corners
		t.column :AC,	:integer
#	HY = Home Team Yellow Cards
		t.column :HY,	:integer
#	AY = Away Team Yellow Cards
		t.column :AY,	:integer
#	HR = Home Team Red Cards
		t.column :HR,	:integer
#	AR = Away Team Red Cards
		t.column :AR,	:integer
#	B365H = Bet365 home win odds
		t.column :B365H,	:float
#	B365D = Bet365 draw odds
		t.column :B365D,	:float
#	B365A = Bet365 away win odds
		t.column :B365A,	:float
#	BWH = Bet&Win home win odds
		t.column :BWH,	:float
#	BWD = Bet&Win draw odds
		t.column :BWD,	:float
#	BWA = Bet&Win away win odds
		t.column :BWA,	:float
#	GBH = Gamebookers home win odds
		t.column :GBH,	:float
#	GBD = Gamebookers draw odds
		t.column :GBD,	:float
#	GBA = Gamebookers away win odds
		t.column :GBA,	:float
#	IWH = Interwetten home win odds
		t.column :IWH,	:float
#	IWD = Interwetten draw odds
		t.column :IWD,	:float
#	IWA = Interwetten away win odds
		t.column :IWA,	:float
#	LBH = Ladbrokes home win odds
		t.column :LBH,	:float
#	LBD = Ladbrokes draw odds
		t.column :LBD,	:float
#	LBA = Ladbrokes away win odds
		t.column :LBA,	:float
#	SBH = Sportingbet home win odds
		t.column :SBH,	:float
#	SBD = Sportingbet draw odds
		t.column :SBD,	:float
#	SBA = Sportingbet away win odds
		t.column :SBA,	:float
#	WHH = William Hill home win odds
		t.column :WHH,	:float
#	WHD = William Hill draw odds
		t.column :WHD,	:float
#	WHA = William Hill away win odds
		t.column :WHA,	:float
#	SJH = Stan James home win odds
		t.column :SJH,	:float
#	SJD = Stan James draw odds
		t.column :SJD,	:float
#	SJA = Stan James away win odds
		t.column :SJA,	:float
#	VCH = VC Bet home win odds
		t.column :VCH,	:float
#	VCD = VC Bet draw odds
		t.column :VCD,	:float
#	VCA = VC Bet away win odds
		t.column :VCA,	:float
#	BSH = Blue Square home win odds
		t.column :BSH,	:float
#	BSD = Blue Square draw odds
		t.column :BSD,	:float
#	BSA = Blue Square away win odds
		t.column :BSA,	:float
#	
#	
#	
#	Key to total goals betting odds:
#	
#	
#	GB>2.5 = Gamebookers over 2.5 goals
#	GB<2.5 = Gamebookers under 2.5 goals
#	B365>2.5 = Be365 over 2.5 goals
#	B365<2.5 = Be365 under 2.5 goals
#	
#	Key to Asian handicap betting odds:
#	
#	GBAHH = Gamebookers Asian handicap home team odds
#	GBAHA = Gamebookers Asian handicap away team odds
#	GBAH = Gamebookers size of handicap (home team)
#	LBAHH = Ladbrokes Asian handicap home team odds
#	LBAHA = Ladbrokes Asian handicap away team odds
#	LBAH = Ladbrokes size of handicap (home team)
#	B365AHH = Bet365 Asian handicap home team odds
#	B365AHA = Bet365 Asian handicap away team odds
#	B365AH = Bet365 size of handicap (home team)

#	Bb1X2 = Number of BetBrain bookmakers used to calculate match odds averages and maximums
		t.column :Bb1X2,	:float
#	BbMxH = Betbrain maximum home win odds
		t.column :BbMxH,	:float
#	BbAvH = Betbrain average home win odds
		t.column :BbAvH,	:float
#	BbMxD = Betbrain maximum draw odds
		t.column :BbMxD,	:float
#	BbAvD = Betbrain average draw win odds
		t.column :BbAvD,	:float
#	BbMxA = Betbrain maximum away win odds
		t.column :BbMxA,	:float
#	BbAvA = Betbrain average away win odds
		t.column :BbAvA,	:float
#	BbOU = Number of BetBrain bookmakers used to calculate over/under 2.5 goals (total goals) averages and maximums
		t.column :BbOU,	:float
#	BbMx>2.5 = Betbrain maximum over 2.5 goals
		t.column :BbMx,	:float
#	BbAv>2.5 = Betbrain average over 2.5 goals
		t.column :BbAv,	:float
#	BbMx<2.5 = Betbrain maximum under 2.5 goals
		t.column :BbMx,	:float
#	BbAv<2.5 = Betbrain average under 2.5 goals
		t.column :BbAv,	:float
#	BbAH = Number of BetBrain bookmakers used to Asian handicap averages and maximums
		t.column :BbAH,	:float
#	BbAHh = Betbrain size of handicap (home team)
		t.column :BbAHh,	:float
#	BbMxAHH = Betbrain maximum Asian handicap home team odds
		t.column :BbMxAHH,	:float
#	BbAvAHH = Betbrain average Asian handicap home team odds
		t.column :BbAvAHH,	:float
#	BbMxAHA = Betbrain maximum Asian handicap away team odds
		t.column :BbMxAHA,	:float
#	BbAvAHA = Betbrain average Asian handicap away team odds
		t.column :BbAvAHA,		:float
	end
  end

  def self.down
    drop_table :soccers
  end
end
