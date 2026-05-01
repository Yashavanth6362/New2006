import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;

void main() => runApp(const CrimeSearchApp());

class CrimeSearchApp extends StatelessWidget {
  const CrimeSearchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Crime Search',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.red,
        useMaterial3: true,
      ),
      home: const CrimeHomePage(),
    );
  }
}

class CrimeHomePage extends StatefulWidget {
  const CrimeHomePage({super.key});

  @override
  State<CrimeHomePage> createState() => _CrimeHomePageState();
}

class _CrimeHomePageState extends State<CrimeHomePage> {
  List<Map<String, dynamic>> crimes = [];
  List<Map<String, dynamic>> filteredCrimes = [];
  TextEditingController searchController = TextEditingController();
  String selectedType = 'All';
  bool isLoading = true;

  // Crime types for filter dropdown
  List<String> crimeTypes = [
    'All', 'murder', 'rape', 'robbery', 'theft', 'assault',
    'kidnapping', 'fraud', 'drugs', 'riot', 'cybercrime', 'terrorism'
  ];

  // URL for live data (GitHub raw URL)
  static const String liveDataUrl =
      'https://raw.githubusercontent.com/YOUR_USERNAME/YOUR_REPO/main/crimes.json';

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    try {
      // Try live URL first
      final response = await http.get(Uri.parse(liveDataUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          crimes = List<Map<String, dynamic>>.from(data['crimes'] ?? []);
          filteredCrimes = crimes;
          isLoading = false;
        });
        return;
      }
    } catch (e) {
      // Fallback to bundled JSON
    }

    // Load from assets if live fails
    try {
      final jsonString = await rootBundle.loadString('crimes.json');
      final data = json.decode(jsonString);
      setState(() {
        crimes = List<Map<String, dynamic>>.from(data['crimes'] ?? []);
        filteredCrimes = crimes;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  void filterCrimes(String query) {
    setState(() {
      filteredCrimes = crimes.where((crime) {
        final matchesType = selectedType == 'All' || crime['type'] == selectedType;
        final matchesSearch = query.isEmpty ||
            (crime['headline']?.toString().toLowerCase() ?? '')
                .contains(query.toLowerCase()) ||
            (crime['location']?.toString().toLowerCase() ?? '')
                .contains(query.toLowerCase());
        return matchesType && matchesSearch;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🔍 Crime Search'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: searchController,
              onChanged: filterCrimes,
              decoration: InputDecoration(
                hintText: 'Search by keyword or location...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          searchController.clear();
                          filterCrimes('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
            ),
          ),

          // Type filter chips
          SizedBox(
            height: 45,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: crimeTypes.length,
              itemBuilder: (context, index) {
                final type = crimeTypes[index];
                final isSelected = selectedType == type;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(type == 'All' ? 'All' : type),
                    selected: isSelected,
                    selectedColor: Colors.red[300],
                    onSelected: (selected) {
                      setState(() => selectedType = type);
                      filterCrimes(searchController.text);
                    },
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 8),

          // Results count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  '${filteredCrimes.length} results',
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: loadData,
                ),
              ],
            ),
          ),

          // Crime list
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredCrimes.isEmpty
                    ? const Center(
                        child: Text('No crimes found', style: TextStyle(fontSize: 16)))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        itemCount: filteredCrimes.length,
                        itemBuilder: (context, index) {
                          final crime = filteredCrimes[index];
                          return CrimeCard(crime: crime);
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

class CrimeCard extends StatelessWidget {
  final Map<String, dynamic> crime;

  const CrimeCard({super.key, required this.crime});

  Color getTypeColor(String? type) {
    switch (type) {
      case 'rape': return Colors.red;
      case 'murder': return Colors.black;
      case 'robbery': case 'theft': return Colors.orange;
      case 'assault': return Colors.deepOrange;
      case 'kidnapping': return Colors.purple;
      case 'fraud': case 'cybercrime': return Colors.blue;
      case 'drugs': return Colors.green;
      case 'terrorism': return Colors.brown;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final type = crime['type'] ?? 'unknown';
    final headline = crime['headline'] ?? 'No headline';
    final location = crime['location'] ?? 'Unknown';
    final source = crime['source'] ?? '';
    final published = crime['published'] ?? '';

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Type badge + source
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: getTypeColor(type),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    type.toUpperCase(),
                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 8),
                if (location != 'unknown' && location.isNotEmpty)
                  Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                Text(location, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                const Spacer(),
                Text(source, style: TextStyle(color: Colors.grey[500], fontSize: 11)),
              ],
            ),
            const SizedBox(height: 8),

            // Headline
            Text(
              headline,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),

            // Date
            if (published.isNotEmpty)
              Text(
                published.substring(0, 10),
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
              ),
          ],
        ),
      ),
    );
  }
}