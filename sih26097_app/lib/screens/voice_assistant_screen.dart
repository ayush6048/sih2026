import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:math';
import 'profile_screen.dart';
import '../services/api_service.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  ChatMessage({required this.text, required this.isUser});
}

class VoiceAssistantScreen extends StatefulWidget {
  final Function(int)? onNavigate;
  const VoiceAssistantScreen({super.key, this.onNavigate});

  @override
  State<VoiceAssistantScreen> createState() => _VoiceAssistantScreenState();
}

class _VoiceAssistantScreenState extends State<VoiceAssistantScreen> {
  final List<ChatMessage> _messages = [];
  final ScrollController _scrollController = ScrollController();
  final ApiService _apiService = ApiService();
  late String _sessionId;
  
  final stt.SpeechToText _speechToText = stt.SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();
  bool _speechEnabled = false;

  bool _isListening = false;
  bool _isTyping = false;
  String _lastWords = '';
  String? _lastProcessedMessage;
  
  UserProfile? _currentProfile;
  bool _isProfileComplete = false;

  @override
  void initState() {
    super.initState();
    _sessionId = "session_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(1000)}";
    _initSpeech();
    _initTts();
    _addInitialMessages();
    _checkBackendHealth();
  }

  void _initTts() async {
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setPitch(1.0);
  }

  void _checkBackendHealth() async {
    bool isHealthy = await _apiService.checkHealth();
    if (!isHealthy && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Warning: Cannot reach backend server. Please check your connection.'),
          duration: Duration(seconds: 4),
        ),
      );
    }
  }

  Future<bool> _initSpeech() async {
    try {
      _speechEnabled = await _speechToText.initialize(
        onError: (SpeechRecognitionError error) {
          if (!mounted) return;
          final errorMsg = error.errorMsg.toLowerCase();
          if (errorMsg.contains('timeout') || errorMsg.contains('error_no_match') || errorMsg.contains('speech_timeout')) {
            _stopListeningCleanly();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("I didn't hear anything. Please tap the microphone and try again.")),
            );
          } else {
            setState(() {
              _isListening = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Speech error: ${error.errorMsg}')),
            );
          }
        },
        onStatus: (String status) {
          if (status == 'done' || status == 'notListening') {
            if (mounted && _isListening) {
              _stopListening();
            }
          }
        },
      );
      if (mounted) setState(() {});
      return _speechEnabled;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to initialize speech recognition.')),
        );
      }
      return false;
    }
  }

  void _stopListeningCleanly() {
    if (!mounted) return;
    
    setState(() {
      _isListening = false;
      _lastWords = '';
    });
    
    try {
      if (_speechToText.isListening) {
        _speechToText.stop();
      }
    } catch (e) {
      // ignore
    }
  }

  void _addInitialMessages() {
    String welcomeMsg = "Namaste! I can help you find suitable training and livelihood opportunities. Tell me a little about yourself, like your education or what you currently do.";
    _messages.add(ChatMessage(
        text: welcomeMsg,
        isUser: false));
    _flutterTts.speak(welcomeMsg);
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _startListening() async {
    if (_isListening) return; // Prevent multiple calls
    
    bool hasPermission = await _speechToText.hasPermission;
    if (!hasPermission) {
      _speechEnabled = await _initSpeech();
      hasPermission = await _speechToText.hasPermission;
    }

    if (!hasPermission || !_speechEnabled) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Microphone permission is required to use voice input.')),
        );
      }
      return;
    }

    if (!_speechToText.isAvailable) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Speech recognition is not available on this device.')),
        );
      }
      return;
    }

    if (mounted) {
      setState(() {
        _isListening = true;
      });
    }

    _lastWords = '';
    _lastProcessedMessage = null;
    await _flutterTts.stop();
    
    try {
      await _speechToText.listen(
        onResult: _onSpeechResult,
        listenOptions: stt.SpeechListenOptions(
          listenFor: const Duration(seconds: 30),
          pauseFor: const Duration(seconds: 5),
          cancelOnError: true,
          listenMode: stt.ListenMode.confirmation,
          partialResults: true,
        ),
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _isListening = false;
        });
      }
    }
  }

  void _stopListening() {
    if (!mounted || !_isListening) return;
    
    setState(() {
      _isListening = false;
    });
    
    try {
      if (_speechToText.isListening) {
        _speechToText.stop();
      }
    } catch (e) {
      // ignore
    }
      
    if (_lastWords.isNotEmpty) {
      final spokenText = _lastWords;
      _lastWords = '';
      _processUserMessage(spokenText);
    }
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    if (mounted) {
      setState(() {
        if (!_isTyping) {
          _lastWords = result.recognizedWords;
        }
      });
      if (result.finalResult && !_isTyping) {
        _stopListening();
      }
    }
  }

  void _handleMicTap() {
    if (_isTyping || _isProfileComplete) return;

    if (_isListening) {
      _stopListening();
    } else {
      _startListening();
    }
  }

  void _processUserMessage(String userMsg) async {
    final msg = userMsg.trim();
    if (msg.isEmpty) return;
    if (_isTyping) return;
    if (msg == _lastProcessedMessage) return;

    _lastProcessedMessage = msg;

    setState(() {
      _messages.add(ChatMessage(text: msg, isUser: true));
      _isTyping = true;

    });
    _scrollToBottom();

    try {
      final response = await _apiService.sendMessage(userMsg, _sessionId);
      
      if (mounted) {
        setState(() {
          _isTyping = false;
          _messages.add(ChatMessage(text: response.reply, isUser: false));
          
          _flutterTts.speak(response.reply);

          if (response.profile != null) {
            _currentProfile = response.profile;
          }
          
          if (response.isProfileComplete) {
            _isProfileComplete = true;
          }
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isTyping = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll("Exception: ", ""))),
        );
      }
    }
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = MediaQuery.of(context).size.width > 800;
    
    // Calculate progress based on non-null fields
    int filledFields = 0;
    if (_currentProfile != null) {
      if (_currentProfile!.education != null) filledFields++;
      if (_currentProfile!.occupation != null) filledFields++;
      if (_currentProfile!.skills.isNotEmpty) filledFields++;
      if (_currentProfile!.interests.isNotEmpty) filledFields++;
      if (_currentProfile!.location != null) filledFields++;
      if (_currentProfile!.careerGoal != null) filledFields++;
    }
    final double progress = filledFields / 6.0;

    return isDesktop 
        ? _buildDesktopLayout(theme, progress)
        : _buildMobileLayout(theme, progress);
  }

  Widget _buildDesktopLayout(ThemeData theme, double progress) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          flex: 3,
          child: Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withAlpha(50),
              border: Border(right: BorderSide(color: Colors.grey.shade300)),
            ),
            child: _buildProfilePanel(theme, progress),
          ),
        ),
        Expanded(
          flex: 7,
          child: _buildChatPanel(theme),
        ),
      ],
    );
  }

  Widget _buildProfilePanel(ThemeData theme, double progress) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Profile',
            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
          ),
          const SizedBox(height: 24),
          Text(
            'Conversation Progress: ${(progress * 100).toInt()}%',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: theme.colorScheme.primaryContainer,
            color: theme.colorScheme.primary,
            minHeight: 12,
            borderRadius: BorderRadius.circular(6),
          ),
          const SizedBox(height: 48),
          _buildProfileItem(theme, 'Education', _currentProfile?.education, Icons.school),
          _buildProfileItem(theme, 'Occupation', _currentProfile?.occupation, Icons.work),
          _buildProfileItem(theme, 'Skills', _currentProfile?.skills.isEmpty ?? true ? null : _currentProfile?.skills.join(', '), Icons.build),
          _buildProfileItem(theme, 'Interests', _currentProfile?.interests.isEmpty ?? true ? null : _currentProfile?.interests.join(', '), Icons.favorite),
          _buildProfileItem(theme, 'Location', _currentProfile?.location, Icons.location_on),
          _buildProfileItem(theme, 'Career Goal', _currentProfile?.careerGoal, Icons.flag),
          
          if (_isProfileComplete) ...[
            const SizedBox(height: 48),
            _buildProfileButton(theme),
          ]
        ],
      ),
    );
  }

  Widget _buildProfileItem(ThemeData theme, String label, String? value, IconData icon) {
    final hasValue = value != null && value.isNotEmpty;
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 28, color: hasValue ? theme.colorScheme.primary : Colors.grey.shade400),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: hasValue ? theme.colorScheme.onSurface : Colors.grey.shade500,
                  ),
                ),
                const SizedBox(height: 4),
                if (hasValue)
                  Text(value, style: theme.textTheme.bodyLarge)
                else
                  Text('Not provided yet', style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey.shade500, fontStyle: FontStyle.italic)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatPanel(ThemeData theme) {
    return Column(
      children: [
        if (_isProfileComplete)
           Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "Profile Complete!",
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.green),
            ),
          ),
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 48.0, vertical: 24.0),
            itemCount: _messages.length + (_isTyping ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == _messages.length) {
                return _buildTypingIndicator(theme);
              }
              return _buildMessageBubble(_messages[index], theme);
            },
          ),
        ),
        if (_isListening && _lastWords.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 8),
            child: Text(
              '$_lastWords...',
              style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.grey, fontSize: 18),
            ),
          ),
        _buildMicArea(theme),
      ],
    );
  }

  Widget _buildMobileLayout(ThemeData theme, double progress) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            _isProfileComplete ? "Profile Complete!" : "Gathering your profile information...",
            style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
          ),
        ),
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            itemCount: _messages.length + (_isTyping ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == _messages.length) {
                return _buildTypingIndicator(theme);
              }
              return _buildMessageBubble(_messages[index], theme);
            },
          ),
        ),
        if (_isListening && _lastWords.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Text(
              '$_lastWords...',
              style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.grey, fontSize: 16),
            ),
          ),
        if (!_isProfileComplete) _buildMicArea(theme),
        if (_isProfileComplete) _buildProfileButton(theme),
      ],
    );
  }

  Widget _buildMessageBubble(ChatMessage message, ThemeData theme) {
    final isUser = message.isUser;
    final isDesktop = MediaQuery.of(context).size.width > 800;
    
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16.0),
        padding: const EdgeInsets.all(16.0),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * (isDesktop ? 0.5 : 0.8)),
        decoration: BoxDecoration(
          color: isUser ? theme.colorScheme.primary : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 0),
            bottomRight: Radius.circular(isUser ? 0 : 16),
          ),
        ),
        child: Text(
          message.text,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: isUser ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface,
            fontWeight: FontWeight.w500,
            fontSize: isDesktop ? 18 : 16,
          ),
        ),
      ),
    );
  }

  Widget _buildTypingIndicator(ThemeData theme) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2.5),
            ),
            const SizedBox(width: 16),
            Text("AI is thinking...", style: theme.textTheme.bodyLarge),
          ],
        ),
      ),
    );
  }

  Widget _buildMicArea(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: _handleMicTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: EdgeInsets.all(_isListening ? 40.0 : 32.0),
              decoration: BoxDecoration(
                color: _isListening ? Colors.red : theme.colorScheme.primaryContainer,
                shape: BoxShape.circle,
                boxShadow: _isListening
                    ? [BoxShadow(color: Colors.red.withAlpha(100), blurRadius: 20, spreadRadius: 10)]
                    : [],
              ),
              child: Icon(
                _isTyping
                    ? Icons.hourglass_empty
                    : _isListening ? Icons.mic : Icons.mic_none,
                size: 48,
                color: _isTyping
                    ? theme.colorScheme.onSurface.withAlpha(100)
                    : _isListening ? Colors.white : theme.colorScheme.onPrimaryContainer,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _isTyping
                ? "Processing..."
                : _isListening ? "Listening..." : "Tap to Speak",
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: _isTyping
                  ? Colors.grey
                  : _isListening ? Colors.red : theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Tap the microphone and speak",
            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileButton(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        child: FilledButton(
          onPressed: () {
            if (widget.onNavigate != null) {
              widget.onNavigate!(4); // Switch to My Profile tab
            } else if (_currentProfile != null) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfileScreen(profile: _currentProfile!)),
              );
            }
          },
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 20),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: const Text("View My Livelihood Profile", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}

