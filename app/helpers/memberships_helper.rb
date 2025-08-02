module MembershipsHelper
  def membership_status_options
    Membership.statuses.map do |key, value|
      [ key.humanize, key ]
    end
  end
end
