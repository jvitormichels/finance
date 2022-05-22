class EntriesController < ApplicationController
  def new
    @entry = Entry.new
    @categories = current_user.categories.pluck(:name, :id)
    @installments = current_user.installments.pluck(:name, :id)
    @accounts = current_user.accounts.pluck(:name, :id)

    render 'new'
  end

  def create
    data = params.require(:entry).permit(Entry.allowed_params)
    entry = Entry.create(data)

    if entry.type_id == 1
      account_service.subtract_balance(entry.account_id, entry.value)
    elsif entry.type_id == 2
      account_service.add_balance(entry.account_id, entry.value)
    end

    redirect_to root_path
  end

  def edit
    @entry = Entry.where(id: params['id']).first
    @categories = current_user.categories.pluck(:name, :id)
    @installments = current_user.installments.pluck(:name, :id)
    @accounts = current_user.accounts.pluck(:name, :id)

    render 'edit'
  end

  def update
    entry = Entry.where(id: params['id']).first
    data = params.require(:entry).permit(Entry.allowed_params)
    entry.assign_attributes(data)
    value_changes = entry.changes['value']
    entry.save

    if value_changes.present?
      if entry.type_id == 1
        values = value_changes[0] - value_changes[1]
      elsif entry.type_id == 2
        values = value_changes[1] - value_changes[0]
      end
      account_service.update_balance(entry.account_id, values)
    end
    # account_service.update_balance(entry.account_id, values) if value_changes.present?
    
    redirect_to "/accounts/#{entry.account.id}"
  end

  def destroy
    entry = Entry.where(id: params['id']).first
    # account_service.add_balance(entry.account_id, entry.value)
    if entry.type_id == 1
      account_service.add_balance(entry.account_id, entry.value)
    elsif entry.type_id == 2
      account_service.subtract_balance(entry.account_id, entry.value)
    end
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