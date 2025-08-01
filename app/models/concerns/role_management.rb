module RoleManagement
  extend ActiveSupport::Concern

  included do
    enum :role, { collaborator: 0, instructor: 1, admin: 2 },
         prefix: true, validate: true

    scope :staff, -> { where.not(role: nil) }
    scope :management, -> { where(role: [ :instructor, :admin ]) }
    scope :by_role, ->(role) { where(role: role) if role.present? }
  end

  def management_role?
    role_instructor? || role_admin?
  end

  def can_manage_members?
    management_role?
  end

  def can_process_payments?
    !role_collaborator?
  end

  def role_hierarchy_level
    case role
    when "admin" then 3
    when "instructor" then 2
    when "collaborator" then 1
    else 0
    end
  end
end
