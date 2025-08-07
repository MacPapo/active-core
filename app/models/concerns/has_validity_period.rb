module HasValidityPeriod
  extend ActiveSupport::Concern

  included do
    # Aggiunge uno scope per trovare tutti gli oggetti validi in una certa data.
    scope :available_on, ->(date) {
      where("valid_from IS NULL OR valid_from <= ?", date)
        .where("valid_until IS NULL OR valid_until >= ?", date)
    }
  end

  # Metodo per controllare la validità di una singola istanza.
  def is_available?(date = Date.current)
    (valid_from.nil? || valid_from <= date) && (valid_until.nil? || valid_until >= date)
  end
end
