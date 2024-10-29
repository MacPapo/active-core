# frozen_string_literal: true

# Membership Presenter
class MembershipPresenter
  include Rails.application.routes.url_helpers

  def initialize(membership)
    @membership = membership
  end

  def appropriate_path(user)
    case membership_handler
    when :active
      membership_path(@membership)
    when :inactive
      new_payment_path(eid: @membership.id, type: 'mem')
    when :expired
      renew_membership_path(@membership, user_id: user&.id)
    when :deleted
      restore_membership_path(@membership)
    else
      new_membership_path(user_id: user&.id)
    end
  end

  def method
    return :patch if membership_handler == :deleted

    :get
  end

  def link_title
    return I18n.t('global.restore') if membership_handler == :deleted
    return @membership.humanize_status unless membership_handler == :empty

    I18n.t('empty')
  end

  def link_icon
    case membership_handler
    when :active
      'me-1 text-secondary bi bi-eye-fill'
    when :inactive
      'me-1 text-secondary bi bi-credit-card'
    when :expired
      'me-1 text-secondary bi bi-arrow-clockwise'
    when :deleted
      'me-1 text-secondary bi bi-recycle'
    else
      'me-1 text-secondary bi bi-plus-circle-fill'
    end
  end

  def css_color
    case membership_handler
    when :active
      'success'
    when :inactive
      'info'
    when :expired
      'warning'
    when :deleted
      'restore'
    else
      'danger'
    end
  end

  private

  def membership_handler
    return :deleted if @membership&.discarded?

    return :active if @membership&.active?
    return :inactive if @membership&.inactive?
    return :expired if @membership&.expired?

    :empty
  end
end
