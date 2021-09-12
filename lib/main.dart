import 'package:bill_creator/screens/report_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

import '/models/product_manage.dart';

import '/screens/order_details_screen.dart';
import '/screens/orders_scree.dart';
import '/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => ProductMange(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Order Management',
        theme: ThemeData(primarySwatch: Colors.teal, accentColor: Colors.amber),
        routes: {
          OrdersScreen.routeName: (ctx) => const OrdersScreen(),
          OrderDetailsScreen.routeName: (ctx) => OrderDetailsScreen(),
          ReportScreen.routeName: (ctx) => ReportScreen(),
        },
        home: const HomeScreen(),
      ),
    );
  }
}
