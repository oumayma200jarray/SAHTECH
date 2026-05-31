import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:sahtek/core/api/endpoint.dart';

const Color _primaryBlue = Color(0xFF0052FF);

const List<Map<String, String>> _reviewCategories = [
  {'value': 'GENERAL', 'label': 'Général'},
  {'value': 'UX', 'label': 'Expérience utilisateur'},
  {'value': 'PERFORMANCE', 'label': 'Performance'},
  {'value': 'BUG', 'label': 'Bug / Problème technique'},
  {'value': 'FEATURE_REQUEST', 'label': 'Suggestion de fonctionnalité'},
  {'value': 'SUPPORT', 'label': 'Support'},
  {'value': 'COMPLAINT', 'label': 'Réclamation'},
];

String _categoryLabel(String value) =>
    _reviewCategories.firstWhere(
      (c) => c['value'] == value,
      orElse: () => {'label': value},
    )['label']!;

class MyReviewsPage extends StatefulWidget {
  const MyReviewsPage({super.key});

  @override
  State<MyReviewsPage> createState() => _MyReviewsPageState();
}

class _MyReviewsPageState extends State<MyReviewsPage> {
  List<dynamic> _reviews = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await EndPoint.client.get(EndPoint.myReviews);
      final list = data is List
          ? data
          : (data is Map && data['data'] is List ? data['data'] : []);
      setState(() {
        _reviews = list;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceFirst('ApiException: ', '');
        _loading = false;
      });
    }
  }

  Future<void> _deleteReview(dynamic review) async {
    final confirmed = await _showDeleteConfirm();
    if (!confirmed) return;

    final id = review['id']?.toString() ?? '';
    try {
      await EndPoint.client.delete(EndPoint.deleteMyReview(id));
      setState(() => _reviews.removeWhere((r) => r['id']?.toString() == id));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Avis supprimé avec succès'),
            backgroundColor: Color(0xFF10B981),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('ApiException: ', '')),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  Future<bool> _showDeleteConfirm() async {
    return await showModalBottomSheet<bool>(
          context: context,
          backgroundColor: Colors.transparent,
          builder: (ctx) => Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: const Icon(
                    Icons.delete_outline_rounded,
                    color: Color(0xFFEF4444),
                    size: 26,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Supprimer cet avis ?',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0A0F1E),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Cette action est irréversible.',
                  style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 28),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(0, 48),
                          side: const BorderSide(color: Color(0xFFBFDBFE)),
                          shape: const StadiumBorder(),
                        ),
                        child: const Text(
                          'Annuler',
                          style: TextStyle(color: _primaryBlue, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(0, 48),
                          backgroundColor: const Color(0xFFFEF2F2),
                          elevation: 0,
                          shape: const StadiumBorder(),
                        ),
                        child: const Text(
                          'Supprimer',
                          style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ) ??
        false;
  }

  void _showSubmitSheet() {
    int rating = 5;
    String category = 'GENERAL';
    final textController = TextEditingController();
    bool submitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [Color(0xFF0052FF), Color(0xFF00A3FF)],
                        ),
                      ),
                      child: const Icon(Icons.star_rounded, color: Colors.white, size: 22),
                    ),
                    const SizedBox(width: 12),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Soumettre un avis',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0A0F1E),
                          ),
                        ),
                        Text(
                          'Partagez votre retour sur l\'application',
                          style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Star rating
                const Text(
                  'NOTE',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: List.generate(5, (i) {
                    final n = i + 1;
                    return GestureDetector(
                      onTap: () => setSheet(() => rating = n),
                      child: Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: Icon(
                          n <= rating ? Icons.star_rounded : Icons.star_outline_rounded,
                          size: 32,
                          color: n <= rating
                              ? const Color(0xFFF59E0B)
                              : const Color(0xFFE2E8F0),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 20),

                // Category
                const Text(
                  'CATÉGORIE',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: category,
                      isExpanded: true,
                      style: const TextStyle(fontSize: 14, color: Color(0xFF0A0F1E)),
                      onChanged: (v) {
                        if (v != null) setSheet(() => category = v);
                      },
                      items: _reviewCategories
                          .map((c) => DropdownMenuItem(
                                value: c['value'],
                                child: Text(c['label']!),
                              ))
                          .toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Comment
                const Text(
                  'COMMENTAIRE',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: textController,
                  maxLines: 4,
                  maxLength: 500,
                  style: const TextStyle(fontSize: 14, color: Color(0xFF0A0F1E)),
                  decoration: InputDecoration(
                    hintText: 'Partagez votre avis sur l\'application...',
                    hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                    filled: true,
                    fillColor: const Color(0xFFF1F5F9),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                  onChanged: (_) => setSheet(() {}),
                ),
                const SizedBox(height: 16),

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(ctx),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(0, 48),
                          side: const BorderSide(color: Color(0xFFBFDBFE)),
                          shape: const StadiumBorder(),
                        ),
                        child: const Text(
                          'Annuler',
                          style: TextStyle(color: _primaryBlue, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: submitting || textController.text.trim().isEmpty
                            ? null
                            : () async {
                                setSheet(() => submitting = true);
                                try {
                                  await EndPoint.client.post(
                                    EndPoint.createReview,
                                    body: {
                                      'rating': rating,
                                      'category': category,
                                      'text': textController.text.trim(),
                                    },
                                  );
                                  if (ctx.mounted) Navigator.pop(ctx);
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Avis soumis avec succès'),
                                        backgroundColor: Color(0xFF10B981),
                                      ),
                                    );
                                    _loadReviews();
                                  }
                                } catch (e) {
                                  setSheet(() => submitting = false);
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          e.toString().replaceFirst('ApiException: ', ''),
                                        ),
                                        backgroundColor: Colors.redAccent,
                                      ),
                                    );
                                  }
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(0, 48),
                          backgroundColor: _primaryBlue,
                          disabledBackgroundColor: _primaryBlue.withValues(alpha: 0.4),
                          shape: const StadiumBorder(),
                        ),
                        child: submitting
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Soumettre',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                              ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(dynamic raw) {
    if (raw == null) return '—';
    try {
      final dt = DateTime.parse(raw.toString()).toLocal();
      return '${dt.day.toString().padLeft(2, '0')} '
          '${_months[dt.month - 1]} '
          '${dt.year}';
    } catch (_) {
      return raw.toString();
    }
  }

  static const _months = [
    'jan.', 'fév.', 'mar.', 'avr.', 'mai', 'juin',
    'juil.', 'août', 'sep.', 'oct.', 'nov.', 'déc.',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left_2, color: _primaryBlue, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Mes avis',
          style: TextStyle(
            color: Color(0xFF0A0F1E),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: _primaryBlue, size: 22),
            onPressed: _loadReviews,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showSubmitSheet,
        backgroundColor: _primaryBlue,
        icon: const Icon(Icons.star_rounded, color: Colors.white),
        label: const Text(
          'Évaluer',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: _primaryBlue));
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.wifi_off_rounded, size: 48, color: Color(0xFFCBD5E1)),
              const SizedBox(height: 16),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF64748B), fontSize: 14),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loadReviews,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryBlue,
                  shape: const StadiumBorder(),
                ),
                child: const Text('Réessayer', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      );
    }

    if (_reviews.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: _primaryBlue.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.star_outline_rounded, size: 36, color: _primaryBlue),
              ),
              const SizedBox(height: 16),
              const Text(
                'Aucun avis soumis',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0A0F1E),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Appuyez sur "Évaluer" pour soumettre votre premier avis.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      color: _primaryBlue,
      onRefresh: _loadReviews,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
        itemCount: _reviews.length,
        itemBuilder: (context, index) => _ReviewCard(
          review: _reviews[index],
          formatDate: _formatDate,
          onDelete: () => _deleteReview(_reviews[index]),
        ),
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final dynamic review;
  final String Function(dynamic) formatDate;
  final VoidCallback onDelete;

  const _ReviewCard({
    required this.review,
    required this.formatDate,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final int rating = (review['rating'] as num?)?.toInt() ?? 0;
    final String category = review['category']?.toString() ?? '';
    final String text = review['text']?.toString() ?? '';
    final String date = formatDate(review['createdAt']);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: _primaryBlue.withValues(alpha: 0.07),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Avis du $date',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0A0F1E),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _categoryLabel(category),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: _primaryBlue,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(5, (i) {
                    final n = i + 1;
                    return Icon(
                      n <= rating ? Icons.star_rounded : Icons.star_outline_rounded,
                      size: 16,
                      color: n <= rating
                          ? const Color(0xFFF59E0B)
                          : const Color(0xFFE2E8F0),
                    );
                  }),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              text,
              style: const TextStyle(fontSize: 13, color: Color(0xFF64748B), height: 1.5),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 14),
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: onDelete,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.delete_outline_rounded, size: 15, color: Color(0xFFEF4444)),
                      SizedBox(width: 4),
                      Text(
                        'Supprimer',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFEF4444),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
