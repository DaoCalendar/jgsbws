class PredictionsController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @prediction_pages, @predictions = paginate :predictions, :per_page => 10, :order=>"game_date_time DESC"
  end

  def show
    @prediction = Prediction.find(params[:id])
  end

  def new
    @prediction = Prediction.new
  end

  def create
    @prediction = Prediction.new(params[:prediction])
    if @prediction.save
      flash[:notice] = 'Prediction was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @prediction = Prediction.find(params[:id])
  end

  def update
    @prediction = Prediction.find(params[:id])
    if @prediction.update_attributes(params[:prediction])
      flash[:notice] = 'Prediction was successfully updated.'
      redirect_to :action => 'show', :id => @prediction
    else
      render :action => 'edit'
    end
  end

  def destroy
    Prediction.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
