# frozen_string_literal: true

class AddDiscardedAtToStaffs < ActiveRecord::Migration[7.1]
  def change
    add_column :staffs, :discarded_at, :datetime
    add_index :staffs, :discarded_at
  end
end
