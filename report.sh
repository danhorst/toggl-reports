#!/usr/bin/bash

source .env
curl -v -u "$TOGGL_API_KEY:api_token" -H "User-Agent: Weekly-Decimal-Time" -H "Content-Type: application/json" "https://api.track.toggl.com/reports/api/v2/weekly?user_agent=Weekly-Decimal-Time&workspace_id=$TOGGL_WORKSPACE_ID" -o weekly.json
