import 'package:flutter/material.dart';
import 'package:heathbridge_lao/package.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SearchBarWidget extends StatefulWidget {
  final Function(String) onSearch;
  final List<String> searchHistory;
  final Function(String) onRemoveHistoryItem;
  final Function(String) updateFilter;
  final Function(String) updateType;
  final String selectTypeName;
  final String selectedType;
  final TextEditingController searchController;
  const SearchBarWidget({
    required this.searchController,
    required this.onSearch,
    required this.searchHistory,
    required this.onRemoveHistoryItem,
    required this.updateFilter,
    required this.updateType,
    required this.selectTypeName,
    required this.selectedType,
    super.key,
  });

  @override
  _SearchBarWidgetState createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  @override
  void initState() {
    widget.searchController.text = '';
    super.initState();
  }

  // final TextEditingController _searchController = TextEditingController();
  List<String> _filteredSuggestions = [];

  void _updateFilteredSuggestions(String query) {
    setState(() {
      _filteredSuggestions = widget.searchHistory
          .where((item) => item.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });

    widget.searchController.text = query;
  }

  void _performSearch(String query) async {
    widget.onSearch(query);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Dialog(
          backgroundColor: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 10),
              Text("Searching..."),
            ],
          ),
        );
      },
    );

    try {
      await context.read<FacilityProvider>().searchFacilities(
            widget.selectTypeName == query || query == "ທັງໝົດ" ? "" : query,
            widget.selectTypeName == "ທັງໝົດ" ? "" : widget.selectTypeName,
            facilityTypes: widget.selectedType == "ທັງໝົດ"
                ? null
                : [widget.selectedType.toLowerCase()],
          );

      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop(); // Pop loading dialog
        Navigator.of(context, rootNavigator: true).pop(); // Pop search page
        // setState(() {
        //   widget.searchController.text.clear();
        // });
      }
    } catch (e) {
      // Handle errors gracefully
      print('Error during search: $e');
      // Optionally show an error dialog to the user
    }
  }

  void _removeHistoryItem(String item) {
    widget.onRemoveHistoryItem(item);
  }

  void _selectHistoryItem(String item) {
    widget.searchController.text = item;
    widget.updateFilter(item); // Update filter in SearchPage
    _performSearch(item);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15.0),
            border: Border.all(
              color: ConstantColor.colorMain,
              width: 2.0,
            ),
          ),
          child: TextField(
            controller: widget.searchController,
            decoration: InputDecoration(
              isDense: true,
              hintText: 'ຄົ້ນຫາ...',
              hintStyle: const TextStyle(
                fontSize: 16,
              ),
              suffixIcon: IconButton(
                style: ButtonStyle(
                  iconSize: MaterialStateProperty.all(25.0),
                ),
                icon: const Icon(Icons.search),
                onPressed: () {
                  _performSearch(widget.searchController.text);
                },
              ),
            ),
            onChanged: _updateFilteredSuggestions,
            onSubmitted: _performSearch,
          ),
        ),
        if (_filteredSuggestions.isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  'Suggested Searches',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              Wrap(
                spacing: 8.0,
                children: _filteredSuggestions.map((historyItem) {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Chip(
                        label: InkWell(
                          onTap: () {
                            _selectHistoryItem(historyItem);
                          },
                          child: Text(historyItem),
                        ),
                        onDeleted: () => _removeHistoryItem(historyItem),
                      ),
                      const SizedBox(width: 4),
                    ],
                  );
                }).toList(),
              ),
            ],
          ),
      ],
    );
  }
}

class SearchHistoryChips extends StatefulWidget {
  final List<String> searchHistory;
  final TextEditingController searchController;
  final Function(String) onRemoveHistoryItem;
  final Function(String) updateFilter;

  const SearchHistoryChips({
    required this.searchHistory,
    required this.searchController,
    required this.onRemoveHistoryItem,
    required this.updateFilter,
    super.key,
  });

  @override
  State<SearchHistoryChips> createState() => _SearchHistoryChipsState();
}

class _SearchHistoryChipsState extends State<SearchHistoryChips> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            'Search History',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        Wrap(
          spacing: 8.0,
          children: widget.searchHistory.map((historyItem) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Chip(
                  label: InkWell(
                    onTap: () {
                      widget.searchController.text = historyItem;
                      widget.updateFilter(historyItem);
                    },
                    child: Text(historyItem),
                  ),
                  onDeleted: () => widget.onRemoveHistoryItem(historyItem),
                ),
                const SizedBox(width: 4),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }
}
