# frozen_string_literal: true

# Application Controller
class ApplicationController < ActionController::Base
  include Pagy::Backend

  # before_action :authenticate_user! TODO

  private

  def authorize_internal_access!
    unless current_user&.staff?
      redirect_to root_path, alert: "Accesso negato. Solo personale interno."
    end
  end

  # Per controller che richiedono privilegi admin
  def authorize_admin!
    unless current_user&.role_admin?
      redirect_to root_path, alert: "Accesso negato. Privilegi amministratore richiesti."
    end
  end
end
