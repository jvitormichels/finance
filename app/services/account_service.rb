class AccountService
  def initialize
  end
  
  def update_balance(account_id, value)
    account = Account.where(id: account_id).first
    balance = account.balance + value
    account.update(balance: balance)
  end
end