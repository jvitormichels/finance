class AccountService
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