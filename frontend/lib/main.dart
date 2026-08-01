import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'providers/app_state.dart';
import 'providers/auth_provider.dart';
import 'providers/market_provider.dart';
import 'providers/portfolio_provider.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  try {
    await Firebase.initializeApp();
    debugPrint('[Firebase] Initialized successfully');
  } catch (e) {
    debugPrint('[Firebase] Notice: $e');
  }
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..initAuth()),
        ChangeNotifierProvider(create: (_) => MarketProvider()),
        ChangeNotifierProvider(create: (_) => PortfolioProvider()),
        ChangeNotifierProxyProvider3<AuthProvider, MarketProvider, PortfolioProvider, AppState>(
          create: (context) => AppState(
            authProvider: context.read<AuthProvider>(),
            marketProvider: context.read<MarketProvider>(),
            portfolioProvider: context.read<PortfolioProvider>(),
          ),
          update: (context, auth, market, portfolio, previous) {
            return previous ?? AppState(
              authProvider: auth,
              marketProvider: market,
              portfolioProvider: portfolio,
            );
          },
        ),
      ],
      child: const BlackDiamondApp(),
    ),
  );
}
