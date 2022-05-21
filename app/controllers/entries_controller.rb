class EntriesController < ApplicationController
  def new
    @entry = Entry.new
    @accounts = Account.all.pluck(:name, :id)

    render 'new'
  end

  def create
    entry_params = params['entry']
    entry = Entry.create(title: entry_params['title'], description: entry_params['description'], value: entry_params['value'], account_id: entry_params['account_id'], value: entry_params['value'])
    account_service.subtract_balance(entry.account_id, entry.value)

    redirect_to root_path
  end

  def edit
    @entry = Entry.where(id: params['id']).first
    @accounts = Account.all.pluck(:name, :id)

    render 'edit'
  end

  def update
    entry = Entry.where(id: params['id']).first
    data = params.require(:entry).permit(Entry.allowed_params)
    entry.assign_attributes(data)
    value_changes = entry.changes['value']
    entry.save
    account_service.update_balance(entry.account_id, value_changes) if value_changes.present?
    
    redirect_to "/accounts/#{entry.account.id}"
  end

  def destroy
    entry = Entry.where(id: params['id']).first
    account_service.add_balance(entry.account_id, entry.value)
    entry.destroy

    respond_to do |format|
      format.js { render inline: "location.reload();" }
    end
  end

  private

  def account_service
    @account_service ||= AccountService.new
  end
end