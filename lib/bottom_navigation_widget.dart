// import 'package:flutter/material.dart';
// import 'point_list.dart'; // tab1 스크린을 정의한 파일을 import합니다.
// import 'google_map_screen.dart'; // google_map_screen을 import합니다.
// import 'theme_screen.dart';
// import 'sample_screen.dart';
// import 'my_page.dart';
// import 'point_details_screen.dart';


// class BottomNavigationWidget extends StatefulWidget {
//   final int selectedIndex;
//   final ValueChanged<int> onItemTapped;

//   const BottomNavigationWidget({Key? key, required this.selectedIndex, required this.onItemTapped}) : super(key: key);

//   @override
//   _BottomNavigationWidgetState createState() => _BottomNavigationWidgetState();
// }

// class _BottomNavigationWidgetState extends State<BottomNavigationWidget> {
//   @override
//   Widget build(BuildContext context) {
//     return ClipRRect(
//       borderRadius: const BorderRadius.only(
//         topLeft: Radius.circular(17.0),
//         topRight: Radius.circular(17.0),
//       ),
//       child: BottomNavigationBar(
//         items: const <BottomNavigationBarItem>[
//           BottomNavigationBarItem(
//             icon: Icon(Icons.home),
//             label: 'Home',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.place),
//             label: 'Theme',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.map),
//             label: 'Map',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.person),
//             label: 'MyPage',
//           ),
//         ],
//         currentIndex: widget.selectedIndex,
//         selectedItemColor: Colors.white,
//         unselectedItemColor: Colors.white.withOpacity(0.5),
//         backgroundColor: Color(0x80A8DF8E),
//         showSelectedLabels: true,
//         showUnselectedLabels: false,
//         onTap: widget.onItemTapped,
//         type: BottomNavigationBarType.fixed,
//       ),
//     );
//   }
// }
