class InstallmentsController < ApplicationController
  def index
    @installments = get_all_records("installment").select { |installment| installment['user_id'] == current_user.id.to_s }
  end

  def show
    @installment = redis_client.hgetall("installment:#{params['id']}")
    @entries = get_all_records("entry").select { |entry| entry['installment_id'] == @installment['id']}

    expenses = @entries.select { |entry| entry['type_id'] == '1' }.sum { |entry| entry['value'].to_i }
    incomes = @entries.select { |entry| entry['type_id'] == '2' }.sum { |entry| entry['value'].to_i }
    real_expense = expenses - incomes
    installment_state = real_expense >= 0 ? "positive" : "negative"
    balance = @installment['planned_expense'].to_i - real_expense

    render 'show', locals: { real_expense: real_expense, balance: balance, installment_state: installment_state }
  end

  def new
  end

  def create
    new_id = redis_client.hmget("next_object_ids", "installment")[0] || 1
    redis_client.hmset("next_object_ids", "installment", (new_id.to_i + 1))
    redis_client.mapped_hmset("installment:#{new_id}", installment_params)
    redis_client.mapped_hmset("installment:#{new_id}", {"user_id": current_user.id, "id": new_id})

    redirect_to '/installments'
  end

  def edit
    @installment = redis_client.hgetall("installment:#{params['id']}")
  end

  def update
    redis_client.mapped_hmset("installment:#{params['id']}", installment_params)

    redirect_to '/installments'
  end

  def destroy
    redis_client.del("installment:#{params['id']}")
    installment_entry_keys = redis_client.keys("entry:*")
    installment_entry_keys.each do |key|
      byebug
      entry = redis_client.hgetall(key)
      redis_client.hmset(key, "installment_id", "") if entry['installment_id'] == params['id']
    end

    redirect_to '/'
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

  def installment_params
    params.require(:installment).permit(Installment.allowed_params).to_h
  end
end