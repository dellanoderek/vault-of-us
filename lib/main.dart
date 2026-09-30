import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'core/router/app_router.dart';
import 'core/storage/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa pastas do vault (Application Support)
  final storageService = StorageService();
  await storageService.initializeFolders();

  // Determina rota inicial baseada no estado do onboarding
  const secureStorage = FlutterSecureStorage();
  final onboardingDone =
      await secureStorage.read(key: 'onboarding_complete');
  final initialRoute =
      onboardingDone == 'true' ? '/pin' : '/onboarding';

  runApp(
    ProviderScope(
      overrides: [
        initialRouteProvider.overrideWith((ref) => initialRoute),
      ],
      child: const VaultOfUsApp(),
    ),
  );
}

class VaultOfUsApp extends ConsumerWidget {
  const VaultOfUsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Vault of Us',
      theme: _buildLightTheme(),
      darkTheme: _buildDarkTheme(),
      themeMode: ThemeMode.system,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }

  ThemeData _buildLightTheme() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFFD4A574), // Tom quente dourado
        brightness: Brightness.light,
      ),
      useMaterial3: true,
      appBarTheme: const AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
      ),
    );
  }

  ThemeData _buildDarkTheme() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFFD4A574),
        brightness: Brightness.dark,
      ),
      useMaterial3: true,
      appBarTheme: const AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
      ),
    );
  }
}
