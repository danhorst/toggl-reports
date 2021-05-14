#!/usr/bin/env ruby

require 'dotenv'
Dotenv.load

`curl -v -u #{ENV['TOGGL_API_KEY']}:api_token -H "User-Agent: Weekly-Decimal-Time" -H "Content-Type: application/json" https://api.track.toggl.com/reports/api/v2/weekly -o weekly.json`
