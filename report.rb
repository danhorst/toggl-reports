#!/usr/bin/env ruby
# frozen_string_literal: true

require 'uri'
require 'net/http'
require 'json'
require 'dotenv'
Dotenv.load

def report_uri(
  user_agent: 'Weekly-Decimal-Time',
  workspace_id: ENV['TOGGL_WORKSPACE_ID']
)
  URI("https://api.track.toggl.com/reports/api/v2/weekly?user_agent=#{user_agent}&workspace_id=#{workspace_id}")
end

def request_report(
  api_key: ENV['TOGGL_API_KEY'],
  debug: false,
  uri: report_uri
)
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  http.set_debug_output $stderr if debug
  request = Net::HTTP::Get.new(uri.request_uri)
  request.basic_auth api_key, 'api_token'
  request.add_field 'content-type', 'application/json'
  http.request(request)
end

def report_json(response: request_report)
  return {} unless response.code == '200'

  JSON.parse(response.body)
end

puts JSON.pretty_generate(report_json)
