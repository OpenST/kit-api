class EmailTokenEncryptor

  include Util::ResultHelper

  def initialize(key)
    @key = key
  end

  def encrypt(string, token_type)
    handle_exception('encrypt', token_type) do
      ciphertext_blob = client.encrypt_and_sign(string)
      success_with_data(ciphertext_blob: ciphertext_blob)
    end
  end

  def decrypt(encrypted_text, token_type)
    handle_exception('decrypt', token_type) do
      plaintext = client.decrypt_and_verify(encrypted_text)
      success_with_data(plaintext: plaintext)
    end
  end

  private

  def client
    ActiveSupport::MessageEncryptor.new(@key)
  end

  def handle_exception(task, token_type)
    begin
      fail 'no code to execute' unless block_given?
      yield
    rescue ActiveSupport::MessageEncryptor::InvalidMessage => e
      if token_type == GlobalConstant::ManagerValidationHash::manager_invite_kind
        error_identifier = 'invalid_i_t'
      else
        error_identifier = 'invalid_r_t'
      end
      validation_error(
          'etc_1',
          'invalid_api_params',
          [error_identifier],
          GlobalConstant::ErrorAction.default
      )
    end
  end

end