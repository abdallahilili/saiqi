import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/core.dart';

/// Aide : contact du support (appel / WhatsApp) et signalement d'un problème.
class HelpScreen extends ConsumerStatefulWidget {
  const HelpScreen({super.key});

  @override
  ConsumerState<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends ConsumerState<HelpScreen> {
  final _form = GlobalKey<FormState>();
  final _text = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (!(_form.currentState?.validate() ?? false)) return;
    setState(() => _busy = true);
    final ok = await runAction(
      context,
      () => ref.read(bookingRepositoryProvider).fileComplaint(text: _text.text.trim()),
      successMessage: context.l10n.complaintSentMsg,
    );
    if (!mounted) return;
    setState(() => _busy = false);
    if (ok) _text.clear();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final settings = ref.watch(appSettingsProvider).value ?? AppSettings.empty;
    final call = settings.supportPhone;
    final wa = settings.supportWhatsapp.isNotEmpty ? settings.supportWhatsapp : call;
    return Scaffold(
      appBar: AppBar(title: Text(l.helpClient)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (call.isNotEmpty) ...[
            SecondaryButton(label: l.contactSupportCall, icon: Icons.call_outlined, onPressed: () => Launchers.call(call)),
            const SizedBox(height: 10),
            SecondaryButton(label: l.contactSupportWhatsapp, icon: Icons.chat_outlined, onPressed: () => Launchers.whatsapp(wa)),
          ] else
            Text(l.supportNotConfigured),
          const SizedBox(height: 24),
          Text(l.fileComplaint, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          Form(
            key: _form,
            child: Column(
              children: [
                AppTextField(
                  controller: _text,
                  label: l.fileComplaint,
                  hint: l.complaintHint,
                  maxLines: 5,
                  validator: (v) => (v == null || v.trim().length < 5) ? l.err_text_too_short : null,
                ),
                const SizedBox(height: 14),
                PrimaryButton(label: l.send, icon: Icons.send_rounded, loading: _busy, onPressed: _send),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
