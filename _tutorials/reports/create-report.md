---
title: Create a report
---

# Create a report

To create a report, you need to send a `POST` request to `https://api.nexmo.com/v2/reports`. The request that you send to the endpoint will determine what kind of report you receive.

For example, to view all SMS messages sent from your Nexmo Account in June 2019, you'd use the following request:

```bash
curl -X POST https://api.nexmo.com/v2/reports/ \
  -u $API_KEY:$API_SECRET \
  -H "Content-Type: application/json" \
  -d '{"account_id": "$API_KEY","product": "SMS","direction": "outbound","start_date": "2019-06-01T00:00:00+0000","end_date": "2019-07-01T00:00:00+0000"}'
```

> When generating reports with a date range, `start_date` is inclusive, but `end_date` is exclusive. This means that in the above example we would not match any SMS messages sent at 00:00:00

For a full list of available reports, see the [reports API reference](/api/reports)