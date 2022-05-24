class DashboardController < ApplicationController
  def index
    @accounts = current_user.accounts
    @categories = current_user.categories.left_joins(:entries).where(entries: {type_id: 1}).group(:id).order('COUNT(entries.id) DESC')
    # @categories = current_user.categories.left_joins(:entries).where(entries: {type_id: 1}).group(:id).order('SUM(entries.value) DESC')

    user_cash_flow = account_service.user_cash_flow(current_user.id)
    cash_flow_state = user_cash_flow >= 0 ? "positive" : "negative"

    render 'index', locals: {user_cash_flow: user_cash_flow, cash_flow_state: cash_flow_state}
  end

  def categories_service
    @categories_service ||= CategoryService.new
  end

  def account_service
    @account_service ||= AccountService.new
  end
end