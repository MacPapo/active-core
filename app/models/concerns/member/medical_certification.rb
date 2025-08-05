module Member::MedicalCertification
  extend ActiveSupport::Concern

  included do
    validates :med_cert_issue_date,
              comparison: {
                less_than_or_equal_to: -> { Date.current },
                greater_than: -> { 2.years.ago }
              },
              allow_blank: true

    scope :with_valid_certificate, -> {
      where(med_cert_issue_date: 1.year.ago..)
    }

    scope :certificate_expiring_soon, -> {
      where(med_cert_issue_date: 1.year.ago..11.months.ago)
    }
  end

  def medical_certificate_valid?
    # med_cert_issue_date && med_cert_issue_date > 1.year.ago TODO
    true
  end

  def medical_certificate_expired?
    !medical_certificate_valid?
  end

  def medical_certificate_expires_on
    med_cert_issue_date + 1.year if med_cert_issue_date
  end

  def certificate_expires_in_days
    return unless medical_certificate_valid?
    (medical_certificate_expires_on - Date.current).to_i
  end
end
