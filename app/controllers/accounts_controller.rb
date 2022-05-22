class AccountsController < ApplicationController
  def index
    @accounts = current_user.accounts
  end

  def show
    @account = Account.where(id: params['id']).first
    @entries = @account.entries

    render 'show'
  end

  def new
    @account = Account.new
    render 'new'
  end

  def create
    Account.create(account_params)

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
end