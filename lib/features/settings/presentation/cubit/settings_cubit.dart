import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/datasources/settings_datasource.dart';
import '../../domain/entities/app_settings.dart';

class SettingsCubit extends Cubit<AppSettings> {
  SettingsCubit(this._ds) : super(_ds.load());

  final SettingsDataSource _ds;

  Future<void> update(AppSettings s) async {
    emit(s);
    await _ds.save(s);
  }
}
