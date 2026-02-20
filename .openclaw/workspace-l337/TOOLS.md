# TOOLS.md - Local Notes

## Health Tracking CLIs

### whoop
your custom CLI for WHOOP API data.
- Use the `whoop` skill for full command reference
- Key commands: `whoop summary`, `whoop recovery --days 7`, `whoop sleep --days 7`, `whoop strain --days 7`
- Authoritative for: recovery score, sleep stages, HRV, RHR, strain, SpO2, skin temp, respiratory rate
- Does NOT have: steps, walking distance, VO2max

### hvault
your custom CLI for Apple Health data (via Health Auto Export SQLite DB).
- Use the `hvault` skill for full command reference
- Key commands: `hvault dashboard --json`, `hvault metrics --metric step_count --days 14`, `hvault workouts --days 30`, `hvault nutrition --days 7`
- Authoritative for: steps, distance, workouts, nutrition, body weight, VO2max, stand hours, active calories
- Does NOT have: recovery score, sleep stages, strain

### Workflow for health checks
1. Run `whoop summary` + `hvault dashboard --json` in parallel for full snapshot
2. Drill into specifics as needed
3. Always check `session_status` for current time before giving activity/exercise advice

## your Devices
- Apple Watch — worn during waking hours (steps, workouts, HR)
- WHOOP — worn 24/7 including sleep (recovery, sleep stages, HRV)
- iPhone — passive step/distance supplement
