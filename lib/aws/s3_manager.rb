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
    # @param [Hash] options - options for signed url (ex expires_in = 9000 (seconds after which URL would expire))
    #
    # @return [Result::Base]
    #
    def get_signed_url_for(bucket, s3_path, options = {})

      begin

        signer = Aws::S3::Presigner.new({client: client})
        params = {
            bucket: bucket,
            key: s3_path
        }

        presigned_url = signer.presigned_url(
            :get_object,
            params.merge(options)
        )

        success_with_data({
                              presigned_url: presigned_url
                          })

      rescue StandardError => se

        return exception_with_data(
            se,
            'l_a_s3_m_1',
            GlobalConstant::ErrorAction.default,
            {
                key: s3_path,
                bucket: bucket,
                options: options
            }
        )

      end

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

      begin

        params = {
            key: s3_path,
            body: body,
            bucket: bucket
        }

        aws_response_obj = client.put_object(params.merge(options))

        aws_response = aws_response_obj.to_h

        if aws_response[:etag].present?

          success_with_data({
                                etag: aws_response[:etag]
                            })

        else

          error_with_data(
              'l_a_s3_m_3',
              'something_went_wrong',
              GlobalConstant::ErrorAction.default,
              {
                  aws_response: aws_response
              }
          )

        end

      rescue StandardError => se

        return exception_with_data(
            se,
            'l_a_s3_m_4',
            GlobalConstant::ErrorAction.default,
            {
              key: s3_path,
              bucket: bucket
            }
        )

      end

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

      begin

        client.get_object(
            bucket: bucket,
            response_target: path,
            key: key)

      rescue StandardError => se

        return exception_with_data(
            se,
            'l_a_s3_m_5',
            GlobalConstant::ErrorAction.default,
            {
                path: path,
                key: key,
                bucket: bucket
            }
        )

      end

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