import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app/app.dart';
import 'app/app_bloc_observer.dart';
import 'app/router/app_router.dart';
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
  runApp(const SocialBoxApp());
}