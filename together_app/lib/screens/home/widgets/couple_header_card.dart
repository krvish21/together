import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../constants/app_theme.dart';
import '../../../providers/together_state.dart';

class CoupleHeaderCard extends StatelessWidget {
  const CoupleHeaderCard({super.key});

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<TogetherState>(context);
    final couple = state.couple;
    if (couple == null) return const SizedBox.shrink();

    final isP1 = state.myRole == 'partner1';
    final p1Name = couple.partner1Name;
    final p2Name = couple.partner2Name ?? 'Invite Partner';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppTheme.romanticGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryRose.withOpacity(0.3),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Partner Switcher & Code Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Space Code Pill
              GestureDetector(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: couple.spaceCode));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Space code ${couple.spaceCode} copied!')),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.22),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.copy_rounded, color: Colors.white, size: 14),
                      const SizedBox(width: 5),
                      Text(
                        couple.spaceCode,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Simulation Switch Role Pill
              GestureDetector(
                onTap: () => state.switchPartnerRole(),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.28),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.swap_horiz_rounded, color: Colors.white, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        'Switch: ${state.myDisplayName}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Avatars & Heart Center
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Partner 1 Avatar
              _buildAvatar(
                name: p1Name,
                isMe: isP1,
                isOnline: isP1 ? true : state.isPartnerOnline,
              ),
              const SizedBox(width: 16),
              // Floating Animated Heart
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text('❤️', style: TextStyle(fontSize: 22)),
                ),
              ),
              const SizedBox(width: 16),
              // Partner 2 Avatar
              _buildAvatar(
                name: p2Name,
                isMe: !isP1,
                isOnline: !isP1 ? true : state.isPartnerOnline,
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Names
          Text(
            '$p1Name & $p2Name',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),

          const SizedBox(height: 4),

          // Days Together & Status
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${couple.daysTogether} Days Together',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.95),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                width: 4,
                height: 4,
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              ),
              Text(
                couple.relationshipStatus,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.95),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar({required String name, required bool isMe, required bool isOnline}) {
    final initials = name.isNotEmpty ? name[0].toUpperCase() : '?';
    return Stack(
      children: [
        Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(
              color: isMe ? const Color(0xFFFFD166) : Colors.white,
              width: 3,
            ),
          ),
          child: Center(
            child: Text(
              initials,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: AppTheme.primaryRose,
              ),
            ),
          ),
        ),
        if (isOnline)
          Positioned(
            bottom: 2,
            right: 2,
            child: Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: const Color(0xFF06D6A0),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
      ],
    );
  }
}
