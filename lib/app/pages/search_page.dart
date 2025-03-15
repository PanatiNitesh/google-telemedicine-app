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

  // Mock data for recent searches
  final List<Map<String, dynamic>> recentSearches = [
    {
      'title': 'Dermatologist',
      'type': 'Doctor',
      'image': 'assets/doctor1.png',
      'action': 'Book',
    },
    {
      'title': 'CBC Test',
      'type': 'Lab Test',
      'icon': Icons.local_hospital,
      'action': 'Book',
    },
    {
      'title': 'Dolo - 650mg',
      'type': 'Medicine',
      'icon': Icons.medication,
      'action': 'Order',
    },
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);

    // Check for route arguments and perform search if query exists
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
    return Scaffold(
      backgroundColor: const Color(0xFFDDDDDD), // Background color
      body: Column(
        children: [
          // Navbar with Back Button at Top Left
          Container(
            padding: const EdgeInsets.only(top: 10.0, left: 6.0), // Moved closer to top with left padding of 6
            height: 60.0, // Reduced height to keep it compact
            decoration: const BoxDecoration(
              color: Colors.transparent,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start, // Align to the left
              children: [
                GestureDetector(
                  onTap: _goBack,
                  child: Image.asset(
                    'assets/back.png',
                    width: 30, // Keep size at 30x30 as per your code
                    height: 30,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSearchBar(), // Search bar below navbar
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
                  // Recent Searches Section
                  if (_searchQuery == null) ...[
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Previous Search',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        TextButton(
                          onPressed: () {
                            // TODO: Implement View All functionality
                          },
                          child: const Text(
                            'View All',
                            style: TextStyle(color: Colors.blue),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _buildRecentSearches(),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
      // Chat Bot Floating Action Button with Image
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Implement chat bot functionality
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Chat Bot Opened')),
          );
        },
        backgroundColor: Colors.blue,
        elevation: 4.0,
        child: Image.asset(
          'assets/chatbot.png',
          width: 24,
          height: 24,
          errorBuilder: (context, error, stackTrace) {
            return const Icon(Icons.chat_bubble_outline, color: Colors.white);
          },
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 50,
      margin: const EdgeInsets.only(top: 10), // Space below navbar
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
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

  Widget _buildRecentSearches() {
    return SizedBox(
      height: 120,
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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  search['image'] != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.asset(
                            search['image'],
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(Icons.person, size: 40);
                            },
                          ),
                        )
                      : Icon(search['icon'] as IconData?, size: 40, color: Colors.blue),
                  const SizedBox(height: 8),
                  Text(
                    search['title'],
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 12),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${search['action']} clicked for ${search['title']}')),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      minimumSize: const Size(60, 30),
                    ),
                    child: Text(
                      search['action'],
                      style: const TextStyle(fontSize: 12, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}