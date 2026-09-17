import 'dart:convert';
import 'package:http/http.dart' as http;
import '../domain/ai/ai_model.dart';

class AiService {
  final http.Client _httpClient;
  
  // Backend Proxy URL — Keep configurable.
  // Note: Flutter code NEVER contains secret Groq API keys.
  // The backend proxy receives the request, injects the server-side GROQ_API_KEY, calls Groq API, and returns JSON.
  final String proxyEndpoint;

  AiService({
    http.Client? httpClient,
    this.proxyEndpoint = 'http://10.0.2.2:3000/api/recommendations', // Android Emulator localhost bridge
  }) : _httpClient = httpClient ?? http.Client();

  /// Fetches AI route recommendation via backend proxy, falling back gracefully to local grounded logic if backend is unavailable.
  Future<AiRecommendationResult> fetchRecommendation(AiRecommendationRequest request) async {
    try {
      final response = await _httpClient.post(
        Uri.parse(proxyEndpoint),
        headers: const {
          'Content-Type': 'application/json',
          'User-Agent': 'AuraRoute/1.0 (com.auraroute.app)',
        },
        body: json.encode(request.toJson()),
      ).timeout(const Duration(seconds: 6));

      if (response.statusCode == 200) {
        final jsonMap = json.decode(response.body) as Map<String, dynamic>;
        return AiRecommendationResult.fromJson(jsonMap, isFallback: false);
      } else {
        return _generateGroundedFallback(request);
      }
    } catch (_) {
      // Backend Proxy offline / unreachable / network error fallback
      return _generateGroundedFallback(request);
    }
  }

  /// Grounded Local Fallback Engine
  /// Ensures zero crashes and 100% grounded suggestions using actual retrieved places and weather.
  AiRecommendationResult _generateGroundedFallback(AiRecommendationRequest request) {
    final mood = request.mood;
    final weather = request.weather;
    final dest = request.destination;
    final places = request.nearbyPlaces;

    final targetName = dest?.title ?? (places.isNotEmpty ? places.first.title : 'Nearby Scenic Spot');
    final tempStr = weather != null ? weather.formattedTemperature : 'fair conditions';
    final condStr = weather != null ? weather.conditionLabel.toLowerCase() : 'pleasant weather';

    String title;
    String recommendation;
    String reason;
    List<String> challenges;
    String encouragement;

    if (mood.toLowerCase().contains('energetic') || mood.toLowerCase().contains('high')) {
      title = 'High Energy Power Grind';
      recommendation = 'Pace yourself toward $targetName for an invigorating route.';
      reason = 'With $tempStr and $condStr, your high energy level pairs great with an active tempo walk.';
      challenges = [
        'Maintain a brisk walking pace for 10 minutes continuously',
        'Take a 30-second elevation stride at the midpoint',
      ];
      encouragement = 'Push your boundaries and enjoy the surge of momentum!';
    } else if (mood.toLowerCase().contains('calm') || mood.toLowerCase().contains('restorative')) {
      title = 'Mindful Restorative Stroll';
      recommendation = 'Take a relaxed walk towards $targetName with calm breathing pauses.';
      reason = 'The $condStr weather and comfortable $tempStr offer a tranquil backdrop for your mindful mood.';
      challenges = [
        'Identify 3 natural shapes or textures along your path',
        'Take 5 slow, deep breaths at your destination point',
      ];
      encouragement = 'Let go of tension and take in every peaceful moment.';
    } else if (mood.toLowerCase().contains('adventure') || mood.toLowerCase().contains('curious')) {
      title = 'Scenic Discovery Quest';
      recommendation = 'Explore surrounding paths toward $targetName to discover new sights.';
      reason = 'Curious energy under $condStr skies makes this an ideal time for route exploration.';
      challenges = [
        'Spot 2 architectural or natural features you haven’t noticed before',
        'Take a quick photo of an interesting perspective along the route',
      ];
      encouragement = 'Embrace curiosity—every step has a story waiting!';
    } else {
      title = 'Curated Mood Route';
      recommendation = 'Enjoy a balanced walk towards $targetName.';
      reason = 'Tailored for your active mood under $tempStr ($condStr).';
      challenges = [
        'Walk at your natural, comfortable rhythm for the entire route',
        'Stay present and mindful of your surroundings',
      ];
      encouragement = 'Enjoy your personal time out on the route today!';
    }

    return AiRecommendationResult(
      title: title,
      recommendation: recommendation,
      reason: reason,
      challenges: challenges,
      encouragement: encouragement,
      isFallback: true,
    );
  }
}
