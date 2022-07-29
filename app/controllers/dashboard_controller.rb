class DashboardController < ApplicationController
  def index
    @accounts = get_all_records("account").select {|account| account['user_id'] == current_user.id.to_s }

    user_cash_flow = account_service.user_cash_flow(current_user.id)
    cash_flow_state = user_cash_flow >= 0 ? "positive" : "negative"

    render 'index', locals: {user_cash_flow: user_cash_flow, cash_flow_state: cash_flow_state}
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

  def categories_service
    @categories_service ||= CategoryService.new
  end

  def account_service
    @account_service ||= AccountService.new
  end
end