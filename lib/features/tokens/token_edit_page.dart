// Design Ref: §5.4 TokenEditPage — add/edit/delete + non-blocking note warning.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/domain/token_entry.dart';
import '../../l10n/app_localizations.dart';
import 'note_token_detector.dart';
import 'token_providers.dart';

class TokenEditPage extends ConsumerStatefulWidget {
  final TokenEntry? existing;
  const TokenEditPage({super.key, this.existing});

  @override
  ConsumerState<TokenEditPage> createState() => _TokenEditPageState();
}

class _TokenEditPageState extends ConsumerState<TokenEditPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _serviceCtrl;
  late final TextEditingController _urlCtrl;
  late final TextEditingController _noteCtrl;
  DateTime? _issuedAt;
  DateTime? _expiresAt;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _serviceCtrl = TextEditingController(text: e?.serviceName ?? '');
    _urlCtrl = TextEditingController(text: e?.url ?? '');
    _noteCtrl = TextEditingController(text: e?.note ?? '');
    _issuedAt = e?.issuedAt;
    _expiresAt = e?.expiresAt;
  }

  @override
  void dispose() {
    _serviceCtrl.dispose();
    _urlCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate(bool isExpiry) async {
    final now = DateTime.now();
    final initial = (isExpiry ? _expiresAt : _issuedAt) ?? now;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(now.year + 30),
    );
    if (picked != null) {
      setState(() {
        if (isExpiry) {
          _expiresAt = picked;
        } else {
          _issuedAt = picked;
        }
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final l = AppLocalizations.of(context);

    // Non-blocking token-pattern warning (E-NOTE-01).
    if (NoteTokenDetector.looksLikeToken(_noteCtrl.text)) {
      final proceed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(l.noteWarnTitle),
          content: Text(l.noteWarnBody),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(l.actionCancel)),
            FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(l.actionSaveAnyway)),
          ],
        ),
      );
      if (proceed != true) return;
    }

    final now = DateTime.now();
    final base = widget.existing;
    // Monotonic updatedAt: an edit must beat the version it edits even if that
    // version carries a future timestamp from a clock-skewed device.
    final updatedAt = (base != null && !base.updatedAt.isBefore(now))
        ? base.updatedAt.add(const Duration(milliseconds: 1))
        : now;
    final entry = TokenEntry(
      id: base?.id ?? const Uuid().v4(),
      serviceName: _serviceCtrl.text.trim(),
      url: _urlCtrl.text.trim(),
      issuedAt: _issuedAt,
      expiresAt: _expiresAt,
      note: _noteCtrl.text,
      createdAt: base?.createdAt ?? now,
      updatedAt: updatedAt,
    );
    await ref.read(tokenListProvider.notifier).save(entry);
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _delete() async {
    final l = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.actionDelete),
        content: Text(l.deleteBody(widget.existing!.serviceName)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l.actionCancel)),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(l.actionDelete)),
        ],
      ),
    );
    if (ok == true) {
      await ref.read(tokenListProvider.notifier).remove(widget.existing!.id);
      if (mounted) Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? l.editTitleEdit : l.editTitleNew),
        actions: [
          if (_isEdit)
            IconButton(
                onPressed: _delete, icon: const Icon(Icons.delete_outline)),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _securityBanner(l),
            const SizedBox(height: 16),
            TextFormField(
              controller: _serviceCtrl,
              decoration: InputDecoration(
                labelText: l.fieldService,
                hintText: l.fieldServiceHint,
                border: const OutlineInputBorder(),
              ),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? l.validationServiceRequired
                  : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _urlCtrl,
              keyboardType: TextInputType.url,
              decoration: InputDecoration(
                labelText: l.fieldUrl,
                hintText: l.fieldUrlHint,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.link),
              ),
            ),
            const SizedBox(height: 16),
            _dateField(l, l.fieldIssued, _issuedAt, () => _pickDate(false),
                () => setState(() => _issuedAt = null)),
            const SizedBox(height: 12),
            _dateField(l, l.fieldExpiry, _expiresAt, () => _pickDate(true),
                () => setState(() => _expiresAt = null)),
            if (_expiresAt == null)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(l.hintNoExpiry,
                    style: const TextStyle(color: Colors.orange, fontSize: 12)),
              ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _noteCtrl,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: l.fieldNote,
                hintText: l.fieldNoteHint,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.save_outlined),
              label: Text(l.actionSave),
            ),
          ],
        ),
      ),
    );
  }

  Widget _securityBanner(AppLocalizations l) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.amber.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.amber),
        ),
        child: Row(
          children: [
            const Icon(Icons.warning_amber, color: Colors.amber),
            const SizedBox(width: 8),
            Expanded(
              child: Text(l.securityBanner,
                  style: const TextStyle(fontSize: 12)),
            ),
          ],
        ),
      );

  Widget _dateField(AppLocalizations l, String label, DateTime? value,
      VoidCallback onPick, VoidCallback onClear) {
    final text = value == null
        ? l.dateUnset
        : '${value.year}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      child: Row(
        children: [
          Expanded(child: Text(text)),
          if (value != null)
            IconButton(
                onPressed: onClear, icon: const Icon(Icons.clear, size: 18)),
          TextButton(onPressed: onPick, child: Text(l.dateSelect)),
        ],
      ),
    );
  }
}
