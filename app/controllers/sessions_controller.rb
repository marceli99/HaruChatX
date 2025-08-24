# frozen_string_literal: true

class SessionsController < ApplicationController
  allow_unauthenticated_access only: %i[new create]
  layout 'auth', only: %i[new create]

  def new; end

  def create
    if (user = User.authenticate_by(email_address: params[:email_address], password: params[:password]))
      start_new_session_for(user)
      redirect_to after_authentication_url, notice: t('flash.sessions.create.success')
    else
      flash.now[:alert] = t('flash.sessions.create.failure')
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    terminate_session
    redirect_to new_session_url, notice: t('flash.sessions.destroy.success')
  end
end
