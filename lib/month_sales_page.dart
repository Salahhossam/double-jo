import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';

import 'double_joo_home_page.dart';

class MonthOverviewPage extends StatefulWidget {
  const MonthOverviewPage({super.key});

  @override
  State<MonthOverviewPage> createState() => _MonthOverviewPageState();
}

class _MonthOverviewPageState extends State<MonthOverviewPage>
    with TickerProviderStateMixin {
  DateTime _focusedMonth = DateTime.now();
  Map<String, int> monthlyAmounts = {};

  @override
  void initState() {
    super.initState();
    _fetchMonthlySales();
  }

  Future<void> _fetchMonthlySales() async {
    String year = _focusedMonth.year.toString();
    String month = _focusedMonth.month.toString().padLeft(2, '0');

    try {
      List<Future<void>> futures = [];

      for (var flavor in flavors) {
        futures.add(_fetchFlavorData(flavor.name, year, month));
      }

      await Future.wait(futures);

      setState(() {});
    } catch (e) {
      log("Failed to fetch monthly sales: $e");
    }
  }

  Future<void> _fetchFlavorData(
      String flavor, String year, String month) async {
    int totalAmount = 0;

    List<Future<DocumentSnapshot>> dayFutures = List.generate(31, (day) {
      String dayStr = (day + 1).toString().padLeft(2, '0');
      return FirebaseFirestore.instance
          .collection('sales')
          .doc(year)
          .collection(month)
          .doc(dayStr)
          .collection('flavors')
          .doc('flavorsData')
          .get();
    });

    List<DocumentSnapshot> snapshots = await Future.wait(dayFutures);

    for (var snapshot in snapshots) {
      if (snapshot.exists) {
        var data = snapshot.data() as Map<String, dynamic>;
        if (data.containsKey(flavor)) {
          int amount = data[flavor]['amount'] ?? 0;
          totalAmount += amount;
        }
      }
    }

    monthlyAmounts[flavor] = totalAmount;
  }

  Future<void> _selectMonth() async {
    final DateTime? picked = await showMonthPicker(
      context: context,
      initialDate: _focusedMonth,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _focusedMonth) {
      setState(() {
        _focusedMonth = picked;
        _fetchMonthlySales();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: WillPopScope(
          onWillPop: () async {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                  builder: (context) => const DoubleJooHomePage()),
            );
            return true; // Return true to allow back navigation
          },
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Stack(
              children: [
                CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Container(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            TextButton(
                              onPressed: _selectMonth,
                              style: TextButton.styleFrom(
                                backgroundColor:
                                    const Color.fromRGBO(8, 15, 44, 1),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 16.0, horizontal: 32.0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                ),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.calendar_today,
                                      color: Colors.white),
                                  SizedBox(width: 8.0),
                                  Text(
                                    'Select Month',
                                    style: TextStyle(fontSize: 16.0),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16.0),
                            Text(
                              '${_focusedMonth.month}/${_focusedMonth.year}',
                              style: const TextStyle(
                                  color: Color.fromRGBO(8, 15, 44, 1),
                                  fontSize: 24.0,
                                  fontWeight: FontWeight.bold),
                            ),
                        const SizedBox(height: 16.0),

                          ],
                        ),
                      ),
                    ),
                    SliverGrid(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          var flavor = flavors[index];
                          int amount = monthlyAmounts[flavor.name] ?? 0;

                          return Card(
                            elevation: 5,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                color: Colors.blue[50],
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircleAvatar(
                                    radius: 45,
                                    backgroundImage:
                                        AssetImage(flavor.imagePath),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    flavor.name,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    '$amount Sold',
                                    style: const TextStyle(
                                        fontSize: 14, color: Colors.black54),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        childCount: flavors.length,
                      ),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16.0,
                        mainAxisSpacing: 16.0,
                        childAspectRatio: 1.0,
                        mainAxisExtent: 200,
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Container(
                        padding: const EdgeInsets.all(10.0),
                        child: StreamBuilder(
                          stream: FirebaseFirestore.instance
                              .collection('specials')
                              .where('date',
                                  isGreaterThanOrEqualTo: DateTime(
                                      _focusedMonth.year,
                                      _focusedMonth.month,
                                      1))
                              .where('date',
                                  isLessThanOrEqualTo: DateTime(
                                      _focusedMonth.year,
                                      _focusedMonth.month + 1,
                                      0))
                              .snapshots(),
                          builder:
                              (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                            if (!snapshot.hasData) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }

                            final docs = snapshot.data!.docs;

                            return ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: docs.length,
                              itemBuilder: (context, index) {
                                final data = docs[index];
                                return Card(
                                  elevation: 5,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.all(18.0),
                                    decoration: BoxDecoration(
                                      color: Colors.blue[50],
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        CircleAvatar(
                                          radius: 30,
                                          backgroundImage:
                                              AssetImage(data['flavor_image']),
                                        ),
                                        Text(
                                          '${data['additions']} + ${data['flavor']}',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        CircleAvatar(
                                          radius: 30,
                                          backgroundImage: AssetImage(
                                              data['additions_image']),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                Positioned(
                  top: 10,
                  left: 0,
                  child: IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Color.fromRGBO(8, 15, 44, 1),
                      size: 50,
                    ),
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                            builder: (context) => const DoubleJooHomePage()),
                      );
                    },
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
