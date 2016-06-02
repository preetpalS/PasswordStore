
module PasswordStore
  # Wraps database backend
  class Storage
    def all_targets
      (@db.execute @sql_resources['all_targets']).flatten
    end

    # [hash (value), target (name), whether_hash_is_still_valid (0 or 1)]
    def all_hash_target_combos
      @db.execute @sql_resources['all_hashes']
    end

    # Assumes `hashes.valid_from` is not in future (extra validation logic would be
    # needed to deal with this not being the case)
    def store_hash(hash, target)
      transition_time = Time.now.to_i
      should_invalidate_existing_hash = any_hashes_for_target(target)
      t_id = target_id(target)

      @db.transaction do |db|
        invalidate_existing_hash(target_id: t_id,
                                 transition_time: (user_transition_time || transition_time),
                                 db: db) if should_invalidate_existing_hash
        create_hash(hash: hash, target_id: t_id, transition_time: transition_time, db: db)
      end
    end

    def any_hashes_for_target(target)
      db_result = @db.execute <<SQL, [target_id(target)]
SELECT * FROM hashes WHERE target_id = ?
SQL
      !db_result.empty?
    end

    # Creates target if target not found
    def target_id(target)
      db_result = @db.execute 'SELECT id FROM targets WHERE target = ?', target
      return db_result[0][0] unless db_result.empty?

      now = Time.now.to_i
      @db.execute <<SQL, [target, now, now, now]
INSERT INTO targets (target, created_at, updated_at, valid_from)
VALUES (?, ?, ?, ?)
SQL
      target_id(target)
    end

    def initialize(settings)
      @settings = settings
      @sql_resources = Res::SQL.new @settings
      @filename = @settings[:database_filename]
      open_db
    end

    private

    def open_db
      is_schema_initialized = File.exist?(@filename) ? true : false
      @db = SQLite3::Database.new @filename
      @db.execute_batch(@sql_resources['schema']) unless is_schema_initialized
      @db.execute 'PRAGMA foreign_keys = ON;'
    end

    def invalidate_existing_hash(target_id:,
                                 transition_time: Time.now,
                                 now: Time.now, db: nil)
      db = @db if db.nil?
      db.execute(<<SQL, [transition_time.to_i, now.to_i, target_id])
UPDATE hashes
SET valid_to = ?, updated_at = ?
WHERE target_id = ? AND valid_to IS NULL
SQL
    end

    def create_hash(hash:, target_id:, transition_time:,
                    now: Time.now, db: nil)
      db = @db if db.nil?
      db.execute <<SQL, [hash, now.to_i, now.to_i, transition_time.to_i, target_id]
INSERT INTO hashes (hash, created_at, updated_at, valid_from, target_id)
VALUES (?, ?, ?, ?, ?)
SQL
    end

    def user_transition_time
      print 'What time did you change the password (leave blank if you just changed it now)? '
      input = STDIN.cooked(&:gets).strip
      Time.parse(input) unless input == ''
    end
  end
end
