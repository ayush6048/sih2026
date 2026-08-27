import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'dart:math';
import 'profile_screen.dart';
import '../services/api_service.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  ChatMessage({required this.text, required this.isUser});
}

class VoiceAssistantScreen extends StatefulWidget {
  const VoiceAssistantScreen({super.key});

  @override
  State<VoiceAssistantScreen> createState() => _VoiceAssistantScreenState();
}

class _VoiceAssistantScreenState extends State<VoiceAssistantScreen> {
  final List<ChatMessage> _messages = [];
  final ScrollController _scrollController = ScrollController();
  final ApiService _apiService = ApiService();
  late String _sessionId;
  
  final stt.SpeechToText _speechToText = stt.SpeechToText();
  bool _speechEnabled = false;

  bool _isListening = false;
  bool _isTyping = false;
  String _lastWords = '';
  
  UserProfile? _currentProfile;
  bool _isProfileComplete = false;

  @override
  void initState() {
    super.initState();
    _sessionId = "session_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(1000)}";
    _initSpeech();
    _addInitialMessages();
    _checkBackendHealth();
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
          if (error.errorMsg == 'error_speech_timeout') {
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

  void _stopListeningCleanly() async {
    if (_speechToText.isListening) {
      await _speechToText.stop();
    }
    if (mounted) {
      setState(() {
        _isListening = false;
        _lastWords = '';
      });
    }
  }

  void _addInitialMessages() {
    _messages.add(ChatMessage(
        text: "Namaste! I can help you find suitable training and livelihood opportunities. Tell me a little about yourself, like your education or what you currently do.",
        isUser: false));
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
    if (!_speechEnabled) {
      bool initialized = await _initSpeech();
      if (!initialized) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Microphone permission is required to use voice input.')),
          );
        }
        return;
      }
    }

    if (!_speechToText.isAvailable) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Speech recognition is not available on this device.')),
        );
      }
      return;
    }

    _lastWords = '';
    
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
    
    if (mounted) {
      setState(() {
        _isListening = true;
      });
    }
  }

  void _stopListening() async {
    if (_speechToText.isListening) {
      await _speechToText.stop();
    }
    
    if (mounted) {
      setState(() {
        _isListening = false;
      });
      
      if (_lastWords.isNotEmpty) {
        final spokenText = _lastWords;
        _lastWords = '';
        _processUserMessage(spokenText);
      }
    }
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    if (mounted) {
      setState(() {
        _lastWords = result.recognizedWords;
      });
      if (result.finalResult) {
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
    setState(() {
      _messages.add(ChatMessage(text: userMsg, isUser: true));
      _isTyping = true;
    });
    _scrollToBottom();

    try {
      final response = await _apiService.sendMessage(userMsg, _sessionId);
      
      if (mounted) {
        setState(() {
          _isTyping = false;
          _messages.add(ChatMessage(text: response.reply, isUser: false));
          
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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
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

    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            const Text('AI Livelihood Assistant', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            Text(
              "Let's understand your skills and goals",
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
            ),
          ],
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4.0),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: theme.colorScheme.primaryContainer,
            color: theme.colorScheme.primary,
          ),
        ),
      ),
      body: Column(
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
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message, ThemeData theme) {
    final isUser = message.isUser;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12.0),
        padding: const EdgeInsets.all(16.0),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
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
          ),
        ),
      ),
    );
  }

  Widget _buildTypingIndicator(ThemeData theme) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12.0),
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
              height: 16,
              width: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 12),
            Text("AI is thinking...", style: theme.textTheme.bodyMedium),
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
              padding: EdgeInsets.all(_isListening ? 36.0 : 28.0),
              decoration: BoxDecoration(
                color: _isListening ? Colors.red : theme.colorScheme.primaryContainer,
                shape: BoxShape.circle,
                boxShadow: _isListening
                    ? [BoxShadow(color: Colors.red.withAlpha(100), blurRadius: 20, spreadRadius: 10)]
                    : [],
              ),
              child: Icon(
                _isListening ? Icons.mic : Icons.mic_none,
                size: 48,
                color: _isListening ? Colors.white : theme.colorScheme.onPrimaryContainer,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _isListening ? "Listening..." : "Tap to Speak",
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: _isListening ? Colors.red : theme.colorScheme.primary,
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
            if (_currentProfile != null) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfileScreen(profile: _currentProfile!)),
              );
            }
          },
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: const Text("View My Livelihood Profile", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}
