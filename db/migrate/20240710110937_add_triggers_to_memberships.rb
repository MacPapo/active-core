class AddTriggersToMemberships < ActiveRecord::Migration[7.1]
  def up
    execute <<-SQL
      CREATE TRIGGER after_membership_insert
      AFTER INSERT ON memberships
      FOR EACH ROW
      BEGIN
        INSERT INTO membership_histories (user_id, membership_id, renewal_date, old_end_date, new_end_date, action, staff_id, created_at, updated_at)
        VALUES (NEW.user_id, NEW.id, NEW.start_date, NULL, NEW.end_date, 0, NEW.staff_id, NEW.created_at, NEW.updated_at);
      END;
    SQL

    execute <<-SQL
      CREATE TRIGGER after_membership_update
      AFTER UPDATE OF end_date ON memberships
      FOR EACH ROW
      BEGIN
        INSERT INTO membership_histories (user_id, membership_id, renewal_date, old_end_date, new_end_date, action, staff_id, created_at, updated_at)
        VALUES (NEW.user_id, NEW.id, NEW.start_date, OLD.end_date, NEW.end_date, 1, NEW.staff_id, NEW.created_at, NEW.updated_at);
      END;
    SQL

    # TODO set after update on discarded_at (gem Discard)
    # execute <<-SQL
    #   CREATE TRIGGER after_membership_delete
    #   AFTER DELETE ON memberships
    #   FOR EACH ROW
    #   BEGIN
    #     INSERT INTO membership_histories (user_id, membership_id, renewal_date, old_end_date, new_end_date, action, staff_id, created_at, updated_at)
    #     VALUES (OLD.user_id, OLD.id, OLD.start_date, OLD.end_date, NULL, 2, OLD.staff_id, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);
    #   END;
    # SQL
  end

  def down

    # DROP TRIGGER IF EXISTS after_membership_delete;
    execute <<-SQL
      DROP TRIGGER IF EXISTS after_membership_insert;
      DROP TRIGGER IF EXISTS after_membership_update;
    SQL
  end
end
