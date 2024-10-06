# frozen_string_literal: true

class AddDiscardedAtToLegalGuardians < ActiveRecord::Migration[7.1]
  def change
    add_column :legal_guardians, :discarded_at, :datetime
    add_index :legal_guardians, :discarded_at
  end
end
