import '../../domain/entities/app_settings.dart';
import '../../domain/repositories/settings_repository.dart';
import '../datasources/settings_datasource.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  SettingsRepositoryImpl(this._local);
  final SettingsDataSource _local;

  @override
  AppSettings getSettings() => _local.load();

  @override
  Future<void> saveSettings(AppSettings settings) => _local.save(settings);
}