import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/auth/providers/auth_provider.dart';

class NotificationService {
  static final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  static Future<void> initialize() async {
    // Request permission
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      if (kDebugMode) {
        print('User granted permission');
      }
      
      // Get token
      String? token = await _fcm.getToken();
      if (token != null) {
        await _saveToken(token);
      }

      // Listen for token refreshes
      _fcm.onTokenRefresh.listen((newToken) async {
        await _saveToken(newToken);
      });

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        if (kDebugMode) {
          print('Got a message whilst in the foreground!');
          print('Message data: ${message.data}');
        }

        if (message.notification != null) {
          if (kDebugMode) {
            print('Message also contained a notification: ${message.notification}');
          }
        }
      });
    } else {
      if (kDebugMode) {
        print('User declined or has not accepted permission');
      }
    }
  }

  static Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('fcm_token', token);
    
    // We will register it with the backend when the user is logged in
    if (kDebugMode) {
      print('FCM Token: $token');
    }
  }

  static Future<void> registerTokenWithBackend(String baseUrl, String authToken) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('fcm_token');
    
    if (token == null) return;

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/user/register-fcm-token'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode({'token': token}),
      );

      if (response.statusCode == 200) {
        if (kDebugMode) {
          print('FCM Token registered with backend');
        }
      } else {
        if (kDebugMode) {
          print('Failed to register FCM token: ${response.body}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error registering FCM token: $e');
      }
    }
  }
}
