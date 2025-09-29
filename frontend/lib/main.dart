import 'package:flutter/material.dart';
import 'package:food_delivery_app/login_page_user/register_form.dart';
import 'package:provider/provider.dart';
import 'home_page_user/permission_page.dart';
import 'login_page_user/login_page.dart';
import 'login_page_user/login_form.dart';
import 'splash/splash_page.dart';

import 'home_page_user/cart_provider.dart';
import 'home_page_user/address_provider.dart';
import 'providers/chat_provider.dart';
import 'providers/location_provider.dart';
import 'home_page_user/demo_page.dart';
import 'realtime/realtime.dart';
import 'realtime/ui/realtime_test_page.dart';
import 'realtime/ui/main_demo_page.dart';

void main() {
  runApp(FoodDeliveryApp());
}

class FoodDeliveryApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => CartProvider()),
        ChangeNotifierProvider(create: (context) => AddressProvider()),
        ChangeNotifierProvider(create: (context) => ChatProvider()),
        ChangeNotifierProvider(create: (context) => LocationProvider()),
        ChangeNotifierProvider(create: (context) => RealtimeChatProvider()),
        ChangeNotifierProvider(create: (context) => RealtimeLocationProvider()),
      ],
      child: MaterialApp(
        title: 'Food Delivery',
        theme: ThemeData(primarySwatch: Colors.orange),
        initialRoute: '/splash',
        routes: {
          '/splash': (_) => SplashPage(),
          '/login': (_) => LoginPage(),
          '/permissions': (_) => PermissionPage(),
          '/auth': (_) => LoginFormPage(),
          '/register': (_) => RegisterFormPage(),
          '/demo': (_) => DemoPage(),
          '/realtime-demo': (_) => RealtimeDemoPage(),
          '/websocket-test': (_) => RealtimeTestPage(),
          '/main-demo': (_) => MainDemoPage(),
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
