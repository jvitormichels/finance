class DashboardController < ApplicationController
  def index
    @accounts = Account.all
    render 'index'
  end
end