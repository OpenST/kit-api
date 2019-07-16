# Pre-requisites
# ------------------------
# 1. Enable sheets api in google developer console
# 2. Create a service account
# 3. Download the service account credential file
# 4. Create a sheet
# 5. Create books with 'testnet-lifetime', 'testnet-daily' etc. names
# 6. Give edit access to client email in sheets

module Google
  class Sheet

    require "google/apis/sheets_v4"
    require "googleauth"
    require "stringio"

    include Util::ResultHelper

    # Initialize
    #
    # * Author: Santhosh
    # * Date: 15/07/2019
    # * Reviewed By: Kedar
    #
    # @return [Google::Sheet]
    #
    def initialize
      @service = Google::Apis::SheetsV4::SheetsService.new
      @service_account = Google::Auth::ServiceAccountCredentials.new

      @scope = Google::Apis::SheetsV4::AUTH_SPREADSHEETS
      @spreadsheet_id = GlobalConstant::Google.usage_report_spreadsheet_id
    end

    # Upload to sheets
    #
    # * Author: Santhosh
    # * Date: 15/07/2019
    # * Reviewed By: Kedar
    #
    # @return [Result::Base]
    #
    def upload(sheet_name, rows)

      @service.authorization = authorize

      if @service.authorization.nil?
        return error_with_data(
            'gs_1',
            'invalid_google_credentials',
            GlobalConstant::ErrorAction.default
        )
      end

      begin

        col_length = rows[0] ? rows[0].length : 0

        if col_length == 0 || rows.length == 0
          return error_with_data(
              'gs_2',
              'empty_data',
              GlobalConstant::ErrorAction.default
          )
        end

        rows.each do |r|
          if r.length != col_length
            return error_with_data(
                'gs_3',
                'invalid_columns',
                GlobalConstant::ErrorAction.default
            )
          end
        end

        range = fetch_range(sheet_name, rows.length, col_length)

        value_range_object = fetch_value_range_object(sheet_name, range, rows)

        result = @service.update_spreadsheet_value(@spreadsheet_id,
                                                   range,
                                                   value_range_object, value_input_option: 'RAW')
        success_with_data(response: result.inspect)
      rescue => e
        puts "===Error uploading to google sheets", e
        return error_with_data(
            'gs_4',
            'something_went_wrong',
            GlobalConstant::ErrorAction.default
        )
      end
    end

    private

    # Fetch sheet column range
    #
    # * Author: Santhosh
    # * Date: 15/07/2019
    # * Reviewed By: Kedar
    #
    # @return [String]
    #
    def fetch_range(sheetName, row_length, col_length)
      col_count = col_length
      last_id = []

      while col_count > 0
        rem = col_count % 26

        if rem == 0
          last_id.unshift('Z')
          col_count = (col_count / 26 ).floor - 1
        else
          character = (65 + rem - 1).chr  # 65 in ASCII is char 'A'
          last_id.unshift(character)
          col_count = (col_count / 26 ).floor
        end
      end

      last_id = last_id.join('')

      "#{sheetName}!A1:#{last_id}#{row_length}"
    end

    # Fetch value range object
    #
    # * Author: Santhosh
    # * Date: 15/07/2019
    # * Reviewed By: Kedar
    #
    # @return [Object]
    #
    def fetch_value_range_object(sheet_name, range, rows)

      value_range_object = Google::Apis::SheetsV4::ValueRange.new(range: range,
                                                                  values: rows)
      value_range_object
    end

    # Get authorization
    #
    # * Author: Santhosh
    # * Date: 15/07/2019
    # * Reviewed By: Kedar
    #
    # @return [Hash]
    #
    def authorize
      authorization = nil

      cred_io = {
          client_email: GlobalConstant::Google.client_email,
          private_key: GlobalConstant::Google.private_key,
          project_id: GlobalConstant::Google.project_id
      }

      string_io = StringIO.new(cred_io.to_json)

      begin
        authorization = Google::Auth::ServiceAccountCredentials.make_creds(
            json_key_io: string_io,
            scope: @scope)
      rescue => e
        puts "===Error fetching authorization google sheets", e
      end
      authorization
    end

  end
end