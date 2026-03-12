import 'package:flutter/material.dart';
import '../services/gemini_service.dart';

// --- Data Model ---

enum MessageSender { user, ai }

class ChatMessage {
  final String text;
  final MessageSender sender;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.sender,
    required this.timestamp,
  });
}

// --- Screen ---

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen>
    with TickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;
  late AnimationController _typingAnimController;

  @override
  void initState() {
    super.initState();
    _typingAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    // Welcome message
    _messages.add(ChatMessage(
      text:
          'Hi! 👋 I\'m **EduBot**, your educational assistant.\n\nAsk me anything — science, math, history, coding, and more! I\'m here to help you learn. 🎓',
      sender: MessageSender.ai,
      timestamp: DateTime.now(),
    ));
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _typingAnimController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _textController.text.trim();
    if (text.isEmpty || _isTyping) return;

    _textController.clear();

    setState(() {
      _messages.add(ChatMessage(
        text: text,
        sender: MessageSender.user,
        timestamp: DateTime.now(),
      ));
      _isTyping = true;
    });
    _scrollToBottom();

    final reply = await GeminiService.sendMessage(text);

    setState(() {
      _isTyping = false;
      _messages.add(ChatMessage(
        text: reply,
        sender: MessageSender.ai,
        timestamp: DateTime.now(),
      ));
    });
    _scrollToBottom();
  }

  void _clearChat() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text('Clear Chat', style: TextStyle(color: Colors.white)),
        content: const Text(
          'This will clear all messages and reset the conversation.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              GeminiService.clearHistory();
              setState(() {
                _messages.clear();
                _messages.add(ChatMessage(
                  text:
                      'Chat cleared! Ask me anything about your studies. 📚',
                  sender: MessageSender.ai,
                  timestamp: DateTime.now(),
                ));
              });
            },
            child:
                const Text('Clear', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      body: Column(
        children: [
          // ── App Bar ──
          _ChatAppBar(onClear: _clearChat),

          // ── Messages ──
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (_isTyping && index == _messages.length) {
                  return _TypingBubble(
                      animController: _typingAnimController);
                }
                return _MessageBubble(message: _messages[index]);
              },
            ),
          ),

          // ── Input Bar ──
          _InputBar(
            controller: _textController,
            isTyping: _isTyping,
            onSend: _sendMessage,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Sub-widgets
// ─────────────────────────────────────────────

class _ChatAppBar extends StatelessWidget {
  final VoidCallback onClear;
  const _ChatAppBar({required this.onClear});

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    return Container(
      padding: EdgeInsets.only(
          top: topPadding + 8, left: 16, right: 8, bottom: 12),
      decoration: const BoxDecoration(
        color: Color(0xFF0F0F0F),
        border: Border(
          bottom: BorderSide(color: Colors.white12, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4285F4), Color(0xFF0F9D58)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.auto_awesome,
                color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'EduBot',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Powered by Gemini • Educational AI',
                  style:
                      TextStyle(color: Colors.white54, fontSize: 11),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline,
                color: Colors.white54, size: 22),
            tooltip: 'Clear conversation',
            onPressed: onClear,
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.sender == MessageSender.user;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            Container(
              width: 30,
              height: 30,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4285F4), Color(0xFF0F9D58)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.auto_awesome,
                  color: Colors.white, size: 16),
            ),
          ],
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isUser
                    ? const Color(0xFF1A73E8)
                    : const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isUser ? 16 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 16),
                ),
                border: isUser
                    ? null
                    : Border.all(
                        color: Colors.white10, width: 0.5),
              ),
              child: _buildText(message.text, isUser),
            ),
          ),
          if (isUser) const SizedBox(width: 38),
        ],
      ),
    );
  }

  Widget _buildText(String text, bool isUser) {
    // Very basic bold markdown: **text**
    final color = isUser ? Colors.white : const Color(0xDEFFFFFF);
    final parts = text.split('**');
    if (parts.length <= 1) {
      return Text(text,
          style: TextStyle(color: color, fontSize: 14, height: 1.45));
    }
    final spans = <TextSpan>[];
    for (int i = 0; i < parts.length; i++) {
      spans.add(TextSpan(
        text: parts[i],
        style: TextStyle(
          color: color,
          fontSize: 14,
          height: 1.45,
          fontWeight: i.isOdd ? FontWeight.bold : FontWeight.normal,
        ),
      ));
    }
    return RichText(text: TextSpan(children: spans));
  }
}

class _TypingBubble extends StatelessWidget {
  final AnimationController animController;
  const _TypingBubble({required this.animController});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: 30,
            height: 30,
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4285F4), Color(0xFF0F9D58)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.auto_awesome,
                color: Colors.white, size: 16),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomLeft: Radius.circular(4),
                bottomRight: Radius.circular(16),
              ),
              border: Border.all(color: Colors.white10, width: 0.5),
            ),
            child: _AnimatedDots(controller: animController),
          ),
        ],
      ),
    );
  }
}

class _AnimatedDots extends AnimatedWidget {
  const _AnimatedDots({required AnimationController controller})
      : super(listenable: controller);

  @override
  Widget build(BuildContext context) {
    final Animation<double> animation =
        listenable as Animation<double>;
    final double t = animation.value;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        final double delay = i / 3.0;
        final double dt = (t - delay).clamp(0.0, 1.0);
        final double opacity =
            (0.4 + 0.6 * (0.5 - (dt - 0.5).abs() / 0.5).clamp(0.0, 1.0));
        return Container(
          margin: EdgeInsets.only(right: i < 2 ? 5 : 0),
          child: Opacity(
            opacity: opacity,
            child: Container(
              width: 7,
              height: 7,
              decoration: const BoxDecoration(
                color: Colors.white70,
                shape: BoxShape.circle,
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _InputBar extends StatelessWidget {
  final TextEditingController controller;
  final bool isTyping;
  final VoidCallback onSend;

  const _InputBar({
    required this.controller,
    required this.isTyping,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(12, 8, 12, 8 + bottomPadding),
      decoration: const BoxDecoration(
        color: Color(0xFF0F0F0F),
        border: Border(
          top: BorderSide(color: Colors.white12, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              maxLines: 4,
              minLines: 1,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => onSend(),
              decoration: InputDecoration(
                hintText: 'Ask EduBot anything…',
                hintStyle:
                    const TextStyle(color: Colors.white38, fontSize: 14),
                filled: true,
                fillColor: const Color(0xFF1E1E1E),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(
                      color: Colors.white10, width: 0.5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(
                      color: Color(0xFF1A73E8), width: 1),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            child: Material(
              color: isTyping
                  ? Colors.grey.shade800
                  : const Color(0xFF1A73E8),
              borderRadius: BorderRadius.circular(24),
              child: InkWell(
                borderRadius: BorderRadius.circular(24),
                onTap: isTyping ? null : onSend,
                child: Padding(
                  padding: const EdgeInsets.all(11),
                  child: Icon(
                    isTyping ? Icons.hourglass_bottom : Icons.send_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
