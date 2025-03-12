import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSuggestionVisible = false;
  String? _searchQuery;

  // Sample suggestions (same as HomePage for consistency)
  final List<String> suggestions = [
    'Dolo - 650mg',
    'Doc2 - Dermatologist',
    'Blood - CBC',
    'Doc2 - Dermatologist',
  ];

  // Sample search results (mock data for demonstration)
  final List<Map<String, dynamic>> searchResults = [
    {
      'title': 'Doctor-2',
      'type': 'Doctor',
      'specialty': 'Dermatologist',
      'image': 'assets/doctor2.png',
    },
    {
      'title': 'Blood - CBC',
      'type': 'Lab Test',
      'icon': Icons.local_hospital,
    },
    {
      'title': 'Dolo - 650mg',
      'type': 'Medicine',
      'icon': Icons.medication,
    },
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchController.removeListener(_onSearchChanged);
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _isSuggestionVisible = _searchController.text.isNotEmpty && _searchQuery == null;
    });
  }

  void _performSearch(String query) {
    if (query.isNotEmpty) {
      setState(() {
        _searchQuery = query;
        _isSuggestionVisible = false;
      });
      FocusScope.of(context).unfocus();
    }
  }

  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _searchQuery = null;
      _isSuggestionVisible = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
        backgroundColor: Colors.grey[200],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSearchBar(),
            if (_isSuggestionVisible) _buildSuggestions(),
            if (_searchQuery != null) ...[
              const SizedBox(height: 16),
              Text(
                'Results for "$_searchQuery"',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Expanded(child: _buildSearchResults()),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(51),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _clearSearch,
          ),
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search Doctors, medicines',
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 10),
              ),
              onSubmitted: _performSearch,
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 5),
            child: InkWell(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Google Lens'),
                    content: const Text('Open camera for visual search'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Open Camera'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                    ],
                  ),
                );
              },
              child: Image.asset(
                'assets/google_lens.png',
                width: 24,
                height: 24,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.camera_alt, size: 24);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestions() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(51),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Suggestion',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...suggestions.map((suggestion) => ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(suggestion),
                onTap: () {
                  _searchController.text = suggestion;
                  _performSearch(suggestion);
                },
              )),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    final filteredResults = searchResults.where((result) {
      return result['title'].toString().toLowerCase().contains(_searchQuery!.toLowerCase());
    }).toList();

    if (filteredResults.isEmpty) {
      return const Center(child: Text('No results found'));
    }

    return ListView.builder(
      itemCount: filteredResults.length,
      itemBuilder: (context, index) {
        final result = filteredResults[index];
        return ListTile(
          leading: result['image'] != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    result['image'],
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.person, size: 40);
                    },
                  ),
                )
              : Icon(result['icon'] as IconData?, size: 40, color: Colors.blue),
          title: Text(result['title']),
          subtitle: Text(result['type']),
          onTap: () {
            if (result['type'] == 'Doctor') {
              Navigator.pushNamed(context, '/doctors_list');
            } else if (result['type'] == 'Lab Test') {
              Navigator.pushNamed(context, '/test_results');
            } else if (result['type'] == 'Medicine') {
              Navigator.pushNamed(context, '/medicines');
            }
          },
        );
      },
    );
  }
}