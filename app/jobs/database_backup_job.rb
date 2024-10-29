# frozen_string_literal: true

# Database Backup Job
class DatabaseBackupJob < ApplicationJob
  queue_as :background

  def perform
    backup_directory = Rails.root.join('db/backups')

    timestamp = Time.zone.now.strftime('%Y%m%d%H%M%S')
    backup_file = backup_directory.join("#{Rails.env}_backup_#{timestamp}.sqlite3")

    ActiveRecord::Base.connection.execute("VACUUM INTO '#{backup_file}'")
    Rails.logger.info "Backup SQLite created: #{backup_file}"

    latest_alias = backup_directory.join('latest.sqlite3')
    FileUtils.ln_sf(backup_file, latest_alias)
    Rails.logger.info "Alias updated: #{latest_alias} -> #{backup_file}"
  end
end
