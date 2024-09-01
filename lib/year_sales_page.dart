import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'double_joo_home_page.dart';


class YearOverViewPage extends StatefulWidget {
  const YearOverViewPage({super.key});

  @override
  State<YearOverViewPage> createState() => _YearOverViewPageState();
}

class _YearOverViewPageState extends State<YearOverViewPage> {
  DateTime _selectedYear = DateTime.now();
  Map<String, int> yearlyAmounts = {};

  @override
  void initState() {
    super.initState();
    _fetchYearlySales();
  }

  Future<void> _fetchYearlySales() async {
    String year = _selectedYear.year.toString();

    for (var flavor in flavors) {
      _fetchFlavorData(flavor.name, year);
    }
  }

  Future<void> _fetchFlavorData(String flavor, String year) async {
    int totalAmount = 0;

    List<Future<void>> monthFutures = List.generate(12, (month) async {
      String monthStr = (month + 1).toString().padLeft(2, '0');

      for (int day = 1; day <= 31; day++) {
        String dayStr = day.toString().padLeft(2, '0');

        DocumentSnapshot snapshot = await FirebaseFirestore.instance
            .collection('sales')
            .doc(year)
            .collection(monthStr)
            .doc(dayStr)
            .collection('flavors')
            .doc('flavorsData')
            .get();

        if (snapshot.exists) {
          var data = snapshot.data() as Map<String, dynamic>;
          if (data.containsKey(flavor)) {
            int amount = data[flavor]['amount'] ?? 0;
            totalAmount += amount;
          }
        }
      }
    });

    await Future.wait(monthFutures);

    setState(() {
      yearlyAmounts[flavor] = totalAmount;
    });
  }

  Future<void> _selectYear() async {
    final DateTime? picked = await showDialog<DateTime>(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: SizedBox(
            height: 300,
            child: YearPicker(
              selectedDate: _selectedYear,
              onChanged: (DateTime selectedDate) {
                Navigator.of(context).pop(selectedDate);
              },
              firstDate: DateTime(2020),
              lastDate: DateTime(2030),
            ),
          ),
        );
      },
    );

    if (picked != null && picked != _selectedYear) {
      setState(() {
        _selectedYear = picked;
        _fetchYearlySales();
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
                          children: [
                            TextButton(
                              onPressed: _selectYear,
                              style: TextButton.styleFrom(
                                backgroundColor:
                                    const Color.fromARGB(255, 0, 0, 0),
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
                                    'Select Year',
                                    style: TextStyle(fontSize: 16.0),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16.0),
                            Text(
                              '${_selectedYear.year}',
                              style: const TextStyle(
                                  fontSize: 24.0, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 16.0),
                          ],
                        ),
                      ),
                    ),
                    SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16.0,
                        mainAxisSpacing: 16.0,
                        childAspectRatio: 1.0,
                        mainAxisExtent: 200,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          var flavor = flavors[index];
                          int amount = yearlyAmounts[flavor.name] ?? 0;
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
                    ),
                    SliverToBoxAdapter(
                      child: Container(
                        padding: const EdgeInsets.all(10.0),
                        child: StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('specials')
                              .where('date',
                                  isGreaterThanOrEqualTo: DateTime(
                                    _selectedYear.year,
                                  ))
                              .where('date',
                                  isLessThan: DateTime(
                                    _selectedYear.year + 1,
                                  ))
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
