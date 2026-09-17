import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/mood_provider.dart';
import '../../../core/theme/mood_tokens.dart';
import '../../../domain/favorites/favorites_provider.dart';
import '../../../domain/location/location_provider.dart';
import '../../../domain/location/location_state.dart';
import '../../../domain/places/place_model.dart';
import '../../../domain/places/place_search_provider.dart';
import '../../../domain/routing/route_provider.dart';
import '../../adventure/widgets/adventure_discovery_card.dart';
import '../../common/widgets/reusable_components.dart';
import '../../common/widgets/route_completion_dialog.dart';
import '../../common/widgets/share_summary_dialog.dart';
import '../../common/widgets/weather_chip.dart';

class MapScreenShell extends ConsumerStatefulWidget {
  const MapScreenShell({super.key});

  @override
  ConsumerState<MapScreenShell> createState() => _MapScreenShellState();
}

class _MapScreenShellState extends ConsumerState<MapScreenShell>
    with SingleTickerProviderStateMixin {
  late final MapController _mapController;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  // 0: Walk ('foot'), 1: Jog ('foot'), 2: Motorcycle ('car')
  int _selectedModeIndex = 0;

  late AnimationController _pulseController;
  static const LatLng _defaultCenter = LatLng(37.7749, -122.4194);

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _mapController.dispose();
    _pulseController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  String _getProfileForIndex(int index) {
    switch (index) {
      case 0:
        return 'foot';
      case 1:
        return 'jog';
      case 2:
        return 'car'; // OSRM Driving profile for Motorcycle routing
      default:
        return 'foot';
    }
  }

  void _recenterMap(LatLng target) {
    _mapController.move(target, 16.0);
  }

  void _zoomIn() {
    final currentZoom = _mapController.camera.zoom;
    _mapController.move(_mapController.camera.center, currentZoom + 1.0);
  }

  void _zoomOut() {
    final currentZoom = _mapController.camera.zoom;
    _mapController.move(_mapController.camera.center, currentZoom - 1.0);
  }

  void _onSelectPlace(PlaceSearchResult place, LatLng origin) {
    _searchFocusNode.unfocus();
    ref.read(placeSearchProvider.notifier).selectPlace(place);
    _searchController.text = place.title;

    final destLatLng = LatLng(place.latitude, place.longitude);
    _mapController.move(destLatLng, 15.0);

    // Calculate route to destination
    final profile = _getProfileForIndex(_selectedModeIndex);
    ref.read(routeProvider.notifier).calculateRoute(
          origin: origin,
          destination: destLatLng,
          profile: profile,
        );
  }

  void _onModeChanged(int newIndex, LatLng origin) {
    setState(() => _selectedModeIndex = newIndex);
    final profile = _getProfileForIndex(newIndex);
    
    final routeState = ref.read(routeProvider);
    final selectedPlace = ref.read(placeSearchProvider).selectedPlace;

    LatLng? destLatLng;
    if (selectedPlace != null) {
      destLatLng = LatLng(selectedPlace.latitude, selectedPlace.longitude);
    } else if (routeState.route != null && routeState.route!.points.isNotEmpty) {
      destLatLng = routeState.route!.points.last;
    }

    if (destLatLng != null) {
      ref.read(routeProvider.notifier).calculateRoute(
            origin: origin,
            destination: destLatLng,
            profile: profile,
          );
    }
  }

  ColorFilter _getTileColorFilter(AppMoodColors moodColors) {
    if (moodColors.isDark) {
      return const ColorFilter.matrix(<double>[
        -0.2126, -0.7152, -0.0722, 0, 255,
        -0.2126, -0.7152, -0.0722, 0, 255,
        -0.2126, -0.7152, -0.0722, 0, 255,
        0, 0, 0, 1, 0,
      ]);
    } else {
      return const ColorFilter.mode(
        Colors.transparent,
        BlendMode.dst,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentMood = ref.watch(moodProvider);
    final colors = context.moodColors;
    final locationState = ref.watch(locationProvider);
    final searchState = ref.watch(placeSearchProvider);
    final routeState = ref.watch(routeProvider);

    final LatLng currentLatLng = locationState.position != null
        ? LatLng(locationState.position!.latitude, locationState.position!.longitude)
        : _defaultCenter;

    // Listen to position updates during active navigation session to track position and detect route deviation
    ref.listen<LocationState>(locationProvider, (previous, next) {
      if (next.position != null && ref.read(routeProvider).isNavigationActive) {
        final currentPos = LatLng(next.position!.latitude, next.position!.longitude);
        ref.read(routeProvider.notifier).updateNavigationPosition(currentPos);
      }
    });

    final selectedPlace = searchState.selectedPlace;
    final LatLng? destLatLng = selectedPlace != null
        ? LatLng(selectedPlace.latitude, selectedPlace.longitude)
        : null;

    return Scaffold(
      body: Stack(
        children: [
          // 1. Real OpenStreetMap Container via flutter_map
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: currentLatLng,
              initialZoom: 15.0,
              minZoom: 3.0,
              maxZoom: 18.0,
            ),
            children: [
              // OpenStreetMap Tile Layer
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.auraroute.app',
                tileBuilder: (context, tileWidget, tile) {
                  return ColorFiltered(
                    colorFilter: _getTileColorFilter(colors),
                    child: tileWidget,
                  );
                },
              ),

              // Polyline Layer for calculated route
              if (routeState.route != null && routeState.route!.points.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: routeState.route!.points,
                      strokeWidth: 6.0,
                      color: colors.route,
                      borderColor: colors.isDark ? Colors.black38 : Colors.white60,
                      borderStrokeWidth: 2.0,
                    ),
                  ],
                ),

              // Markers Layer (User location + Waypoints + Destination)
              MarkerLayer(
                markers: [
                  // User Location Marker
                  if (locationState.position != null)
                    Marker(
                      point: currentLatLng,
                      width: 50,
                      height: 50,
                      child: AnimatedBuilder(
                        animation: _pulseController,
                        builder: (context, child) {
                          final scale = 1.0 + (_pulseController.value * 0.3);
                          return Transform.scale(
                            scale: scale,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: colors.accent.withValues(
                                      alpha: 0.25 * (1.0 - _pulseController.value),
                                    ),
                                  ),
                                ),
                                Container(
                                  width: 18,
                                  height: 18,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: colors.accent,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2.5,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: colors.accent.withValues(alpha: 0.5),
                                        blurRadius: 8,
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),

                  // Intermediate Waypoints Markers
                  if (routeState.waypoints.isNotEmpty)
                    ...routeState.waypoints.map(
                      (waypoint) => Marker(
                        point: waypoint,
                        width: 32,
                        height: 32,
                        child: Container(
                          decoration: BoxDecoration(
                            color: colors.accent,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(
                            Icons.adjust_rounded,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                  // Destination Marker
                  if (destLatLng != null)
                    Marker(
                      point: destLatLng,
                      width: 44,
                      height: 44,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: colors.accent2,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: colors.accent2.withValues(alpha: 0.4),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            )
                          ],
                        ),
                        child: Icon(
                          Icons.location_on_rounded,
                          size: 22,
                          color: colors.isDark ? Colors.black : Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),

          // 2. Location Status Banner
          if (locationState.status != LocationStatus.success &&
              locationState.status != LocationStatus.loading)
            Positioned(
              top: 170,
              left: 16,
              right: 16,
              child: GlassSurfaceCard(
                borderRadius: 16,
                padding: const EdgeInsets.all(14),
                borderColor: colors.accent,
                child: Row(
                  children: [
                    Icon(Icons.location_off_rounded, color: colors.accent, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            locationState.status == LocationStatus.serviceDisabled
                                ? 'GPS Services Disabled'
                                : 'Location Access Needed',
                            style: TextStyle(
                              color: colors.text,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            locationState.errorMessage ??
                                'Enable location to calculate mood routes.',
                            style: TextStyle(
                              color: colors.mutedText,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    SecondaryButton(
                      label: locationState.status ==
                              LocationStatus.permissionPermanentlyDenied
                          ? 'Settings'
                          : 'Enable',
                      onPressed: () {
                        final notifier = ref.read(locationProvider.notifier);
                        if (locationState.status ==
                            LocationStatus.permissionPermanentlyDenied) {
                          notifier.openAppSettings();
                        } else if (locationState.status ==
                            LocationStatus.serviceDisabled) {
                          notifier.openLocationSettings();
                        } else {
                          notifier.requestPermission();
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),

          // 3. Routing Error Banner
          if (routeState.status == RouteStatus.routeError)
            Positioned(
              top: 170,
              left: 16,
              right: 16,
              child: GlassSurfaceCard(
                borderRadius: 16,
                padding: const EdgeInsets.all(14),
                borderColor: Colors.redAccent,
                child: Row(
                  children: [
                    const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Route Error',
                            style: TextStyle(
                              color: colors.text,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            routeState.errorMessage ?? 'Could not calculate route.',
                            style: TextStyle(
                              color: colors.mutedText,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close_rounded, color: colors.mutedText),
                      onPressed: () => ref.read(routeProvider.notifier).clearRoute(),
                    ),
                  ],
                ),
              ),
            ),

          // 4. Top Search & Chips Overlay
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search Bar Card
                  GlassSurfaceCard(
                    borderRadius: 16,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    child: Row(
                      children: [
                        Icon(Icons.search_rounded, color: colors.accent),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            focusNode: _searchFocusNode,
                            style: TextStyle(color: colors.text, fontSize: 14),
                            onChanged: (val) {
                              ref
                                  .read(placeSearchProvider.notifier)
                                  .onQueryChanged(val);
                            },
                            decoration: InputDecoration(
                              hintText: 'Search destination or vibe location...',
                              hintStyle: TextStyle(color: colors.mutedText, fontSize: 13),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        if (searchState.isLoading)
                          SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: colors.accent,
                            ),
                          )
                        else if (_searchController.text.isNotEmpty)
                          IconButton(
                            icon: Icon(Icons.clear_rounded, color: colors.mutedText, size: 20),
                            onPressed: () {
                              _searchController.clear();
                              ref.read(placeSearchProvider.notifier).clearSelection();
                              ref.read(routeProvider.notifier).clearRoute();
                            },
                          ),
                      ],
                    ),
                  ),

                  // Autocomplete Search Results Dropdown List
                  if (searchState.results.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Container(
                      constraints: const BoxConstraints(maxHeight: 220),
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: colors.mutedText.withValues(alpha: 0.2),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: colors.isDark ? 0.4 : 0.1),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: ListView.separated(
                        shrinkWrap: true,
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        itemCount: searchState.results.length,
                        separatorBuilder: (ctx, idx) => Divider(
                          height: 1,
                          color: colors.mutedText.withValues(alpha: 0.1),
                        ),
                        itemBuilder: (context, index) {
                          final place = searchState.results[index];
                          return ListTile(
                            dense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 2,
                            ),
                            leading: Icon(
                              Icons.place_outlined,
                              color: colors.accent,
                              size: 20,
                            ),
                            title: Text(
                              place.title,
                              style: TextStyle(
                                color: colors.text,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            subtitle: Text(
                              place.subtitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: colors.mutedText,
                                fontSize: 11,
                              ),
                            ),
                            onTap: () => _onSelectPlace(place, currentLatLng),
                          );
                        },
                      ),
                    ),
                  ],

                  const SizedBox(height: 10),

                  // Mood & Weather Chips Row
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        MoodChip(mood: currentMood),
                        const SizedBox(width: 8),
                        const WeatherChip(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 5. Floating Controls (Zoom, Travel Modes, Recenter FAB)
          Positioned(
            right: 16,
            bottom: 230 + MediaQuery.of(context).padding.bottom,
            child: Column(
              children: [
                // Zoom Controls Group
                Container(
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: colors.mutedText.withValues(alpha: 0.2)),
                  ),
                  child: Column(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.add, size: 20),
                        color: colors.text,
                        onPressed: _zoomIn,
                      ),
                      Divider(height: 1, color: colors.mutedText.withValues(alpha: 0.2)),
                      IconButton(
                        icon: const Icon(Icons.remove, size: 20),
                        color: colors.text,
                        onPressed: _zoomOut,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // Travel Mode Toggle Selector
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: colors.mutedText.withValues(alpha: 0.2)),
                  ),
                  child: Column(
                    children: [
                      _buildModeIcon(0, Icons.directions_walk_rounded, currentLatLng),
                      _buildModeIcon(1, Icons.directions_run_rounded, currentLatLng),
                      _buildModeIcon(2, Icons.two_wheeler_rounded, currentLatLng),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // Adventure Discovery FAB
                FloatingActionButton.small(
                  heroTag: 'adventure_discovery_fab',
                  backgroundColor: colors.surface,
                  foregroundColor: colors.accent,
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      backgroundColor: Colors.transparent,
                      isScrollControlled: true,
                      builder: (ctx) => SafeArea(
                        child: Padding(
                          padding: EdgeInsets.only(
                            left: 16.0,
                            right: 16.0,
                            top: 16.0,
                            bottom: 16.0 + MediaQuery.of(ctx).viewInsets.bottom,
                          ),
                          child: const AdventureDiscoveryCard(),
                        ),
                      ),
                    );
                  },
                  child: const Icon(Icons.explore_rounded),
                ),
                const SizedBox(height: 10),

                // Recenter Location FAB
                FloatingActionButton.small(
                  heroTag: 'recenter_location_fab',
                  backgroundColor: colors.surface,
                  foregroundColor: colors.accent,
                  onPressed: () {
                    if (locationState.position != null) {
                      _recenterMap(currentLatLng);
                    } else {
                      ref.read(locationProvider.notifier).requestPermission();
                    }
                  },
                  child: locationState.status == LocationStatus.loading
                      ? SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: colors.accent,
                          ),
                        )
                      : Icon(
                          locationState.position != null
                              ? Icons.my_location_rounded
                              : Icons.location_searching_rounded,
                        ),
                ),
              ],
            ),
          ),

          // 6. Bottom Route Information Card Overlay
          Positioned(
            left: 16,
            right: 16,
            bottom: 16 + MediaQuery.of(context).padding.bottom,
            child: routeState.isNavigationActive
                // ACTIVE NAVIGATION CARD OVERLAY
                ? GlassSurfaceCard(
                    borderRadius: 20,
                    padding: const EdgeInsets.all(18),
                    borderColor: routeState.isOffRoute ? Colors.orangeAccent : colors.accent,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Off Route Deviation Warning Banner
                        if (routeState.isOffRoute) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.orangeAccent.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.orangeAccent.withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.warning_amber_rounded, color: Colors.orangeAccent, size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Off route detected. Tap to recalculate route.',
                                    style: TextStyle(
                                      color: colors.text,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                TextButton(
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    minimumSize: Size.zero,
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  onPressed: destLatLng == null
                                      ? null
                                      : () {
                                          ref.read(routeProvider.notifier).calculateRoute(
                                                origin: currentLatLng,
                                                destination: destLatLng,
                                              );
                                        },
                                  child: const Text('Reroute', style: TextStyle(color: Colors.orangeAccent, fontSize: 12, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],

                        // Active Navigation Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: colors.accent.withValues(alpha: 0.2),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(Icons.navigation_rounded, size: 14, color: colors.accent),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'NAVIGATION ACTIVE',
                                        style: TextStyle(
                                          color: colors.accent,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 11,
                                          letterSpacing: 0.8,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    selectedPlace != null ? selectedPlace.title : 'Navigating',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 17,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: colors.accent.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                currentMood.displayName,
                                style: TextStyle(
                                  color: colors.accent,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 20),

                        // Navigation Live Remaining Metrics
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildRouteStat(
                              'Remaining',
                              routeState.formattedRemainingDistance,
                              Icons.straighten_rounded,
                            ),
                            _buildRouteStat(
                              'Est. Remaining',
                              routeState.formattedRemainingDuration,
                              Icons.timer_rounded,
                            ),
                            _buildRouteStat(
                              'Mode',
                              _getModeLabel(),
                              _selectedModeIndex == 2
                                  ? Icons.two_wheeler_rounded
                                  : Icons.directions_walk_rounded,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Live Guidance Availability Notice
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: colors.surface,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: colors.mutedText.withValues(alpha: 0.15)),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.info_outline_rounded, size: 16, color: colors.mutedText),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Live position tracking active. Full turn-by-turn voice guidance is not yet available.',
                                  style: TextStyle(
                                    color: colors.mutedText,
                                    fontSize: 11,
                                    height: 1.3,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Action Buttons (Recenter + End Navigation)
                        Row(
                          children: [
                            Expanded(
                              child: SecondaryButton(
                                label: 'Recenter Map',
                                icon: Icons.my_location_rounded,
                                onPressed: () => _recenterMap(currentLatLng),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: PrimaryButton(
                                label: 'End Navigation',
                                icon: Icons.stop_rounded,
                                onPressed: () {
                                  final route = routeState.route;
                                  if (route != null) {
                                    showDialog(
                                      context: context,
                                      barrierDismissible: false,
                                      builder: (dialogCtx) => RouteCompletionDialog(
                                        distanceMeters: route.distanceMeters,
                                        durationSeconds: route.durationSeconds,
                                        activityType: _getModeLabel(),
                                        mood: currentMood.displayName,
                                        destinationName: selectedPlace?.title ?? 'Exploration Route',
                                        onDismissed: () {
                                          ref.read(routeProvider.notifier).endNavigation();
                                        },
                                      ),
                                    );
                                  } else {
                                    ref.read(routeProvider.notifier).endNavigation();
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                // PREVIEW ROUTE CARD OVERLAY
                : GlassSurfaceCard(
                    borderRadius: 20,
                    padding: const EdgeInsets.all(18),
                    borderColor: colors.accent.withValues(alpha: 0.3),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    selectedPlace != null
                                        ? selectedPlace.title
                                        : 'Select Destination',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 17,
                                        ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    selectedPlace != null
                                        ? (routeState.route?.summary ?? selectedPlace.subtitle)
                                        : 'Type location in search bar above',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: colors.mutedText,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: colors.accent.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                currentMood.displayName,
                                style: TextStyle(
                                  color: colors.accent,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildRouteStat(
                              'Distance',
                              routeState.route != null
                                  ? routeState.route!.formattedDistance
                                  : '—',
                              Icons.straighten_rounded,
                            ),
                            _buildRouteStat(
                              'ETA',
                              routeState.route != null
                                  ? routeState.route!.formattedDuration
                                  : '—',
                              Icons.schedule_rounded,
                            ),
                            _buildRouteStat(
                              'Mode',
                              _getModeLabel(),
                              _selectedModeIndex == 2
                                  ? Icons.two_wheeler_rounded
                                  : Icons.directions_walk_rounded,
                            ),
                          ],
                        ),
                        if (_selectedModeIndex == 2) ...[
                          const SizedBox(height: 6),
                          Text(
                            '* Motorcycle-style route via Driving profile',
                            style: TextStyle(
                              color: colors.mutedText,
                              fontSize: 10,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.bookmark_border_rounded, color: colors.accent),
                              onPressed: routeState.route == null || destLatLng == null
                                  ? null
                                  : () async {
                                      await ref.read(favoritesProvider.notifier).saveFavorite(
                                            title: selectedPlace?.title ?? 'Saved Route',
                                            destinationName: selectedPlace?.title ?? 'Destination',
                                            destLat: destLatLng.latitude,
                                            destLon: destLatLng.longitude,
                                            distanceMeters: routeState.route!.distanceMeters,
                                            durationSeconds: routeState.route!.durationSeconds,
                                            mood: currentMood.displayName,
                                          );
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('Route saved to Favorites!'),
                                            duration: Duration(seconds: 2),
                                          ),
                                        );
                                      }
                                    },
                            ),
                            IconButton(
                              icon: Icon(Icons.share_rounded, color: colors.accent),
                              onPressed: routeState.route == null
                                  ? null
                                  : () {
                                      showDialog(
                                        context: context,
                                        builder: (dialogCtx) => ShareSummaryDialog(
                                          distanceMeters: routeState.route!.distanceMeters,
                                          durationSeconds: routeState.route!.durationSeconds,
                                          mood: currentMood.displayName,
                                          destinationName: selectedPlace?.title ?? 'Destination',
                                        ),
                                      );
                                    },
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: PrimaryButton(
                                label: routeState.status == RouteStatus.loading
                                    ? 'Calculating Route...'
                                    : 'Start Navigation',
                                icon: Icons.navigation_rounded,
                                isLoading: routeState.status == RouteStatus.loading,
                                onPressed: routeState.route == null
                                    ? null
                                    : () {
                                        ref.read(routeProvider.notifier).startNavigation();
                                      },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  String _getModeLabel() {
    switch (_selectedModeIndex) {
      case 0:
        return 'Walk';
      case 1:
        return 'Jog';
      case 2:
        return 'Motorcycle';
      default:
        return 'Walk';
    }
  }

  Widget _buildModeIcon(int index, IconData icon, LatLng origin) {
    final colors = context.moodColors;
    final isSelected = _selectedModeIndex == index;

    return GestureDetector(
      onTap: () => _onModeChanged(index, origin),
      child: Container(
        padding: const EdgeInsets.all(8),
        margin: const EdgeInsets.symmetric(vertical: 2),
        decoration: BoxDecoration(
          color: isSelected ? colors.accent : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          size: 18,
          color: isSelected
              ? (colors.isDark ? Colors.black : Colors.white)
              : colors.mutedText,
        ),
      ),
    );
  }

  Widget _buildRouteStat(String label, String value, IconData icon) {
    final colors = context.moodColors;

    return Row(
      children: [
        Icon(icon, size: 16, color: colors.accent),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: TextStyle(
                color: colors.text,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: colors.mutedText,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
