class AddTriggersToSubscriptions < ActiveRecord::Migration[7.1]
  def up
    execute <<-SQL
      CREATE TRIGGER after_subscription_insert
      AFTER INSERT ON subscriptions
      FOR EACH ROW
      BEGIN
        INSERT INTO subscription_histories (renewal_date, old_end_date, new_end_date, action, activity_plan_id, staff_id, created_at, updated_at)
        VALUES (NEW.start_date, NULL, NEW.end_date, 0, NEW.id, NEW.staff_id, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);
      END;
    SQL

    execute <<-SQL
      CREATE TRIGGER after_subscription_update
      AFTER UPDATE OF end_date ON subscriptions
      FOR EACH ROW
      BEGIN
        INSERT INTO subscription_histories (renewal_date, old_end_date, new_end_date, action, activity_plan_id, staff_id, created_at, updated_at)
        VALUES (CURRENT_TIMESTAMP, OLD.end_date, NEW.end_date, 1, NEW.id, NEW.staff_id, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);
      END;
    SQL

    execute <<-SQL
      CREATE TRIGGER after_subscription_delete
      AFTER DELETE ON subscriptions
      FOR EACH ROW
      BEGIN
        INSERT INTO subscription_histories (renewal_date, old_end_date, new_end_date, action, activity_plan_id, staff_id, created_at, updated_at)
        VALUES (CURRENT_TIMESTAMP, OLD.end_date, NULL, 2, OLD.id, OLD.staff_id, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);
      END;
    SQL
  end

  def down
    execute <<-SQL
      DROP TRIGGER IF EXISTS after_subscription_insert;
      DROP TRIGGER IF EXISTS after_subscription_update;
      DROP TRIGGER IF EXISTS after_subscription_delete;
    SQL
  end
end
