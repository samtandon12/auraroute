# AuraRoute --- Product Requirements Document (PRD)

## 1. Product Overview

**Product name:** AuraRoute\
**Product type:** AI-assisted navigation, walking, jogging, and local
exploration Android app.\
**Core idea:** Help users navigate to places and create personalized
walking experiences based on their mood, time, preferences, and
surroundings.

AuraRoute combines practical navigation with mood-aware recommendations
and optional real-world mini-adventures.

## 2. Product Goals

-   Let users search for places and navigate using walking or motorcycle
    travel modes.
-   Provide route distance, estimated duration, map visualization, and
    live GPS progress.
-   Personalize walks using mood, intention, available time, and user
    preferences.
-   Make walking more engaging through optional food discovery, scenic
    stops, and safe challenges.
-   Support scheduled walking and jogging reminders.
-   Allow users to build and install an Android APK without publishing
    on Google Play.

## 3. Target Users

-   People who walk or jog for fitness or relaxation.
-   Users who want to explore nearby places.
-   Users who want mood-aware walking suggestions.
-   Users who prefer lightweight, personalized navigation and reminders.

## 4. Core User Journeys

### Journey A: Navigate

1.  Open the app.
2.  Search for a destination or use current location.
3.  Select walking or motorcycle mode.
4.  Review route options, distance, and ETA.
5.  Start navigation and view live location/progress.
6.  Arrive, end navigation, and optionally save the trip.

### Journey B: Mood Walk

1.  Choose a mood and desired outcome.
2.  Answer a few optional questions.
3.  Set duration, pace, and preferences.
4.  Receive a route with relevant stops.
5.  Start the walk and follow the map.
6.  Complete the walk and optionally record post-walk mood.

### Journey C: Adventure Walk

1.  Choose Adventure mode.
2.  Select a duration and challenge category.
3.  Review suggested route, stops, and optional dares.
4.  Start the walk; complete or skip challenges.
5.  Finish and view a summary.

### Journey D: Scheduled Walk/Jog

1.  Choose walk or jog.
2.  Set time, recurrence, duration, and preferred mood.
3.  Save a local reminder.
4.  Receive a notification at the scheduled time.
5.  Open AuraRoute and start the planned activity.

## 5. Functional Requirements

### Navigation

-   Search places and addresses.
-   Show the user's current location after permission is granted.
-   Display map tiles, route polyline, start/end markers, and stop
    markers.
-   Support walking and motorcycle route profiles where the routing
    provider supports them.
-   Display distance and estimated travel time.
-   Track GPS position during an active session.
-   Detect off-route movement and request a reroute when supported.
-   Provide clear loading, no-route, network-error, and
    permission-denied states.

### Mood Personalization

-   Support four moods: Neon Rain, Quiet Reset, Main Character Walk,
    Golden Hour Grind.
-   Each mood has its own visual theme.
-   Ask optional questions about current mood, desired feeling, time
    available, and preferred environment.
-   Generate recommendations from validated nearby places and valid
    routes.
-   Never claim to know a user's mood without user input or explicit
    consent.

### Adventure

-   Offer optional food discovery, photo prompts, nature observation,
    and exploration challenges.
-   Allow users to skip any challenge.
-   Avoid unsafe, illegal, coercive, or disruptive dares.
-   Do not require users to buy food or interact with strangers.

### Weather

-   Display current weather and relevant forecast information when
    available.
-   Use weather data to suggest adjustments, not to guarantee safety.
-   Handle unavailable or stale weather data transparently.

### Reminders

-   Schedule local walk/jog notifications.
-   Support one-time and recurring reminders where supported by the
    platform.
-   Let users edit, disable, and delete reminders.
-   Explain notification permissions and handle denied permissions.

### User Data

-   Save recent walks and favorite routes.
-   Store preferences and scheduled reminders.
-   Provide a way to delete account-associated data if cloud accounts
    are implemented.
-   Minimize collection and retention of location history.

### AI Companion

-   Use Groq API with a supported Llama model selected at implementation
    time.
-   Use AI for conversation, preference interpretation, itinerary
    wording, and challenge ideas.
-   Ground location and route suggestions in results from
    map/place/routing services.
-   Validate structured AI output before using it.
-   Keep API credentials out of the mobile app binary.

## 6. Non-Functional Requirements

-   Responsive layouts for common Android phone sizes.
-   Smooth theme transitions and restrained animations.
-   Accessible contrast, readable typography, and touch targets.
-   Graceful handling of weak connectivity and service limits.
-   Reasonable battery use during tracking.
-   Secure API credential handling through a backend/proxy for
    production.
-   Clear privacy and permission explanations.

## 7. MVP Scope

**MVP:** onboarding, home/search, map, current location, route preview,
walking/motorcycle mode where supported, mood selection, basic mood
recommendations, walk tracking, local reminders, favorites/recent walks,
AI companion, and APK build.

**Later enhancements:** trusted-contact live sharing, SOS workflows,
advanced rerouting, offline maps, social features, and advanced
analytics.

## 8. Success Measures

-   Users can search, preview, and start a valid route.
-   Route and ETA values come from routing data, not invented by AI.
-   Users can complete and save a tracked walk.
-   Reminders trigger as configured on supported devices.
-   Mood recommendations use real nearby place data.
-   App handles permission denial and service failures without crashing.

## 9. Risks and Constraints

-   Public map, geocoding, routing, weather, and AI services have usage
    limits and terms.
-   Motorcycle routing availability depends on the selected routing
    provider and profile.
-   GPS accuracy, background execution, and notifications vary by
    Android version/device.
-   AI can hallucinate; all places and routes must be validated against
    external data.
-   APK sideloading requires users to permit installation from the
    browser/source.

## 10. Out of Scope for Initial MVP

-   Building a proprietary global map database.
-   Guaranteed safety ratings for streets or neighborhoods.
-   Emergency-service dispatch.
-   Guaranteed offline navigation.
-   Public social network or user-generated marketplace.
