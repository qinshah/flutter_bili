import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bili/core/http/loading_state.dart';
import 'package:flutter_bili/core/http/member_http.dart';
import 'package:flutter_bili/module/up/model/space_archive.dart';
import 'package:flutter_bili/module/up/model/space_data.dart';

class UpPageVm extends ChangeNotifier {
  final int mid;

  UpPageVm({required this.mid});

  // User card info
  SpaceCard? _card;
  LoadingState<SpaceCard>? _cardState;

  // Archive list
  List<SpaceArchiveItem> _archives = [];
  LoadingState<SpaceArchiveData>? _archiveState;
  bool _hasMore = true;
  bool _loadingMore = false;
  String? _lastAid;

  SpaceCard? get card => _card;
  LoadingState<SpaceCard>? get cardState => _cardState;
  List<SpaceArchiveItem> get archives => _archives;
  LoadingState<SpaceArchiveData>? get archiveState => _archiveState;
  bool get hasMore => _hasMore;
  bool get loadingMore => _loadingMore;

  String get order => _order;
  String _order = 'pubdate'; // pubdate | click

  Future<void> loadUserCard() async {
    _cardState = null;
    notifyListeners();

    final result = await MemberHttp.userCard(mid: mid);
    _cardState = result;

    if (result is Success<SpaceCard>) {
      _card = result.response;
    }

    notifyListeners();
  }

  Future<void> loadArchives({bool refresh = false}) async {
    if (refresh) {
      _archiveState = null;
      _archives = [];
      _lastAid = null;
      _hasMore = true;
      notifyListeners();
    } else if (_loadingMore || !_hasMore) {
      return;
    }

    if (_archives.isEmpty) {
      _archiveState = null;
    }
    _loadingMore = true;
    notifyListeners();

    final result = await MemberHttp.spaceArchive(
      mid: mid,
      order: _order,
      aid: _lastAid,
    );

    _loadingMore = false;

    if (result is Success<SpaceArchiveData>) {
      final data = result.response;
      _archives.addAll(data.items);
      _hasMore = data.hasNext;
      // 记录最后一个视频的param(aid)用于下次分页
      if (data.items.isNotEmpty) {
        _lastAid = data.items.last.param;
      }
      _archiveState = Success(
        SpaceArchiveData(
          count: data.count,
          items: _archives,
          hasNext: _hasMore,
        ),
      );
    } else {
      _archiveState = result;
    }

    notifyListeners();
  }

  void toggleOrder() {
    _order = _order == 'pubdate' ? 'click' : 'pubdate';
    loadArchives(refresh: true);
  }

  Future<void> refreshAll() async {
    await loadUserCard();
    await loadArchives(refresh: true);
  }
}
