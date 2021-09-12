import 'package:bill_creator/screens/report_screen.dart';
import 'package:flutter/material.dart';

import '/screens/orders_scree.dart';

class SideDrawer extends StatelessWidget {
  const SideDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mHeight = MediaQuery.of(context).size.height;
    return Drawer(
      child: Column(
        children: [
          Container(
            alignment: Alignment.centerLeft,
            height: mHeight * .3,
            width: double.infinity,
            decoration: const BoxDecoration(color: Colors.teal),
            child: const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Surya IND',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 25,
                    color: Colors.white),
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          ListTile(
            leading: const Icon(Icons.collections_bookmark),
            title: const Text('View Orders'),
            onTap: () {
              Navigator.of(context)
                  .pushNamed(OrdersScreen.routeName, arguments: 'order');
            },
          ),
          const SizedBox(height: 5),
          ListTile(
            leading: const Icon(Icons.done_all),
            title: const Text('Finished Orders'),
            onTap: () {
              Navigator.of(context)
                  .pushNamed(OrdersScreen.routeName, arguments: 'finished');
            },
          ),
          const SizedBox(height: 5),
          ListTile(
            leading: const Icon(Icons.bookmarks),
            title: const Text('Report'),
            onTap: () {
              Navigator.of(context).pushNamed(ReportScreen.routeName);
            },
          ),
        ],
      ),
    );
  }
}
