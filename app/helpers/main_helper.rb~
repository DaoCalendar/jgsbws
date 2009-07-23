module MainHelper
	def gettitle(params)
		return "<h3>Joe Guy's 2007 National Football League Season</h3>" if params[:id].to_i == 0 and params[:league].to_i == 1
		return "<h3>Joe Guy's 2008 National Football League Season</h3>" if params[:id].to_i == 1 and params[:league].to_i == 1
		return "<h3>Joe Guy's 2008 National Basketball Association Season</h3>" if params[:league].to_i == 2 and params[:id].to_i == 1
		return "<h3>..Joe Guy's 2007 National Basketball Association Season</h3>" if params[:league].to_i == 2 and params[:id].to_i == 0
		return "<h3>Joe Guy's 2008 NCAA Football League Season</h3>" if params[:league].to_i == 4 and params[:id].to_i == 2
		return "<h3>Joe Guy's 2007 NCAA Football League Season</h3>" if params[:league].to_i == 4 and params[:id].to_i == 1
		return "<h3>Joe Guy's 2008 NCAA Basketball Season</h3>" if params[:league].to_i == 5 and params[:id].to_i == 2
		return "<h3>Joe Guy's 2007 NCAA Basketball Season</h3>" if params[:league].to_i == 5 and params[:id].to_i == 1
		raise "params.inspect #{params.inspect}"
	end
	
	def chargeshash(shash, weeklyinvestment, wins, losses, pushes, weeklywinmatrix, totalwinmatrix, suww, sulw, supw, suwy, suly, supy, weeklyprofit, tthash, mlhash, ww, lw) 
            shash["Weekly Investment"] = weeklyinvestment
            shash["Wins"]              = wins
            shash["Losses"]            = losses
            shash["Pushes"]            = pushes
            shash["Weekly Wins"]       = weeklywinmatrix[1][0]
            shash["Weekly Pushes"]     = weeklywinmatrix[1][1]
	    shash["Weekly Losses"]     = weeklywinmatrix[1][2]
	    shash["Weekly Wins"]		= 0.0 unless shash["Weekly Wins"].kind_of? Float
	    shash["Weekly Pushes"]	= 0.0 unless shash["Weekly Pushes"].kind_of? Float
	    shash["Weekly Losses"]	= 0.0 unless shash["Weekly Losses"].kind_of? Float
	    shash["Weekly Wins"]		= 0.0 if shash["Weekly Wins"].nan?
	    shash["Weekly Pushes"]	= 0.0 if shash["Weekly Pushes"].nan?
	    shash["Weekly Losses"]	= 0.0 if shash["Weekly Losses"].nan?
            shash["Total Wins"]	= totalwinmatrix[1][0] 
            shash["Total Pushes"]	= totalwinmatrix[1][1] 
            shash["Total Losses"]	= totalwinmatrix[1][2] 
            ww += 1 if shash["Weekly Wins"] > (shash["Weekly Losses"] * 1.1)
            lw += 1 if (shash["Weekly Losses"] * 1.1) > shash["Weekly Wins"]
            shash["SU Weekly Wins"]    = suww
            shash["SU Weekly Losses"]  = sulw
            shash["SU Weekly Pushes"]  = supw
            shash["SU Total Wins"]     = suwy
            shash["SU Total Losses"]   = suly
            shash["SU Total Pushes"]   = supy
            shash["Weekly Profit"]     = weeklyprofit
            shash["TT Bets"]           = tthash["bets"]   
            shash["TT Wins"]           = tthash["wins"]   
            shash["TT Losses"]         = tthash["losses"] 
            shash["TT Pushes"]         = tthash["pushes"]
            shash["Weekly TT Bets"]    = tthash["Weekly TT Bets"]
            shash["Weekly TT Wins"]    = tthash["Weekly TT Wins"]
            shash["Weekly TT Losses"]  = tthash["Weekly TT Losses"]
            shash["Weekly TT Pushes"]  = tthash["Weekly TT Pushes"]
	    shash["ml bets"]  = mlhash["ml bets"] 
	    shash["ml wins"]  = mlhash["ml wins"] 
	    shash["ml losses"]  = mlhash["ml losses"] 
	    shash["ml pushes"]  = mlhash["ml pushes"] 
	    shash["ml prize"]  = mlhash["ml prize"] 
	    shash["weekly ml bets"]     = mlhash["weekly ml bets"] 
	    shash["weekly ml wins"]     = mlhash["weekly ml wins"] 
	    shash["weekly ml losses"]   = mlhash["weekly ml losses"]  
	    shash["weekly ml pushes"] = mlhash["weekly ml pushes"] 
	    shash["weekly ml prize"] = mlhash["weekly ml prize"] 
            shash["Winning Weeks"]    = ww
            shash["Losing Weeks"]     = lw
	    return [shash, ww, lw]
	end
	def nflinit(leagueid)
		mlfullbet = 0.0
		brmlats = 1000
		betprob = []
		mlats   = 0.0
		mlsum = 0.0
		winprob  = 11.0/21.0
		weeklywinmatrix    = [[0, 0, 0],[0, 0, 0]]
		totalwinmatrix     = [[0, 0, 0],[0, 0, 0]]
		suww = sulw = supw = 0
		suwy = suly = supy = 0
		weeklyprofit            = 0
		isadmin            = false
		mlhash             = {}
		mlhash["ml bets"]     = 0
		mlhash["ml wins"]     = 0
		mlhash["ml losses"]   = 0
		mlhash["ml pushes"]   = 0
		mlhash["ml prize"]  = 0.0
		mlhash["weekly ml bets"]     = 0
		mlhash["weekly ml wins"]     = 0
		mlhash["weekly ml losses"]   = 0
		mlhash["weekly ml pushes"]   = 0
		mlhash["weekly ml prize"]   = 0.0
		tthash	=	{}
		tthash["bets"]     = 0
		tthash["wins"]     = 0
		tthash["losses"]   = 0
		tthash["pushes"]   = 0
		tthash["Weekly TT Bets"]   = 0
		tthash["Weekly TT Wins"]   = 0
		tthash["Weekly TT Losses"] = 0
		tthash["Weekly TT Pushes"] = 0
		wageramount	=	20
		ttwageramount	=	40 
		topten	=	0.75
		topten	=	0.9 if params[:id].to_i == 1
		winprob	=	0.9 if	leagueid	<=	2
		return mlfullbet, brmlats, betprob, mlats, mlsum, winprob, weeklywinmatrix, totalwinmatrix, suww, sulw, supw, suwy, suly, supy, weeklyprofit, isadmin, mlhash, tthash, wageramount, ttwageramount,  topten	
	end
	def  weeklyinit(p, wins, loses, pushes, weeklywinmatrix, weeklyinvestment, suww, sulw, supw, weekv, weeklyprofit, tthash, mlhash)
           wins = losses = pushes = 0 
           weeklywinmatrix    = [[0, 0, 0],[0, 0, 0]]
           weeklyinvestment   = 0 
           suww = sulw = supw = 0 
           weekv              = p.week 
           weeklyprofit       = 0 
           tthash["Weekly TT Bets"]   = 0 
           tthash["Weekly TT Wins"]   = 0 
           tthash["Weekly TT Losses"] = 0 
           tthash["Weekly TT Pushes"] = 0 
           mlhash["weekly ml bets"]     = 0 
           mlhash["weekly ml wins"]     = 0 
           mlhash["weekly ml losses"]   = 0 
           mlhash["weekly ml pushes"]   = 0 
           mlhash["weekly ml prize"]   = 0.0
	   return wins, loses, pushes, weeklywinmatrix, weeklyinvestment, suww, sulw, supw, weekv, weeklyprofit, tthash, mlhash
    end
end
