# AuraRoute --- Technology Stack

## 1. Application

-   **Flutter + Dart:** Android application UI, navigation between
    screens, state management, and APK packaging.
-   **Antigravity:** AI-assisted development environment for
    implementing and iterating on the codebase.
-   **Android Studio / Android SDK:** Android build tools, emulator,
    device debugging, and signing configuration.
-   **Git + GitHub:** Source control, issue tracking, and release
    artifact hosting.

## 2. Maps, Places, and Routing

-   **OpenStreetMap data:** Base geographic data, subject to attribution
    and data-use terms.
-   **flutter_map:** Flutter map rendering package.
-   **Routing engine:** Evaluate Valhalla or OSRM based on required
    profiles and deployment/usage constraints.
-   **Geocoding/place search:** Use a provider compatible with OSM data
    and its usage policy; avoid assuming public endpoints are unlimited.
-   **GPS:** `geolocator` or an equivalent maintained Flutter location
    package.

Important: A map renderer does not calculate routes by itself. The
routing service must return route geometry, distance, and duration.
Motorcycle support depends on provider/profile availability; verify
before promising it.

## 3. AI

-   **Groq API + a supported Llama model:** AI conversation,
    mood-preference interpretation, route preference summaries,
    itinerary descriptions, and safe optional challenge generation.
-   Keep the model name configurable because model availability can
    change.
-   Use structured outputs where possible and validate every response.
-   Ground suggestions in actual place and routing results.
-   Never let the model fabricate route geometry, distances, ETA,
    business locations, opening hours, or weather.

## 4. Weather

-   **Open-Meteo** or another suitable weather provider.
-   Display data timestamp/source where useful.
-   Treat weather as advisory and handle unavailable data gracefully.

## 5. Backend and Data

-   **Firebase Authentication:** Optional account sign-in.
-   **Cloud Firestore:** Optional user preferences, saved routes, and
    walk history.
-   **Secure backend/API proxy:** Protect Groq credentials and enforce
    quotas. A small serverless backend can be used, subject to provider
    limits.
-   For a local-first prototype, store preferences and history on-device
    and add cloud sync later.

## 6. Notifications and Tracking

-   `flutter_local_notifications` for scheduled reminders.
-   `geolocator` for foreground GPS tracking.
-   Background tracking requires platform-specific permissions,
    lifecycle handling, battery testing, and clear user consent.
-   Do not promise reliable background operation until tested across
    target Android versions and device manufacturers.

## 7. APK Distribution

-   Build a release APK with Flutter tooling.
-   Host the APK on GitHub Releases or the project's own website.
-   Users download it through their phone browser and allow installation
    from that source.
-   Play Store publishing is not required for private/direct APK
    distribution.
-   Protect signing keys and document the update process.

## 8. Cost and Service Limits

Many tools have free tiers or open-source licenses, but hosted APIs and
public endpoints may impose quotas, rate limits, attribution
requirements, or commercial-use restrictions. Confirm current terms
before release. Free access is not equivalent to unlimited or
production-grade availability.

## 9. Suggested Architecture

-   Presentation layer: screens, reusable widgets, theme tokens.
-   Domain layer: mood selection, route planning, walk session,
    reminders.
-   Data layer: map/routing/geocoding/weather/AI/backend clients.
-   Services: location, notifications, permissions, secure API calls.
-   Configuration: environment-specific endpoints and feature flags.

## 10. Security and Privacy

-   Never embed private API keys in the APK.
-   Request location permissions only when needed and explain why.
-   Minimize location retention and provide user controls.
-   Avoid sending precise location to AI unless necessary and explicitly
    disclosed.
-   Validate external responses and handle malformed data, timeouts, and
    quota errors.
