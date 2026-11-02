import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_theme.dart';
import '../../constants/api_config.dart';
import '../../services/storage_service.dart';
import '../../providers/together_state.dart';

class JoinSpaceScreen extends StatefulWidget {
  const JoinSpaceScreen({super.key});

  @override
  State<JoinSpaceScreen> createState() => _JoinSpaceScreenState();
}

class _JoinSpaceScreenState extends State<JoinSpaceScreen> {
  final _codeController = TextEditingController();
  final _nameController = TextEditingController(text: 'Sam');
  bool _submitting = false;

  void _openServerConfig() {
    final controller = TextEditingController(text: ApiConfig.baseUrl);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Server Configuration'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter your Render URL (e.g. https://your-app.onrender.com) or local computer Wi-Fi IP (e.g. http://192.168.1.5:4000):',
              style: TextStyle(fontSize: 13, color: AppTheme.textMuted),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              decoration: const InputDecoration(hintText: 'https://together-api.onrender.com'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final nav = Navigator.of(ctx);
              ApiConfig.setCustomBaseUrl(controller.text);
              await StorageService.setServerUrl(controller.text);
              nav.pop();
              setState(() {});
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleJoin() async {
    final code = _codeController.text.trim().toUpperCase();
    final name = _nameController.text.trim();

    if (code.isEmpty || name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter both code and your name')),
      );
      return;
    }

    setState(() => _submitting = true);
    try {
      final state = Provider.of<TogetherState>(context, listen: false);
      await state.joinSpace(spaceCode: code, partner2Name: name);

      if (mounted) {
        Navigator.popUntil(context, (route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Join Couple Space'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Server Settings',
            onPressed: _openServerConfig,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Server Banner
              GestureDetector(
                onTap: _openServerConfig,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3EFFF),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2D9FF)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.dns_rounded, size: 16, color: AppTheme.accentPurple),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Server: ${ApiConfig.baseUrl}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.accentPurple),
                        ),
                      ),
                      const Text('Change', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.primaryRose)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Enter your partner\'s code',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppTheme.textDark),
              ),
              const SizedBox(height: 8),
              const Text(
                'Ask your partner for the 6-character space code displayed in their app.',
                style: TextStyle(fontSize: 14, color: AppTheme.textMuted),
              ),
              const SizedBox(height: 28),
              const Text('INVITE CODE', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.textMuted)),
              const SizedBox(height: 8),
              TextField(
                controller: _codeController,
                textCapitalization: TextCapitalization.characters,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, letterSpacing: 2),
                decoration: const InputDecoration(
                  hintText: 'e.g. LOVE-7489',
                  prefixIcon: Icon(Icons.key_rounded, color: AppTheme.primaryRose),
                ),
              ),
              const SizedBox(height: 24),
              const Text('YOUR NAME', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.textMuted)),
              const SizedBox(height: 8),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  hintText: 'Enter your name',
                  prefixIcon: Icon(Icons.person_outline_rounded, color: AppTheme.primaryRose),
                ),
              ),
              const SizedBox(height: 36),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitting ? null : _handleJoin,
                  child: _submitting
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Connect to Partner'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
