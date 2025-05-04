import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  Map<String, dynamic>? _otherUserProfile;
  bool _isLoadingProfile = true;

  @override
  void initState() {
    super.initState();
    _loadOtherUserProfile();
  }

  Future<void> _loadOtherUserProfile() async {
    try {
      final doc =
          await FirebaseFirestore.instance
              .collection('Users')
              .doc(widget.otherUserId)
              .get();

      if (mounted) {
        setState(() {
          _otherUserProfile = doc.data();
          _isLoadingProfile = false;
        });
      }
    } catch (e) {
      print('Error loading profile: $e');
      if (mounted) {
        setState(() {
          _isLoadingProfile = false;
        });
      }
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
                      top: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    children: [
                      // Drag handle
                      Container(
                        margin: EdgeInsets.only(top: 8),
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
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
                                                      _otherUserProfile?['Instagram'] !=
                                                              null
                                                          ? '@${_otherUserProfile?['Instagram']}'
                                                          : '',
                                                  isActive:
                                                      _otherUserProfile?['Instagram'] !=
                                                      null,
                                                  onTap:
                                                      _otherUserProfile?['Instagram'] !=
                                                              null
                                                          ? () async {
                                                            final url =
                                                                'https://instagram.com/${_otherUserProfile?['Instagram']}';
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
                                                      _otherUserProfile?['Facebook'] !=
                                                              null
                                                          ? '@${_otherUserProfile?['Facebook']}'
                                                          : '',
                                                  isActive:
                                                      _otherUserProfile?['Facebook'] !=
                                                      null,
                                                  onTap:
                                                      _otherUserProfile?['Facebook'] !=
                                                              null
                                                          ? () async {
                                                            final url =
                                                                'https://facebook.com/${_otherUserProfile?['Facebook']}';
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
                                                      _otherUserProfile?['Twitter'] !=
                                                              null
                                                          ? '@${_otherUserProfile?['Twitter']}'
                                                          : '',
                                                  isActive:
                                                      _otherUserProfile?['Twitter'] !=
                                                      null,
                                                  onTap:
                                                      _otherUserProfile?['Twitter'] !=
                                                              null
                                                          ? () async {
                                                            final url =
                                                                'https://twitter.com/${_otherUserProfile?['Twitter']}';
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
                                                      _otherUserProfile?['WhatsApp'] !=
                                                              null
                                                          ? '@${_otherUserProfile?['WhatsApp']}'
                                                          : '',
                                                  isActive:
                                                      _otherUserProfile?['WhatsApp'] !=
                                                      null,
                                                  onTap:
                                                      _otherUserProfile?['WhatsApp'] !=
                                                              null
                                                          ? () async {
                                                            final url =
                                                                'https://wa.me/${_otherUserProfile?['WhatsApp']}';
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

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final message = _messageController.text.trim();
    _messageController.clear();

    try {
      final matchRef = FirebaseFirestore.instance
          .collection('Matches')
          .doc(widget.matchId);

      await matchRef.collection('messages').add({
        'senderId': currentUser?.uid,
        'message': message,
        'timestamp': FieldValue.serverTimestamp(),
      });

      await matchRef.update({
        'lastMessage': message,
        'lastMessageTimestamp': FieldValue.serverTimestamp(),
      });

      _scrollToBottom();
    } catch (e) {
      print('Error sending message: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to send message')));
    }
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
      appBar: AppBar(
        backgroundColor: Color(0xFFFF426D),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: InkWell(
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
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance
                      .collection('Matches')
                      .doc(widget.matchId)
                      .collection('messages')
                      .orderBy('timestamp', descending: false)
                      .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error loading messages'));
                }

                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data!.docs;

                return ListView.builder(
                  controller: _scrollController,
                  padding: EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message =
                        messages[index].data() as Map<String, dynamic>;
                    final isMe = message['senderId'] == currentUser?.uid;

                    return Align(
                      alignment:
                          isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: EdgeInsets.only(
                          bottom: 8,
                          left: isMe ? 64 : 0,
                          right: isMe ? 0 : 64,
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: isMe ? Color(0xFFFF426D) : Colors.grey[300],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          message['message'] ?? '',
                          style: TextStyle(
                            color: isMe ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                    );
                  },
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
