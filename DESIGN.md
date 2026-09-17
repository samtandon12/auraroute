# AuraRoute --- UI/UX Design Specification

## 1. Design Principles

-   Clean, mood-driven, mobile-first interface.
-   The four moods change the complete app color theme while preserving
    layout, spacing, component shapes, and typography.
-   Navigation remains practical and legible; mood styling must never
    reduce map clarity.
-   Left-align content except for onboarding/login and intentionally
    centered actions.
-   Use subtle, purposeful motion.

## 2. Typography

-   Display/headline: Space Grotesk.
-   Body/UI: Inter.
-   Screen titles: 26--30 px, bold.
-   Mood card titles: around 19 px, semibold.
-   Stop names: around 14 px, bold.
-   Body text: 12--14 px with 1.4--1.5 line height.
-   Sentence case labels; avoid loud all-caps labels.

## 3. Mood Color Tokens

### Neon Rain

-   Background: #0A0E1A
-   Elevated surface: #11162A
-   Text: #EEF1FF
-   Secondary text: #9AA3C9
-   Accent: #B26BFF
-   Accent 2: #26F0E0
-   Map lines: #2A2F55
-   Route: #26F0E0

### Quiet Reset

-   Background: #EEF3EE
-   Elevated surface: #FFFFFF
-   Text: #1F2E28
-   Secondary text: #5C6D64
-   Accent: #6F9C85
-   Accent 2: #B7CDBF
-   Map lines: #D3E0D8
-   Route: #6F9C85

### Main Character Walk

-   Background: #FFF2E2
-   Elevated surface: #FFFAF3
-   Text: #3B2318
-   Secondary text: #8A6A54
-   Accent: #E8933D
-   Accent 2: #D9707A
-   Map lines: #F0D8BD
-   Route: #D9707A

### Golden Hour Grind

-   Background: #241812
-   Elevated surface: #2F2018
-   Text: #F4E9DC
-   Secondary text: #C3A688
-   Accent: #C99A63
-   Accent 2: #E8C78F
-   Map lines: #4A3728
-   Route: #E8C78F

All colors must be centralized in a mood theme/token model. Do not
hardcode mood colors inside individual screens.

## 4. Global Components

-   Major cards: 20 px radius.
-   Itinerary cards: 16 px radius.
-   Inputs/buttons/chips: 12 px radius.
-   Pills and circular badges: fully rounded.
-   Consistent spacing scale and reusable components.
-   Use theme secondary-text token for de-emphasis, not arbitrary accent
    colors.

## 5. Main Screens

### Onboarding / Login

-   Quiet Reset palette by default.
-   AuraRoute wordmark in Space Grotesk.
-   Short tagline, email/password fields if authentication is enabled.
-   Primary action full-width; account creation link.
-   Keep the screen uncluttered.

### Home / Map

-   Search bar prominent at top.
-   Current-location action.
-   Quick actions: Navigate, Mood Walk, Adventure, Walk/Jog.
-   Map with current-location marker.
-   Destination and travel-mode controls.
-   Clear route preview card showing distance, ETA, and start action.

### Mood Select

-   Greeting and question headline.
-   Four vertically stacked mood cards, approximately 100--110 px tall.
-   Each card uses its own mood palette regardless of currently active
    theme.
-   One-line mood description.
-   "Surprise me" action selects a random mood.
-   Press state scales to approximately 0.98.

### Mood Questionnaire

-   Ask only a few concise, optional questions.
-   Examples: current mood, desired outcome, time available, preferred
    setting.
-   Include skip/back controls and avoid implying clinical diagnosis.

### Route View

-   Mood/activity name and weather chip.
-   Map card approximately 220 px tall or responsive to screen size.
-   Route polyline, start/end markers, numbered stop markers.
-   Show route distance, estimated time, and optional estimated calories
    with clear caveat.
-   Conditions-changed banner only when supported by fresh data.
-   Itinerary cards with stop name, short description, and travel time
    to next stop.
-   Bottom navigation: Recent, Regenerate, Share, Profile, adapted to
    the product's navigation architecture.

### Active Walk

-   High-visibility current-location marker and route.
-   Distance/time progress and next instruction where available.
-   Pause/resume/end controls.
-   Keep essential controls reachable one-handed.
-   Avoid blocking the map with decorative overlays.

### Adventure

-   Show route checkpoints and optional challenges.
-   Clearly label challenge duration and allow skip.
-   Food stops must be sourced from actual place data; show opening
    hours only when available and current.

### Schedule Walk/Jog

-   Activity type, time, recurrence, duration, mood, and reminder
    toggle.
-   Explain notification permission.
-   Show upcoming scheduled activities.

### Completion / History

-   Summary with duration, distance, route, and optional mood check-in.
-   Save/share actions.
-   Recent walks and favorites in clear lists.

### Profile / Settings

-   Theme/mood preferences, units, permissions, privacy, reminders, and
    account controls.

## 6. Motion

-   Mood theme transition: cross-fade around 300 ms.
-   Card press: scale 0.98, no bounce.
-   Conditions banner: slide/fade.
-   Avoid animating every element.

## 7. Accessibility and Responsive Behavior

-   Support approximately 375--430 px phone widths and smaller devices.
-   Respect system text scaling where practical.
-   Maintain contrast and clear focus/selected states.
-   Do not rely on color alone to communicate route status or selection.
-   Handle safe areas, keyboard overlap, and one-handed reach.

## 8. Design Acceptance Criteria

-   All screens consume the active mood theme.
-   Mood cards always preview their own palette.
-   Map controls and route remain legible in all themes.
-   Loading, empty, permission-denied, and error states are designed.
-   No fake map, weather, place, or route data is presented as live
    data.
