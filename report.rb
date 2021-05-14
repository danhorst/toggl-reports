#!/usr/bin/env ruby

require 'dotenv'
Dotenv.load

`curl -v -u #{ENV['TOGGL_API_KEY']}:api_token -H "User-Agent: Weekly-Decimal-Time" -H "Content-Type: application/json" "https://api.track.toggl.com/reports/api/v2/weekly?user_agent=Weekly-Decimal-Time&workspace_id=#{ENV['TOGGL_WORKSPACE_ID']}" -o weekly.json`
