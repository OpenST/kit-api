module ClientManagement

  module ApiCredentials

    class Create < ServicesBase

      # Initialize
      #
      # * Author: Puneet
      # * Date: 21/01/2018
      # * Reviewed By:
      #
      # @param [Integer] client_id (mandatory) -  client id
      #
      # @return [ClientManagement::ApiCredentials::Create]
      #
      def initialize(params)
        super
        @client_id = @params[:client_id]
      end

      # Perform
      #
      # * Author: Puneet
      # * Date: 21/01/2019
      # * Reviewed By:
      #
      def perform

        r = generate_api_key_salt
        return r unless r.success?

        api_salt = r.data

        api_credential = ApiCredential.new(
            client_id: @client_id,
            api_key: ApiCredential.generate_api_key,
            api_secret: ApiCredential.generate_encrypted_secret_key(api_salt[:plaintext]),
            api_salt: api_salt[:ciphertext_blob],
            expiry_timestamp: (Time.now+10.year).to_i
        )

        api_credential.save!

      end

      private

      # Generate Api Key salt
      #
      # * Author: Puneet
      # * Date: 21/01/2019
      # * Reviewed By:
      #
      # @return [Result::Base]
      #
      def generate_api_key_salt
        Aws::Kms.new(GlobalConstant::Kms.api_key_purpose, GlobalConstant::Kms.user_role).generate_data_key
      end

    end

  end

end