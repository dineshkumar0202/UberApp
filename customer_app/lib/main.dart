import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ridoo_customer/app.dart';
import 'package:ridoo_customer/core/storage/local_storage.dart';
import 'package:ridoo_customer/data/providers/auth_provider.dart';
import 'package:ridoo_customer/data/providers/ride_provider.dart';
import 'package:ridoo_customer/data/providers/wallet_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalStorage.init();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => RideProvider()),
        ChangeNotifierProvider(create: (_) => WalletProvider()),
      ],
      child: const RidooCustomerApp(),
    ),
  );
}
