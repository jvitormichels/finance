class EntriesController < ApplicationController
  def new
    @entry = Entry.new
    @account_id = params['account_id']

    render 'new'
  end

  def create
    entry_params = params['entry']
    entry = Entry.create(title: entry_params['title'], description: entry_params['description'], value: entry_params['value'], account_id: entry_params['account_id'], value: entry_params['value'])
    account_service.update_balance(entry.account_id, 0 - entry.value)

    redirect_to root_path
  end

  def edit
    @entry = Entry.where(id: params['id']).first
    @accounts = Account.all.pluck(:name, :id)

    render 'edit'
  end

  def update
    entry = Entry.where(id: params['id']).first
    old_value = entry.value
    entry_params = params['entry']
    entry.update(title: entry_params['title'], description: entry_params['description'], value: entry_params['value'], account_id: entry_params['account_id'], value: entry_params['value'])
    account_service.update_balance(entry.account_id, old_value - entry.value)
  end

  def destroy
    entry = Entry.where(id: params['id']).first
    AccountService.new.update_balance(entry.account_id, entry.value)
    entry.destroy

    respond_to do |format|
      format.js {render inline: "location.reload();" }
    end
  end

  private

  def account_service
    @account_service ||= AccountService.new
  end
end