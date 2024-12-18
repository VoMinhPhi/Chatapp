import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/chat_provider.dart';
import 'providers/auth_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/chat/chat_screen.dart';
import 'theme/phix_theme.dart';
import 'providers/sticker_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => StickerProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PhiX',
      theme: ThemeData(
        primaryColor: PhixTheme.primaryColor,
        scaffoldBackgroundColor: PhixTheme.backgroundColor,
        appBarTheme: const AppBarTheme(
          backgroundColor: PhixTheme.primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: PhixTheme.primaryColor,
          secondary: PhixTheme.secondaryColor,
        ),
      ),
      home: Consumer2<AuthProvider, ChatProvider>(
        builder: (context, authProvider, chatProvider, child) {
          final currentUser = authProvider.currentUser;
          
          if (currentUser != null) {
            chatProvider.initializeWithUser(currentUser);
            chatProvider.updateUserProfile(
              currentUser.id,
              name: currentUser.name,
              avatarUrl: currentUser.avatarUrl,
            );
          }
          
          if (!authProvider.isAuthenticated) {
            return const LoginScreen();
          }
          return const ChatScreen();
        },
      ),
    );
  }
}
