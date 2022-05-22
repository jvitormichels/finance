class AccountService
  def cash_flow(account_id, year = Date.current.year, month = Date.current.month)
    account = Account.where(id: account_id).first
    expense_total = account.entries.where(type_id: 1).sum(:value)
    income_total = account.entries.where(type_id: 2).sum(:value)
    income_total - expense_total
  end

  def add_balance(account_id, value)
    account = Account.where(id: account_id).first
    balance = account.balance + value
    account.update(balance: balance)
  end

  def subtract_balance(account_id, value)
    account = Account.where(id: account_id).first
    balance = account.balance - value
    account.update(balance: balance)
  end

  # def update_balance(account_id, values)
  def update_balance(account_id, value)
    account = Account.where(id: account_id).first
    # difference = values[0] - values[1]
    # account.balance += value
    account.balance += value
    account.save
  end
end