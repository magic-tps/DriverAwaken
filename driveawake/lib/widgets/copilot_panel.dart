import 'dart:async';
import 'package:flutter/material.dart';
import '../l10n/localized_text.dart';
import '../l10n/locale_controller.dart';
import '../navigation/conversation_engine.dart';
import '../navigation/copilot_conversation.dart';
import '../navigation/smart_navigation.dart';
import '../services/voice_command_service.dart';

class CopilotPanel extends StatefulWidget {
  const CopilotPanel({
    super.key,
    required this.contextProvider,
    required this.onAction,
  });
  final ConversationContext Function() contextProvider;
  final Future<void> Function(VoiceCommand) onAction;
  @override
  State<CopilotPanel> createState() => _CopilotPanelState();
}

class _CopilotPanelState extends State<CopilotPanel>
    with WidgetsBindingObserver {
  final nav = SmartNavigation.instance;
  late final conversation = CopilotConversation(
    voice: nav.voice,
    input: VoiceCommandService.instance,
    context: widget.contextProvider,
    onAction: widget.onAction,
    language: () => LocaleController.instance.effectiveLocale.languageCode,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) unawaited(conversation.stop());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    conversation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SafeArea(
    child: SizedBox(
      height: MediaQuery.sizeOf(context).height * .78,
      child: ListenableBuilder(
        listenable: Listenable.merge([conversation, nav.voice]),
        builder: (context, _) => SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: LocalizedText(
                  'Tu copiloto',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              SwitchListTile(
                title: const LocalizedText('Alertas habladas'),
                subtitle: const LocalizedText(
                  'Te aviso con voz cuando detecto señales de cansancio.',
                ),
                value: nav.voice.enabled,
                onChanged: (enabled) {
                  unawaited(nav.setVoiceEnabled(enabled));
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LocalizedText(nav.voice.status),
                    TextButton.icon(
                      icon: const Icon(Icons.record_voice_over),
                      label: const LocalizedText('Probar voz'),
                      onPressed: nav.voice.speaking || conversation.active
                          ? null
                          : () async {
                              await nav.setVoiceEnabled(true);
                              await nav.voice.say(
                                'voice_test',
                                'Hola, soy tu copiloto. Estoy aquí para escucharte y avisarte si detecto señales de cansancio.',
                                DateTime.now(),
                                reply: true,
                              );
                            },
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: MediaQuery.sizeOf(context).height * .24,
                child: conversation.messages.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.all(20),
                        child: LocalizedText(
                          'Podemos hablar de tu día, viajes o curiosidades. También puedes decir: cómo voy, necesito descansar, pausar o SOS.',
                        ),
                      )
                    : ListView.builder(
                        reverse: true,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: conversation.messages.length,
                        itemBuilder: (context, index) {
                          final message =
                              conversation.messages[conversation
                                      .messages
                                      .length -
                                  1 -
                                  index];
                          return Align(
                            alignment: message.fromDriver
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(12),
                              constraints: const BoxConstraints(maxWidth: 340),
                              decoration: BoxDecoration(
                                color: message.fromDriver
                                    ? Theme.of(
                                        context,
                                      ).colorScheme.primaryContainer
                                    : Theme.of(
                                        context,
                                      ).colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  LocalizedText(
                                    message.fromDriver ? 'Tú' : 'Copiloto',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(message.text),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    LocalizedText(conversation.status),
                    const SizedBox(height: 10),
                    FilledButton.icon(
                      icon: Icon(
                        conversation.active
                            ? Icons.stop_circle_outlined
                            : Icons.mic,
                      ),
                      label: LocalizedText(
                        conversation.active
                            ? 'Terminar conversación'
                            : 'Conversa conmigo',
                      ),
                      onPressed: () async {
                        if (conversation.active) {
                          await conversation.stop();
                        } else {
                          await nav.setVoiceEnabled(true);
                          await conversation.start();
                        }
                      },
                    ),
                    const SizedBox(height: 8),
                    const LocalizedText(
                      'Al iniciar, el micrófono escucha por turnos. El silencio o cerrar este panel termina la escucha. Android puede usar Internet para reconocer tu voz. La charla se borra al cerrar.',
                      style: TextStyle(fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
