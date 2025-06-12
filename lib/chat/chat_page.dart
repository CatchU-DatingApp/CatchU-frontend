import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class ChatPage extends StatefulWidget {
  final String matchId;
  final String otherUserId;
  final String otherUserName;
  final String otherUserImage;

  ChatPage({
    required this.matchId,
    required this.otherUserId,
    required this.otherUserName,
    required this.otherUserImage,
  });

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final currentUser = FirebaseAuth.instance.currentUser;

  List<Map<String, dynamic>> _messages = [];
  Map<String, dynamic>? _otherUserProfile;
  bool _isLoadingMessages = true;
  bool _isLoadingProfile = true;




  @override
  void initState() {
    super.initState();
    _fetchMessages();
    _loadOtherUserProfile();
    _markMessagesAsRead();
  }
  String _getMessageText(dynamic messageData) {
    if (messageData == null) return '[No message]';

    if (messageData is String) {
      return messageData;
    } else if (messageData is Map<String, dynamic>) {
      return messageData['text'] ?? messageData['message'] ?? '[No message]';
    }

    return messageData.toString();
  }

  DateTime? _parseTimestamp(dynamic timestampData) {
    if (timestampData == null) return null;

    if (timestampData is String) {
      // ISO format string
      return DateTime.tryParse(timestampData);
    } else if (timestampData is Map<String, dynamic>) {
      // Firestore Timestamp object
      final seconds = timestampData['seconds'];
      final nanoseconds = timestampData['nanoseconds'] ?? 0;
      if (seconds != null) {
        return DateTime.fromMillisecondsSinceEpoch(
            (seconds * 1000) + (nanoseconds ~/ 1000000)
        );
      }
    } else if (timestampData is int) {
      // Milliseconds since epoch
      return DateTime.fromMillisecondsSinceEpoch(timestampData);
    }

    return null;
  }

  Future<void> _loadOtherUserProfile() async {
    try {
      final response = await http.get(
        Uri.parse('http://192.168.0.102:8080/chat/user/${widget.otherUserId}'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          setState(() {
            _otherUserProfile = data['data'];
            _isLoadingProfile = false;
          });
        }
      } else {
        throw Exception('Failed to load profile');
      }
    } catch (e) {
      print('Error loading profile: $e');
      setState(() => _isLoadingProfile = false);
    }
  }
  Future<void> _fetchMessages() async {
    setState(() => _isLoadingMessages = true);
    try {
      final response = await http.get(Uri.parse(
          'http://192.168.0.102:8080/chat/match/${widget.matchId}/messages'));

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body['success']) {
          setState(() {
            _messages = List<Map<String, dynamic>>.from(body['data']);
            _isLoadingMessages = false;
          });
          _scrollToBottom();
        }
      } else {
        throw Exception('Failed to load messages');
      }
    } catch (e) {
      print('Error loading messages: $e');
      setState(() => _isLoadingMessages = false);
    }
  }

  Future<void> _markMessagesAsRead() async {
    try {
      await http.put(
        Uri.parse(
            'http://192.168.0.102:8080/chat/match/${widget.matchId}/messages/read'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'currentUserId': currentUser?.uid,
          'otherUserId': widget.otherUserId,
        }),
      );
    } catch (e) {
      print('Error marking messages as read: $e');
    }
  }

  void _showProfile(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => DraggableScrollableSheet(
            initialChildSize: 0.9,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            builder:
                (_, controller) => Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(10),
                    ),
                  ),
                  child: Column(
                    children: [
                      // Drag handle
                      Container(
                        margin: EdgeInsets.only(top: 8),
                        width: 60,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      SizedBox(height: 6),
                      // Content
                      Expanded(
                        child:
                            _isLoadingProfile
                                ? Center(child: CircularProgressIndicator())
                                : _otherUserProfile == null
                                ? Center(child: Text('Failed to load profile'))
                                : SingleChildScrollView(
                                  controller: controller,
                                  child: Column(
                                    children: [
                                      // Profile Images Section
                                      Container(
                                        height:
                                            MediaQuery.of(context).size.height *
                                            0.5,
                                        child: Stack(
                                          children: [
                                            PageView.builder(
                                              itemCount:
                                                  List<String>.from(
                                                    _otherUserProfile?['photos'] ??
                                                        [],
                                                  ).length,
                                              itemBuilder: (context, index) {
                                                return Image.network(
                                                  List<String>.from(
                                                    _otherUserProfile?['photos'] ??
                                                        [],
                                                  )[index],
                                                  width: double.infinity,
                                                  height: double.infinity,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (
                                                    context,
                                                    error,
                                                    stackTrace,
                                                  ) {
                                                    return Container(
                                                      color: Colors.grey[300],
                                                      child: Icon(Icons.error),
                                                    );
                                                  },
                                                );
                                              },
                                            ),
                                            // Gradient overlay
                                            Positioned(
                                              bottom: 0,
                                              left: 0,
                                              right: 0,
                                              height: 200,
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    begin: Alignment.topCenter,
                                                    end: Alignment.bottomCenter,
                                                    colors: [
                                                      Colors.transparent,
                                                      Colors.black.withOpacity(
                                                        0.8,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                            // Basic info with location
                                            Positioned(
                                              left: 20,
                                              bottom: 30,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    '${_otherUserProfile?['nama'] ?? ''}, ${_otherUserProfile?['umur'] ?? ''}',
                                                    style: TextStyle(
                                                      fontSize: 32,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  SizedBox(height: 8),
                                                  Row(
                                                    children: [
                                                      Icon(
                                                        Icons.location_on,
                                                        size: 16,
                                                        color: Colors.white70,
                                                      ),
                                                      SizedBox(width: 4),
                                                      Text(
                                                        '0.1 km',
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          color: Colors.white70,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(height: 8),
                                                  Row(
                                                    children: [
                                                      Icon(
                                                        Icons.school,
                                                        size: 16,
                                                        color: Colors.white70,
                                                      ),
                                                      SizedBox(width: 4),
                                                      Text(
                                                        _otherUserProfile?['faculty'] ??
                                                            '',
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          color: Colors.white70,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      // Profile Info Section
                                      Container(
                                        color: Colors.white,
                                        padding: EdgeInsets.all(20),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            // About Me Section
                                            Text(
                                              'About Me',
                                              style: TextStyle(
                                                fontSize: 24,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFFFF426D),
                                              ),
                                            ),
                                            SizedBox(height: 12),
                                            Text(
                                              _otherUserProfile?['bio'] ?? '',
                                              style: TextStyle(
                                                fontSize: 16,
                                                height: 1.5,
                                                color: Colors.black87,
                                              ),
                                            ),
                                            SizedBox(height: 24),
                                            // Interests Section
                                            Text(
                                              'Interests',
                                              style: TextStyle(
                                                fontSize: 24,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFFFF426D),
                                              ),
                                            ),
                                            SizedBox(height: 12),
                                            Wrap(
                                              spacing: 8,
                                              runSpacing: 8,
                                              children:
                                                  List<String>.from(
                                                        _otherUserProfile?['interest'] ??
                                                            [],
                                                      )
                                                      .map(
                                                        (interest) => Container(
                                                          padding:
                                                              EdgeInsets.symmetric(
                                                                horizontal: 20,
                                                                vertical: 8,
                                                              ),
                                                          decoration: BoxDecoration(
                                                            color: Color(
                                                              0xFFFF426D,
                                                            ).withOpacity(0.1),
                                                            border: Border.all(
                                                              color: Color(
                                                                0xFFFF426D,
                                                              ),
                                                              width: 1,
                                                            ),
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  20,
                                                                ),
                                                          ),
                                                          child: Text(
                                                            interest,
                                                            style: TextStyle(
                                                              color: Color(
                                                                0xFFFF426D,
                                                              ),
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                            ),
                                                          ),
                                                        ),
                                                      )
                                                      .toList(),
                                            ),
                                            SizedBox(height: 24),
                                            // Social Media Section
                                            Column(
                                              children: [
                                                // Instagram Button
                                                _buildSocialButtonNew(
                                                  icon:
                                                      'assets/images/instagram.png',
                                                  username:
                                                      _otherUserProfile?['instagram']
                                                          ?.toString() ??
                                                      '',
                                                  isActive:
                                                      (_otherUserProfile?['instagram']
                                                                  ?.toString() ??
                                                              '')
                                                          .isNotEmpty,
                                                  onTap:
                                                      (_otherUserProfile?['instagram']
                                                                      ?.toString() ??
                                                                  '')
                                                              .isNotEmpty
                                                          ? () async {
                                                            final url =
                                                                'https://www.instagram.com/${_otherUserProfile?['instagram']}';
                                                            if (await canLaunch(
                                                              url,
                                                            )) {
                                                              await launch(url);
                                                            }
                                                          }
                                                          : null,
                                                ),
                                                SizedBox(height: 8),
                                                // Facebook Button
                                                _buildSocialButtonNew(
                                                  icon:
                                                      'assets/images/facebook.png',
                                                  username:
                                                      _otherUserProfile?['facebook']
                                                          ?.toString() ??
                                                      '',
                                                  isActive:
                                                      (_otherUserProfile?['facebook']
                                                                  ?.toString() ??
                                                              '')
                                                          .isNotEmpty,
                                                  onTap:
                                                      (_otherUserProfile?['facebook']
                                                                      ?.toString() ??
                                                                  '')
                                                              .isNotEmpty
                                                          ? () async {
                                                            final url =
                                                                'https://www.facebook.com/${_otherUserProfile?['facebook']}';
                                                            if (await canLaunch(
                                                              url,
                                                            )) {
                                                              await launch(url);
                                                            }
                                                          }
                                                          : null,
                                                ),
                                                SizedBox(height: 8),
                                                // Twitter/X Button
                                                _buildSocialButtonNew(
                                                  icon:
                                                      'assets/images/twitter.png',
                                                  username:
                                                      _otherUserProfile?['x']
                                                          ?.toString() ??
                                                      '',
                                                  isActive:
                                                      (_otherUserProfile?['x']
                                                                  ?.toString() ??
                                                              '')
                                                          .isNotEmpty,
                                                  onTap:
                                                      (_otherUserProfile?['x']
                                                                      ?.toString() ??
                                                                  '')
                                                              .isNotEmpty
                                                          ? () async {
                                                            final url =
                                                                'https://x.com/${_otherUserProfile?['x']}';
                                                            if (await canLaunch(
                                                              url,
                                                            )) {
                                                              await launch(url);
                                                            }
                                                          }
                                                          : null,
                                                ),
                                                SizedBox(height: 8),
                                                // WhatsApp Button
                                                _buildSocialButtonNew(
                                                  icon:
                                                      'assets/images/whatsapp.png',
                                                  username:
                                                      _otherUserProfile?['whatsapp']
                                                          ?.toString() ??
                                                      '',
                                                  isActive:
                                                      (_otherUserProfile?['whatsapp']
                                                                  ?.toString() ??
                                                              '')
                                                          .isNotEmpty,
                                                  onTap:
                                                      (_otherUserProfile?['whatsapp']
                                                                      ?.toString() ??
                                                                  '')
                                                              .isNotEmpty
                                                          ? () async {
                                                            final url =
                                                                'https://wa.me/${_otherUserProfile?['whatsapp']}';
                                                            if (await canLaunch(
                                                              url,
                                                            )) {
                                                              await launch(url);
                                                            }
                                                          }
                                                          : null,
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                      ),
                    ],
                  ),
                ),
          ),
    );
  }

  Widget _buildSocialButton({
    required String icon,
    required Color color,
    required VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Image.asset(icon, width: 24, height: 24, color: Colors.white),
      ),
    );
  }

  Widget _buildSocialButtonNew({
    required String icon,
    required String username,
    required bool isActive,
    required VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 48,
        decoration: BoxDecoration(
          color: isActive ? Color(0xFFFF426D) : Colors.grey,
          borderRadius: BorderRadius.circular(8),
        ),
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Image.asset(icon, width: 24, height: 24, color: Colors.white),
            if (username.isNotEmpty) ...[
              SizedBox(width: 12),
              Text(
                username,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty || currentUser == null) return;

    _messageController.clear();

    try {
      final response = await http.post(
        Uri.parse('http://192.168.0.102:8080/chat/match/${widget.matchId}/messages'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'senderId': currentUser!.uid,
          'receiverId': widget.otherUserId,
          'message': message,
          'type': 'text',
        }),
      );

      if (response.statusCode == 200) {
        _fetchMessages();
      } else {
        throw Exception('Failed to send message');
      }
    } catch (e) {
      print('Error sending message: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send message')),
      );
    }
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}.${time.minute.toString().padLeft(2, '0')}';
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          PreferredSize(
            preferredSize: Size.fromHeight(kToolbarHeight),
            child: Container(
              decoration: BoxDecoration(
                color: Color(0xFFFF426D),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: SafeArea(
                bottom: false,
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () => _showProfile(context),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundImage:
                                  widget.otherUserImage.isNotEmpty
                                      ? NetworkImage(widget.otherUserImage)
                                      : null,
                              child:
                                  widget.otherUserImage.isEmpty
                                      ? Icon(Icons.person, color: Colors.white)
                                      : null,
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    widget.otherUserName,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'Tap to view profile',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: _isLoadingMessages
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isMe = message['senderId'] == currentUser?.uid;

                // Fixed timestamp parsing
                DateTime? timestamp;
                final timestampData = message['timestamp'];

                if (timestampData != null) {
                  if (timestampData is String) {
                    // If it's a string (ISO format)
                    timestamp = DateTime.tryParse(timestampData);
                  } else if (timestampData is Map<String, dynamic>) {
                    // If it's Firestore Timestamp object
                    final seconds = timestampData['seconds'];
                    final nanoseconds = timestampData['nanoseconds'] ?? 0;
                    if (seconds != null) {
                      timestamp = DateTime.fromMillisecondsSinceEpoch(
                          (seconds * 1000) + (nanoseconds ~/ 1000000)
                      );
                    }
                  } else if (timestampData is int) {
                    // If it's milliseconds since epoch
                    timestamp = DateTime.fromMillisecondsSinceEpoch(timestampData);
                  }
                }

                final isRead = message['isRead'] ?? false;

                return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: EdgeInsets.only(
                      bottom: 8,
                      left: isMe ? 64 : 0,
                      right: isMe ? 0 : 64,
                    ),
                    child: Column(
                      crossAxisAlignment:
                      isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: isMe ? Color(0xFFFF426D) : Colors.grey[300],
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                              bottomLeft: isMe
                                  ? Radius.circular(20)
                                  : Radius.circular(5),
                              bottomRight: isMe
                                  ? Radius.circular(5)
                                  : Radius.circular(20),
                            ),
                          ),
                          child: Text(
                            _getMessageText(message['message']),
                            style: TextStyle(
                              color: isMe ? Colors.white : Colors.black87,
                            ),
                          ),
                        ),
                        if (isMe)
                          Padding(
                            padding: EdgeInsets.only(top: 4, right: 8),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  timestamp != null ? _formatTime(timestamp) : '',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                SizedBox(width: 4),
                                Icon(
                                  isRead ? Icons.done_all : Icons.done,
                                  size: 14,
                                  color: isRead ? Colors.blue : Colors.grey[600],
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  offset: Offset(0, -2),
                  blurRadius: 4,
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Color(0xFFFF426D),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: _sendMessage,
                    icon: Icon(Icons.send, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
