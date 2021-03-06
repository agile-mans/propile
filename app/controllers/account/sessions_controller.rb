class Account::SessionsController < ApplicationController
  skip_before_filter :authorize_action, :only => [:new, :create]
  layout 'account'
  def new
    @account = Account.new
  end

  def create
    @account = Account.authenticate_by_email_and_password(account_params[:email], account_params[:password])
    if @account 
      sign_in @account
      redirect_to @account.landing_page
    else
      flash.alert = 'e-mail ou mot de passe incorrect'
      @account = Account.new
      render :action => 'new'
    end
  end

  def destroy
    sign_out
    redirect_to root_path
  end
  private 

  def account_params
    @account_params ||= params[:account]
  end
end
