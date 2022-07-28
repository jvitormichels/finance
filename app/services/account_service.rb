class AccountService
  def account_cash_flow(account_id, year = Date.current.year, month = Date.current.month)
    byebug
    account = redis_client.hgetall("account:#{account_id}")
    entries = get_all_records("entry").select { |entry| entry['account_id'] == account['id'] && entry['date'].to_date.year == year && entry['date'].to_date.month == month }
    expense_total = entries.select { |entry| entry['type_id'] == '1' }.sum { |entry| entry['value'].to_i }
    income_total = entries.select { |entry| entry['type_id'] == '2' }.sum { |entry| entry['value'].to_i }
    income_total - expense_total

    # account = Account.where(id: account_id).first
    # entries = account.entries.where('extract(year from date) = ?', year).where('extract(month from date) = ?', month)
    # expense_total = entries.where(type_id: 1).sum(:value)
    # income_total = entries.where(type_id: 2).sum(:value)
    # income_total - expense_total
  end

  def user_cash_flow(user_id, year = Date.current.year, month = Date.current.month)
    accounts = get_all_records("account").select { |account| account['user_id'] == user_id.to_s }
    entries = get_all_records("entry").select { |entry| accounts.pluck('id').include?(entry['account_id']) && entry['date'].to_date.year == year && entry['date'].to_date.month == month }
    expense_total = entries.select { |entry| entry['type_id'] == '1' }.sum { |entry| entry['value'].to_i }
    income_total = entries.select { |entry| entry['type_id'] == '2' }.sum { |entry| entry['value'].to_i }
    income_total - expense_total

    # user = User.where(id: user_id).first
    # entries = user.entries.where('extract(year from date) = ?', year).where('extract(month from date) = ?', month)
    # expense_total = entries.where(type_id: 1).sum(:value)
    # income_total = entries.where(type_id: 2).sum(:value)
    # income_total - expense_total
  end

  def add_balance(account_id, value)
    balance = redis_client.hmget("account:#{account_id}", "balance")[0].to_i
    new_balance = balance + value.to_i
    redis_client.hmset("account:#{account_id}", "balance", new_balance)

    # account = Account.where(id: account_id).first
    # balance = account.balance + value.to_i
    # account.update(balance: balance)
  end

  def subtract_balance(account_id, value)
    byebug
    balance = redis_client.hmget("account:#{account_id}", "balance")[0].to_i
    new_balance = balance - value.to_i
    redis_client.hmset("account:#{account_id}", "balance", new_balance)

    # account = Account.where(id: account_id).first
    # balance = account.balance - value.to_i
    # account.update(balance: balance)
  end

  # def update_balance(account_id, values)
  def update_balance(account_id, value)
    balance = redis_client.hmget("account:#{account_id}", "balance")[0].to_i
    new_balance = balance + value.to_i
    redis_client.hmset("account:#{account_id}", "balance", new_balance)

    # account = Account.where(id: account_id).first
    # # difference = values[0] - values[1]
    # # account.balance += value
    # account.balance += value.to_i
    # account.save
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
end