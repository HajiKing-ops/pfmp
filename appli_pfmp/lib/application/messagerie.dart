import 'package:appli_pfmp/bloc/pfmp_bloc/pfmp_bloc.dart';
import 'package:appli_pfmp/bloc/pfmp_bloc/pfmp_event.dart';
import 'package:appli_pfmp/bloc/pfmp_bloc/pfmp_state.dart';
import 'package:appli_pfmp/custom/custom_colors/couleurs_widgets.dart';
import 'package:appli_pfmp/custom/responsive/responsive.dart';
import 'package:appli_pfmp/data/message_api.dart';
import 'package:appli_pfmp/model/message.dart';
import 'package:appli_pfmp/model/pfmp.dart';
import 'package:appli_pfmp/model/utilisateur.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class Messagerie extends StatefulWidget {
  final double lEcran;
  final double hEcran;
  final Utilisateur utilisateur;

  const Messagerie({
    super.key,
    required this.lEcran,
    required this.hEcran,
    required this.utilisateur,
  });

  @override
  State<Messagerie> createState() => _MessagerieState();
}

class _MessagerieState extends State<Messagerie> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  int? _loadedPfmpId;
  bool _loadingMessages = false;
  bool _sendingMessage = false;
  String? _errorMessage;
  List<MessagePfmp> _messages = [];

  @override
  void initState() {
    super.initState();
    context.read<PfmpBloc>().add(PfmpInitializeEvent(widget.utilisateur.id, null));
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PfmpBloc, PfmpState>(
      builder: (context, state) {
        if (state is PfmpLoadingState) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is PfmpErrorState) {
          return Center(
            child: Text(
              state.error.toString(),
              style: const TextStyle(color: Colors.redAccent),
            ),
          );
        }

        if (state is! PfmpSuccessState) {
          return const Center(child: CircularProgressIndicator());
        }

        final activePfmp = _activePfmp(state.pfmp.whereType<Pfmp>().toList());
        if (activePfmp == null) {
          return _buildEmptyState(
            icon: Icons.chat_bubble_outline,
            title: 'Aucune messagerie active',
            message:
                'La messagerie est disponible pendant une PFMP en cours.',
          );
        }

        if (_loadedPfmpId != activePfmp.idPfmp && !_loadingMessages) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _loadMessages(activePfmp.idPfmp);
          });
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(activePfmp),
            const SizedBox(height: 12),
            Expanded(child: _buildMessagePanel()),
            const SizedBox(height: 10),
            _buildComposer(activePfmp.idPfmp),
          ],
        );
      },
    );
  }

  Widget _buildHeader(Pfmp activePfmp) {
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        const Text(
          'Messagerie',
          style: TextStyle(color: Colors.white, fontSize: 25.0),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: couleurWidget,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.black),
          ),
          child: Text(
            activePfmp.raisonSociale,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.amber),
          ),
        ),
        IconButton(
          tooltip: 'Rafraichir',
          onPressed: _loadingMessages
              ? null
              : () => _loadMessages(activePfmp.idPfmp),
          icon: const Icon(Icons.refresh, color: Colors.white70),
        ),
      ],
    );
  }

  Widget _buildMessagePanel() {
    if (_loadingMessages) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return _buildEmptyState(
        icon: Icons.error_outline,
        title: 'Messages indisponibles',
        message: _errorMessage!,
      );
    }

    if (_messages.isEmpty) {
      return _buildEmptyState(
        icon: Icons.forum_outlined,
        title: 'Aucun message',
        message: 'Envoyez le premier message pour cette PFMP.',
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: couleurWidget,
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(10),
      child: ListView.separated(
        controller: _scrollController,
        itemCount: _messages.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) => _buildMessageBubble(_messages[index]),
      ),
    );
  }

  Widget _buildMessageBubble(MessagePfmp message) {
    final isMine = message.idUtilisateur == widget.utilisateur.id;
    final alignment = isMine ? Alignment.centerRight : Alignment.centerLeft;
    final backgroundColor = isMine ? Colors.amber : couleurBandeau;
    final foregroundColor = isMine ? Colors.black : Colors.white;

    return Align(
      alignment: alignment,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: Responsive.isMobile(context)
              ? MediaQuery.of(context).size.width * 0.78
              : 520,
        ),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.black),
          ),
          child: Column(
            crossAxisAlignment:
                isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Text(
                message.roleExpediteur,
                style: TextStyle(
                  color: foregroundColor.withOpacity(0.75),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Text(message.contenu, style: TextStyle(color: foregroundColor)),
              const SizedBox(height: 6),
              Text(
                _formatDate(message.dateEnvoi),
                style: TextStyle(
                  color: foregroundColor.withOpacity(0.65),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildComposer(int idPfmp) {
    return Container(
      decoration: BoxDecoration(
        color: couleurWidget,
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              minLines: 1,
              maxLines: 4,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendCurrentMessage(idPfmp),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Votre message...',
                hintStyle: const TextStyle(color: Colors.blueGrey),
                filled: true,
                fillColor: couleurFormulaire,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton.filled(
            tooltip: 'Envoyer',
            style: IconButton.styleFrom(
              backgroundColor: Colors.amber,
              foregroundColor: Colors.black,
            ),
            onPressed:
                _sendingMessage ? null : () => _sendCurrentMessage(idPfmp),
            icon: _sendingMessage
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.send),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String message,
  }) {
    return ResponsiveScrollView(
      fillViewport: true,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white54, size: 58),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Pfmp? _activePfmp(List<Pfmp> pfmps) {
    final today = DateTime.now();
    final currentDate = DateTime(today.year, today.month, today.day);

    for (final pfmp in pfmps) {
      final start = DateTime.tryParse(pfmp.dateDebut);
      final end = DateTime.tryParse(pfmp.dateFin);
      if (start == null || end == null) {
        continue;
      }

      final startDate = DateTime(start.year, start.month, start.day);
      final endDate = DateTime(end.year, end.month, end.day);

      if (!currentDate.isBefore(startDate) && !currentDate.isAfter(endDate)) {
        return pfmp;
      }
    }

    return null;
  }

  Future<void> _loadMessages(int idPfmp) async {
    if (!mounted) return;
    setState(() {
      _loadingMessages = true;
      _errorMessage = null;
      _loadedPfmpId = idPfmp;
    });

    final result = await fetchMessages(idPfmp);
    if (!mounted) return;

    setState(() {
      _loadingMessages = false;
      _messages = result.data ?? [];
      _errorMessage = result.errorMessage;
    });
    _scrollToBottom();
  }

  Future<void> _sendCurrentMessage(int idPfmp) async {
    final contenu = _messageController.text.trim();
    if (contenu.isEmpty || _sendingMessage) {
      return;
    }

    setState(() {
      _sendingMessage = true;
      _errorMessage = null;
    });

    final result = await sendMessage(idPfmp, contenu);
    if (!mounted) return;

    setState(() {
      _sendingMessage = false;
    });

    if (result.data == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.errorMessage ?? "Impossible d'envoyer le message"),
        ),
      );
      return;
    }

    _messageController.clear();
    setState(() {
      _messages = [..._messages, result.data!];
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  String _formatDate(String? value) {
    if (value == null || value.isEmpty) {
      return '';
    }

    final parsed = DateTime.tryParse(value);
    if (parsed == null) {
      return value;
    }

    return DateFormat('dd/MM/yyyy HH:mm').format(parsed.toLocal());
  }
}
