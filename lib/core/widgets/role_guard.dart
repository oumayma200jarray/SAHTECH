import 'package:flutter/material.dart';
import 'package:sahtek/core/services/storage_service.dart';

class RoleGuard extends StatefulWidget {
  final Widget child;
  final List<String> allowedRoles; // e.g. ['SPECIALIST','DOCTOR']

  const RoleGuard({
    required this.child,
    this.allowedRoles = const ['SPECIALIST', 'SPECIALISTE', 'DOCTOR'],
    Key? key,
  }) : super(key: key);

  @override
  State<RoleGuard> createState() => _RoleGuardState();
}

class _RoleGuardState extends State<RoleGuard> {
  bool _checking = true;
  bool _authorized = false;

  @override
  void initState() {
    super.initState();
    _checkRole();
  }

  Future<void> _checkRole() async {
    final role = await StorageService.getRole();
    final normalized = role?.toUpperCase() ?? '';
    final hasRole = widget.allowedRoles
        .map((r) => r.toUpperCase())
        .any(
          (allowed) => normalized == allowed || normalized.contains(allowed),
        );
    if (!mounted) return;
    setState(() {
      _authorized = hasRole;
      _checking = false;
    });

    if (!hasRole) {
      // Redirect to home after a short delay to allow this page to settle
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.pushReplacementNamed(context, '/accueil');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_checking) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (!_authorized) {
      // while redirecting show empty scaffold
      return const Scaffold();
    }

    return widget.child;
  }
}
