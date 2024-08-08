// import 'package:heathbridge_lao/package.dart';
// List<String> _searchResults = [];
// List<String> _searchHistory = [];
// String _selectTypeName = 'ທັງໝົດ';
// String _selectedType = 'ທັງໝົດ';
// final TextEditingController _searchController = TextEditingController();
// class SearchBar extends StatefulWidget {
//   final Function(String) onSearch;
//   final List<String> searchHistory;
//   final Function(String) onRemoveHistoryItem;

//   const SearchBar({
//     required this.onSearch,
//     required this.searchHistory,
//     required this.onRemoveHistoryItem,
//     super.key,
//   });

//   @override
//   _SearchBarState createState() => _SearchBarState();
// }

// class _SearchBarState extends State<SearchBar> {
//   List<String> _filteredSuggestions = [];

//   void _updateFilteredSuggestions(String query) {
//     setState(() {
//       _filteredSuggestions = widget.searchHistory
//           .where((item) => item.toLowerCase().contains(query.toLowerCase()))
//           .toList();
//     });
//   }

//   void _performSearch(String query) async {
//     widget.onSearch(query);
//     showDialog(
//       context: context,
//       barrierDismissible:
//           false, // Prevents closing the dialog by clicking outside
//       builder: (BuildContext context) {
//         return const Dialog(
//           backgroundColor: Colors.transparent,
//           child: Column(
//             mainAxisSize: MainAxisSize.max,
//             children: [
//               CircularProgressIndicator(),
//               SizedBox(height: 10),
//               Text("Searching..."),
//             ],
//           ),
//         );
//       },
//     );
//     await context.read<FacilityProvider>().searchFacilities(
//         _selectTypeName == query || query == "ທັງໝົດ" ? "" : query,
//         _selectTypeName == "ທັງໝົດ" ? "" : _selectTypeName,
//         facilityTypes:
//             _selectedType == "ທັງໝົດ" ? null : [_selectedType.toLowerCase()]);

//     if (mounted) {
//       Navigator.of(context, rootNavigator: true).pop();
//       Navigator.of(context, rootNavigator: true).pop();
//       setState(() {
//         _filteredSuggestions = [];
//         _searchController.clear();
//       });
//     }
//   }

//   void _removeHistoryItem(String item) {
//     widget.onRemoveHistoryItem(item);
//   }

//   void _selectHistoryItem(String item) {
//     _searchController.text = item;
//     _performSearch(item);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         Container(
//           padding: const EdgeInsets.symmetric(horizontal: 16.0),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(15.0),
//             border: Border.all(
//               color: ConstantColor.colorMain,
//               width: 2.0,
//             ),
//           ),
//           child: TextField(
//             controller: _searchController,
//             decoration: InputDecoration(
//               isDense: true,
//               hintText: 'ຄົ້ນຫາ...',
//               hintStyle: const TextStyle(
//                 fontSize: 16,
//               ),
//               suffixIcon: IconButton(
//                 style:
//                     const ButtonStyle(iconSize: MaterialStatePropertyAll(25.0)),
//                 icon: const Icon(Icons.search),
//                 onPressed: () {
//                   _performSearch(_searchController.text);
//                 },
//               ),
//             ),
//             onChanged: _updateFilteredSuggestions,
//             onSubmitted: _performSearch,
//           ),
//         ),
//       ],
//     );
//   }
// }
