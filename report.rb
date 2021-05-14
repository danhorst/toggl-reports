#!/usr/bin/env ruby
# frozen_string_literal: true

require 'uri'
require 'net/http'
require 'json'
require 'dotenv'
Dotenv.load

module WeeklyReport
  # Returns the weekly report data from the Toggl reports API
  module Json
    module_function

    def uri(
      end_date: nil,
      start_date: nil,
      user_agent: 'Weekly-Decimal-Time',
      workspace_id: ENV['TOGGL_WORKSPACE_ID']
    )
      report_url = "https://api.track.toggl.com/reports/api/v2/weekly?user_agent=#{user_agent}&workspace_id=#{workspace_id}"
      report_url += "&since=#{start_date}&until=#{end_date}" if start_date && end_date
      URI(report_url)
    end

    def response(
      api_key: ENV['TOGGL_API_KEY'],
      debug: false,
      uri: self.uri
    )
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.set_debug_output $stderr if debug
      request = Net::HTTP::Get.new(uri.request_uri)
      request.basic_auth api_key, 'api_token'
      request.add_field 'content-type', 'application/json'
      http.request(request)
    end

    def call(response: self.response)
      return {} unless response.code == '200'

      JSON.parse(response.body)
    end
  end
end

puts JSON.pretty_generate(WeeklyReport::Json.call(response: WeeklyReport::Json.response(uri: WeeklyReport::Json.uri(start_date: '2021-05-10', end_date: '2021-05-16'))))
#puts WeeklyReport::Csv.call.inspect
