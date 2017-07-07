require 'crypt_keeper/log_subscriber/mysql_aes'

module CryptKeeper
  module Provider
    class MysqlAesNew < Base
      include CryptKeeper::Helper::SQL
      include CryptKeeper::Helper::DigestPassphrase

      attr_accessor :key

      # Public: Initializes the encryptor
      #
      #  options - A hash, :key and :salt are required
      def initialize(options = {})
        ActiveSupport.run_load_hooks(:crypt_keeper_mysql_aes_log, self)
        @key = digest_passphrase(options[:key], options[:salt])
      end

      # Public: Encrypts a string
      #
      # Returns an encrypted string
      def encrypt(value)
       # Base64.encode64 escape_and_execute_sql(
       #   "SELECT AES_ENCRYPT(?, ?)", value, key).first
        puts "key , value " + key.inspect + value.inspect
	new_value=escape_and_execute_sql(["select hex(aes_encrypt(?,?))",value,'test']).values[0]
        puts "got from sql" + new_value.inspect
        #puts Base64.encode64(new_value).inspect
        #return Base64.encode64(new_value)
	return new_value
      end

      # Public: Decrypts a string
      #
      # Returns a plaintext string
      def decrypt(value)
        #escape_and_execute_sql(
        #  "SELECT AES_DECRYPT(?, ?)", Base64.decode64(value), key).first
        puts "key , value " + key.inspect + value.inspect
	#new_value=escape_and_execute_sql(["select aes_decrypt(?,?)",Base64.decode64(value),key])
        new_value = escape_and_execute_sql(["select aes_decrypt(unhex(?),?) ",value,'test' ])
	puts "got from sql  d" + new_value.inspect
	
        return new_value.values[0]
      end

      # Public: Searches the table
      #
      # Returns an Enumerable
      def search(records, field, criteria)
        records.where("#{field} = ?", encrypt(criteria))
      end
    end
  end
end
