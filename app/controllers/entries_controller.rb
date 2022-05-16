class EntriesController < ApplicationController
  def new
    @entry = Entry.new
    @account_id = params['account_id']

    render 'new'
  end

  def create
    entry = params['entry']
    Entry.create(title: entry['title'], description: entry['description'], value: entry['value'], account_id: entry['account_id'], value: entry['value'])

    redirect_to root_path
  end

  def edit
    @entry = Entry.where(id: params['id']).first
    @accounts = Account.all.pluck(:name, :id)

    render 'edit'
  end

  def update
    entry = Entry.where(id: params['id']).first
    entry_params = params['entry']
    entry.update(title: entry_params['title'], description: entry_params['description'], value: entry_params['value'], account_id: entry_params['account_id'], value: entry_params['value'])
  end

  def destroy
    Entry.where(id: params['id']).first.destroy

    respond_to do |format|
      format.js {render inline: "location.reload();" }
    end
  end
end