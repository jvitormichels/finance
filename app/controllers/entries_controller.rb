class EntriesController < ApplicationController
  def index
    # Entry.all.group_by { |m| m.created_at.beginning_of_month }
    @entries = get_all_records("entry")
  end

  def show
    @entry = redis_client.hgetall("entry:#{params['id']}")
  end

  def new
    load_related_objects

    render 'new'
  end

  def create
    new_id = redis_client.hmget("next_object_ids", "entry")[0] || 1
    redis_client.hmset("next_object_ids", "entry", (new_id.to_i + 1))
    redis_client.mapped_hmset("entry:#{new_id}", entry_params)
    redis_client.mapped_hmset("entry:#{new_id}", {"id": new_id})
    entry = redis_client.hgetall("entry:#{new_id}")

    if entry['type_id'] == '1'
      account_service.subtract_balance(entry['account_id'], entry['value'])
    elsif entry['type_id'] == '2'
      account_service.add_balance(entry['account_id'], entry['value'])
    end

    redirect_to root_path
  end

  def edit
    @entry = redis_client.hgetall("entry:#{params['id']}")
    load_related_objects

    render 'edit'
  end

  def update
    old_value = redis_client.hgetall("entry:#{params['id']}")['value']
    redis_client.mapped_hmset("entry:#{params['id']}", entry_params)
    entry = redis_client.hgetall("entry:#{params['id']}")
    value_changes = [old_value, entry_params['value']]

    if entry['type_id'] == '1'
      values = value_changes[0].to_f - value_changes[1].to_f
    elsif entry['type_id'] == '2'
      values = value_changes[1].to_f - value_changes[0].to_f
    end

    account_service.update_balance(entry['account_id'], values)

    redirect_to "/accounts/#{entry['account_id']}"
  end

  def destroy
    entry = redis_client.hgetall("entry:#{params['id']}")
    if entry['type_id'] == '1'
      account_service.add_balance(entry['account_id'], entry['value'])
    elsif entry['type_id'] == '2'
      account_service.subtract_balance(entry['account_id'], entry['value'])
    end
    redis_client.del("entry:#{params['id']}")

    respond_to do |format|
      format.js { render inline: "location.reload();" }
    end
  end

  private

  def load_related_objects
    @categories = get_all_records("category", ['name', 'id'])
    @installments = get_all_records("installment", ['name', 'id'])
    @accounts = get_all_records("account", ['name', 'id'])
  end

  def get_all_records(record_type, columns = [])
    objects = []
    object_keys = redis_client.keys("#{record_type}:*")
    object_keys.each do |key|
      object = columns.present? ? redis_client.hmget(key, columns) : redis_client.hgetall(key)
      objects.push(object)
    end
    objects
  end

  def entry_params
    params.require(:entry).permit(Entry.allowed_params).to_h
  end

  def redis_client
    Redis.new(host: "redis")
  end

  def account_service
    @account_service ||= AccountService.new
  end
end