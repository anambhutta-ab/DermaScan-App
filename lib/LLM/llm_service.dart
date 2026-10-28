import 'dart:convert';
import 'package:http/http.dart' as http;

class LLMService {
  static const String _endpoint =
      'https://api.groq.com/openai/v1/chat/completions';
  static const String _model = 'llama-3.3-70b-versatile';

  Future<String> getResponse(String userMessage) async {
    const systemPrompt = '''
You are a medically informed assistant specializing in dermatology and skin conditions.
Respond with proper markdown formatting that Flutter can render:
- Use **bold** for important terms (do NOT include literal "**" in text).
- Use bullet points with proper indentation and spacing.
- Use line breaks between each bullet item.
- Keep language clean, medical, and educational.
- Never diagnose. Always recommend seeing a dermatologist.
You are a dermatology assistant.
Only answer questions related to:
- Skin diseases
- Dermatology
- Skin care
- Symptoms
- Prevention
- Treatments
If the user asks anything unrelated to dermatology, reply:
"I can only assist with dermatology and skin-related topics."
''';
    final headers = {
      'Authorization': 'Bearer $_apiKey',
      'Content-Type': 'application/json',
    };

    final body = jsonEncode({
      "model": _model,
      "messages": [
        {"role": "system", "content": systemPrompt},
        {"role": "user", "content": userMessage},
      ],
      "temperature": 0.3,
      "max_tokens": 350,
    });

    try {
      final response = await http.post(
        Uri.parse(_endpoint),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices']?[0]?['message']?['content'] ??
            'No response from the assistant.';
      } else {
        throw Exception('API error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to get response: $e');
    }
  }
}
