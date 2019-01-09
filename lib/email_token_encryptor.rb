class EmailTokenEncryptor

  include Util::ResultHelper

  def initialize(key)
    @key = key
  end

  def encrypt(string)
    handle_exception('encrypt') do
      ciphertext_blob = client.encrypt_and_sign(string)
      success_with_data(ciphertext_blob: ciphertext_blob)
    end
  end

  def decrypt(encrypted_text)
    handle_exception('decrypt') do
      plaintext = client.decrypt_and_verify(encrypted_text)
      success_with_data(plaintext: plaintext)
    end
  end

  private

  def client
    ActiveSupport::MessageEncryptor.new(@key)
  end

  def handle_exception(task)
    begin
      fail 'no code to execute' unless block_given?
      yield
    rescue ActiveSupport::MessageEncryptor::InvalidMessage => e
      validation_error(
          'etc_1',
          'invalid_api_params',
          ['invalid_i_t'],
          GlobalConstant::ErrorAction.default
      )
    end
  end

end