# Prerequisites
# ------------------------
# 1. Enable sheets api in google developer console
# 2. Create a service account
# 3. Download the service account credential file
# 4. Create a sheet
# 5. Create books with 'testnet-lifetime', 'testnet-daily' etc. names
# 6. Give edit access to client email in sheets

module Google
  class Sheets

    require "google/apis/sheets_v4"
    require "googleauth"

    include Util::ResultHelper

    # Initialize
    #
    # * Author: Santhosh
    # * Date: 15/07/2019
    # * Reviewed By:
    #
    # @return [Google::Sheets]
    #
    def initialize
      @service = Google::Apis::SheetsV4::SheetsService.new
      @service_account = Google::Auth::ServiceAccountCredentials.new

      @scope = Google::Apis::SheetsV4::AUTH_SPREADSHEETS
      @spreadsheet_id = GlobalConstant::Google.usage_report_spreadsheet_id
      @service.authorization = authorize
    end

    # Upload to sheets
    #
    # * Author: Santhosh
    # * Date: 15/07/2019
    # * Reviewed By:
    #
    # @return [Result::Base]
    #
    def upload(sheetName, rows)
      begin
        col_length = rows[0] ? rows[0].length : 0
        range = fetch_range(sheetName, rows.length, col_length)
        value_range_object = Google::Apis::SheetsV4::ValueRange.new(range: range,
                                                                    values: rows)
        result = @service.update_spreadsheet_value(@spreadsheet_id,
                                                   range,
                                                   value_range_object, value_input_option: 'RAW')
        success_with_data(response: result.inspect)
      rescue => e
        puts "===Error uploading to google sheets", e
        return error_with_data(
            'gs_1',
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
    # * Reviewed By:
    #
    # @return [String]
    #
    def fetch_range(sheetName, row_length, col_length)
      last_id = (65 + col_length - 1).chr #TODO - might have write a identifier generator from col length
      "#{sheetName}!A1:#{last_id}#{row_length}"
    end

    # Get authorization
    #
    # * Author: Santhosh
    # * Date: 15/07/2019
    # * Reviewed By:
    #
    # @return [Hash]
    #
    def authorize
      authorization = nil
      begin
        authorization = Google::Auth.get_application_default(@scope)
      rescue => e
        puts "===Error fetching authorization google sheets", e
      end
      authorization
    end

  end
end