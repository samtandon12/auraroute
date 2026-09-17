/**
 * AuraRoute Backend Proxy Server for Groq API
 * 
 * SECURITY MANDATE:
 * Secret API Keys (like GROQ_API_KEY) MUST NEVER be embedded inside the Flutter APK or source code.
 * The Flutter client calls this server endpoint (`/api/recommendations`), which securely injects the 
 * server-side environment variable GROQ_API_KEY and proxies the request to Groq API.
 * 
 * Usage:
 *   1. npm install express cors dotenv node-fetch
 *   2. Create .env with GROQ_API_KEY=your_groq_api_key_here
 *   3. node server.js
 */

const express = require('express');
const cors = require('cors');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;
const GROQ_API_KEY = process.env.GROQ_API_KEY;

app.use(cors());
app.use(express.json());

app.post('/api/recommendations', async (req, res) => {
  try {
    if (!GROQ_API_KEY) {
      console.warn('Warning: GROQ_API_KEY is not set in environment variables.');
      return res.status(500).json({ error: 'Server GROQ_API_KEY not configured.' });
    }

    const { mood, location, weather, destination, nearbyPlaces } = req.body;

    // Strict Grounding System Prompt
    const systemPrompt = `You are AuraRoute AI Companion, a helpful, encouraging outdoor walk and routing guide.
STRICT GROUNDING RULES:
1. NEVER invent non-existent cafes, restaurants, business names, addresses, or fake coordinates.
2. Only reference places provided in the user request (destination or nearbyPlaces). If no specific places are provided, refer to general route exploration (e.g. "your outdoor route", "the nearby walking path").
3. Always tailor suggestions to match the user's active mood and weather conditions.
4. Output MUST be valid JSON adhering strictly to this schema:
{
  "title": "Short Punchy Title (max 6 words)",
  "recommendation": "Grounded activity recommendation sentence",
  "reason": "Clear explanation connecting active mood and current weather metrics",
  "challenges": ["Optional safe challenge 1", "Optional safe challenge 2"],
  "encouragement": "Short uplifting mood message"
}`;

    const userPrompt = `User Context:
- Active Mood: ${mood || 'Exploratory'}
- Weather: ${weather ? `${weather.temperature}°C, ${weather.condition}, wind ${weather.windSpeedKmh} km/h` : 'Fair outdoor weather'}
- Destination: ${destination ? destination.title : 'None specified'}
- Available Valid Places: ${nearbyPlaces && nearbyPlaces.length > 0 ? nearbyPlaces.map(p => p.title).join(', ') : 'None specified'}

Generate a grounded mood recommendation JSON object.`;

    const groqResponse = await fetch('https://api.groq.com/openai/v1/chat/completions', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${GROQ_API_KEY}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        model: 'llama-3.3-70b-versatile',
        messages: [
          { role: 'system', content: systemPrompt },
          { role: 'user', content: userPrompt }
        ],
        response_format: { type: 'json_object' },
        temperature: 0.7,
        max_tokens: 500,
      }),
    });

    if (!groqResponse.ok) {
      const errText = await groqResponse.text();
      console.error('Groq API Error:', errText);
      return res.status(groqResponse.status).json({ error: 'Groq API request failed' });
    }

    const groqData = await groqResponse.json();
    const content = groqData.choices[0].message.content;
    const recommendationJson = JSON.parse(content);

    return res.json(recommendationJson);
  } catch (error) {
    console.error('Proxy Error:', error);
    return res.status(500).json({ error: 'Internal proxy server error' });
  }
});

app.listen(PORT, () => {
  console.log(`AuraRoute AI Proxy Server listening on port ${PORT}`);
});
