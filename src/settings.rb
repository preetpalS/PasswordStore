
module PasswordStore
  # Contains settings (TODO: load configuration overrides from config files)
  class Settings < Hash
    def initialize
      super
      load
    end

    private

    def load
      self[:cost] = 20
      self[:database_filename] = 'db.sqlite3'
      self[:asset_load_path] = 'src/res'
    end
  end
end
