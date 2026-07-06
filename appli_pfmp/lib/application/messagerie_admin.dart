import 'package:appli_pfmp/custom/custom_colors/couleurs_widgets.dart';
import 'package:appli_pfmp/custom/custom_widgets/date.dart';
import 'package:appli_pfmp/custom/responsive/responsive.dart';
import 'package:appli_pfmp/data/message_api.dart';
import 'package:appli_pfmp/model/infos_admin.dart';
import 'package:appli_pfmp/model/message.dart';
import 'package:appli_pfmp/model/utilisateur.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MessagerieAdmin extends StatefulWidget {
  final Utilisateur utilisateur;
  final List<StagiaireAdmin> stagiaires;

  const MessagerieAdmin({
    super.key,
    required this.utilisateur,
    required this.stagiaires,
  });

  @override
  State<MessagerieAdmin> createState() => _MessagerieAdminState();
}

class _MessagerieAdminState extends State<MessagerieAdmin> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  int? _selectedPfmpId;
  int? _loadedPfmpId;
  bool _loadingMessages = false;
  bool _sendingMessage = false;
  String? _errorMessage;
  List<MessagePfmp> _messages = [];

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final conversations = _activeConversations(widget.stagiaires);

    if (conversations.isEmpty) {
      return _buildEmptyState(
        icon: Icons.forum_outlined,
        title: 'Aucune conversation active',
        message: 'Les messages sont disponibles pendant une PFMP en cours.',
      );
    }

    final selectedConversation = _selectedConversation(conversations);
    if (_selectedPfmpId == null && selectedConversation != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _selectedPfmpId == null) {
          _selectConversation(selectedConversation);
        }
      });
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 900;
        if (compact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPageTitle(conversations.length),
              const SizedBox(height: 10),
              _buildConversationStrip(conversations, selectedConversation),
              const SizedBox(height: 10),
              Expanded(child: _buildChatArea(selectedConversation)),
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPageTitle(conversations.length),
            const SizedBox(height: 10),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    width: 340,
                    child: _buildConversationList(
                      conversations,
                      selectedConversation,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: _buildChatArea(selectedConversation)),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPageTitle(int count) {
    return Wrap(
      spacing: 10,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        const Text(
          'Messagerie',
          style: TextStyle(color: Colors.white, fontSize: 20.0),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: couleurWidget,
            border: Border.all(color: Colors.black),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '$count active${count > 1 ? 's' : ''}',
            style: const TextStyle(color: Colors.amber),
          ),
        ),
      ],
    );
  }

  Widget _buildConversationList(
    List<StagiaireAdmin> conversations,
    StagiaireAdmin? selectedConversation,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: couleurWidget,
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListView.separated(
        padding: const EdgeInsets.all(8),
        itemCount: conversations.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final conversation = conversations[index];
          return _buildConversationTile(
            conversation,
            selected: conversation.idPfmp == selectedConversation?.idPfmp,
          );
        },
      ),
    );
  }

  Widget _buildConversationStrip(
    List<StagiaireAdmin> conversations,
    StagiaireAdmin? selectedConversation,
  ) {
    return SizedBox(
      height: 92,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: conversations.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final conversation = conversations[index];
          return SizedBox(
            width: 260,
            child: _buildConversationTile(
              conversation,
              selected: conversation.idPfmp == selectedConversation?.idPfmp,
            ),
          );
        },
      ),
    );
  }

  Widget _buildConversationTile(
    StagiaireAdmin conversation, {
    required bool selected,
  }) {
    final background = selected ? Colors.amber : couleurFormulaire;
    final foreground = selected ? Colors.black : Colors.white;
    final secondary = selected ? Colors.black87 : Colors.grey;

    return Material(
      color: background,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => _selectConversation(conversation),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: selected ? Colors.amber : Colors.black),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Icon(Icons.person_rounded, color: secondary, size: 18),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '${conversation.prenom} ${conversation.nom}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: foreground,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                conversation.entreprise,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: secondary, fontSize: 12),
              ),
              const SizedBox(height: 2),
              Text(
                '${conversation.libelleFiliere} - ${conversation.libelleClasse}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: secondary, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChatArea(StagiaireAdmin? conversation) {
    if (conversation == null) {
      return _buildEmptyState(
        icon: Icons.chat_bubble_outline,
        title: 'Conversation indisponible',
        message: 'Selectionnez une PFMP active.',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildChatHeader(conversation),
        const SizedBox(height: 10),
        Expanded(child: _buildMessagePanel()),
        const SizedBox(height: 10),
        _buildComposer(conversation.idPfmp),
      ],
    );
  }

  Widget _buildChatHeader(StagiaireAdmin conversation) {
    return Container(
      decoration: BoxDecoration(
        color: couleurWidget,
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          const Icon(Icons.forum_rounded, color: Colors.amber),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${conversation.prenom} ${conversation.nom}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Wrap(
                  spacing: 6,
                  runSpacing: 2,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      conversation.entreprise,
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const Text('-', style: TextStyle(color: Colors.grey)),
                    DateFr(date: conversation.dateDebut, couleur: Colors.grey),
                    const Text('-', style: TextStyle(color: Colors.grey)),
                    DateFr(date: conversation.dateFin, couleur: Colors.grey),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Rafraichir',
            onPressed: _loadingMessages
                ? null
                : () => _loadMessages(conversation.idPfmp),
            icon: const Icon(Icons.refresh_rounded, color: Colors.white70),
          ),
        ],
      ),
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
        icon: Icons.chat_bubble_outline,
        title: 'Aucun message',
        message: 'Envoyez le premier message pour cette PFMP.',
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: couleurWidget,
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(12),
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
    final background = isMine ? Colors.amber : couleurBandeau;
    final foreground = isMine ? Colors.black : Colors.white;

    return Align(
      alignment: alignment,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: Responsive.isMobile(context)
              ? MediaQuery.of(context).size.width * 0.78
              : 560,
        ),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: background,
            border: Border.all(color: Colors.black),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment:
                isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Text(
                isMine ? 'Vous' : message.roleExpediteur,
                style: TextStyle(
                  color: foreground.withOpacity(0.72),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                message.contenu,
                style: TextStyle(color: foreground),
              ),
              const SizedBox(height: 6),
              Text(
                _formatDate(message.dateEnvoi),
                style: TextStyle(
                  color: foreground.withOpacity(0.64),
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
        borderRadius: BorderRadius.circular(12),
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
                hintText: 'Message...',
                hintStyle: const TextStyle(color: Colors.blueGrey),
                filled: true,
                fillColor: couleurFormulaire,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
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
                : const Icon(Icons.send_rounded),
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
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: couleurWidget,
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(18),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white54, size: 52),
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

  List<StagiaireAdmin> _activeConversations(List<StagiaireAdmin> stagiaires) {
    final active = stagiaires.where(_isActivePfmp).toList();
    active.sort((a, b) {
      final nameA = '${a.prenom} ${a.nom}'.toLowerCase();
      final nameB = '${b.prenom} ${b.nom}'.toLowerCase();
      return nameA.compareTo(nameB);
    });
    return active;
  }

  StagiaireAdmin? _selectedConversation(List<StagiaireAdmin> conversations) {
    if (conversations.isEmpty) {
      return null;
    }

    if (_selectedPfmpId == null) {
      return conversations.first;
    }

    for (final conversation in conversations) {
      if (conversation.idPfmp == _selectedPfmpId) {
        return conversation;
      }
    }

    return conversations.first;
  }

  bool _isActivePfmp(StagiaireAdmin stagiaire) {
    final today = DateTime.now();
    final currentDate = DateTime(today.year, today.month, today.day);
    final start = DateTime.tryParse(stagiaire.dateDebut);
    final end = DateTime.tryParse(stagiaire.dateFin);

    if (start == null || end == null) {
      return false;
    }

    final startDate = DateTime(start.year, start.month, start.day);
    final endDate = DateTime(end.year, end.month, end.day);

    return !currentDate.isBefore(startDate) && !currentDate.isAfter(endDate);
  }

  void _selectConversation(StagiaireAdmin conversation) {
    if (_selectedPfmpId == conversation.idPfmp &&
        _loadedPfmpId == conversation.idPfmp) {
      return;
    }

    setState(() {
      _selectedPfmpId = conversation.idPfmp;
      _messages = [];
      _errorMessage = null;
    });
    _loadMessages(conversation.idPfmp);
  }

  Future<void> _loadMessages(int idPfmp) async {
    if (!mounted) return;

    setState(() {
      _loadingMessages = true;
      _errorMessage = null;
      _loadedPfmpId = idPfmp;
    });

    final result = await fetchMessages(idPfmp);
    if (!mounted || _loadedPfmpId != idPfmp) return;

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
