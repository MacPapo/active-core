class AddTriggersToSubscriptions < ActiveRecord::Migration[7.1]
  def up

    # TRACK CREATION
    execute <<-SQL
      CREATE TRIGGER after_subscription_insert
      AFTER INSERT ON subscriptions
      FOR EACH ROW
      BEGIN
        INSERT INTO subscription_histories (subscription_id, renewal_date, old_end_date, new_end_date, action, created_at, updated_at)
        VALUES (NEW.id, NEW.start_date, NULL, NEW.end_date, 0, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);
      END;
    SQL

    # TRACK RENEWAL
    execute <<-SQL
      CREATE TRIGGER after_subscription_update_end_date
      AFTER UPDATE OF end_date ON subscriptions
      FOR EACH ROW
      BEGIN
        INSERT INTO subscription_histories (subscription_id, renewal_date, old_end_date, new_end_date, action, created_at, updated_at)
        VALUES (NEW.id, NEW.start_date, OLD.end_date, NEW.end_date, 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);
      END;
    SQL

    # TRACK ACTIVATION
    execute <<-SQL
      CREATE TRIGGER after_subscription_update_status
      AFTER UPDATE OF status ON subscriptions
      FOR EACH ROW
      BEGIN
        INSERT INTO subscription_histories (subscription_id, renewal_date, old_end_date, new_end_date, action, created_at, updated_at)
        VALUES (NEW.id, NEW.start_date, NEW.end_date, NULL, 2, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);
      END;
    SQL

    # TODO set after update on discarded_at (gem Discard)
    # execute <<-SQL
    #   CREATE TRIGGER after_subscription_delete
    #   AFTER DELETE ON subscriptions
    #   FOR EACH ROW
    #   BEGIN
    #     INSERT INTO subscription_histories (renewal_date, old_end_date, new_end_date, action, activity_plan_id, staff_id, created_at, updated_at)
    #     VALUES (CURRENT_TIMESTAMP, OLD.end_date, NULL, 2, OLD.id, OLD.staff_id, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);
    #   END;
    # SQL
  end

  def down
    # DROP TRIGGER IF EXISTS after_subscription_delete;
    execute <<-SQL
      DROP TRIGGER IF EXISTS after_subscription_insert;
      DROP TRIGGER IF EXISTS after_subscription_update_end_date;
      DROP TRIGGER IF EXISTS after_subscription_update_status;
    SQL
  end
end
