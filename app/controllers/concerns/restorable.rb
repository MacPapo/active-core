module Restorable
  extend ActiveSupport::Concern

  private

  def restore_record(record, redirect_path)
    record.undiscard
    redirect_to redirect_path, notice: "#{record.class.name} ripristinato con successo."
  end
end
