import 'package:flutter/material.dart';

class Conversation {
  final String id;
  final String name;
  final String lastMessage;
  final DateTime timestamp;
  final int unreadCount;
  final String avatarUrl;
  final bool isOnline;
  final bool isRead;

  Conversation({
    required this.id,
    required this.name,
    required this.lastMessage,
    required this.timestamp,
    required this.unreadCount,
    required this.avatarUrl,
    this.isOnline = false,
    this.isRead = false,
  });

  // Données de démonstration (Mock Data) conformes à l'image fournie
  static List<Conversation> mockConversations = [
    Conversation(
      id: "1",
      name: "Jean Dupont",
      lastMessage: "Bonjour docteur, j'ai fini mes...",
      timestamp: DateTime.now().subtract(const Duration(minutes: 54)),
      unreadCount: 2,
      avatarUrl: "https://i.pravatar.cc/150?u=jean",
      isOnline: true,
    ),
    Conversation(
      id: "2",
      name: "Amélie Laurent",
      lastMessage: "Le compte rendu de la séance d...",
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      unreadCount: 0,
      avatarUrl: "https://i.pravatar.cc/150?u=amelie",
      isRead: true,
    ),
    Conversation(
      id: "3",
      name: "Marc Lefebvre",
      lastMessage: "Merci pour les conseils, la douleu...",
      timestamp: DateTime.now().subtract(const Duration(days: 3)),
      unreadCount: 0,
      avatarUrl: "https://i.pravatar.cc/150?u=marc",
      isOnline: true,
      isRead: true,
    ),
    Conversation(
      id: "4",
      name: "Sophie Bernard",
      lastMessage: "Pouvez-vous décaler notre...",
      timestamp: DateTime.now().subtract(const Duration(days: 7)),
      unreadCount: 1,
      avatarUrl: "https://i.pravatar.cc/150?u=sophie",
    ),
  ];
}
