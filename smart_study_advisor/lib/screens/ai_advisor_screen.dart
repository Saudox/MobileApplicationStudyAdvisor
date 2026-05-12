import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../services/student_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

class AiAdvisorScreen extends StatefulWidget {
  const AiAdvisorScreen({super.key});

  @override
  State<AiAdvisorScreen> createState() => _AiAdvisorScreenState();
}

class _AiAdvisorScreenState extends State<AiAdvisorScreen> {
  String get _backendUrl {
    final host = kIsWeb ? 'localhost' : (Platform.isAndroid ? '10.0.2.2' : 'localhost');
    return 'http://$host:8000/api/advisor/ai-chat/';
  }

  final TextEditingController _questionCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();

  final List<_Message> _messages = [];
  bool _loading = false;

  @override
  void dispose() {
    _questionCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendMessage(String question, StudentProvider provider) async {
    if (question.trim().isEmpty) return;

    setState(() {
      _messages.add(_Message(text: question, isUser: true));
      _loading = true;
    });
    _questionCtrl.clear();
    _scrollToBottom();

    try {
      final response = await http.post(
        Uri.parse(_backendUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'message': question,
          'completed': provider.completedCourses.toList(),
          'interests': provider.interests.toList(),
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data['reply'] as String;
        setState(() {
          _messages.add(_Message(text: text.trim(), isUser: false));
          _loading = false;
        });
      } else {
        final data = jsonDecode(response.body);
        throw Exception(data['error'] ?? 'Status ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _messages.add(_Message(
          text: 'Sorry, I could not connect to the AI. Make sure the backend server is running and try again.',
          isUser: false,
          isError: true,
        ));
        _loading = false;
      });
    }
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<StudentProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          backgroundColor: AppTheme.background,
          body: SafeArea(
            child: Column(
              children: [
                _buildHeader(provider),
                Expanded(
                  child: _messages.isEmpty
                      ? _buildEmptyState(provider)
                      : _buildMessageList(),
                ),
                if (_loading) _buildTypingIndicator(),
                _buildInputBar(provider),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(StudentProvider provider) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
      decoration: BoxDecoration(
        color: AppTheme.background,
        border: Border(bottom: BorderSide(color: AppTheme.border)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4285F4), Color(0xFF34A853)],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.auto_awesome_rounded,
                color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('AI Advisor',
                    style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w700)),
                Text('Powered by Llama 3 via Groq',
                    style: TextStyle(
                        color: AppTheme.textMuted, fontSize: 11)),
              ],
            ),
          ),
          if (_messages.isNotEmpty)
            GestureDetector(
              onTap: () => setState(() => _messages.clear()),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceElevated,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.border),
                ),
                child: const Text('Clear',
                    style: TextStyle(
                        color: AppTheme.textSecondary, fontSize: 12)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(StudentProvider provider) {
    final suggestions = [
      'What course should I take next?',
      'I like programming, what do you recommend?',
      'How hard is Operating Systems?',
      'What are the prerequisites for AI?',
    ];

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const SizedBox(height: 20),
        const Center(
          child: Icon(Icons.psychology_rounded,
              size: 56, color: AppTheme.textMuted),
        ),
        const SizedBox(height: 16),
        const Center(
          child: Text('Ask me anything about your studies',
              style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 15,
                  fontWeight: FontWeight.w600)),
        ),
        const SizedBox(height: 6),
        Center(
          child: Text(
            provider.completedCourses.isEmpty
                ? 'Tip: mark some courses as complete for better advice'
                : 'I know you\'ve completed ${provider.completedCourses.length} courses',
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
          ),
        ),
        const SizedBox(height: 32),
        const Text('Suggestions',
            style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        ...suggestions.map((s) => GestureDetector(
              onTap: () => _sendMessage(s, provider),
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceElevated,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lightbulb_outline_rounded,
                        size: 16, color: AppTheme.accent),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(s,
                          style: const TextStyle(
                              color: AppTheme.textPrimary, fontSize: 13)),
                    ),
                    const Icon(Icons.arrow_forward_rounded,
                        size: 14, color: AppTheme.textMuted),
                  ],
                ),
              ),
            )),
      ],
    );
  }

  Widget _buildMessageList() {
    return ListView.builder(
      controller: _scrollCtrl,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      itemCount: _messages.length,
      itemBuilder: (context, idx) {
        final msg = _messages[idx];
        return _MessageBubble(message: msg);
      },
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4285F4), Color(0xFF34A853)],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.auto_awesome_rounded,
                color: Colors.white, size: 16),
          ),
          const SizedBox(width: 10),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppTheme.surfaceElevated,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const _TypingDots(),
          ),
        ],
      ),
    );
  }

  Widget _buildInputBar(StudentProvider provider) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      decoration: BoxDecoration(
        color: AppTheme.background,
        border: Border(top: BorderSide(color: AppTheme.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.surfaceElevated,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppTheme.border),
              ),
              child: TextField(
                controller: _questionCtrl,
                style: const TextStyle(
                    color: AppTheme.textPrimary, fontSize: 14),
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  hintText: 'Ask about courses, study plans...',
                  hintStyle:
                      TextStyle(color: AppTheme.textMuted, fontSize: 14),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                ),
                onSubmitted: (v) => _sendMessage(v, provider),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: _loading
                ? null
                : () => _sendMessage(_questionCtrl.text, provider),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: _loading
                    ? null
                    : const LinearGradient(
                        colors: [Color(0xFF4285F4), Color(0xFF34A853)],
                      ),
                color: _loading ? AppTheme.border : null,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.send_rounded,
                color: _loading ? AppTheme.textMuted : Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Message {
  final String text;
  final bool isUser;
  final bool isError;

  _Message({required this.text, required this.isUser, this.isError = false});
}

class _MessageBubble extends StatelessWidget {
  final _Message message;

  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4285F4), Color(0xFF34A853)],
                ),
                borderRadius: BorderRadius.circular(7),
              ),
              child: const Icon(Icons.auto_awesome_rounded,
                  color: Colors.white, size: 14),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isUser
                    ? AppTheme.accent.withOpacity(0.2)
                    : message.isError
                        ? AppTheme.error.withOpacity(0.1)
                        : AppTheme.surfaceElevated,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isUser ? 16 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 16),
                ),
                border: Border.all(
                  color: isUser
                      ? AppTheme.accent.withOpacity(0.3)
                      : message.isError
                          ? AppTheme.error.withOpacity(0.3)
                          : AppTheme.border,
                ),
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  color: message.isError
                      ? AppTheme.error
                      : AppTheme.textPrimary,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
            ),
          ),
          if (isUser) const SizedBox(width: 8),
        ],
      ),
    );
  }
}

class _TypingDots extends StatefulWidget {
  const _TypingDots();

  @override
  State<_TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<_TypingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final offset = ((_ctrl.value * 3) - i).clamp(0.0, 1.0);
            final bounce = (offset < 0.5 ? offset : 1.0 - offset) * 2;
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              width: 7,
              height: 7 + bounce * 4,
              decoration: BoxDecoration(
                color: AppTheme.accent.withOpacity(0.5 + bounce * 0.5),
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
        );
      },
    );
  }
}
