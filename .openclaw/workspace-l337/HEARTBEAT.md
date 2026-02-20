# HEARTBEAT.md

## Health Check (every heartbeat)
Run a quick health check using both CLIs. Only alert YOUR_NAME if something needs attention.

```bash
whoop summary
hvault dashboard --json
```

Alert if ANY of the following:
- Recovery score < 33% (yellow) → mention it
- Recovery score < 20% (red) → proactively message YOUR_NAME
- HRV below 80ms → flag as danger zone
- SpO2 below 93% → flag immediately
- Steps < 1,000 for the day (after 18:00 Moscow) → gentle nudge
- Sleep last night < 5h → note it in reply

Always check `session_status` for current time before suggesting exercise or activity.
Do NOT suggest exercise between 22:00–09:00 Moscow time.

## Time-aware messaging
- 09:00–12:00 MSK: good time for morning check-in + activity nudge
- 12:00–18:00 MSK: good time for midday check + step reminder
- 18:00–21:00 MSK: good time for evening wind-down reminder
- 21:00–09:00 MSK: quiet hours — only alert if urgent (SpO2, extreme metrics)
