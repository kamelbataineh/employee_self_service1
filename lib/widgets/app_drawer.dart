import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer>
    with SingleTickerProviderStateMixin {
  bool isChangingLang = false;

  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );

    _scaleAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> changeLanguage(Locale locale) async {
    setState(() => isChangingLang = true);

    _controller.forward();

    await context.setLocale(locale);

    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      Navigator.pop(context);

      _controller.reverse();
      setState(() => isChangingLang = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Drawer(
          child: Column(
            children: [
              /// HEADER
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.indigo, Colors.blue],
                  ),
                ),
                child: const Column(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.business, color: Colors.indigo),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "ESS SYSTEM",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              /// SETTINGS
              ListTile(
                leading: const Icon(Icons.settings),
                title: Text("settings".tr()),
                onTap: () {},
              ),

              /// LANGUAGE
              ListTile(
                leading: const Icon(Icons.language),
                title: Text("language".tr()),
                trailing: PopupMenuButton<Locale>(
                  icon: const Icon(Icons.arrow_drop_down),
                  onSelected: (Locale locale) {
                    changeLanguage(locale);
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(
                      value: Locale('ar', 'SA'),
                      child: Text("🇯🇴 العربية"),
                    ),
                    PopupMenuItem(
                      value: Locale('en', 'US'),
                      child: Text("🇺🇸 English"),
                    ),
                    PopupMenuItem(
                      value: Locale('fr', 'FR'),
                      child: Text("🇫🇷 Français"),
                    ),
                  ],
                ),
              ),

              /// SUPPORT
              ListTile(
                leading: const Icon(Icons.support_agent),
                title: Text("support".tr()),
                onTap: () {},
              ),

              const Spacer(),

              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  "v1.0.0",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ],
          ),
        ),

        /// 🔥 LOADING OVERLAY (ANIMATED)
        if (isChangingLang)
          FadeTransition(
            opacity: _fadeAnimation,
            child: Container(
              color: Colors.black54,
              child: Center(
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: Colors.white),
                      SizedBox(height: 12),
                      Text(
                        "Changing Language...",
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}