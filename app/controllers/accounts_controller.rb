class AccountsController < ApplicationController
  def index
    @accounts = current_user.accounts
  end

  def show
    @account = Account.where(id: params['id']).first
    @entries = @account.entries.order(date: :desc)

    cash_flow = account_service.account_cash_flow(@account.id)
    cash_flow_state = cash_flow >= 0 ? "positive" : "negative"
    render 'show', locals: {cash_flow: cash_flow.abs, cash_flow_state: cash_flow_state}
  rescue
    redirect_to root_path
  end

  def new
    @account = Account.new
    render 'new'
  end

  def create
    account = Account.new(account_params)
    account.user_id = current_user.id
    account.save

    redirect_to root_path
  end

  def edit
    @account = Account.where(id: params['id']).first
    render 'edit'
  end

  def update
    account = Account.where(id: params['id']).first
    account_params = params['account']
    account.update(account_params)

    redirect_to root_path
  end

  def destroy
    Account.where(id: params['id']).first.destroy

    respond_to do |format|
      format.js {render inline: "location.reload();" }
    end
  end

  private

  def account_params
    params.require(:account).permit(Account.allowed_params)
  end

  def account_service
    @account_service ||= AccountService.new
  end
end