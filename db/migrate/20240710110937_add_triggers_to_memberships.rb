class AddTriggersToMemberships < ActiveRecord::Migration[7.1]
  def up
    execute <<-SQL
      CREATE TRIGGER after_membership_insert
      AFTER INSERT ON memberships
      FOR EACH ROW
      BEGIN
        INSERT INTO membership_histories (start_date, end_date, action, membership_id, user_id, staff_id, created_at, updated_at)
        VALUES (NEW.date, NULL, 0, NEW.id, NEW.user_id, NEW.staff_id, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);
      END;
    SQL

    execute <<-SQL
      CREATE TRIGGER after_membership_update
      AFTER UPDATE OF end_date ON memberships
      FOR EACH ROW
      BEGIN
        INSERT INTO membership_histories (start_date, end_date, action, membership_id, user_id, staff_id, created_at, updated_at)
        VALUES (OLD.date, NEW.date, 1, NEW.id, NEW.user_id, NEW.staff_id, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);
      END;
    SQL

    execute <<-SQL
      CREATE TRIGGER after_membership_delete
      AFTER DELETE ON memberships
      FOR EACH ROW
      BEGIN
        INSERT INTO membership_histories (start_date, end_date, action, membership_id, user_id, staff_id, created_at, updated_at)
        VALUES (OLD.date, OLD.end_date, 2, OLD.id, OLD.user_id, OLD.staff_id, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);
      END;
    SQL
  end

  def down
    execute <<-SQL
      DROP TRIGGER IF EXISTS after_membership_insert;
      DROP TRIGGER IF EXISTS after_membership_update;
      DROP TRIGGER IF EXISTS after_membership_delete;
    SQL
  end
end
