class PlansController < ApplicationController
  def index
    @plans = Plan.all.order(name: :asc)
  end

  def show
    @plan = Plan.find(params[:id])
  end
end
