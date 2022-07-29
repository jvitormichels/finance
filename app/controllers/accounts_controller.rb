class AccountsController < ApplicationController
  def index
    @accounts = get_all_records("account").select { |account| account['user_id'] == current_user.id.to_s }
    # @accounts = current_user.accounts
  end

  def show
    @account = redis_client.hgetall("account:#{params['id']}")
    @entries = get_all_records("entry").select { |entry| entry['account_id'] == @account['id'] }

    cash_flow = account_service.account_cash_flow(@account['id'])
    cash_flow_state = cash_flow >= 0 ? "positive" : "negative"
    render 'show', locals: {cash_flow: cash_flow.abs, cash_flow_state: cash_flow_state}

    # @account = Account.where(id: params['id']).first
    # @entries = @account.entries.order(date: :desc)

    # cash_flow = account_service.account_cash_flow(@account.id)
    # cash_flow_state = cash_flow >= 0 ? "positive" : "negative"
    # render 'show', locals: {cash_flow: cash_flow.abs, cash_flow_state: cash_flow_state}
  rescue
    redirect_to root_path
  end

  def new
    # @account = Account.new
    # @account = {"name": "", "balance": 0, "user_id": 0}
    render 'new'
  end

  def create
    new_id = redis_client.hmget("next_object_ids", "account")[0]
    redis_client.hmset("next_object_ids", "account", (new_id.to_i + 1))
    redis_client.mapped_hmset("account:#{new_id}", account_params.to_h)
    redis_client.mapped_hmset("account:#{new_id}", {"id": new_id, "user_id": current_user.id.to_s})
    
    # account = Account.new(account_params)
    # account.user_id = current_user.id
    # account.save

    redirect_to root_path
  end

  def edit
    @account = redis_client.hgetall("account:#{params['id']}")
    # @account = Account.where(id: params['id']).first
    render 'edit'
  end

  def update
    redis_client.mapped_hmset("account:#{params['id']}", account_params)

    # account = Account.where(id: params['id']).first
    # account_params = params['account']
    # account.update(account_params)

    redirect_to root_path
  end

  def destroy
    redis_client.del("account:#{params['id']}")
    account_entries = get_all_records("entry").select { |entry| entry['account_id'] == params['id'] }
    account_entries.each do |account_entry|
      redis_client.del("entry:#{account_entry['id']}")
    end
    # Account.where(id: params['id']).first.destroy

    respond_to do |format|
      format.js {render inline: "location.reload();" }
    end
  end

  private

  def get_all_records(record_type, columns = [])
    objects = []
    object_keys = redis_client.keys("#{record_type}:*")
    object_keys.each do |key|
      object = columns.present? ? redis_client.hmget(key, columns) : redis_client.hgetall(key)
      objects.push(object)
    end
    objects
  end

  def redis_client
    Redis.new(host: "redis")
  end

  def account_params
    params.require(:account).permit(Account.allowed_params).to_h
  end

  def account_service
    @account_service ||= AccountService.new
  end
end