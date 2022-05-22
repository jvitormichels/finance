class InstallmentsController < ApplicationController
  def index
    @installments = current_user.installments
  end

  def show
    @installment = current_user.installments.where(id: params['id']).first
    @entries = @installment.entries

    render 'show', locals: { real_expense: @installment.real_expense }
  end

  def new
    @installment = Installment.new
  end

  def create
    installment = Installment.new(installment_params)
    installment.user_id = current_user.id
    installment.save

    redirect_to '/installments'
  end

  def edit
    @installment = current_user.installments.where(id: params['id']).first
  end

  def update
    installment = Installment.where(id: params['id']).first
    installment.update(installment_params)

    redirect_to '/installments'
  end

  def destroy
    Installment.where(id: params['id']).first.destroy

    redirect_to '/installments'
  end

  private

  def installment_params
    params.require(:installment).permit(Installment.allowed_params)
  end
end