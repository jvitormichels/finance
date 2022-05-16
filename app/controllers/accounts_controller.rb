class AccountsController < ApplicationController
  def index
    @accounts = Account.all
  end

  def show
    
  end

  def new
    @account = Account.new
    render 'new'
  end

  def create
    account = params['account']
    Account.create(name: account['name'], color: account['color'], balance: account['balance'])

    redirect_to root_path
  end

  def edit
    @account = Account.where(id: params['id']).first
    render 'edit'
  end

  def update
    account = Account.where(id: params['id']).first
    account_params = params['account']
    account.update(name: account_params['name'], color: account_params['color'], balance: account_params['balance'])
  end

  def destroy
    Account.where(id: params['id']).first.destroy

    respond_to do |format|
      format.js {render inline: "location.reload();" }
    end
  end

  private

  def account_params
    params['account']
  end
end