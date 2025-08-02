module RoleManagement
  extend ActiveSupport::Concern

  included do
    enum :role, {
           user: 0,
           collaborator: 1,
           admin: 2
         }, prefix: true, validate: true

    scope :staff, -> { where(role: [ :collaborator, :admin ]) }
    scope :internal_only, -> { where(role: [ :collaborator, :admin ]) }
    scope :by_role, ->(role) { where(role: role) if role.present? }
  end

  def staff?
    role_collaborator? || role_admin?
  end

  def internal_user?
    staff? # Per ora solo staff ha accesso interno
  end

  def can_manage_members?
    staff? # Sia collaboratori che admin possono gestire membri
  end

  def can_process_payments?
    staff? # Sia collaboratori che admin possono processare pagamenti
  end

  def can_manage_system?
    role_admin? # Solo admin può gestire sistema, utenti, configurazioni
  end

  def can_view_reports?
    staff? # Tutti gli staff possono vedere i report
  end

  def can_manage_discounts?
    role_admin? # Solo admin può creare/modificare sconti
  end

  def role_display_name
    case role
    when "admin" then "Amministratore"
    when "collaborator" then "Collaboratore"
    when "user" then "Utente" # Non usato ora
    else "Sconosciuto"
    end
  end

  def role_hierarchy_level
    case role
    when "admin" then 2
    when "collaborator" then 1
    when "user" then 0
    else 0
    end
  end
end
