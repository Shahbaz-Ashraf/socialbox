import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:workmanager/workmanager.dart';

import 'app/app.dart';
import 'app/app_bloc_observer.dart';
import 'app/router/app_router.dart';
import 'core/constants/app_constants.dart';
import 'core/services/background_service.dart';
import 'core/services/notification_service.dart';
import 'injection_container.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations(
    [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown],
  );
  await configureDependencies();
  Bloc.observer = AppBlocObserver();
  await getIt<NotificationService>().init(
    onTap: (payload) {
      if (payload != null && payload.isNotEmpty) {
        appRouter.push('/posts/$payload');
      }
    },
  );
  if (!kIsWeb && Platform.isAndroid) {
    Workmanager().initialize(callbackDispatcher);
    await BackgroundService.register();
  }
  runApp(const SocialBoxApp());
}

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, _) async {
    return switch (task) {
      AppConstants.scheduledPostingTask =>
        BackgroundService.executeScheduledPosting(),
      _ => Future.value(true),
    };
  });
}