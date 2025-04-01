import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io' show Platform;
import 'package:android_intent_plus/android_intent.dart';

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
    {
      'title': 'Doctor-2',
      'type': 'Doctor',
      'specialty': 'Dermatologist',
      'image': 'assets/doctor2.png'
    },
    {'title': 'Blood - CBC', 'type': 'Lab Test', 'icon': Icons.local_hospital},
    {'title': 'Dolo - 650mg', 'type': 'Medicine', 'icon': Icons.medication},
  ];

  final List<Map<String, dynamic>> recentSearches = [
    {
      'title': 'Dermatologist',
      'type': 'Doctor',
      'image': 'assets/doctor1.png',
      'action': 'Book'
    },
    {'title': 'CBC Test', 'type': 'Lab Test', 'icon': Icons.local_hospital, 'action': 'Book'},
    {
      'title': 'Dolo - 650mg',
      'type': 'Medicine',
      'icon': Icons.medication,
      'action': 'Order'
    },
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

  void _openGoogleLens() async {
    if (Platform.isAndroid) {
      try {
        const String googleLensPackage = 'com.google.ar.lens';
        print('Attempting to launch Google Lens app with package: $googleLensPackage');
        final intent = AndroidIntent(
          action: 'android.intent.action.MAIN',
          package: googleLensPackage,
          category: 'android.intent.category.LAUNCHER',
        );
        await intent.launch();
        print('Successfully launched Google Lens app');
        return;
      } catch (e) {
        print('Error launching Google Lens app with package com.google.ar.lens: $e');
      }
      try {
        const String googleAppPackage = 'com.google.android.googlequicksearchbox';
        print('Attempting to launch Google app with deep link: googleapp://lens');
        final intent = AndroidIntent(
          action: 'android.intent.action.VIEW',
          package: googleAppPackage,
          data: 'googleapp://lens',
        );
        await intent.launch();
        print('Successfully launched Google Lens via Google app');
        return;
      } catch (e) {
        print('Error launching Google app with Lens deep link: $e');
      }
      try {
        print('Attempting to launch Google Lens with specific intent');
        final intent = AndroidIntent(
          action: 'com.google.android.apps.lens.LENS',
          package: 'com.google.ar.lens',
        );
        await intent.launch();
        print('Successfully launched Google Lens with specific intent');
        return;
      } catch (e) {
        print('Error launching Google Lens with specific intent: $e');
      }
      try {
        final Uri deepLink = Uri.parse('googlelens://');
        print('Attempting to launch Google Lens with deep link: $deepLink');
        if (await canLaunchUrl(deepLink)) {
          await launchUrl(deepLink, mode: LaunchMode.externalApplication);
          print('Successfully launched Google Lens with deep link');
          return;
        } else {
          print('Deep link not supported: $deepLink');
        }
      } catch (e) {
        print('Error launching Google Lens with deep link googlelens://: $e');
      }
      print('Falling back to web version of Google Lens');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Google Lens app not found. Opening web version.'),
        ),
      );
      final Uri webUrl = Uri.parse('https://lens.google.com/');
      if (await canLaunchUrl(webUrl)) {
        await launchUrl(webUrl, mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to open Google Lens')),
        );
      }
    } else {
      print('Non-Android platform detected, opening web version of Google Lens');
      final Uri webUrl = Uri.parse('https://lens.google.com/');
      if (await canLaunchUrl(webUrl)) {
        await launchUrl(webUrl, mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Google Lens is not available')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final double titleFontSize = screenWidth * 0.06;
    final double subtitleFontSize = screenWidth * 0.04;
    final double paddingHorizontal = screenWidth * 0.04;
    final double paddingVertical = screenHeight * 0.02;
    final double searchBarHeight = screenHeight * 0.06;
    final double iconSize = screenWidth * 0.06 > 40 ? screenWidth * 0.06 : 40;
    final double cardWidth = screenWidth * 0.25;

    return Scaffold(
      backgroundColor: const Color(0xFFDDDDDD),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: EdgeInsets.only(left: paddingHorizontal),
          child: GestureDetector(
            onTap: _goBack,
            child: Image.asset(
              'assets/back.png',
              width: iconSize,
              height: iconSize,
              errorBuilder: (context, error, stackTrace) => Icon(
                Icons.arrow_back,
                size: iconSize,
              ),
            ),
          ),
        ),
        title: Text(
          'Search',
          style: TextStyle(
            fontSize: titleFontSize,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        foregroundColor: Colors.black,
        centerTitle: false,
      ),
      body: Padding(
        padding: EdgeInsets.fromLTRB(
          paddingHorizontal,
          AppBar().preferredSize.height + MediaQuery.of(context).padding.top,
          paddingHorizontal,
          paddingVertical + 60,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSearchBar(
                searchBarHeight: searchBarHeight,
                iconSize: iconSize,
                paddingHorizontal: paddingHorizontal,
              ),
              if (_isSuggestionVisible) _buildSuggestions(),
              if (_searchQuery != null) ...[
                SizedBox(height: paddingVertical),
                Text(
                  'Results for "$_searchQuery"',
                  style: TextStyle(
                    fontSize: subtitleFontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: paddingVertical * 0.5),
                SizedBox(
                  height: screenHeight * 0.5, 
                  child: _buildSearchResults(
                    iconSize: iconSize,
                  ),
                ),
              ],
              if (_searchQuery == null) ...[
                SizedBox(height: paddingVertical),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Previous Search',
                      style: TextStyle(
                        fontSize: subtitleFontSize,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        'View All',
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: subtitleFontSize * 0.8,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: paddingVertical * 0.5),
                _buildRecentSearches(
                  cardWidth: cardWidth,
                  iconSize: iconSize,
                  fontSize: subtitleFontSize * 0.7,
                  buttonHeight: searchBarHeight * 0.5,
                ),
              ],
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Chat Bot Opened')),
          );
          Future.delayed(const Duration(milliseconds: 500), () {
            Navigator.pushNamed(context, '/ai_diagnose');
          });
        },
        backgroundColor: Colors.blue,
        elevation: 4.0,
        child: Image.asset(
          'assets/chatbot.png',
          width: iconSize,
          height: iconSize,
          errorBuilder: (context, error, stackTrace) =>
              const Icon(Icons.chat_bubble_outline, color: Colors.white),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildSearchBar({
    required double searchBarHeight,
    required double iconSize,
    required double paddingHorizontal,
  }) {
    return Container(
      height: searchBarHeight,
      margin: EdgeInsets.only(top: paddingHorizontal * 0.5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(searchBarHeight * 0.5),
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
              decoration: InputDecoration(
                hintText: 'Search Doctors, medicines',
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: paddingHorizontal,
                  vertical: searchBarHeight * 0.25,
                ),
              ),
              onSubmitted: _performSearch,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(right: paddingHorizontal * 0.5),
            child: InkWell(
              onTap: _openGoogleLens,
              child: Image.asset(
                'assets/google_lens.png',
                width: iconSize,
                height: iconSize,
                errorBuilder: (context, error, stackTrace) =>
                    Icon(Icons.camera_alt, size: iconSize),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestions() {
    final screenWidth = MediaQuery.of(context).size.width;
    final paddingHorizontal = screenWidth * 0.04;
    final subtitleFontSize = screenWidth * 0.04;

    return Container(
      margin: EdgeInsets.only(top: paddingHorizontal * 0.5),
      padding: EdgeInsets.all(paddingHorizontal),
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
          Text(
            'Suggestion',
            style: TextStyle(
              fontSize: subtitleFontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: paddingHorizontal * 0.5),
          ...suggestions.map(
            (suggestion) => ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                suggestion,
                style: TextStyle(fontSize: subtitleFontSize * 0.9),
              ),
              onTap: () {
                _searchController.text = suggestion;
                _performSearch(suggestion);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults({
    required double iconSize,
  }) {
    final filteredResults = searchResults
        .where((result) =>
            result['title'].toString().toLowerCase().contains(_searchQuery!.toLowerCase()))
        .toList();
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
                    width: iconSize,
                    height: iconSize,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        Icon(Icons.person, size: iconSize),
                  ),
                )
              : Icon(
                  result['icon'] as IconData?,
                  size: iconSize,
                  color: Colors.blue,
                ),
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

  Widget _buildRecentSearches({
    required double cardWidth,
    required double iconSize,
    required double fontSize,
    required double buttonHeight,
  }) {
    return SizedBox(
      height: cardWidth * 1.4,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: recentSearches.length,
        itemBuilder: (context, index) {
          final search = recentSearches[index];
          return Container(
            width: cardWidth,
            margin: EdgeInsets.only(right: cardWidth * 0.1),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: EdgeInsets.all(cardWidth * 0.08),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    search['image'] != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.asset(
                              search['image'],
                              width: iconSize,
                              height: iconSize,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Icon(Icons.person, size: iconSize),
                            ),
                          )
                        : Icon(
                            search['icon'] as IconData?,
                            size: iconSize,
                            color: Colors.blue,
                          ),
                    SizedBox(height: cardWidth * 0.04),
                    Text(
                      search['title'],
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: fontSize),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: cardWidth * 0.04),
                    SizedBox(
                      height: buttonHeight,
                      child: ElevatedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  '${search['action']} clicked for ${search['title']}'),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: cardWidth * 0.06,
                            vertical: 2,
                          ),
                          minimumSize: Size(cardWidth * 0.5, buttonHeight),
                        ),
                        child: Text(
                          search['action'],
                          style: TextStyle(
                            fontSize: fontSize * 0.8,
                            color: Colors.white,
                          ),
                        ),
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