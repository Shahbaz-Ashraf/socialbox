import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/app_settings.dart';
import '../../domain/usecases/settings_usecases.dart';

class SettingsCubit extends Cubit<AppSettings> {
  SettingsCubit({
    required GetSettings getSettings,
    required UpdateSettings updateSettings,
    required ExportCommentsCsv exportCommentsCsv,
  })  : _getSettings = getSettings,
        _updateSettings = updateSettings,
        _exportCommentsCsv = exportCommentsCsv,
        super(const AppSettings()) {
    _load();
  }

  final GetSettings _getSettings;
  final UpdateSettings _updateSettings;
  final ExportCommentsCsv _exportCommentsCsv;

  Future<void> _load() async {
    final r = await _getSettings(const NoParams());
    r.fold((_) {}, emit);
  }

  Future<void> update(AppSettings s) async {
    emit(s);
    await _updateSettings(s);
  }

  Future<bool> exportCommentsToShare() async {
    final r = await _exportCommentsCsv(const NoParams());
    return r.fold(
      (_) => false,
      (csv) async {
        await Share.share(csv, subject: 'SocialBox Comments Export');
        return true;
      },
    );
  }

  Future<String?> exportCommentsToClipboard() async {
    final r = await _exportCommentsCsv(const NoParams());
    return r.fold((_) => null, (csv) => csv);
  }
}