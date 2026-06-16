import 'package:flutter/material.dart';
import 'package:teamup/core/theme/design_tokens.dart';
import 'package:teamup/features/messaging/data/messaging_service.dart';
import 'package:teamup/features/messaging/models/message_model.dart';

/// A simple group chat for a game's players, backed by the booking
/// conversation (`booking_{bookingId}`) so the host and all joiners share it.
class GameChatScreen extends StatefulWidget {
  const GameChatScreen({
    super.key,
    required this.bookingId,
    required this.participantIds,
    required this.userId,
    required this.title,
  });

  final String bookingId;
  final List<String> participantIds;
  final String userId;
  final String title;

  @override
  State<GameChatScreen> createState() => _GameChatScreenState();
}

class _GameChatScreenState extends State<GameChatScreen> {
  final _service = MessagingService();
  final _controller = TextEditingController();
  final _scroll = ScrollController();
  bool _sending = false;

  late final String _convId = _service.bookingConversationId(widget.bookingId);

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _sending) return;
    setState(() => _sending = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await _service.sendBookingMessage(
        bookingId: widget.bookingId,
        senderId: widget.userId,
        participantIds: widget.participantIds,
        text: text,
      );
      _controller.clear();
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Could not send: $e')));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TUColors.bg,
      appBar: AppBar(
        backgroundColor: TUColors.bg,
        foregroundColor: TUColors.ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(widget.title, style: const TextStyle(fontWeight: FontWeight.w800, letterSpacing: -0.4, color: TUColors.ink)),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<MessageModel>>(
              stream: _service.streamMessages(conversationId: _convId, userId: widget.userId),
              builder: (context, snap) {
                if (snap.hasError) {
                  return Center(child: Padding(padding: const EdgeInsets.all(24), child: Text('Messages failed: ${snap.error}', textAlign: TextAlign.center)));
                }
                final messages = snap.data ?? const <MessageModel>[];
                if (messages.isEmpty) {
                  return const Center(
                    child: Text('No messages yet — say hi 👋', style: TextStyle(color: TUColors.ink3, fontWeight: FontWeight.w500)),
                  );
                }
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (_scroll.hasClients) _scroll.jumpTo(_scroll.position.maxScrollExtent);
                });
                return ListView.builder(
                  controller: _scroll,
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  itemCount: messages.length,
                  itemBuilder: (_, i) => _Bubble(message: messages[i], mine: messages[i].senderId == widget.userId),
                );
              },
            ),
          ),
          _Composer(controller: _controller, sending: _sending, onSend: _send),
        ],
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.message, required this.mine});
  final MessageModel message;
  final bool mine;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.72),
        decoration: BoxDecoration(
          color: mine ? TUColors.brand : TUColors.surface,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(mine ? 16 : 4),
            bottomRight: Radius.circular(mine ? 4 : 16),
          ),
          border: mine ? null : Border.all(color: TUColors.line),
        ),
        child: Text(
          message.text,
          style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w500, color: mine ? Colors.white : TUColors.ink, height: 1.3),
        ),
      ),
    );
  }
}

class _Composer extends StatelessWidget {
  const _Composer({required this.controller, required this.sending, required this.onSend});
  final TextEditingController controller;
  final bool sending;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: TUColors.surface, border: Border(top: BorderSide(color: TUColors.line))),
      padding: EdgeInsets.fromLTRB(14, 10, 14, 10 + MediaQuery.of(context).padding.bottom),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              minLines: 1,
              maxLines: 4,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => onSend(),
              decoration: InputDecoration(
                hintText: 'Message the team…',
                hintStyle: const TextStyle(color: TUColors.ink3),
                filled: true,
                fillColor: TUColors.surface2,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(TUColors.rPill), borderSide: BorderSide.none),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Material(
            color: TUColors.brand,
            shape: const CircleBorder(),
            child: InkWell(
              onTap: sending ? null : onSend,
              customBorder: const CircleBorder(),
              child: SizedBox(
                width: 46,
                height: 46,
                child: sending
                    ? const Padding(padding: EdgeInsets.all(13), child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.send_rounded, size: 20, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
