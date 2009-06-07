class ProcessController < ApplicationController
	def main
		passed_key	=	params[:id]
		# process data from the net if it's ok
		tl			=	Time.local
		key			=	Digest::SHA1.hexdigest("#{key.year}	#{key.month}#{key.day} 05b76c924d8d2ebc2f9771c5195a9790e8b5135fad77e9b11eac2848f781c25b53316dc727efef2a7b354c980b5524f499da2237e5a6daa7a9abbd032ca1cad6add5d365d7a189")
		return unless key == passed_key
		da			=	IO.readlines(File.dirname(__FILE__) + '/../../app/procdata/procdata.dat')
		return unless key == da.first.chomp
	end
end
