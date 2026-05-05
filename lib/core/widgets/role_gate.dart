import 'package:flutter/material.dart';
import 'package:sahtek/core/services/storage_service.dart';

/// A simple role-based gate that shows [child] only when the current
/// user's role matches one of [allowedRoles]. While loading it shows a
/// progress indicator. If access is denied it shows an informative screen
/// with a button to go back to home ('/accueil').
class RoleGate extends StatefulWidget {
  final Widget child;
  final List<String> allowedRoles;

  const RoleGate({Key? key, required this.child, required this.allowedRoles})
    : super(key: key);

  @override
  State<RoleGate> createState() => _RoleGateState();
}

class _RoleGateState extends State<RoleGate> {
  String? _role;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadRole();
  }

  Future<void> _loadRole() async {
    final r = (await StorageService.getRole()) ?? '';
    setState(() {
      _role = r.toUpperCase();
      _loading = false;
    });
  }

  bool get _allowed {
    if (_role == null) return false;
    final normalized = _role!.toUpperCase();
    return widget.allowedRoles.map((e) => e.toUpperCase()).contains(normalized);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (!_allowed) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Access Denied'),
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: Colors.black87,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.lock_outline, size: 72, color: Colors.grey),
                const SizedBox(height: 16),
                const Text(
                  'You do not have permission to view this page.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.black87),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/accueil',
                    (r) => false,
                  ),
                  child: const Text('Go to Home'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return widget.child;
  }
}
