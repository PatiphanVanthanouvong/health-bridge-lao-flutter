// ignore_for_file: unused_field, use_build_context_synchronously, library_private_types_in_public_api

import 'dart:developer';

import 'package:heathbridge_lao/package.dart';
import 'package:heathbridge_lao/src/screens/home/widget/typedropdown.dart';

final TextEditingController _searchController = TextEditingController();
String _selectTypeName = 'ທັງໝົດ';
String _selectedType = 'ທັງໝົດ';
DropdownItem? dropdownValue1;
String? dropdownValue2;
List<DropdownItem> _dropdownItems1 = [
  DropdownItem(id: '0', name: 'ປະເພດທັງໝົດ')
];
List<String> _dropdownItems2 = ['ການບໍລິການທັງໝົດ'];
bool _isPanelExpanded1 = false;
bool _isPanelExpanded2 = false;

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  List<String> _searchHistory = [];
  @override
  void initState() {
    super.initState();
    _loadSearchHistory();
    _fetchInitialData();
  }

  Future<void> _loadSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _searchHistory = prefs.getStringList('searchHistory') ?? [];
    });
  }

  Future<void> _saveSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList('searchHistory', _searchHistory);
  }

  void _performSearch(String query) {
    setState(() {
      if (!_searchHistory.contains(query)) {
        _searchHistory.insert(0, query);
        _saveSearchHistory();
      }
    });
  }

  void _updateFilter(String filter) {
    setState(() {
      _selectTypeName = filter;
    });
  }

  void _removeHistoryItem(String item) {
    setState(() {
      _searchHistory.remove(item);
      _saveSearchHistory();
    });
  }

  Future<void> _fetchInitialData() async {
    await context.read<ServiceProvider>().fetchServices().then((services) {
      setState(() {
        for (var service in services) {
          final serviceName = service.nameLa ?? "";
          if (!_dropdownItems2.contains(serviceName)) {
            _dropdownItems2.add(serviceName);
          }
        }
        dropdownValue2 = _dropdownItems2.isNotEmpty ? _dropdownItems2[0] : null;
      });
    });

    await context.read<FacTypeProvider>().fetchonSearchPage().then((types) {
      setState(() {
        Set<DropdownItem> typeSet = _dropdownItems1.toSet();
        for (var type in types) {
          final newItem = DropdownItem(
            id: type.facTypeId!,
            name: "${type.nameLa} ${type.sub_type}",
          );
          typeSet.add(newItem);
        }
        _dropdownItems1 = typeSet.toList();
        dropdownValue1 = _dropdownItems1.isNotEmpty ? _dropdownItems1[0] : null;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 5,
        automaticallyImplyLeading: true,
        backgroundColor: Colors.transparent,
      ),
      extendBody: false,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  margin: const EdgeInsets.only(right: 5, left: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10.0),
                    border: Border.all(
                      color: ConstantColor.colorMain,
                      width: 2.0,
                    ),
                  ),
                  width: 50,
                  height: 50,
                  child: IconButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.arrow_back),
                  ),
                ),
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: SearchBar(
                      onSearch: _performSearch,
                      searchHistory: _searchHistory,
                      onRemoveHistoryItem: _removeHistoryItem,
                    ),
                  ),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
              child: Divider(),
            ),
            ExpansionPanelList(
              expandedHeaderPadding: EdgeInsets.zero,
              elevation: 0,
              materialGapSize: 1,
              expansionCallback: (int index, bool isExpanded) {
                setState(() {
                  if (index == 0) {
                    _isPanelExpanded1 = !_isPanelExpanded1;
                    _isPanelExpanded2 = false;
                    context.read<FacilityProvider>().searchFacilities("", "");
                  } else {
                    _isPanelExpanded2 = !_isPanelExpanded2;
                    _isPanelExpanded1 = false;
                    context.read<FacilityProvider>().searchFacilities("", "");
                  }
                });
              },
              children: [
                ExpansionPanel(
                  headerBuilder: (BuildContext context, bool isExpanded) {
                    return const ListTile(
                      title: Row(
                        children: [
                          Icon(Icons.category_outlined),
                          SizedBox(width: 10),
                          Text('ຄົ້ນຫາຕາມປະເພດ'),
                        ],
                      ),
                    );
                  },
                  body: Column(
                    children: [
                      DropdownButton<DropdownItem>(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(15)),
                        dropdownColor: Colors.grey.shade100,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        isExpanded: true,
                        value: dropdownValue1,
                        onChanged: (DropdownItem? newValue) {
                          setState(() {
                            dropdownValue1 = newValue;

                            if (dropdownValue1?.id.toString() == '0') {
                              context
                                  .read<FacilityProvider>()
                                  .searchFacilities("", "");
                            } else {
                              context.read<FacilityProvider>().searchByTypes(
                                  search: dropdownValue1!.id.toString());
                            }
                            context.pop();
                          });
                        },
                        items: _dropdownItems1
                            .map<DropdownMenuItem<DropdownItem>>(
                                (DropdownItem value) {
                          return DropdownMenuItem<DropdownItem>(
                            value: value,
                            child: Text(value.name),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                  isExpanded: _isPanelExpanded1,
                ),
                ExpansionPanel(
                  headerBuilder: (BuildContext context, bool isExpanded) {
                    return const ListTile(
                      title: Row(
                        children: [
                          Icon(Icons.medical_services_outlined),
                          SizedBox(width: 10),
                          Text('ຄົ້ນຫາຕາມການບໍລິການ'),
                        ],
                      ),
                    );
                  },
                  body: Column(
                    children: [
                      DropdownButton<String>(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(15)),
                        dropdownColor: Colors.grey.shade100,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        isExpanded: true,
                        value: dropdownValue2,
                        onChanged: (String? newValue) {
                          setState(() {
                            dropdownValue2 = newValue;

                            context.read<FacilityProvider>().searchByServices(
                                search: dropdownValue2.toString() ==
                                        "ການບໍລິການທັງໝົດ"
                                    ? ""
                                    : dropdownValue2.toString());
                            log(dropdownValue2.toString());
                            context.pop();
                          });
                        },
                        items: _dropdownItems2
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                  isExpanded: _isPanelExpanded2,
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
              child: Divider(),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5.0),
              child: FilterOptions(
                selectedFilter: _selectTypeName,
                onFilterChanged: _updateFilter,
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
              child: Divider(),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SearchHistoryChips(
                searchHistory: _searchHistory,
                searchController: _searchController,
                onRemoveHistoryItem: _removeHistoryItem,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SearchBar extends StatefulWidget {
  final Function(String) onSearch;
  final List<String> searchHistory;
  final Function(String) onRemoveHistoryItem;

  const SearchBar({
    required this.onSearch,
    required this.searchHistory,
    required this.onRemoveHistoryItem,
    super.key,
  });

  @override
  _SearchBarState createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  List<String> _filteredSuggestions = [];

  void _updateFilteredSuggestions(String query) {
    setState(() {
      _filteredSuggestions = widget.searchHistory
          .where((item) => item.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
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
            mainAxisSize: MainAxisSize.max,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 10),
              Text("ກໍາລັງຄົ້ນຫາ..."),
            ],
          ),
        );
      },
    );
    await context.read<FacilityProvider>().searchFacilities(
        _selectTypeName == query || query == "ທັງໝົດ" ? "" : query,
        _selectTypeName == "ທັງໝົດ" ? "" : _selectTypeName,
        facilityTypes:
            _selectedType == "ທັງໝົດ" ? null : [_selectedType.toLowerCase()]);

    if (mounted) {
      Navigator.of(context, rootNavigator: true).pop();
      Navigator.of(context, rootNavigator: true).pop();
      setState(() {
        _filteredSuggestions = [];
        _searchController.clear();
      });
    }
  }

  void _removeHistoryItem(String item) {
    widget.onRemoveHistoryItem(item);
  }

  void _selectHistoryItem(String item) {
    _searchController.text = item;
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
            controller: _searchController,
            decoration: InputDecoration(
              isDense: true,
              hintText: 'ຄົ້ນຫາ...',
              suffixIcon: IconButton(
                icon: const Icon(Icons.search),
                onPressed: () {
                  _performSearch(_searchController.text);
                },
              ),
            ),
            onChanged: _updateFilteredSuggestions,
            onSubmitted: _performSearch,
          ),
        ),
      ],
    );
  }
}

class FilterOptions extends StatelessWidget {
  final String selectedFilter;
  final Function(String) onFilterChanged;

  FilterOptions({
    required this.selectedFilter,
    required this.onFilterChanged,
    super.key,
  });

  final List<String> _filters = [
    'ທັງໝົດ',
    'ໂຮງໝໍ',
    'ຄຣີນິກ',
    'ຮ້ານຂາຍຢາ',
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8.0,
      children: _filters.map((filter) {
        return ChoiceChip(
          label: Text(filter),
          selected: selectedFilter == filter,
          onSelected: (selected) {
            onFilterChanged(filter);

            _searchController.text = filter;
          },
        );
      }).toList(),
    );
  }
}

class SearchHistoryChips extends StatefulWidget {
  final List<String> searchHistory;
  final TextEditingController searchController;
  final Function(String) onRemoveHistoryItem;

  const SearchHistoryChips({
    required this.searchHistory,
    required this.searchController,
    required this.onRemoveHistoryItem,
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
            'ປະຫວັດການຄົ້ນຫາ ',
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
                        _searchController.text = historyItem;
                      },
                      child: Text(historyItem)),
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
