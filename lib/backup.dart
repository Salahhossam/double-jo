// import 'dart:developer';
// import 'package:double_joo/year_over_view_page.dart';
// import 'package:double_joo/month_over_view_page.dart';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:table_calendar/table_calendar.dart';
// import 'package:flutter_styled_toast/flutter_styled_toast.dart';
// import 'month_sales_page.dart';
// import 'specials.dart';
// import 'year_sales_page.dart';

// class DoubleJooHomePage extends StatefulWidget {
//   const DoubleJooHomePage({super.key});

//   @override
//   State<DoubleJooHomePage> createState() => _DoubleJooHomePageState();
// }

// class _DoubleJooHomePageState extends State<DoubleJooHomePage>
//     with TickerProviderStateMixin {
//   DateTime _selectedDay = DateTime.now();
//   Map<String, int> dailyAmounts = {};
//   bool _isCalendarExpanded = false;
//   DateTime? lastBackPressTime;
//   Map<String, int> newAmounts = {}; // Track newAmount for each flavor
//   bool isLoading = false;

//   late final AnimationController _controller;
//   late final Animation<Offset> _slideAnimation;
//   late final Animation<double> _fadeAnimation;

//   @override
//   void initState() {
//     super.initState();
//     _fetchDailySales();
//     _controller = AnimationController(
//       duration: const Duration(milliseconds: 500),
//       vsync: this,
//     );

//     _slideAnimation = Tween<Offset>(
//       begin: const Offset(0.0, 1.0),
//       end: Offset.zero,
//     ).animate(CurvedAnimation(
//       parent: _controller,
//       curve: Curves.easeInOut,
//     ));

//     _fadeAnimation = CurvedAnimation(
//       parent: _controller,
//       curve: Curves.easeIn,
//     );
//   }

//   Future<void> _fetchDailySales() async {
//     String year = _selectedDay.year.toString();
//     String month = _selectedDay.month.toString().padLeft(2, '0');
//     String day = _selectedDay.day.toString().padLeft(2, '0');

//     try {
//       DocumentSnapshot snapshot = await FirebaseFirestore.instance
//           .collection('sales')
//           .doc(year)
//           .collection(month)
//           .doc(day)
//           .collection('flavors')
//           .doc('flavorsData')
//           .get();

//       setState(() {
//         dailyAmounts = {};
//         if (snapshot.exists) {
//           var data = snapshot.data() as Map<String, dynamic>;
//           data.forEach((key, value) {
//             if (value is Map<String, dynamic>) {
//               dailyAmounts[key] = value['amount'] ?? 0;
//               newAmounts[key] = 0; // Initialize newAmount for each flavor
//             }
//           });
//         }
//       });
//     } catch (e) {
//       log("Failed to fetch daily sales: $e");
//     }
//   }

//   Future<void> _updateDailySales(String flavor, int newAmount) async {
//     String year = _selectedDay.year.toString();
//     String month = _selectedDay.month.toString().padLeft(2, '0');
//     String day = _selectedDay.day.toString().padLeft(2, '0');

//     DocumentReference flavorRef = FirebaseFirestore.instance
//         .collection('sales')
//         .doc(year)
//         .collection(month)
//         .doc(day)
//         .collection('flavors')
//         .doc('flavorsData');

//     try {
//       await FirebaseFirestore.instance.runTransaction((transaction) async {
//         DocumentSnapshot snapshot = await transaction.get(flavorRef);

//         Map<String, dynamic> data = snapshot.exists
//             ? (snapshot.data() as Map<String, dynamic>).cast<String, dynamic>()
//             : {};

//         if (data.containsKey(flavor)) {
//           int currentAmount = (data[flavor]['amount'] ?? 0);
//           data[flavor] = {'amount': currentAmount + newAmount};
//         } else {
//           data[flavor] = {'amount': newAmount};
//         }

//         transaction.set(flavorRef, data);
//       });

//       _fetchDailySales();
//     } catch (e) {
//       log("Failed to update flavor amount: $e");
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Scaffold(
//         drawer: Drawer(
//           child: ListView(
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(15.0),
//                 decoration: const BoxDecoration(
//                   borderRadius: BorderRadius.only(
//                       bottomLeft: Radius.circular(15.0),
//                       bottomRight: Radius.circular(15.0)),
//                   color: Color.fromRGBO(8, 15, 44, 1),
//                 ),
//                 height: 230,
//                 child: const Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     CircleAvatar(
//                       radius: 80.0,
//                       backgroundImage:
//                           AssetImage('images/IMG_20220210_171001.jpg'),
//                       backgroundColor: Colors.grey,
//                     ),
//                     SizedBox(
//                       height: 8,
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 15.0),
//               ListTile(
//                 leading: const Icon(Icons.calendar_month_outlined,
//                     color: Color.fromRGBO(8, 15, 44, 1)),
//                 title: const Text(
//                   'Month Sales Page',
//                   style: TextStyle(
//                     color: Color.fromRGBO(8, 15, 44, 1),
//                   ),
//                 ),
//                 onTap: () {
//                   Navigator.of(context).pushReplacement(
//                     MaterialPageRoute(
//                       builder: (context) => const MonthSalesPage(),
//                     ),
//                   );
//                 },
//               ),
//               const SizedBox(height: 15.0),
//               ListTile(
//                 leading: const Icon(Icons.calendar_view_month,
//                     color: Color.fromRGBO(8, 15, 44, 1)),
//                 title: const Text(
//                   'Year Sales Page',
//                   style: TextStyle(
//                     color: Color.fromRGBO(8, 15, 44, 1),
//                   ),
//                 ),
//                 onTap: () {
//                   Navigator.of(context).pushReplacement(
//                     MaterialPageRoute(
//                       builder: (context) => const YearSalesPage(),
//                     ),
//                   );
//                 },
//               ),
//               const SizedBox(height: 15.0),
//               ListTile(
//                 leading: const Icon(Icons.star_half_rounded,
//                     color: Color.fromRGBO(8, 15, 44, 1)),
//                 title: const Text(
//                   'Specials',
//                   style: TextStyle(
//                     color: Color.fromRGBO(8, 15, 44, 1),
//                   ),
//                 ),
//                 onTap: () {
//                   Navigator.of(context).pushReplacement(
//                     MaterialPageRoute(
//                       builder: (context) => const Specials(),
//                     ),
//                   );
//                 },
//               ),
//               const SizedBox(height: 15.0),
//               ListTile(
//                 leading: const Icon(Icons.star_half_rounded,
//                     color: Color.fromRGBO(8, 15, 44, 1)),
//                 title: const Text(
//                   'YearOverViewPage',
//                   style: TextStyle(
//                     color: Color.fromRGBO(8, 15, 44, 1),
//                   ),
//                 ),
//                 onTap: () {
//                   Navigator.of(context).pushReplacement(
//                     MaterialPageRoute(
//                       builder: (context) => const YearOverViewPage(),
//                     ),
//                   );
//                 },
//               ),
//               const SizedBox(height: 15.0),
//               ListTile(
//                 leading: const Icon(Icons.star_half_rounded,
//                     color: Color.fromRGBO(8, 15, 44, 1)),
//                 title: const Text(
//                   'MonthOverviewPage',
//                   style: TextStyle(
//                     color: Color.fromRGBO(8, 15, 44, 1),
//                   ),
//                 ),
//                 onTap: () {
//                   Navigator.of(context).pushReplacement(
//                     MaterialPageRoute(
//                       builder: (context) => const MonthOverviewPage(),
//                     ),
//                   );
//                 },
//               ),
//             ],
//           ),
//         ),
//         appBar: AppBar(
//           centerTitle: true,
//           title: const Text(
//             'Double Joo',
//             style: TextStyle(
//               color: Color.fromRGBO(8, 15, 44, 1),
//               fontSize: 35,
//             ),
//           ),
//         ),
//         body: WillPopScope(
//           onWillPop: () async {
//             DateTime now = DateTime.now();
//             if (lastBackPressTime == null ||
//                 now.difference(lastBackPressTime!) >
//                     const Duration(seconds: 2)) {
//               lastBackPressTime = now;
//               showToast(
//                 'Press again to exit',
//                 context: context,
//                 animation: StyledToastAnimation.scale,
//                 reverseAnimation: StyledToastAnimation.fade,
//                 position: const StyledToastPosition(
//                   align: Alignment.bottomCenter,
//                   offset: 40,
//                 ),
//                 animDuration: const Duration(seconds: 1),
//                 duration: const Duration(seconds: 3),
//                 curve: Curves.elasticOut,
//                 reverseCurve: Curves.linear,
//               );
//               return false;
//             }
//             Navigator.of(context).pop();
//             return true;
//           },
//           child: Padding(
//             padding: const EdgeInsets.all(10.0),
//             child: Column(
//               children: [
//                 GestureDetector(
//                   onTap: () {
//                     setState(() {
//                       _isCalendarExpanded = !_isCalendarExpanded;
//                       _controller.isDismissed
//                           ? _controller.forward()
//                           : _controller.reverse();
//                     });
//                   },
//                   child: Container(
//                     padding: const EdgeInsets.all(16.0),
//                     decoration: BoxDecoration(
//                       color: const Color.fromRGBO(8, 15, 44, 1),
//                       borderRadius: BorderRadius.circular(15),
//                     ),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         const Text(
//                           'Calendar',
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         Icon(
//                           _isCalendarExpanded
//                               ? Icons.keyboard_arrow_up
//                               : Icons.keyboard_arrow_down,
//                           color: Colors.white,
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//                 SizeTransition(
//                   sizeFactor: _fadeAnimation,
//                   axisAlignment: 1.0,
//                   child: SlideTransition(
//                     position: _slideAnimation,
//                     child: Container(
//                       color: Colors.grey[200],
//                       child: TableCalendar(
//                         focusedDay: _selectedDay,
//                         firstDay: DateTime.utc(2020, 1, 1),
//                         lastDay: DateTime.utc(2100, 12, 31),
//                         selectedDayPredicate: (day) =>
//                             isSameDay(_selectedDay, day),
//                         calendarFormat: CalendarFormat.month,
//                         availableCalendarFormats: const {
//                           CalendarFormat.month: 'Month',
//                         },
//                         onDaySelected: (selectedDay, focusedDay) {
//                           setState(() {
//                             _selectedDay = selectedDay;
//                             _fetchDailySales();
//                           });
//                         },
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 10),
//                 Expanded(
//                   child: GridView.builder(
//                     shrinkWrap: true,
//                     // physics: const NeverScrollableScrollPhysics(), // Disable internal scroll
//                     gridDelegate:
//                         const SliverGridDelegateWithFixedCrossAxisCount(
//                       mainAxisExtent: 303,
//                       crossAxisCount: 2,
//                       crossAxisSpacing: 16.0,
//                       mainAxisSpacing: 16.0,
//                     ),
//                     itemCount: flavors.length,
//                     itemBuilder: (context, index) {
//                       var flavor = flavors[index];
//                       int amount = dailyAmounts[flavor.name] ?? 0;

//                       return FlavorCard(
//                         flavor: flavor,
//                         initialAmount: amount,
//                         onUpdate: (flavorName, newAmount) async {
//                           setState(() {
//                             isLoading = true;
//                           });
//                           await _updateDailySales(flavorName, newAmount);

//                           setState(() {
//                             isLoading = false;
//                             // No need to reset newAmounts here, it's handled locally in FlavorCard
//                           });
//                         },
//                       );
//                     },
//                   ),
//                 ),
//                 const SizedBox(height: 10),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// class Flavor {
//   final String name;
//   final String imagePath;

//   Flavor({required this.name, required this.imagePath});
// }

// class Additions {
//   final String name;
//   final String imagePath;

//   Additions({required this.name, required this.imagePath});
// }

// final List<Additions> additions = [
//   Additions(name: 'هوهوز', imagePath: 'images/هوهوز.jpeg'),
//   Additions(name: 'توينكيز', imagePath: 'images/توينكز.jpeg'),
// ];
// final List<Flavor> flavors = [
//   Flavor(name: 'حليب ساده', imagePath: 'images/حليب.jpeg'),
//   Flavor(name: 'حليب زبيب', imagePath: 'images/زبيب.jpeg'),
//   Flavor(name: 'حليب فواكه', imagePath: 'images/فراولة.jpeg'),
//   Flavor(name: 'حليب بوريو', imagePath: 'images/بوريو.jpeg'),
//   Flavor(name: 'حليب بسبوسه', imagePath: 'images/IMG_20220210_171001.jpg'),
//   Flavor(name: 'شيكولاته', imagePath: 'images/شيكولاته.jpeg'),
//   Flavor(name: 'كراميل', imagePath: 'images/كراميل.jpeg'),
//   Flavor(name: 'بندق', imagePath: 'images/بندق.jpeg'),
//   Flavor(name: 'موز', imagePath: 'images/موز.jpeg'),
//   Flavor(name: 'جوافه', imagePath: 'images/جوافة.jpeg'),
//   Flavor(name: 'مانجو', imagePath: 'images/مانجو.jpeg'),
//   Flavor(name: 'فراوله', imagePath: 'images/فراولة.jpeg'),
//   Flavor(name: 'زبادى فراوله', imagePath: 'images/زبادي فراولة.jpeg'),
//   Flavor(name: 'ليمون', imagePath: 'images/لمون.jpeg'),
//   Flavor(name: 'توت بنقسجى', imagePath: 'images/توت بنفسجي.jpeg'),
//   Flavor(name: 'توت برى', imagePath: 'images/توت بري.jpeg'),
//   Flavor(name: 'خوخ', imagePath: 'images/خوخ.jpeg'),
//   Flavor(name: 'نسكافيه', imagePath: 'images/نسكافية.jpeg'),
//   Flavor(name: 'اناناس', imagePath: 'images/اناناس.jpeg'),
//   Flavor(name: 'يوسفي', imagePath: 'images/يوسفي.jpeg'),
//   Flavor(name: 'سنيكرز', imagePath: 'images/سنيكرز.jpeg'),
//   Flavor(name: 'زبادي توت', imagePath: 'images/زبادي توت.jpeg'),
//   Flavor(name: 'نوتيلا ', imagePath: 'images/نيوتيلا.jpeg'),
//   Flavor(name: 'تفاح ', imagePath: 'images/تفاح.jpeg'),
//   Flavor(name: 'ايس كيك فراوله', imagePath: 'images/ايس كيك فراولة.jpeg'),
//   Flavor(name: 'ايس كيك شيكولاته', imagePath: 'images/ايس كيك شيككولاته.jpeg'),
//   Flavor(name: 'شانكي مانكي', imagePath: 'images/IMG_20220210_171001.jpg'),
//   Flavor(name: 'لوتس', imagePath: 'images/لوتس.jpeg'),
//   Flavor(name: 'فحم', imagePath: 'images/فحم.jpg'),
//   Flavor(name: 'كرانشي', imagePath: 'images/IMG_20220210_171001.jpg'),
// ];

// class FlavorCard extends StatefulWidget {
//   final Flavor flavor;
//   final int initialAmount;
//   final Future<void> Function(String flavorName, int newAmount) onUpdate;

//   const FlavorCard({
//     super.key,
//     required this.flavor,
//     required this.initialAmount,
//     required this.onUpdate,
//   });

//   @override
//   State<FlavorCard> createState() => _FlavorCardState();
// }

// class _FlavorCardState extends State<FlavorCard> {
//   late int newAmount;
//   bool _isLoading = false;
//   @override
//   void initState() {
//     super.initState();
//     newAmount = 0; // Initialize newAmount locally
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       elevation: 5,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(10),
//       ),
//       child: Container(
//         padding: const EdgeInsets.all(8.0),
//         decoration: BoxDecoration(
//           color: Colors.blue[50],
//           borderRadius: BorderRadius.circular(10),
//         ),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             CircleAvatar(
//               radius: 50,
//               backgroundImage: AssetImage(widget.flavor.imagePath),
//             ),
//             const SizedBox(height: 5),
//             Text(
//               widget.flavor.name,
//               style: const TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 5),
//             Text(
//               '${widget.initialAmount} Sold',
//               style: const TextStyle(fontSize: 14, color: Colors.black54),
//             ),
//             const SizedBox(height: 5),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 IconButton(
//                   icon: const Icon(Icons.remove_circle_outline),
//                   color: Colors.red,
//                   onPressed: () {
//                     setState(() {
//                       if (newAmount > 0) {
//                         newAmount--;
//                       }
//                     });
//                   },
//                 ),
//                 Text(
//                   '$newAmount',
//                   style: const TextStyle(fontSize: 14, color: Colors.black54),
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.add_circle_outline),
//                   color: Colors.green,
//                   onPressed: () {
//                     setState(() {
//                       newAmount++;
//                     });
//                   },
//                 ),
//               ],
//             ),
//             const SizedBox(height: 5),
//             ElevatedButton(
//               onPressed: _isLoading
//                   ? null // Disable button when loading
//                   : () async {
//                       if (newAmount > 0) {
//                         setState(() {
//                           _isLoading = true; // Start loading
//                         });

//                         await widget.onUpdate(widget.flavor.name, newAmount);

//                         setState(() {
//                           _isLoading = false; // End loading
//                           newAmount = 0; // Reset newAmount locally
//                         });

//                         showToast(
//                           'تم اضافة كمية ${widget.flavor.name}',
//                           context: context,
//                           animation: StyledToastAnimation.scale,
//                           reverseAnimation: StyledToastAnimation.fade,
//                           position: const StyledToastPosition(
//                             align: Alignment.bottomCenter,
//                             offset: 40,
//                           ),
//                           animDuration: const Duration(seconds: 1),
//                           duration: const Duration(seconds: 3),
//                           curve: Curves.elasticOut,
//                           reverseCurve: Curves.linear,
//                         );
//                       }
//                     },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color.fromRGBO(8, 15, 44, 1),
//                 foregroundColor: Colors.white,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//               ),
//               child: _isLoading
//                   ? const CircularProgressIndicator(color: Colors.white)
//                   : const Text('Confirm'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }


// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'dart:developer';
// import 'package:flutter/material.dart';
// import 'package:month_picker_dialog/month_picker_dialog.dart';

// import 'double_joo_home_page.dart';

// class MonthSalesPage extends StatefulWidget {
//   const MonthSalesPage({super.key});

//   @override
//   State<MonthSalesPage> createState() => _MonthSalesPageState();
// }

// class _MonthSalesPageState extends State<MonthSalesPage>
//     with TickerProviderStateMixin {
//   DateTime _focusedMonth = DateTime.now();
//   Map<String, int> monthlyAmounts = {};
  
//   @override
//   void initState() {
//     super.initState();
//     _fetchMonthlySales();
    
//   }

//   Future<void> _fetchMonthlySales() async {
//     String year = _focusedMonth.year.toString();
//     String month = _focusedMonth.month.toString().padLeft(2, '0');

//     try {
//       List<Future<void>> futures = [];

//       for (var flavor in flavors) {
//         futures.add(_fetchFlavorData(flavor.name, year, month));
//       }

//       await Future.wait(futures);

//       setState(() {});
//     } catch (e) {
//       log("Failed to fetch monthly sales: $e");
//     }
//   }

//   Future<void> _fetchFlavorData(
//       String flavor, String year, String month) async {
//     int totalAmount = 0;

//     List<Future<DocumentSnapshot>> dayFutures = List.generate(31, (day) {
//       String dayStr = (day + 1).toString().padLeft(2, '0');
//       return FirebaseFirestore.instance
//           .collection('sales')
//           .doc(year)
//           .collection(month)
//           .doc(dayStr)
//           .collection('flavors')
//           .doc('flavorsData')
//           .get();
//     });

//     List<DocumentSnapshot> snapshots = await Future.wait(dayFutures);

//     for (var snapshot in snapshots) {
//       if (snapshot.exists) {
//         var data = snapshot.data() as Map<String, dynamic>;
//         if (data.containsKey(flavor)) {
//           int amount = data[flavor]['amount'] ?? 0;
//           totalAmount += amount;
//         }
//       }
//     }

//     monthlyAmounts[flavor] = totalAmount;
//   }

//   Future<void> _selectMonth() async {
//     final DateTime? picked = await showMonthPicker(
//       context: context,
//       initialDate: _focusedMonth,
//       firstDate: DateTime(2020),
//       lastDate: DateTime(2100),
//     );
//     if (picked != null && picked != _focusedMonth) {
//       setState(() {
//         _focusedMonth = picked;
//         _fetchMonthlySales();
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Scaffold(
//         body: WillPopScope(
//           onWillPop: () async {
//             Navigator.of(context).pushReplacement(
//               MaterialPageRoute(
//                   builder: (context) => const DoubleJooHomePage()),
//             );
//             return true; // Return true to allow back navigation
//           },
//           child: Padding(
//             padding: const EdgeInsets.all(10.0),
//             child: Stack(
//               children: [
//                 Column(
//                   children: [
//                     Container(
//                       padding: const EdgeInsets.all(16.0),
//                       child: Column(
//                         children: [
//                           TextButton(
//                             onPressed: _selectMonth,
//                             style: TextButton.styleFrom(
//                               backgroundColor:
//                                   const Color.fromRGBO(8, 15, 44, 1),
//                               foregroundColor: Colors.white,
//                               padding: const EdgeInsets.symmetric(
//                                   vertical: 16.0, horizontal: 32.0),
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(15.0),
//                               ),
//                             ),
//                             child: const Row(
//                               mainAxisSize: MainAxisSize.min,
//                               children: [
//                                 Icon(Icons.calendar_today, color: Colors.white),
//                                 SizedBox(width: 8.0),
//                                 Text(
//                                   'Select Month',
//                                   style: TextStyle(fontSize: 16.0),
//                                 ),
//                               ],
//                             ),
//                           ),
//                           const SizedBox(height: 16.0),
//                           Text(
//                             '${_focusedMonth.month}/${_focusedMonth.year}',
//                             style: const TextStyle(
//                                 color: Color.fromRGBO(8, 15, 44, 1),
//                                 fontSize: 24.0,
//                                 fontWeight: FontWeight.bold),
//                           ),
//                         ],
//                       ),
//                     ),
//                     Expanded(
//                       child: GridView.builder(
//                         gridDelegate:
//                             const SliverGridDelegateWithFixedCrossAxisCount(
//                               mainAxisExtent: 200,
//                           crossAxisCount: 2,
//                           crossAxisSpacing: 16.0,
//                           mainAxisSpacing: 16.0,
//                         ),
//                         itemCount: flavors.length,
//                         itemBuilder: (context, index) {
//                           var flavor = flavors[index];
//                           int amount = monthlyAmounts[flavor.name] ?? 0;

//                           return Card(
//                             elevation: 5,
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(10),
//                             ),
//                             child: Container(
//                               padding: const EdgeInsets.all(8.0),
//                               decoration: BoxDecoration(
//                                 color: Colors.blue[50],
//                                 borderRadius: BorderRadius.circular(10),
//                               ),
//                               child: Column(
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 children: [
//                                    CircleAvatar(
//                                     radius: 45,
//                                     backgroundImage: AssetImage(
//                                         flavor.imagePath),
//                                   ),
//                                   const SizedBox(height: 10),
//                                   Text(
//                                     flavor.name,
//                                     style: const TextStyle(
//                                       fontSize: 16,
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                   ),
//                                   const SizedBox(height: 10),
//                                   Text(
//                                     '$amount Sold',
//                                     style: const TextStyle(
//                                         fontSize: 14, color: Colors.black54),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           );
//                         },
//                       ),
//                     ),
//                   ],
//                 ),
//                 Positioned(
//                   top: 10,
//                   left: 0,
//                   child: IconButton(
//                     icon: const Icon(
//                       Icons.arrow_back,
//                       color: Color.fromRGBO(8, 15, 44, 1),
//                       size: 50,
//                     ),
//                     onPressed: () {
//                       Navigator.of(context).pushReplacement(
//                         MaterialPageRoute(
//                             builder: (context) => const DoubleJooHomePage()),
//                       );
//                     },
//                   ),
//                 )
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// import 'double_joo_home_page.dart';

// class YearSalesPage extends StatefulWidget {
//   const YearSalesPage({super.key});

//   @override
//   State<YearSalesPage> createState() => _YearSalesPageState();
// }

// class _YearSalesPageState extends State<YearSalesPage> {
//   DateTime _selectedYear = DateTime.now();
//   Map<String, int> yearlyAmounts = {};

//   @override
//   void initState() {
//     super.initState();
//     _fetchYearlySales();
//   }

//   Future<void> _fetchYearlySales() async {
//     String year = _selectedYear.year.toString();

//     for (var flavor in flavors) {
//       _fetchFlavorData(flavor.name, year);
//     }
//   }

//   Future<void> _fetchFlavorData(String flavor, String year) async {
//     int totalAmount = 0;

//     List<Future<void>> monthFutures = List.generate(12, (month) async {
//       String monthStr = (month + 1).toString().padLeft(2, '0');

//       for (int day = 1; day <= 31; day++) {
//         String dayStr = day.toString().padLeft(2, '0');

//         DocumentSnapshot snapshot = await FirebaseFirestore.instance
//             .collection('sales')
//             .doc(year)
//             .collection(monthStr)
//             .doc(dayStr)
//             .collection('flavors')
//             .doc('flavorsData')
//             .get();

//         if (snapshot.exists) {
//           var data = snapshot.data() as Map<String, dynamic>;
//           if (data.containsKey(flavor)) {
//             int amount = data[flavor]['amount'] ?? 0;
//             totalAmount += amount;
//           }
//         }
//       }
//     });

//     await Future.wait(monthFutures);

//     setState(() {
//       yearlyAmounts[flavor] = totalAmount;
//     });
//   }

//   Future<void> _selectYear() async {
//     final DateTime? picked = await showDialog<DateTime>(
//       context: context,
//       builder: (BuildContext context) {
//         return Dialog(
//           child: SizedBox(
//             height: 300,
//             child: YearPicker(
//               selectedDate: _selectedYear,
//               onChanged: (DateTime selectedDate) {
//                 Navigator.of(context).pop(selectedDate);
//               },
//               firstDate: DateTime(2020),
//               lastDate: DateTime(2030),
//             ),
//           ),
//         );
//       },
//     );

//     if (picked != null && picked != _selectedYear) {
//       setState(() {
//         _selectedYear = picked;
//         _fetchYearlySales();
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Scaffold(
//         body: WillPopScope(
//           onWillPop: () async {
//             Navigator.of(context).pushReplacement(
//               MaterialPageRoute(
//                   builder: (context) => const DoubleJooHomePage()),
//             );
//             return true; // Return true to allow back navigation
//           },
//           child: Padding(
//             padding: const EdgeInsets.all(10.0),
//             child: Stack(
//               children: [
//                 Column(
//                   children: [
//                     Container(
//                       padding: const EdgeInsets.all(16.0),
//                       child: Column(
//                         children: [
//                           TextButton(
//                             onPressed: _selectYear,
//                             style: TextButton.styleFrom(
//                               backgroundColor:
//                                   const Color.fromARGB(255, 0, 0, 0),
//                               foregroundColor: Colors.white,
//                               padding: const EdgeInsets.symmetric(
//                                   vertical: 16.0, horizontal: 32.0),
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(15.0),
//                               ),
//                             ),
//                             child: const Row(
//                               mainAxisSize: MainAxisSize.min,
//                               children: [
//                                 Icon(Icons.calendar_today, color: Colors.white),
//                                 SizedBox(width: 8.0),
//                                 Text(
//                                   'Select Year',
//                                   style: TextStyle(fontSize: 16.0),
//                                 ),
//                               ],
//                             ),
//                           ),
//                           const SizedBox(height: 16.0),
//                           Text(
//                             '${_selectedYear.year}',
//                             style: const TextStyle(
//                                 fontSize: 24.0, fontWeight: FontWeight.bold),
//                           ),
//                         ],
//                       ),
//                     ),
//                     Expanded(
//                       child: GridView.builder(
//                         gridDelegate:
//                             const SliverGridDelegateWithFixedCrossAxisCount(
//                               mainAxisExtent: 200,
//                           crossAxisCount: 2,
//                           crossAxisSpacing: 16.0,
//                           mainAxisSpacing: 16.0,
//                         ),
//                         itemCount: flavors.length,
//                         itemBuilder: (context, index) {
//                           var flavor = flavors[index];
//                           int amount = yearlyAmounts[flavor.name] ?? 0;

//                           return Card(
//                             elevation: 5,
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(10),
//                             ),
//                             child: InkWell(
//                               onTap: () {
//                                 // Add any specific action on tap here
//                               },
//                               child: Container(
//                                 padding: const EdgeInsets.all(8.0),
//                                 decoration: BoxDecoration(
//                                   color: Colors.blue[50],
//                                   borderRadius: BorderRadius.circular(10),
//                                 ),
//                                 child: Column(
//                                   mainAxisAlignment: MainAxisAlignment.center,
//                                   children: [
//                                      CircleAvatar(
//                                       radius: 45,
//                                       backgroundImage: AssetImage(
//                                          flavor.imagePath),
//                                     ),
//                                     const SizedBox(height: 10),
//                                     Text(
//                                       flavor.name,
//                                       style: const TextStyle(
//                                         fontSize: 16,
//                                         fontWeight: FontWeight.bold,
//                                       ),
//                                     ),
//                                     const SizedBox(height: 10),
//                                     Text(
//                                       '$amount Sold',
//                                       style: const TextStyle(
//                                           fontSize: 14, color: Colors.black54),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           );
//                         },
//                       ),
//                     ),
//                   ],
//                 ),
//                 Positioned(
//                   top: 10,
//                   left: 0,
//                   child: IconButton(
//                     icon: const Icon(
//                       Icons.arrow_back,
//                       color: Color.fromRGBO(8, 15, 44, 1),
//                       size: 50,
//                     ),
//                     onPressed: () {
//                       Navigator.of(context).pushReplacement(
//                         MaterialPageRoute(
//                             builder: (context) => const DoubleJooHomePage()),
//                       );
//                     },
//                   ),
//                 )
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }


// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter_styled_toast/flutter_styled_toast.dart';
// import 'back_up.dart';
// import 'package:table_calendar/table_calendar.dart';

// class Specials extends StatefulWidget {
//   const Specials({super.key});

//   @override
//   State<Specials> createState() => _SpecialsState();
// }

// class _SpecialsState extends State<Specials> with TickerProviderStateMixin {
//   Flavor? selectedFlavor = flavors.first;
//   Additions? selectedAdditions = additions.first;
//   bool _isCalendarExpanded = false;
//   DateTime _selectedDay = DateTime.now();
//   bool _isLoading = false;

//   late final AnimationController _controller;
//   late final Animation<Offset> _slideAnimation;
//   late final Animation<double> _fadeAnimation;

//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       duration: const Duration(milliseconds: 500),
//       vsync: this,
//     );

//     _slideAnimation = Tween<Offset>(
//       begin: const Offset(0.0, 1.0),
//       end: Offset.zero,
//     ).animate(CurvedAnimation(
//       parent: _controller,
//       curve: Curves.easeInOut,
//     ));

//     _fadeAnimation = CurvedAnimation(
//       parent: _controller,
//       curve: Curves.easeIn,
//     );
//     _selectedDay = DateTime.now();
//   }

//   Future<void> _saveToFirebase() async {
//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       await FirebaseFirestore.instance.collection('specials').add({
//         'flavor': selectedFlavor?.name,
//         'flavor_image': selectedFlavor?.imagePath,
//         'additions': selectedAdditions?.name,
//         'additions_image': selectedAdditions?.imagePath,
//         'date': DateTime(_selectedDay.year, _selectedDay.month,
//             _selectedDay.day), // Stripping time
//       });

//       showToast(
//         'تم اضافة المطلوب ',
//         context: context,
//         animation: StyledToastAnimation.scale,
//         reverseAnimation: StyledToastAnimation.fade,
//         position: const StyledToastPosition(
//           align: Alignment.bottomCenter,
//           offset: 40,
//         ),
//         animDuration: const Duration(seconds: 1),
//         duration: const Duration(seconds: 3),
//         curve: Curves.elasticOut,
//         reverseCurve: Curves.linear,
//       );
//     } catch (e) {
//       showToast(
//         'Error: $e',
//         context: context,
//         animation: StyledToastAnimation.scale,
//         reverseAnimation: StyledToastAnimation.fade,
//         position: const StyledToastPosition(
//           align: Alignment.bottomCenter,
//           offset: 40,
//         ),
//         animDuration: const Duration(seconds: 1),
//         duration: const Duration(seconds: 3),
//         curve: Curves.elasticOut,
//         reverseCurve: Curves.linear,
//       );
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Scaffold(
//         appBar: AppBar(
//           title: const Text('Specials'),
//           centerTitle: true,
//           leading: IconButton(
//             icon: const Icon(
//               Icons.arrow_back,
//               color: Color.fromRGBO(8, 15, 44, 1),
//               size: 50,
//             ),
//             onPressed: () {
//               Navigator.of(context).pushReplacement(
//                 MaterialPageRoute(
//                     builder: (context) => const DoubleJooHomePage()),
//               );
//             },
//           ),
//         ),
//         body: WillPopScope(
//           onWillPop: () async {
//             Navigator.of(context).pushReplacement(
//               MaterialPageRoute(
//                   builder: (context) => const DoubleJooHomePage()),
//             );
//             return true;
//           },
//           child: Padding(
//             padding: const EdgeInsets.all(20.0),
//             child: Column(
//               children: [
//                 GestureDetector(
//                   onTap: () {
//                     setState(() {
//                       _isCalendarExpanded = !_isCalendarExpanded;
//                       _controller.isDismissed
//                           ? _controller.forward()
//                           : _controller.reverse();
//                     });
//                   },
//                   child: Container(
//                     padding: const EdgeInsets.all(16.0),
//                     decoration: BoxDecoration(
//                       color: const Color.fromRGBO(8, 15, 44, 1),
//                       borderRadius: BorderRadius.circular(15),
//                     ),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         const Text(
//                           'Calendar',
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         Icon(
//                           _isCalendarExpanded
//                               ? Icons.keyboard_arrow_up
//                               : Icons.keyboard_arrow_down,
//                           color: Colors.white,
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//                 SizeTransition(
//                   sizeFactor: _fadeAnimation,
//                   axisAlignment: 1.0,
//                   child: SlideTransition(
//                     position: _slideAnimation,
//                     child: Container(
//                       color: Colors.grey[200],
//                       child: TableCalendar(
//                         focusedDay: _selectedDay,
//                         firstDay: DateTime.utc(2020, 1, 1),
//                         lastDay: DateTime.utc(2100, 12, 31),
//                         selectedDayPredicate: (day) =>
//                             isSameDay(_selectedDay, day),
//                         calendarFormat: CalendarFormat.month,
//                         availableCalendarFormats: const {
//                           CalendarFormat.month: 'Month',
//                         },
//                         onDaySelected: (selectedDay, focusedDay) {
//                           setState(() {
//                             _selectedDay = selectedDay;
//                           });
//                         },
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 30),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Expanded(
//                       child: DropdownButtonFormField<Additions>(
//                         value: selectedAdditions,
//                         decoration: const InputDecoration(
//                           labelText: 'Additions',
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.all(
//                               Radius.circular(15),
//                             ),
//                           ),
//                           contentPadding: EdgeInsets.symmetric(
//                               vertical: 10.0, horizontal: 15.0),
//                         ),
//                         items: additions.map((additions) {
//                           return DropdownMenuItem(
//                             value: additions,
//                             child: Text(additions.name),
//                           );
//                         }).toList(),
//                         onChanged: (Additions? val) {
//                           setState(() {
//                             selectedAdditions = val;
//                           });
//                         },
//                         validator: (Additions? val) {
//                           if (val == null) {
//                             return 'Please select a Additions';
//                           }
//                           return null;
//                         },
//                       ),
//                     ),
//                     const SizedBox(width: 20),
//                     Expanded(
//                       child: DropdownButtonFormField<Flavor>(
//                         value: selectedFlavor,
//                         decoration: const InputDecoration(
//                           labelText: 'Flavor',
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.all(
//                               Radius.circular(15),
//                             ),
//                           ),
//                           contentPadding: EdgeInsets.symmetric(
//                               vertical: 10.0, horizontal: 15.0),
//                         ),
//                         items: flavors.map((flavor) {
//                           return DropdownMenuItem(
//                             value: flavor,
//                             child: Text(flavor.name),
//                           );
//                         }).toList(),
//                         onChanged: (Flavor? val) {
//                           setState(() {
//                             selectedFlavor = val;
//                           });
//                         },
//                         validator: (Flavor? val) {
//                           if (val == null) {
//                             return 'Please select a flavor';
//                           }
//                           return null;
//                         },
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 10),
//                 ElevatedButton(
//                   onPressed: _isLoading
//                       ? null
//                       : () async {
//                           await _saveToFirebase();
//                         },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: const Color.fromRGBO(8, 15, 44, 1),
//                     foregroundColor: Colors.white,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                   ),
//                   child: _isLoading
//                       ? const CircularProgressIndicator(color: Colors.white)
//                       : const Text('Confirm'),
//                 ),
//                 const SizedBox(height: 20),
//                 Expanded(
//                   child: StreamBuilder(
//                     stream: FirebaseFirestore.instance
//                         .collection('specials')
//                         .where('date',
//                             isEqualTo: DateTime(_selectedDay.year,
//                                 _selectedDay.month, _selectedDay.day))
//                         .snapshots(),
//                     builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
//                       if (!snapshot.hasData) {
//                         return const Center(
//                           child: CircularProgressIndicator(),
//                         );
//                       }

//                       final docs = snapshot.data!.docs;

//                       return ListView.builder(
//                         itemCount: docs.length,
//                         itemBuilder: (context, index) {
//                           final data = docs[index];
//                           return Card(
//                             elevation: 5,
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(15),
//                             ),
//                             child: Container(
//                               padding: const EdgeInsets.all(18.0),
//                               decoration: BoxDecoration(
//                                 color: Colors.blue[50],
//                                 borderRadius: BorderRadius.circular(10),
//                               ),
//                               child: Row(
//                                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   CircleAvatar(
//                                     radius: 30,
//                                     backgroundImage:
//                                         AssetImage(data['flavor_image']),
//                                   ),
//                                   Text(
//                                     '${data['additions']} + ${data['flavor']}',
//                                     style: const TextStyle(
//                                       fontSize: 16,
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                   ),
//                                   CircleAvatar(
//                                     radius: 30,
//                                     backgroundImage:
//                                         AssetImage(data['additions_image']),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           );
//                         },
//                       );
//                     },
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }


// import 'dart:developer';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:month_picker_dialog/month_picker_dialog.dart';
// import 'back_up.dart';
// import 'double_joo_home_page.dart';

// class test extends StatefulWidget {
//   const test({super.key});

//   @override
//   State<test> createState() => _testState();
// }

// class _testState extends State<test>
//     with TickerProviderStateMixin {
//   DateTime _focusedMonth = DateTime.now();
//   Map<String, int> monthlyAmounts = {};

//   @override
//   void initState() {
//     super.initState();
//     _fetchMonthlySales();
//   }

//   Future<void> _fetchMonthlySales() async {
//     String year = _focusedMonth.year.toString();
//     String month = _focusedMonth.month.toString().padLeft(2, '0');

//     try {
//       List<Future<void>> futures = [];

//       for (var flavor in flavors) {
//         futures.add(_fetchFlavorData(flavor.name, year, month));
//       }

//       await Future.wait(futures);

//       setState(() {});
//     } catch (e) {
//       log("Failed to fetch monthly sales: $e");
//     }
//   }

//   Future<void> _fetchFlavorData(
//       String flavor, String year, String month) async {
//     int totalAmount = 0;

//     List<Future<DocumentSnapshot>> dayFutures = List.generate(31, (day) {
//       String dayStr = (day + 1).toString().padLeft(2, '0');
//       return FirebaseFirestore.instance
//           .collection('sales')
//           .doc(year)
//           .collection(month)
//           .doc(dayStr)
//           .collection('flavors')
//           .doc('flavorsData')
//           .get();
//     });

//     List<DocumentSnapshot> snapshots = await Future.wait(dayFutures);

//     for (var snapshot in snapshots) {
//       if (snapshot.exists) {
//         var data = snapshot.data() as Map<String, dynamic>;
//         if (data.containsKey(flavor)) {
//           int amount = data[flavor]['amount'] ?? 0;
//           totalAmount += amount;
//         }
//       }
//     }

//     monthlyAmounts[flavor] = totalAmount;
//   }

//   Future<void> _selectMonth() async {
//     final DateTime? picked = await showMonthPicker(
//       context: context,
//       initialDate: _focusedMonth,
//       firstDate: DateTime(2020),
//       lastDate: DateTime(2100),
//     );
//     if (picked != null && picked != _focusedMonth) {
//       setState(() {
//         _focusedMonth = picked;
//         _fetchMonthlySales();
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Scaffold(
//         body: WillPopScope(
//           onWillPop: () async {
//             Navigator.of(context).pushReplacement(
//               MaterialPageRoute(
//                   builder: (context) => const DoubleJooHomePage()),
//             );
//             return true; // Return true to allow back navigation
//           },
//           child: Padding(
//             padding: const EdgeInsets.all(10.0),
//             child: Stack(
//               children: [
//                 CustomScrollView(
//                   slivers: [
//                     SliverToBoxAdapter(
//                       child: Container(
//                         padding: const EdgeInsets.all(16.0),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.center,
//                           children: [
//                             TextButton(
//                               onPressed: _selectMonth,
//                               style: TextButton.styleFrom(
//                                 backgroundColor:
//                                     const Color.fromRGBO(8, 15, 44, 1),
//                                 foregroundColor: Colors.white,
//                                 padding: const EdgeInsets.symmetric(
//                                     vertical: 16.0, horizontal: 32.0),
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(15.0),
//                                 ),
//                               ),
//                               child: const Row(
//                                 mainAxisSize: MainAxisSize.min,
//                                 children: [
//                                   Icon(Icons.calendar_today,
//                                       color: Colors.white),
//                                   SizedBox(width: 8.0),
//                                   Text(
//                                     'Select Month',
//                                     style: TextStyle(fontSize: 16.0),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                             const SizedBox(height: 16.0),
//                             Text(
//                               '${_focusedMonth.month}/${_focusedMonth.year}',
//                               style: const TextStyle(
//                                   color: Color.fromRGBO(8, 15, 44, 1),
//                                   fontSize: 24.0,
//                                   fontWeight: FontWeight.bold),
//                             ),
//                         const SizedBox(height: 16.0),

//                           ],
//                         ),
//                       ),
//                     ),
//                     SliverGrid(
//                       delegate: SliverChildBuilderDelegate(
//                         (context, index) {
//                           var flavor = flavors[index];
//                           int amount = monthlyAmounts[flavor.name] ?? 0;

//                           return Card(
//                             elevation: 5,
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(10),
//                             ),
//                             child: Container(
//                               padding: const EdgeInsets.all(8.0),
//                               decoration: BoxDecoration(
//                                 color: Colors.blue[50],
//                                 borderRadius: BorderRadius.circular(10),
//                               ),
//                               child: Column(
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 children: [
//                                   CircleAvatar(
//                                     radius: 45,
//                                     backgroundImage:
//                                         AssetImage(flavor.imagePath),
//                                   ),
//                                   const SizedBox(height: 10),
//                                   Text(
//                                     flavor.name,
//                                     style: const TextStyle(
//                                       fontSize: 16,
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                   ),
//                                   const SizedBox(height: 10),
//                                   Text(
//                                     '$amount Sold',
//                                     style: const TextStyle(
//                                         fontSize: 14, color: Colors.black54),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           );
//                         },
//                         childCount: flavors.length,
//                       ),
//                       gridDelegate:
//                           const SliverGridDelegateWithFixedCrossAxisCount(
//                         crossAxisCount: 2,
//                         crossAxisSpacing: 16.0,
//                         mainAxisSpacing: 16.0,
//                         childAspectRatio: 1.0,
//                         mainAxisExtent: 200,
//                       ),
//                     ),
//                     SliverToBoxAdapter(
//                       child: Container(
//                         padding: const EdgeInsets.all(10.0),
//                         child: StreamBuilder(
//                           stream: FirebaseFirestore.instance
//                               .collection('specials')
//                               .where('date',
//                                   isGreaterThanOrEqualTo: DateTime(
//                                       _focusedMonth.year,
//                                       _focusedMonth.month,
//                                       1))
//                               .where('date',
//                                   isLessThanOrEqualTo: DateTime(
//                                       _focusedMonth.year,
//                                       _focusedMonth.month + 1,
//                                       0))
//                               .snapshots(),
//                           builder:
//                               (context, AsyncSnapshot<QuerySnapshot> snapshot) {
//                             if (!snapshot.hasData) {
//                               return const Center(
//                                 child: CircularProgressIndicator(),
//                               );
//                             }

//                             final docs = snapshot.data!.docs;

//                             return ListView.builder(
//                               shrinkWrap: true,
//                               physics: const NeverScrollableScrollPhysics(),
//                               itemCount: docs.length,
//                               itemBuilder: (context, index) {
//                                 final data = docs[index];
//                                 return Card(
//                                   elevation: 5,
//                                   shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(15),
//                                   ),
//                                   child: Container(
//                                     padding: const EdgeInsets.all(18.0),
//                                     decoration: BoxDecoration(
//                                       color: Colors.blue[50],
//                                       borderRadius: BorderRadius.circular(10),
//                                     ),
//                                     child: Row(
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.spaceBetween,
//                                       children: [
//                                         CircleAvatar(
//                                           radius: 30,
//                                           backgroundImage:
//                                               AssetImage(data['flavor_image']),
//                                         ),
//                                         Text(
//                                           '${data['flavor']} + ${data['additions']}',
//                                           style: const TextStyle(
//                                             fontSize: 16,
//                                             fontWeight: FontWeight.bold,
//                                           ),
//                                         ),
//                                         CircleAvatar(
//                                           radius: 30,
//                                           backgroundImage: AssetImage(
//                                               data['additions_image']),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 );
//                               },
//                             );
//                           },
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 Positioned(
//                   top: 10,
//                   left: 0,
//                   child: IconButton(
//                     icon: const Icon(
//                       Icons.arrow_back,
//                       color: Color.fromRGBO(8, 15, 44, 1),
//                       size: 50,
//                     ),
//                     onPressed: () {
//                       Navigator.of(context).pushReplacement(
//                         MaterialPageRoute(
//                             builder: (context) => const DoubleJooHomePage()),
//                       );
//                     },
//                   ),
//                 )
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
