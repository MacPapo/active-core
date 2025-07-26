namespace :db do
  desc "Restore production database to latest.sqlite3 backup"
  task restore_from_backup: :environment do
    backup_file = Rails.root.join("db/backups/latest.sqlite3")
    production_db = Rails.root.join("storage/production.sqlite3")

    unless File.exist?(backup_file)
      puts "Backup file not found: #{backup_file}"
      exit
    end

    timestamp = Time.zone.now.strftime("%Y%m%d%H%M%S")
    FileUtils.mv(production_db, Rails.root.join("db", "production_backup_before_restore_#{timestamp}.sqlite3"))

    FileUtils.cp(backup_file, production_db)

    puts "Database restored."
  end
end
