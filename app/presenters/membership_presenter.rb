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
      new_payment_path(payable_type: 'Membership', payable_id: @membership.id)
    when :expired
      renew_membership_path(@membership, user_id: user&.id)
    else
      new_membership_path(user_id: user&.id)
    end
  end

  def link_title
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
    else
      'danger'
    end
  end

  private

  def membership_handler
    return :empty unless @membership

    return :active if @membership.active?
    return :inactive if @membership.inactive?
    return :expired if @membership.expired?

    :empty
  end
end
