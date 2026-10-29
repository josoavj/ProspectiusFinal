import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class AuthPageShell extends StatelessWidget {
  final Widget form;
  final Widget? footer;
  final bool showBrandPanel;

  const AuthPageShell({
    super.key,
    required this.form,
    this.footer,
    this.showBrandPanel = true,
  });

  static Future<T?> pushRightPage<T>(
    BuildContext context,
    Widget page,
  ) {
    return Navigator.of(context).push<T>(
      PageRouteBuilder<T>(
        opaque: false,
        pageBuilder: (_, __, ___) => page,
        transitionsBuilder: (_, animation, __, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          );
          return FadeTransition(
            opacity: curved,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.04, 0),
                end: Offset.zero,
              ).animate(curved),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 350),
        reverseTransitionDuration: const Duration(milliseconds: 250),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: showBrandPanel ? null : Colors.transparent,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 820;
          final content = SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: isWide ? 56 : 24,
              vertical: 32,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  form,
                  if (footer != null) ...[
                    const SizedBox(height: 24),
                    footer!,
                  ],
                ],
              ),
            ),
          );

          if (!isWide) {
            return SafeArea(
              child: Column(
                children: [
                  _BrandHeader(compact: true),
                  Expanded(child: content),
                ],
              ),
            );
          }

          final rightPanel = Expanded(
            flex: 6,
            child: Material(
              color: Theme.of(context).scaffoldBackgroundColor,
              child: Center(child: content),
            ),
          );

          if (!showBrandPanel) {
            return Row(
              children: [
                const Expanded(flex: 5, child: SizedBox.shrink()),
                rightPanel,
              ],
            );
          }

          return Row(
            children: [
              const Expanded(flex: 5, child: _BrandPanel()),
              rightPanel,
            ],
          );
        },
      ),
    );
  }
}

class _BrandPanel extends StatelessWidget {
  const _BrandPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(56),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const _BrandHeader(),
              const SizedBox(height: 48),
              Text(
                'Pilotez vos opportunités.\nDéveloppez votre activité.',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      height: 1.1,
                    ),
              ),
              const SizedBox(height: 20),
              Text(
                'Une vision claire de vos prospects, de vos échanges et de vos résultats.',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.82),
                      height: 1.5,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BrandHeader extends StatelessWidget {
  final bool compact;

  const _BrandHeader({this.compact = false});

  @override
  Widget build(BuildContext context) {
    final logo = Image.asset(
      'assets/images/icon.png',
      height: compact ? 48 : 64,
      errorBuilder: (_, __, ___) => Icon(
        Icons.insights_rounded,
        size: compact ? 42 : 56,
        color: compact ? AppColors.azure : Colors.white,
      ),
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(borderRadius: BorderRadius.circular(14), child: logo),
        const SizedBox(width: 14),
        Text(
          'Prospectius',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: compact ? AppColors.azure : Colors.white,
                fontWeight: FontWeight.w800,
              ),
        ),
      ],
    );
  }
}

class AuthFormHeader extends StatelessWidget {
  final String eyebrow;
  final String title;
  final String subtitle;

  const AuthFormHeader({
    super.key,
    required this.eyebrow,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          eyebrow.toUpperCase(),
          style: TextStyle(
            color: colors.primary,
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.4,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          title,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: TextStyle(color: colors.onSurfaceVariant, height: 1.4),
        ),
      ],
    );
  }
}

class AuthTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final TextInputAction? textInputAction;

  const AuthTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType,
    this.obscureText = false,
    this.suffixIcon,
    this.validator,
    this.textInputAction,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      textInputAction: textInputAction,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        suffixIcon: suffixIcon,
      ),
    );
  }
}
