class AccountService
  def account_cash_flow(account_id, year = Date.current.year, month = Date.current.month)
    account = Account.where(id: account_id).first
    entries = account.entries.where('extract(year from date) = ?', year).where('extract(month from date) = ?', month)
    expense_total = entries.where(type_id: 1).sum(:value)
    income_total = entries.where(type_id: 2).sum(:value)
    income_total - expense_total
  end

  def user_cash_flow(user_id, year = Date.current.year, month = Date.current.month)
    user = User.where(id: user_id).first
    entries = user.entries.where('extract(year from date) = ?', year).where('extract(month from date) = ?', month)
    expense_total = entries.where(type_id: 1).sum(:value)
    income_total = entries.where(type_id: 2).sum(:value)
    income_total - expense_total
  end

  def add_balance(account_id, value)
    account = Account.where(id: account_id).first
    balance = account.balance + value.to_i
    account.update(balance: balance)
  end

  def subtract_balance(account_id, value)
    account = Account.where(id: account_id).first
    balance = account.balance - value.to_i
    account.update(balance: balance)
  end

  # def update_balance(account_id, values)
  def update_balance(account_id, value)
    account = Account.where(id: account_id).first
    # difference = values[0] - values[1]
    # account.balance += value
    account.balance += value.to_i
    account.save
  end
end