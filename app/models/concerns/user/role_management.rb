module User::RoleManagement
  extend ActiveSupport::Concern

  included do
    enum :role, { user: 0, collaborator: 1, admin: 2 }, prefix: true, validate: true

    scope :staff, -> { where(role: [ :collaborator, :admin ]) }
    scope :by_role, ->(role) { where(role: role) if role.present? }
  end

  def staff?
    role_collaborator? || role_admin?
  end

  def can_manage_members?
    staff?
  end

  def can_process_payments?
    staff?
  end

  def can_manage_system?
    role_admin?
  end

  def can_view_reports?
    staff?
  end

  def can_manage_discounts?
    role_admin?
  end

  # TODO localization
  def role_display_name
    I18n.t("activerecord.attributes.user.roles.#{role}")
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
