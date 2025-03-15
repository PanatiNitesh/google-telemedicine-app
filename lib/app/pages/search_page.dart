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

  final List<String> suggestions = [
    'Dolo - 650mg',
    'Doc2 - Dermatologist',
    'Blood - CBC',
    'Doc2 - Dermatologist',
  ];

  final List<Map<String, dynamic>> searchResults = [
    {'title': 'Doctor-2', 'type': 'Doctor', 'specialty': 'Dermatologist', 'image': 'assets/doctor2.png'},
    {'title': 'Blood - CBC', 'type': 'Lab Test', 'icon': Icons.local_hospital},
    {'title': 'Dolo - 650mg', 'type': 'Medicine', 'icon': Icons.medication},
  ];

  final List<Map<String, dynamic>> recentSearches = [
    {'title': 'Dermatologist', 'type': 'Doctor', 'image': 'assets/doctor1.png', 'action': 'Book'},
    {'title': 'CBC Test', 'type': 'Lab Test', 'icon': Icons.local_hospital, 'action': 'Book'},
    {'title': 'Dolo - 650mg', 'type': 'Medicine', 'icon': Icons.medication, 'action': 'Order'},
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null && args.containsKey('query')) {
        final query = args['query'] as String;
        _searchController.text = query;
        _performSearch(query);
      }
    });
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

  void _goBack() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFDDDDDD),
      extendBodyBehindAppBar: true, // Match TestResults.dart
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: EdgeInsets.only(left: screenWidth * 0.04), // Match TestResults.dart
          child: GestureDetector(
            onTap: _goBack,
            child: Image.asset(
              'assets/back.png',
              width: screenWidth * 0.05, // Match TestResults.dart
              height: screenWidth * 0.05, // Match TestResults.dart
              errorBuilder: (context, error, stackTrace) => Icon(
                Icons.arrow_back,
                size: screenWidth * 0.05, // Match TestResults.dart
              ),
            ),
          ),
        ),
        title: const Text(
          'Search',
          style: TextStyle(
            fontSize: 24, // Adjusted to a reasonable size, can match TestResults.dart if needed
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        foregroundColor: Colors.black,
        centerTitle: false,
      ),
      body: Padding(
        padding: EdgeInsets.fromLTRB(
          screenWidth * 0.04,
          AppBar().preferredSize.height + MediaQuery.of(context).padding.top, // Start below AppBar
          screenWidth * 0.04,
          12 + 60, // Match TestResults.dart’s bottom padding
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSearchBar(),
            if (_isSuggestionVisible) _buildSuggestions(),
            if (_searchQuery != null) ...[
              const SizedBox(height: 16),
              Text('Results for "$_searchQuery"', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Expanded(child: _buildSearchResults()),
            ],
            if (_searchQuery == null) ...[
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Previous Search', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  TextButton(
                    onPressed: () {},
                    child: const Text('View All', style: TextStyle(color: Colors.blue)),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _buildRecentSearches(),
            ],
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Chat Bot Opened')),
  );

  // Navigate to the /ai_diagnose route
  Future.delayed(Duration(milliseconds: 500), () {
    Navigator.pushNamed(context, '/ai_diagnose');
  });
},

        backgroundColor: Colors.blue,
        elevation: 4.0,
        child: Image.asset(
          'assets/chatbot.png',
          width: 24,
          height: 24,
          errorBuilder: (context, error, stackTrace) => const Icon(Icons.chat_bubble_outline, color: Colors.white),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 50,
      margin: const EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.3), spreadRadius: 2, blurRadius: 8, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search Doctors, medicines',
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              ),
              onSubmitted: _performSearch,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: InkWell(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Google Lens'),
                    content: const Text('Open camera for visual search'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context), child: const Text('Open Camera')),
                      TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                    ],
                  ),
                );
              },
              child: Image.asset(
                'assets/google_lens.png',
                width: 24,
                height: 24,
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.camera_alt, size: 24),
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
        boxShadow: [BoxShadow(color: Colors.grey.withAlpha(51), spreadRadius: 1, blurRadius: 5, offset: const Offset(0, 1))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Suggestion', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
    final filteredResults = searchResults.where((result) => result['title'].toString().toLowerCase().contains(_searchQuery!.toLowerCase())).toList();
    if (filteredResults.isEmpty) return const Center(child: Text('No results found'));
    return ListView.builder(
      itemCount: filteredResults.length,
      itemBuilder: (context, index) {
        final result = filteredResults[index];
        return ListTile(
          leading: result['image'] != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(result['image'], width: 40, height: 40, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => const Icon(Icons.person, size: 40)),
                )
              : Icon(result['icon'] as IconData?, size: 40, color: Colors.blue),
          title: Text(result['title']),
          subtitle: Text(result['type']),
          onTap: () {
            if (result['type'] == 'Doctor') Navigator.pushNamed(context, '/doctors_list');
            else if (result['type'] == 'Lab Test') Navigator.pushNamed(context, '/test_results');
            else if (result['type'] == 'Medicine') Navigator.pushNamed(context, '/medicines');
          },
        );
      },
    );
  }

  Widget _buildRecentSearches() {
    return SizedBox(
      height: 140,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: recentSearches.length,
        itemBuilder: (context, index) {
          final search = recentSearches[index];
          return Container(
            width: 100,
            margin: const EdgeInsets.only(right: 10),
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    search['image'] != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.asset(search['image'], width: 40, height: 40, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => const Icon(Icons.person, size: 40)),
                          )
                        : Icon(search['icon'] as IconData?, size: 40, color: Colors.blue),
                    const SizedBox(height: 4),
                    Text(
                      search['title'],
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 11),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${search['action']} clicked for ${search['title']}')));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        minimumSize: const Size(50, 25),
                      ),
                      child: Text(
                        search['action'],
                        style: const TextStyle(fontSize: 10, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}