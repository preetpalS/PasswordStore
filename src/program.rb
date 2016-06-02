
module PasswordStore
  # Controls program flow.
  class Program
    def initialize
      @settings = Settings.new
      @text_resources = Res::Text.new @settings
      @storage = Storage.new @settings
      puts @text_resources['splash']

      loop do
        puts @text_resources['main_menu']
        main_loop
      end
    end

    private

    def main_loop
      case STDIN.cooked(&:gets).strip.to_i
      when 1
        store_password
      when 2
        match_password
      when 3
        exit 0
      else
        puts @text_resources['invalid_option_selection']
      end
    end

    def store_password
      print "\nWhat is the password for: "
      target = STDIN.cooked(&:gets).strip
      print 'Enter password: '
      unhashed_password = STDIN.noecho(&:gets).strip
      puts "\nHashing password (COST FACTOR: #{@settings[:cost]}), might take a while..."
      hashed_password = BCrypt::Password.create unhashed_password, cost: @settings[:cost]
      @storage.store_hash hashed_password, target
    end

    def match_password
      print "\nEnter password: "
      unhashed_password = STDIN.noecho(&:gets).strip

      db_result = @storage.all_hash_target_combos
      puts "\nComparing against all password hashes (COST FACTOR: #{@settings[:cost]})."
      puts 'This might take a while...'

      db_result.each do |hash, target, validity|
        is_valid = (validity == 1) ? true : false

        hashed_password = BCrypt::Password.new hash
        if hashed_password == unhashed_password
          puts "\nEntered password #{is_valid ? 'is' : 'used to be'} valid for #{target}."
        end
      end
    end
  end
end
