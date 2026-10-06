import 'package:flutter/material.dart';

import '../../theme/manager_colors.dart';
import '../../widgets/manager/settings_tile.dart';
import '../onboarding_screen.dart';
import 'manager_login_screen.dart';

class ManagerProfileScreen extends StatefulWidget {
  const ManagerProfileScreen({super.key});

  @override
  State<ManagerProfileScreen> createState() => _ManagerProfileScreenState();
}

class _ManagerProfileScreenState extends State<ManagerProfileScreen> {
  int _selectedTab = 0;
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;

  final List<String> _tabs = [
    'Account',
    'Preferences',
    'Payments',
    'Support',
  ];

  void _logout() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Manager Sign Out'),
        content: const Text('Do you want to sign out of the Manager Portal?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute<void>(
                  builder: (_) => const ManagerLoginScreen(),
                ),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ManagerColors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  void _switchToPlayerApp() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(
        builder: (_) => const OnboardingScreen(),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width =
            constraints.maxWidth > 430 ? 430.0 : constraints.maxWidth;

        return Align(
          alignment: Alignment.topCenter,
          child: SizedBox(
            width: width,
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfileHeader(),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSearch(),
                        const SizedBox(height: 14),
                        _buildTabs(),
                        const SizedBox(height: 18),

                        const Text(
                          'Account Settings',
                          style: TextStyle(
                            color: ManagerColors.navyDark,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 12),

                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: ManagerColors.border,
                            ),
                          ),
                          child: SettingsTile(
                            icon: Icons.person_outline_rounded,
                            iconColor: ManagerColors.blue,
                            iconBackground: ManagerColors.blueSoft,
                            title: 'Personal Information',
                            subtitle: 'Facility Manager • manager@gmail.com',
                            onTap: () {},
                          ),
                        ),
                        const SizedBox(height: 12),

                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: ManagerColors.border,
                            ),
                          ),
                          child: SettingsTile(
                            icon: Icons.sports_tennis_rounded,
                            iconColor: ManagerColors.green,
                            iconBackground: ManagerColors.greenSoft,
                            title: 'Facility Profile',
                            subtitle: 'Colombo Sports Centre • 4 Courts',
                            onTap: () {},
                          ),
                        ),
                        const SizedBox(height: 12),

                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: ManagerColors.border,
                            ),
                          ),
                          child: SettingsTile(
                            icon: Icons.payments_outlined,
                            iconColor: ManagerColors.orange,
                            iconBackground: ManagerColors.orangeSoft,
                            title: 'Payout & Merchant Account',
                            subtitle: 'Stripe Gateway Connected',
                            onTap: () {},
                            showDivider: false,
                          ),
                        ),

                        const SizedBox(height: 22),

                        const Text(
                          'Preferences',
                          style: TextStyle(
                            color: ManagerColors.navyDark,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 12),

                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: ManagerColors.border,
                            ),
                          ),
                          child: Column(
                            children: [
                              SettingsTile(
                                icon: Icons.notifications_none_rounded,
                                iconColor: ManagerColors.purple,
                                iconBackground: ManagerColors.purpleSoft,
                                title: 'Instant Booking Alerts',
                                subtitle: 'Push alerts for payments and flags',
                                trailing: _MiniSwitch(
                                  value: _notificationsEnabled,
                                  onChanged: (value) {
                                    setState(() {
                                      _notificationsEnabled = value;
                                    });
                                  },
                                ),
                              ),
                              SettingsTile(
                                icon: Icons.dark_mode_outlined,
                                iconColor: ManagerColors.cyan,
                                iconBackground: ManagerColors.cyanSoft,
                                title: 'Dark Mode',
                                subtitle: 'Theme preferences',
                                showDivider: false,
                                trailing: _MiniSwitch(
                                  value: _darkModeEnabled,
                                  onChanged: (value) {
                                    setState(() {
                                      _darkModeEnabled = value;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Switch & Sign Out buttons
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: OutlinedButton.icon(
                            onPressed: _switchToPlayerApp,
                            icon: const Icon(Icons.swap_horiz_rounded, size: 20),
                            label: const Text('Switch to Player App', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: ManagerColors.navy,
                              side: const BorderSide(color: ManagerColors.border, width: 1.5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: TextButton.icon(
                            onPressed: _logout,
                            icon: const Icon(Icons.logout_rounded, size: 20, color: ManagerColors.red),
                            label: const Text('Sign Out of Manager Portal', style: TextStyle(color: ManagerColors.red, fontSize: 14, fontWeight: FontWeight.w700)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
      color: ManagerColors.headerBackground,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Manager Profile',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 18),

          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  const CircleAvatar(
                    radius: 28,
                    backgroundColor: Color(0xFF4C7FAC),
                    child: Icon(
                      Icons.manage_accounts_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  Positioned(
                    right: -2,
                    bottom: -2,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: ManagerColors.headerBackground,
                          width: 1.5,
                        ),
                      ),
                      child: const Icon(
                        Icons.edit_outlined,
                        size: 11,
                        color: ManagerColors.navy,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Facility Manager',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'manager@gmail.com',
                      style: TextStyle(
                        color: Color(0xFFB7C9DB),
                        fontSize: 12.5,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF144F57),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.verified_rounded,
                            color: Color(0xFF52D39D),
                            size: 13,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Facility Manager',
                            style: TextStyle(
                              color: Color(0xFF6FE0AE),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          const Row(
            children: [
              Expanded(
                child: _StatCard(
                  value: '18',
                  label: "Today's",
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: _StatCard(
                  value: '4',
                  label: 'Pending',
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: _StatCard(
                  value: '2',
                  label: 'Maintenance',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearch() {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: ManagerColors.border),
      ),
      child: const TextField(
        style: TextStyle(
          color: ManagerColors.navyDark,
          fontSize: 13.5,
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 12),
          prefixIcon: Icon(
            Icons.search_rounded,
            size: 20,
            color: ManagerColors.mutedText,
          ),
          hintText: 'Search manager settings...',
          hintStyle: TextStyle(
            color: ManagerColors.mutedText,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildTabs() {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _tabs.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final selected = index == _selectedTab;

          return InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () {
              setState(() {
                _selectedTab = index;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected ? ManagerColors.navy : Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: selected ? ManagerColors.navy : ManagerColors.border,
                ),
              ),
              child: Text(
                _tabs[index],
                style: TextStyle(
                  color: selected ? Colors.white : ManagerColors.navyDark,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.value,
    required this.label,
  });

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: ManagerColors.headerCard,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFFBCD0E2),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniSwitch extends StatelessWidget {
  const _MiniSwitch({
    required this.value,
    required this.onChanged,
  });

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: 0.85,
      child: Switch(
        value: value,
        onChanged: onChanged,
        activeThumbColor: Colors.white,
        activeTrackColor: ManagerColors.green,
        inactiveThumbColor: Colors.white,
        inactiveTrackColor: const Color(0xFFD8E0E8),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}
