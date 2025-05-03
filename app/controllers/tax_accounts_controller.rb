class TaxAccountsController < ApplicationController
  def new
    @tax_account = Current.user.tax_accounts.build
  end

  def create
    @tax_account = Current.user.tax_accounts.build(tax_account_params)

    if @tax_account.save
      redirect_to root_path, notice: "Tax account added successfully."
    else
      render :new, status: :unprocessable_entityñ
    end
  end

  private

  def tax_account_params
    params.require(:tax_account).permit(:rut, :password)
  end
end
