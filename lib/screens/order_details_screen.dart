import 'package:bill_creator/widgets/orders/details_section.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '/models/product_manage.dart';

class OrderDetailsScreen extends StatefulWidget {
  static const routeName = 'order-details-screen';

  @override
  _OrderDetailsScreenState createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  Stream<QuerySnapshot<Map<String, dynamic>>>? stream;
  Stream<QuerySnapshot<Map<String, dynamic>>>? stream2;
  double? mwidth;
  ProductMange? prod;
  double? total;
  ProductMange? manage;
  double? advance;
  String? id;

  bool isInit = true;

  double? balanceToPay;

  final paymntMethodeNode = FocusNode();
  final payingamountNode = FocusNode();

  TextEditingController recivedController = TextEditingController();
  TextEditingController methodeController = TextEditingController();
  TextEditingController payingAmountcontroller = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    stream = FirebaseFirestore.instance.collection('bills').snapshots();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (isInit) prod = Provider.of<ProductMange>(context, listen: false);
    mwidth = MediaQuery.of(context).size.width;
    id = ModalRoute.of(context)!.settings.arguments as String;
    stream2 = FirebaseFirestore.instance
        .collection('bills')
        .doc(id)
        .collection('products')
        .orderBy('fetchBy')
        .snapshots();

    super.didChangeDependencies();
    isInit = false;
  }

  void completedProject(String mainID) {
    final date = DateFormat('yyyy-MM-dd').format(DateTime.now());
    FirebaseFirestore.instance.collection('bills').doc(mainID).update({
      'isFinished': true,
      'finisheddate': date,
      'finishedfetch': Timestamp.now(),
    });
  }

  void show() {
    if (prod!.io) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Congratulations'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('All the works are finished. '),
              Text('This order will be moved in to finished orderes list.'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('ok'),
            )
          ],
        ),
      );
      prod!.io = false;
    }
  }

  Future<void> updateData(String id, double totalpaid) async {
    FocusScope.of(context).unfocus();
    final valid = _formKey.currentState!.validate();
    if (!valid || balanceToPay == null) {
      return;
    }

    await prod!.updateData(id, recivedController.text, methodeController.text,
        payingAmountcontroller.text, totalpaid, total!);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text(
            'Updated Succesfully',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.amber),
    );
    balanceToPay = null;
  }

  Widget buildRow(String leading, String trailing) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: mwidth! * .35,
          child: Text(
            leading,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(width: 10),
        const Text(
          ':',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: mwidth! * .5,
          child: Text(
            trailing,
            overflow: TextOverflow.fade,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // final mHeight = MediaQuery.of(context).size.height;

    return StreamBuilder<QuerySnapshot>(
        stream: stream,
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return Scaffold(
              appBar: AppBar(title: const Text('Order Details')),
              body: const Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          if (snap.data!.docs.isEmpty) {
            return Scaffold(
              appBar: AppBar(title: const Text('Order Details')),
              body: const Center(
                child: Text('Data Deleted Or Moved to Deliverd List'),
              ),
            );
          }
          if (!snap.hasData) {
            return Scaffold(
              appBar: AppBar(title: const Text('Order Details')),
              body: const Center(
                child: Text('Error'),
              ),
            );
          }
          final element =
              snap.data!.docs.firstWhere((element) => element.id == id);
          final tempDate = DateTime.parse((element['delivaryDate']).toString());
          final delDate = DateFormat.yMMMd().format(tempDate);

          balanceToPay =
              double.parse((element['total'] - element['advance']).toString());
          recivedController.text = (element['receivedby']).toString();
          recivedController.selection = TextSelection.fromPosition(
              TextPosition(offset: recivedController.text.length));
          methodeController.text = (element['paymentMethode'] + ' ').toString();
          methodeController.selection = TextSelection.fromPosition(
              TextPosition(offset: methodeController.text.length));
          payingAmountcontroller.text = '0.0';
          payingAmountcontroller.selection = TextSelection.fromPosition(
              TextPosition(offset: payingAmountcontroller.text.length));

          total = double.parse((element['total']).toString());

          return Scaffold(
            key: _scaffoldKey,
            appBar: AppBar(
              title: const Text('Order Details'),
              actions: [
                if (element['balnce'] != 0)
                  IconButton(
                      onPressed: element['balnce'] == 0
                          ? null
                          : () {
                              updateData(
                                  id!,
                                  double.parse(
                                      (element['advance']).toString()));
                            },
                      icon: const Icon(Icons.save))
              ],
            ),
            body: SingleChildScrollView(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildRow('Name', element['name'].toString()),
                    const SizedBox(height: 10),
                    buildRow('Mobile num', element['mobileNUmber'].toString()),
                    const SizedBox(height: 10),
                    buildRow('Address', element['address'].toString()),
                    const SizedBox(height: 10),
                    buildRow('Net Total', (element['total']).toString()),
                    const SizedBox(height: 10),
                    buildRow('Total Paid', (element['advance']).toString()),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          Row(
                            key: const ValueKey('1'),
                            children: [
                              SizedBox(
                                width: mwidth! * .35,
                                child: const Text(
                                  "Received by",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(width: 10),
                              const Text(
                                ':',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: TextFormField(
                                  validator: (val) {
                                    if (val!.isEmpty) {
                                      return 'Provide a name';
                                    }
                                    return null;
                                  },
                                  onEditingComplete: () {
                                    FocusScope.of(context)
                                        .requestFocus(payingamountNode);
                                  },
                                  controller: recivedController,
                                  key: const ValueKey('4'),
                                  readOnly: element['balnce'] == 0,
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                              )
                            ],
                          ),
                          if (element['balnce'] != 0)
                            Row(
                              key: const ValueKey('2'),
                              children: [
                                SizedBox(
                                  width: mwidth! * .35,
                                  child: const Text(
                                    "Paying amount",
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                const Text(
                                  ':',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: TextFormField(
                                    autovalidateMode:
                                        AutovalidateMode.onUserInteraction,
                                    focusNode: payingamountNode,
                                    onEditingComplete: () {
                                      // updateData(id, element['advance']);
                                      FocusScope.of(context)
                                          .requestFocus(paymntMethodeNode);
                                    },
                                    validator: (val) {
                                      if (double.tryParse(val!) == null) {
                                        return null;
                                      } else if (double.tryParse(val)! >
                                          double.parse(
                                            (element['balnce']).toString(),
                                          )) {
                                        return "can't be greater than balance";
                                      }
                                      return null;
                                    },
                                    key: const ValueKey('5'),
                                    readOnly: element['balnce'] == 0,
                                    controller: payingAmountcontroller,
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                )
                              ],
                            ),
                          Row(
                            key: const ValueKey('3'),
                            children: [
                              SizedBox(
                                width: mwidth! * .35,
                                child: const Text(
                                  "Payment method",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(width: 10),
                              const Text(
                                ':',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: TextFormField(
                                  focusNode: paymntMethodeNode,
                                  // initialValue: methodeController.text + ' ',
                                  onEditingComplete: () {
                                    updateData(
                                      id!,
                                      double.parse(
                                        (element['advance']).toString(),
                                      ),
                                    );
                                  },
                                  validator: (val) {
                                    if (val!.isEmpty) {
                                      return 'Provide a method';
                                    }
                                    return null;
                                  },
                                  controller: methodeController,
                                  key: const ValueKey('6'),
                                  readOnly: element['balnce'] == 0,
                                  // initialValue: '${element['paymentMethode']}',
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    buildRow('Balance to pay', balanceToPay.toString()),
                    const SizedBox(height: 10),
                    buildRow('Delivery Date', delDate.toString()),
                    const SizedBox(height: 20),
                    const Text(
                      'products ordered',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    // StreamBuilder<QuerySnapshot>(
                    //     stream: stream2,
                    //     builder: (ctx, subsnap) {
                    //       if (subsnap.connectionState ==
                    //           ConnectionState.waiting) {
                    //         return const Center(
                    //           child: Text(
                    //             'Loading......',
                    //             style: TextStyle(fontWeight: FontWeight.bold),
                    //           ),
                    //         );
                    //       }
                    //       final lenght = subsnap.data!.docs.length;
                    //       final finishList = subsnap.data!.docs
                    //           .where((element) => element['isFinished'] == true)
                    //           .toList();
                    //       final bool projStatus = element['isFinished'];
                    //       // var io = true;
                    //       if (finishList.length == subsnap.data!.docs.length &&
                    //           !projStatus) {
                    //         completedProject(id!);

                    //         Future.delayed(Duration.zero, () async {
                    //           show();
                    //         });
                    //       }

                    //       return Container(
                    //         padding: const EdgeInsets.all(10),
                    //         width: double.infinity,
                    //         height: lenght * (mHeight * .375),
                    //         child: ListView.builder(
                    //             physics: const NeverScrollableScrollPhysics(),
                    //             itemCount: lenght,
                    //             itemBuilder: (ctx, i) {
                    //               final productList = subsnap.data!.docs[i];
                    //               final exList = subsnap.data!.docs;
                    //               return ItemsDecrptionBox(
                    //                 i: i,
                    //                 mainId: id,
                    //                 exlist: exList,
                    //                 subId: productList.id,
                    //                 descrptionController: null,
                    //                 initialValue: productList['specifications']
                    //                     .toString(),
                    //                 isEditable: false,
                    //                 isFinished: productList['isFinished'],
                    //                 title: productList['itemName'].toString(),
                    //                 gst: productList['gst']
                    //                     .toString(), //for web gst:productList['gst']
                    //                 price: productList['price']
                    //                     .toString(), //for web pric:productList['price'],

                    //                 quantity:
                    //                     productList['quantity'].toString(),
                    //               );
                    //             }),
                    //       );
                    //     }),
                    DetailsSection(id!, element),
                  ],
                ),
              ),
            ),
          );
        });
  }
}
