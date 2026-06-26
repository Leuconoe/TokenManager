// Design Ref: §10.4 — Riverpod state for the token list (sort + status filter).

import 'dart:async' show unawaited;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/domain/token_entry.dart';
import '../../core/domain/token_status.dart';
import '../../core/providers.dart';
import 'data/token_repository.dart';

class TokenListState {
  final List<TokenEntry> entries;
  final TokenSort sort;
  final TokenStatus? filter; // null => all
  final int leadDays; // expiry-soon window from Settings
  const TokenListState({
    required this.entries,
    this.sort = TokenSort.expirySoonest,
    this.filter,
    this.leadDays = 14,
  });
}

final tokenListProvider =
    AsyncNotifierProvider<TokenListNotifier, TokenListState>(
        TokenListNotifier.new);

class TokenListNotifier extends AsyncNotifier<TokenListState> {
  TokenSort _sort = TokenSort.expirySoonest;
  TokenStatus? _filter;

  @override
  Future<TokenListState> build() => _load();

  Future<TokenListState> _load() async {
    final repo = ref.read(tokenRepositoryProvider);
    final lead = (await ref.read(settingsRepositoryProvider).getExpiryLead()).days;
    final all = await repo.list(sort: _sort);
    final now = DateTime.now();
    final filtered = _filter == null
        ? all
        : all.where((e) => e.statusAt(now, soonDays: lead) == _filter).toList();
    return TokenListState(
        entries: filtered, sort: _sort, filter: _filter, leadDays: lead);
  }

  Future<void> _refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
  }

  Future<void> setSort(TokenSort sort) {
    _sort = sort;
    return _refresh();
  }

  Future<void> setFilter(TokenStatus? filter) {
    _filter = filter;
    return _refresh();
  }

  Future<void> save(TokenEntry entry) async {
    await ref.read(tokenRepositoryProvider).upsert(entry);
    await _refresh();
    unawaited(ref.read(syncControllerProvider).syncQuietly()); // best-effort push
  }

  Future<void> remove(String id) async {
    await ref.read(tokenRepositoryProvider).delete(id);
    await _refresh();
    unawaited(ref.read(syncControllerProvider).syncQuietly());
  }
}
