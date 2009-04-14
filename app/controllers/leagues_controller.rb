class LeaguesController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @league_pages, @leagues = paginate :leagues, :per_page => 10
  end

  def show
    @league = League.find(params[:id])
  end

  def new
    @league = League.new
  end

  def create
    @league = League.new(params[:league])
    if @league.save
      flash[:notice] = 'League was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @league = League.find(params[:id])
  end

  def update
    @league = League.find(params[:id])
    if @league.update_attributes(params[:league])
      flash[:notice] = 'League was successfully updated.'
      redirect_to :action => 'show', :id => @league
    else
      render :action => 'edit'
    end
  end

  def destroy
    League.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
