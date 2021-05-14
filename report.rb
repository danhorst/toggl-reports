#!/usr/bin/env ruby
# frozen_string_literal: true

require 'csv'
require 'uri'
require 'net/http'
require 'json'
require 'dotenv'
Dotenv.load

# Returns decimal hours from milliseconds at one hundredth of an hour precision
module DecimalHours
  module_function

  def call(input)
    return convert(input) unless input.respond_to?(:collect)
    input.collect {|value| convert(value)}
  end

  def convert(milliseconds)
    time = milliseconds.to_i / 10 / 60 / 60
    time.to_f / 100
  end
end

module WeeklyReport
  # Converts JSON data from the Toggl Reports API into an abbreviated output
  module Csv
    HEADERS = [
      'Project',
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
      'TOTAL'
    ]

    module_function

    def call(headers: HEADERS, json: JSON.parse(File.read('weekly.json')))
      CSV.generate do |csv|
        csv << headers
        json['data'].collect do |entry|
          csv << [entry['title']['project']] + DecimalHours.call(entry['totals'])
        end
        csv << ['TOTAL'] + DecimalHours.call(json['week_totals'])
      end
    end
  end

  # Returns the weekly report data from the Toggl reports API
  module Json
    module_function

    def uri(
      start_date: nil,
      user_agent: 'Weekly-Decimal-Time',
      workspace_id: ENV['TOGGL_WORKSPACE_ID']
    )
      report_url = "https://api.track.toggl.com/reports/api/v2/weekly?user_agent=#{user_agent}&workspace_id=#{workspace_id}"
      report_url += "&since=#{start_date}" if start_date
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

#puts JSON.pretty_generate(WeeklyReport::Json.call(response: WeeklyReport::Json.response(uri: WeeklyReport::Json.uri(start_date: '2021-05-10'))))
puts WeeklyReport::Csv.call
