import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

import '../chat/chat_page.dart';

class MatchPage extends StatefulWidget {
  @override
  _MatchPageState createState() => _MatchPageState();
}

class _MatchPageState extends State<MatchPage> {
  List<Map<String, dynamic>> matches = [];
  bool _isLoading = true;

  final String baseUrl = 'http://192.168.0.102:8080/api/matches'; // Ganti dengan IP backend-mu

  @override
  void initState() {
    super.initState();
    _loadMatches();
  }

  Future<void> _loadMatches() async {
    setState(() {
      _isLoading = true;
    });

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final userId = currentUser.uid;
    final url = Uri.parse('$baseUrl/user/$userId');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        final List<Map<String, dynamic>> loadedMatches = data.map((item) {
          final users = List<String>.from(item['users'] ?? []);
          final userNames = List<String>.from(item['userNames'] ?? []);
          final userPhotos = List<String>.from(item['userPhotos'] ?? []);

          final otherIndex = users.indexOf(userId) == 0 ? 1 : 0;

          return {
            'matchId': item['id'],
            'name': userNames.isNotEmpty ? userNames[otherIndex] : 'Unknown',
            'image': userPhotos.isNotEmpty ? userPhotos[otherIndex] : '',
            'message': item['lastMessage'] ?? 'Say hi to your new match!',
            'timestamp': item['timestamp'],
            'otherUserId': users[otherIndex],
          };
        }).toList();

        setState(() {
          matches = loadedMatches;
        });
      } else {
        print('Failed to load matches: ${response.body}');
      }
    } catch (e) {
      print('Error fetching matches: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _onRefresh() async {
    await _loadMatches();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/backgroundHomepageCatchU.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              automaticallyImplyLeading: false,
              toolbarHeight: 80,
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 10),
                  Text(
                    'MatchU',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Perfect match with you!',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _isLoading
                  ? Center(
                child: CircularProgressIndicator(
                  color: Color(0xFFFF426D),
                ),
              )
                  : matches.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'No matches yet',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Keep swiping to find your match!',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              )
                  : RefreshIndicator(
                onRefresh: _onRefresh,
                color: const Color(0xFFFF426D),
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  itemCount: matches.length,
                  itemBuilder: (context, index) {
                    final match = matches[index];
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: BackdropFilter(
                        filter:
                        ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                        child: Container(
                          margin: EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(22),
                          ),
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChatPage(
                                    matchId: match['matchId'],
                                    otherUserId:
                                    match['otherUserId'],
                                    otherUserName: match['name'],
                                    otherUserImage:
                                    match['image'] ?? '',
                                  ),
                                ),
                              );
                            },
                            child: Padding(
                              padding: EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius:
                                    BorderRadius.circular(10),
                                    child: match['image'] != null &&
                                        match['image'].isNotEmpty
                                        ? Image.network(
                                      match['image'],
                                      width: 70,
                                      height: 70,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context,
                                          error, stackTrace) {
                                        return Container(
                                          width: 70,
                                          height: 70,
                                          color:
                                          Colors.grey[300],
                                          child: Icon(
                                            Icons.person,
                                            color: Colors.grey,
                                          ),
                                        );
                                      },
                                    )
                                        : Container(
                                      width: 70,
                                      height: 70,
                                      color: Colors.grey[300],
                                      child: Icon(
                                        Icons.person,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          match['name'] ?? 'Unknown',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight:
                                            FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          match['message'] ??
                                              'Say hi to your new match!',
                                          style: TextStyle(
                                            color: Colors.grey[700],
                                            fontSize: 14,
                                          ),
                                          maxLines: 1,
                                          overflow:
                                          TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    Icons.chevron_right,
                                    color: Colors.grey,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
