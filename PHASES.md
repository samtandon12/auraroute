# AuraRoute --- Development Phases

## Phase 0 --- Project Setup and Feasibility

**Build:** Flutter project, Git repository, app structure, fonts,
linting, environment configuration.\
**Verify:** App runs on emulator and physical Android device.\
**Research gate:** Confirm routing provider supports required walking
and motorcycle profiles, and review map/geocoding service terms.

## Phase 1 --- Design System and Navigation Shell

**Build:** Four mood themes, centralized tokens, reusable
cards/buttons/inputs, app navigation, responsive layout.\
**Screens:** Home shell, mood select, profile/settings placeholders.\
**Verify:** Theme transitions work and no screen hardcodes mood-specific
colors.

## Phase 2 --- Map, Search, and Route Preview

**Build:** Map display, location permission, current-location marker,
place search, route request, route polyline, distance, ETA,
walking/motorcycle mode where supported.\
**Verify:** Test known routes and handle no route, denied permission,
offline, timeout, and API limit cases.\
**Do not:** Fake route results or claim unsupported motorcycle routing.

## Phase 3 --- Mood Personalization

**Build:** Mood selection, intention questionnaire,
duration/pace/preferences, mood-specific recommendation rules, real
nearby-place retrieval, route stop selection.\
**Verify:** Recommendations use validated places and route service
output.

## Phase 4 --- AI Companion with Groq + Llama

**Build:** Secure backend proxy, configurable model, prompt templates,
structured response validation, conversation UI, safe challenge
generation.\
**Verify:** AI cannot invent route coordinates, ETA, opening hours, or
business details; fallback works when API is unavailable.

## Phase 5 --- Walk/Jog Tracking

**Build:** Start/pause/resume/end session, GPS updates, progress,
elapsed time, distance, completion summary, recent walks.\
**Verify:** Test permission changes, GPS loss, app backgrounding,
battery behavior, and inaccurate GPS readings.

## Phase 6 --- Adventure Mode

**Build:** Food discovery from real place results, scenic/nature stops,
optional photo/nature/exploration challenges, skip controls.\
**Verify:** Challenges are safe, optional, non-disruptive, and never
require purchases or stranger interaction.

## Phase 7 --- Weather and Scheduled Reminders

**Build:** Weather chip, weather-aware suggestions, local walk/jog
reminders, recurrence and edit/delete controls.\
**Verify:** Test notification permission, device reboot behavior where
applicable, timezone changes, and stale weather data.

## Phase 8 --- Favorites, Sharing, and Polish

**Build:** Saved routes, shareable walk summary, settings, privacy
controls, empty/error/loading states, accessibility pass.\
**Verify:** Share content excludes sensitive location details unless the
user chooses to include them.

## Phase 9 --- Release APK

**Build:** Release configuration, app icon, versioning, signing, APK
generation, download page/release notes.\
**Verify:** Install APK on a clean Android device, test update path,
permissions, crashes, and API configuration.

## Phase 10 --- Optional Safety and Advanced Features

**Build later:** Trusted-contact sharing, emergency workflows, offline
support, advanced rerouting, analytics, cloud sync enhancements.\
**Gate:** Do not release safety-critical claims until thoroughly tested
and privacy-reviewed.

## Definition of Done for Each Phase

-   Feature works on a physical Android device.
-   Loading, empty, permission-denied, and error states exist.
-   No hardcoded fake live data.
-   Code is organized and documented.
-   Regression checks pass.
-   User-facing limitations are clear.
