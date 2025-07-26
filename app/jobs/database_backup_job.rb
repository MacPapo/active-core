# frozen_string_literal: true

# Database Backup Job
class DatabaseBackupJob < ApplicationJob
  queue_as :background

  def perform
    conn = ActiveRecord::Base.connection
    backup_file = Rails.root.join("db", "backups", "#{Rails.env}_backup_#{Time.zone.now.strftime("%Y%m%d%H%M%S")}.sqlite3")
    quoted_path = conn.quote(backup_file.to_s)

    conn.execute("VACUUM INTO #{quoted_path}")
    Rails.logger.info "Backup SQLite created: #{backup_file}"

    latest_alias = backup_directory.join("latest.sqlite3")
    FileUtils.ln_sf(backup_file.to_s, latest_alias)

    Rails.logger.info "Alias updated: #{latest_alias} -> #{backup_file}"
  end
end
