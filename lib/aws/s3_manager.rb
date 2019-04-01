module Aws

  class S3Manager

    include ::Util::ResultHelper

    # Initialize
    #
    # * Author: Puneet
    # * Date: 01/04/2019
    # * Reviewed By:
    #
    # @return [Aws::S3Manager]
    #
    def initialize

    end

    # Get signed url for
    #
    # * Author: Puneet
    # * Date: 01/04/2019
    # * Reviewed By: 
    #
    # @param [String] bucket - bucket name
    # @param [String] s3_path - file path in bucket
    # @param [Hash] options - options for signed url
    #
    # @return [Result::Base]
    #
    def get_signed_url_for(bucket, s3_path, options = {})
      signer = Aws::S3::Presigner.new({client: client})
      params = {
          bucket: bucket,
          key: s3_path
      }

      signer.presigned_url(
          :get_object,
          params.merge(options)
      )
    end

    # upload data in s3
    #
    # * Author: Puneet
    # * Date: 01/04/2019
    # * Reviewed By: 
    #
    # @param [String] s3_path - file path against which data would be stored in bucket
    # @param [File] body - file data to be uploaded
    # @param [String] bucket - bucket where file is to be uploaded
    # @param [Hash] options - extra options
    #
    def upload(s3_path, body, bucket, options = {})

      params = {
          key: s3_path,
          body: body,
          bucket: bucket
      }

      client.put_object(params.merge(options))

    end

    # Download an object to disk
    #
    # * Author: Puneet
    # * Date: 01/04/2019
    # * Reviewed By:
    #
    # @param [String] bucket - bucket where file was uploaded
    # @param [String] path - relative to the bucket, path to the folder where this file resides
    # @param [String] key - file name
    #
    def get(path, key, bucket)
      client.get_object(
          bucket: bucket,
          response_target: path,
          key: key)
    end

    private

    # Client
    #
    # * Author: Puneet
    # * Date: 01/04/2019
    # * Reviewed By:
    #
    # @return [Aws::S3::Client]
    #
    def client
      @client ||= Aws::S3::Client.new(
          access_key_id: access_key,
          secret_access_key: secret_key,
          region: region
      )
    end

    # Resource
    #
    # * Author: Puneet
    # * Date: 01/04/2019
    # * Reviewed By:
    #
    # @return [Aws::S3::Resource]
    #
    def resource
      @resource ||= Aws::S3::Resource.new(
          access_key_id: access_key,
          secret_access_key: secret_key,
          region: region
      )
    end

    # Access key
    #
    # * Author: Puneet
    # * Date: 01/04/2019
    # * Reviewed By: 
    #
    # @return [String] returns access key for AWS
    #
    def access_key
      credentials[:access_key]
    end

    # Secret key
    #
    # * Author: Puneet
    # * Date: 01/04/2019
    # * Reviewed By: 
    #
    # @return [String] returns secret key for AWS
    #
    def secret_key
      credentials[:secret_key]
    end

    # Region
    #
    # * Author: Puneet
    # * Date: 01/04/2019
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
    # * Date: 01/04/2019
    # * Reviewed By: 
    #
    # @return [Hash] returns Hash of AWS credentials
    #
    def credentials
      @credentials ||= GlobalConstant::S3.credentials
    end

  end

end