module Google
  class Sheets

    require "google/apis/sheets_v4"
    require "googleauth"

    include Util::ResultHelper

    def initialize
      @service = Google::Apis::SheetsV4::SheetsService.new
      @service_account = Google::Auth::ServiceAccountCredentials.new

      @scope = Google::Apis::SheetsV4::AUTH_SPREADSHEETS
      @spreadsheet_id = GlobalConstant::Google.usage_report_spreadsheet_id
      @service.authorization = authorize
    end

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

    def fetch_range(sheetName, row_length, col_length)
      last_id = (65 + col_length - 1).chr #TODO - might have write a identifier generator from col length
      "#{sheetName}!A1:#{last_id}#{row_length}"
    end

    def authorize
      authorization = Google::Auth.get_application_default(@scope)
      authorization
    end

  end
end