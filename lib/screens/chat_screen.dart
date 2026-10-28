import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:intl/intl.dart';
import 'package:animate_do/animate_do.dart';

// 🔒 Replace with your actual Groq API key

const String groqEndpoint = 'https://api.groq.com/openai/v1/chat/completions';
const String llmModel = 'llama-3.3-70b-versatile';

class ChatScreen extends StatefulWidget {
  // --- NEW: Accept Diagnosis Context ---
  final String? initialContext;

  const ChatScreen({super.key, this.initialContext});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with WidgetsBindingObserver {
  final List<types.Message> _messages = [];
  final _user = const types.User(id: 'user');
  final _bot = const types.User(id: 'bot');
  bool _isTyping = false;
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // --- NEW: Context-Aware Greeting ---
    if (widget.initialContext != null) {
      _addBotMessage(
        "I have received your scan results:\n\n${widget.initialContext}\n\nHow can I assist you further with this diagnosis?",
      );
    } else {
      _addBotMessage(
        "Hi there! I'm your Derma Assistant. I can help answer questions about skin conditions and provide general dermatology information. How can I help you today?",
      );
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) return;
    Future.delayed(const Duration(milliseconds: 200), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 100,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOut,
      );
    });
  }

  void _addBotMessage(String text) {
    final message = types.TextMessage(
      author: _bot,
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );
    setState(() {
      _messages.add(message);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  void _addUserMessage(String text) {
    final userMessage = types.TextMessage(
      author: _user,
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );
    setState(() {
      _messages.add(userMessage);
      _isTyping = true;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  Future<void> _handleSendPressed() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    _controller.clear();
    _addUserMessage(text);

    try {
      final response = await _fetchGroqResponse(text);
      _addBotMessage(response);
    } catch (e) {
      _addBotMessage('❌ Oops! Something went wrong. Please try again later.');
    } finally {
      setState(() {
        _isTyping = false;
      });
    }
  }

  Future<String> _fetchGroqResponse(String prompt) async {
    // --- NEW: Inject Context into System Prompt ---
    String contextString = "";
    if (widget.initialContext != null) {
      contextString = "CURRENT PATIENT CONTEXT: ${widget.initialContext}\n";
    }

    final systemPrompt =
        '''
You are a medically informed assistant specializing in dermatology and skin conditions.
$contextString
Respond with proper markdown formatting that Flutter can render:
- Use **bold** for important terms (do NOT include literal "**" in text).
- Use bullet points with proper indentation and spacing.
- Use line breaks between each bullet item.
- Keep language clean, medical, and educational.
- Never diagnose. Always recommend seeing a dermatologist.


User question: $prompt
''';

    final headers = {
      'Authorization': 'Bearer $groqApiKey',
      'Content-Type': 'application/json',
    };

    final body = jsonEncode({
      "model": llmModel,
      "messages": [
        {"role": "system", "content": systemPrompt},
        {"role": "user", "content": prompt},
      ],
      "temperature": 0.3,
      "max_tokens": 350,
    });

    final response = await http.post(
      Uri.parse(groqEndpoint),
      headers: headers,
      body: body,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final content = data['choices']?[0]?['message']?['content'];
      return content?.toString() ?? 'No response from the assistant.';
    } else {
      throw Exception('Groq API returned status ${response.statusCode}');
    }
  }

  Widget _buildMessageBubble(types.Message rawMessage, int index) {
    if (rawMessage is! types.TextMessage) return const SizedBox.shrink();
    final isUser = rawMessage.author.id == _user.id;

    const userBubbleColor = Color(0xFF2E8BC0);
    final botBubbleColor = Colors.white;

    final text = rawMessage.text;
    final time = DateFormat(
      'hh:mm a',
    ).format(DateTime.fromMillisecondsSinceEpoch(rawMessage.createdAt ?? 0));

    final avatar = isUser
        ? const SizedBox(width: 36)
        : FadeInLeft(
            delay: Duration(milliseconds: 50 * index),
            child: const CircleAvatar(
              radius: 18,
              backgroundImage: AssetImage("assets/bot.png"),
              backgroundColor: Colors.white,
            ),
          );

    final bubble = Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.75,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isUser ? userBubbleColor : botBubbleColor,
        border: isUser
            ? null
            : Border.all(color: const Color(0xFFE2F0F6), width: 1),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(isUser ? 16 : 6),
          topRight: Radius.circular(isUser ? 6 : 16),
          bottomLeft: const Radius.circular(16),
          bottomRight: const Radius.circular(16),
        ),
        boxShadow: isUser
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 5,
                  offset: const Offset(1.5, 2),
                ),
              ],
      ),
      child: isUser
          ? Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                height: 1.4,
              ),
            )
          : MarkdownBody(
              data: text,
              styleSheet: MarkdownStyleSheet(
                p: const TextStyle(
                  color: Color(0xFF3A4F5B),
                  fontSize: 15,
                  height: 1.6,
                ),
                listBullet: const TextStyle(
                  fontSize: 18,
                  color: Color(0xFF2E8BC0),
                ),
                strong: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2E8BC0),
                ),
                listIndent: 22,
              ),
              bulletBuilder: (index, style) => const Padding(
                padding: EdgeInsets.only(right: 8, top: 2),
                child: Text(
                  '▸',
                  style: TextStyle(
                    fontSize: 18,
                    color: Color(0xFF2E8BC0),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
    );

    return FadeInUp(
      delay: Duration(milliseconds: 80 * index),
      duration: const Duration(milliseconds: 400),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Column(
          crossAxisAlignment: isUser
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: isUser
                  ? MainAxisAlignment.end
                  : MainAxisAlignment.start,
              children: isUser
                  ? [Flexible(child: bubble), const SizedBox(width: 8)]
                  : [avatar, const SizedBox(width: 8), Flexible(child: bubble)],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 2, left: 6, right: 6),
              child: Text(
                time,
                style: TextStyle(color: const Color(0xFF7F9DAC), fontSize: 11),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E8BC0),
        centerTitle: true,
        elevation: 0,
        title: const Text(
          'Derma Assistant',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 20,
            letterSpacing: 0.5,
          ),
        ),
        // Ensure back button is white
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              color: const Color(0xFFE2F0F6),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: const Text(
                '⚠️ Health Note: I only provide helpful skin health information. Always consult a medical professional for diagnosis & treatment.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF2E8BC0),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(vertical: 12),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  return _buildMessageBubble(_messages[index], index);
                },
              ),
            ),
            if (_isTyping)
              const Padding(
                padding: EdgeInsets.only(bottom: 6),
                child: Text(
                  '🤖 Assistant is typing...',
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Color(0xFF2E8BC0),
                    fontSize: 13,
                  ),
                ),
              ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 6,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: const Color(0xFFE2F0F6)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        child: TextField(
                          controller: _controller,
                          minLines: 1,
                          maxLines: 5,
                          textInputAction: TextInputAction.send,
                          onSubmitted: (_) => _handleSendPressed(),
                          decoration: const InputDecoration(
                            hintText: 'Type your question...',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.send_rounded,
                        color: Color(0xFF2E8BC0),
                        size: 24,
                      ),
                      onPressed: _handleSendPressed,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
