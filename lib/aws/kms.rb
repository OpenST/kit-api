module Aws

  class Kms

    include ::Util::ResultHelper

    # Initialize
    #
    # * Author: Puneet
    # * Date: 09/10/2017
    # * Reviewed By:
    #
    # @param [String] purpose - this is the purpose for accessing the KMS service - login OR kyc
    # @param [String] role - this is the role of the user for whom the KMS service is being called - admin OR user
    #
    # @return [Aws::Kms]
    #
    def initialize(purpose, role)
      @purpose = purpose
      @role = role
    end

    # Decrypt
    #
    # * Author: Puneet
    # * Date: 09/10/2017
    # * Reviewed By:
    #
    # @param [Blob] ciphertext_blob - the blob you want to decrypt
    #
    # @return [Result::Base]
    #
    def decrypt(ciphertext_blob)
      begin

        d_resp = client.decrypt({
                                  ciphertext_blob: ciphertext_blob
                                }).to_h

        plaintext = d_resp[:plaintext]

        return success_with_data(
          plaintext: plaintext
        )

      rescue => e
        return exception_with_data(
          e,
          'a_k_1',
          GlobalConstant::ErrorAction.default,
          {
            purpose: @purpose,
            role: @role,
            ciphertext_blob: ciphertext_blob
          }
        )
      end
    end

    # Encrypt
    #
    # * Author: Puneet
    # * Date: 09/10/2017
    # * Reviewed By:
    #
    # @param [String] plaintext - the plaintext you want to encrypt
    #
    # @return [Result::Base]
    #
    def encrypt(plaintext)
      begin

        e_resp = client.encrypt({
                                  plaintext: plaintext,
                                  key_id: key_id
                                }).to_h

        ciphertext_blob = e_resp[:ciphertext_blob]

        return success_with_data(
          ciphertext_blob: ciphertext_blob
        )

      rescue => e
        return exception_with_data(
          e,
          'a_k_2',
          GlobalConstant::ErrorAction.default,
          {
            purpose: @purpose,
            role: @role,
            plaintext: plaintext
          }
        )
      end
    end

    # Generate data key
    #
    # * Author: Puneet
    # * Date: 09/10/2017
    # * Reviewed By:
    #
    # @return [Result::Base]
    #
    def generate_data_key
      begin

        resp = client.generate_data_key({
                                   key_id: key_id,
                                   key_spec: "AES_256"
                                 })

        return success_with_data(
          ciphertext_blob: resp.ciphertext_blob,
          plaintext: resp.plaintext
        )

      rescue => e
        return exception_with_data(
          e,
          'a_k_3',
          GlobalConstant::ErrorAction.default,
          {
            purpose: @purpose,
            role: @role
          }
        )
      end

    end

    private

    # Client
    #
    # * Author: Puneet
    # * Date: 09/10/2017
    # * Reviewed By:
    #
    # @return [Aws::KMS::Client]
    #
    def client
      @client ||= Aws::KMS::Client.new(
        access_key_id: access_key_id,
        secret_access_key: secret_key,
        region: region
      )
    end

    # Key id
    #
    # * Author: Puneet
    # * Date: 09/10/2017
    # * Reviewed By:
    #
    # @return [String] returns the key id
    #
    def key_id
      GlobalConstant::Aws::Kms.get_key_id_for(@purpose)
    end

    # Access key
    #
    # * Author: Puneet
    # * Date: 09/10/2017
    # * Reviewed By:
    #
    # @return [String] returns access key for AWS
    #
    def access_key_id
      credentials['access_key']
    end

    # Secret key
    #
    # * Author: Puneet
    # * Date: 09/10/2017
    # * Reviewed By:
    #
    # @return [String] returns secret key for AWS
    #
    def secret_key
      credentials['secret_key']
    end

    # Region
    #
    # * Author: Puneet
    # * Date: 09/10/2017
    # * Reviewed By:
    #
    # @return [String] returns region
    #
    def region
      GlobalConstant::Aws::Common.region
    end

    # Credentials
    #
    # * Author: Puneet
    # * Date: 09/10/2017
    # * Reviewed By:
    #
    # @return [Hash] returns Hash of AWS credentials
    #
    def credentials
      @credentials ||= GlobalConstant::Aws::Common.get_credentials_for(@role)
    end

  end

end