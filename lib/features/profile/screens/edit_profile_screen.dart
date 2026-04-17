import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/mock_data.dart';
import '../../../shared/widgets/app_button.dart';
import '../widgets/animated_form_field.dart';
import '../widgets/chip_selector.dart';
import '../widgets/profile_avatar_picker.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();

  late TextEditingController _usernameCtrl;
  late TextEditingController _fullNameCtrl;
  late TextEditingController _bioCtrl;
  late TextEditingController _locationCtrl;

  String? _travelStyle;
  Set<String> _selectedLanguages = {};
  Set<String> _selectedInterests = {};
  DateTime? _birthDate;
  bool _isSaving = false;
  bool _saved = false;

  static const List<String> _travelStyles = [
    'Solo', 'Couple', 'Group', 'Family'
  ];

  static const List<String> _allLanguages = [
    'Malayalam', 'Tamil', 'Hindi', 'Telugu',
    'Kannada', 'Sanskrit', 'Arabic', 'Punjabi',
    'Bengali', 'Marathi', 'Gujarati', 'English',
  ];

  static const List<String> _allInterests = [
    'Adventure', 'Exploring', 'Hiking', 'Beaches',
    'Mountains', 'Road Trips', 'Photography', 'Culture',
    'Spirituality', 'City Trips', 'Solo Travels', 'Luxury Travel',
    'Budget Travel', 'Wildlife', 'Cuisine', 'Nomad Life',
  ];

  @override
  void initState() {
    super.initState();
    final user = MockData.currentUser;
    _usernameCtrl = TextEditingController(text: user.username);
    _fullNameCtrl = TextEditingController(text: user.fullName);
    _bioCtrl = TextEditingController(text: user.bio ?? '');
    _locationCtrl = TextEditingController(text: user.location ?? '');
    _travelStyle = user.travelStyle;
    _selectedLanguages = Set.from(user.languages);
    _selectedInterests = Set.from(user.interests);
    _birthDate = DateTime(2000, 10, 14);
  }

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _fullNameCtrl.dispose();
    _bioCtrl.dispose();
    _locationCtrl.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;
    setState(() {
      _isSaving = false;
      _saved = true;
    });
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) context.pop();
  }

  String _formatDate(DateTime d) =>
      '${_month(d.month)} ${d.day}, ${d.year}';

  String _month(int m) => const [
        '', 'January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December'
      ][m];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: Form(
        key: _formKey,
        child: ListView(
          controller: _scrollController,
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
          children: [
            const SizedBox(height: 16),

            // Avatar
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOut,
              builder: (_, v, child) => Opacity(
                opacity: v,
                child: Transform.scale(scale: 0.8 + 0.2 * v, child: child),
              ),
              child: ProfileAvatarPicker(
                currentUrl: MockData.currentUser.avatarUrl,
                name: MockData.currentUser.fullName,
                onPickImage: _showImagePickerSheet,
              ),
            ),

            const SizedBox(height: 32),

            // ── Basic Info ─────────────────────────────────────────────
            _SectionLabel(label: 'Basic Info', index: 0),
            const SizedBox(height: 16),

            AnimatedFormField(
              label: 'Username',
              hint: '@username',
              controller: _usernameCtrl,
              index: 1,
              prefixIcon: const Padding(
                padding: EdgeInsets.only(left: 12, right: 4),
                child: Icon(Icons.alternate_email_rounded,
                    size: 18, color: AppColors.textSecondary),
              ),
              validator: (v) =>
                  v == null || v.isEmpty ? 'Username is required' : null,
            ),
            const SizedBox(height: 16),

            AnimatedFormField(
              label: 'Full Name',
              hint: 'Your full name',
              controller: _fullNameCtrl,
              index: 2,
              validator: (v) =>
                  v == null || v.isEmpty ? 'Name is required' : null,
            ),
            const SizedBox(height: 16),

            AnimatedFormField(
              label: 'Bio',
              hint: 'Tell us about yourself...',
              controller: _bioCtrl,
              maxLines: 3,
              index: 3,
            ),
            const SizedBox(height: 16),

            // Location
            AnimatedFormField(
              label: 'Location',
              hint: 'City, State',
              controller: _locationCtrl,
              readOnly: true,
              onTap: _showLocationPicker,
              index: 4,
              suffixIcon: const Padding(
                padding: EdgeInsets.only(right: 12),
                child: Icon(Icons.location_on_outlined,
                    size: 18, color: AppColors.primary),
              ),
            ),
            const SizedBox(height: 16),

            // Date of Birth
            AnimatedFormField(
              label: 'Date of Birth',
              hint: 'Select date',
              initialValue:
                  _birthDate != null ? _formatDate(_birthDate!) : '',
              readOnly: true,
              onTap: _showDatePicker,
              index: 5,
              suffixIcon: const Padding(
                padding: EdgeInsets.only(right: 12),
                child: Icon(Icons.calendar_today_outlined,
                    size: 18, color: AppColors.primary),
              ),
            ),

            const SizedBox(height: 32),

            // ── Travel Style ───────────────────────────────────────────
            _SectionLabel(label: 'Travel Style', index: 6),
            const SizedBox(height: 14),
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOut,
              builder: (_, v, child) =>
                  Opacity(opacity: v, child: child),
              child: SingleChipSelector(
                options: _travelStyles,
                selected: _travelStyle,
                onSelect: (val) => setState(() => _travelStyle = val),
              ),
            ),

            const SizedBox(height: 28),

            // ── Languages ─────────────────────────────────────────────
            _SectionLabel(label: 'Languages', index: 7),
            const SizedBox(height: 14),
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOut,
              builder: (_, v, child) =>
                  Opacity(opacity: v, child: child),
              child: MultiChipSelector(
                options: _allLanguages,
                selected: _selectedLanguages,
                onToggle: (lang) => setState(() {
                  _selectedLanguages.contains(lang)
                      ? _selectedLanguages.remove(lang)
                      : _selectedLanguages.add(lang);
                }),
              ),
            ),

            const SizedBox(height: 28),

            // ── Interests ─────────────────────────────────────────────
            _SectionLabel(label: 'Travel Interests', index: 8),
            const SizedBox(height: 14),
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOut,
              builder: (_, v, child) =>
                  Opacity(opacity: v, child: child),
              child: MultiChipSelector(
                options: _allInterests,
                selected: _selectedInterests,
                onToggle: (interest) => setState(() {
                  _selectedInterests.contains(interest)
                      ? _selectedInterests.remove(interest)
                      : _selectedInterests.add(interest);
                }),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),

      // Sticky save bar
      bottomNavigationBar: _SaveBar(
        isSaving: _isSaving,
        saved: _saved,
        onSave: _save,
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      titleSpacing: 0,
      leading: IconButton(
        icon: const Icon(Icons.close_rounded, color: AppColors.textPrimary),
        onPressed: () => context.pop(),
      ),
      title: Text('Edit Profile', style: AppTextStyles.headlineMedium),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: AppColors.divider),
      ),
    );
  }

  // ── Pickers ───────────────────────────────────────────────────────────────

  void _showImagePickerSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _ImagePickerSheet(),
    );
  }

  void _showLocationPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _LocationPickerSheet(
        current: _locationCtrl.text,
        onSelect: (loc) {
          setState(() => _locationCtrl.text = loc);
        },
      ),
    );
  }

  void _showDatePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _DatePickerSheet(
        initial: _birthDate ?? DateTime(2000),
        onSelect: (date) {
          setState(() => _birthDate = date);
        },
      ),
    );
  }
}

// ── Section Label ─────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  final int index;

  const _SectionLabel({required this.label, required this.index});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 300 + index * 40),
      curve: Curves.easeOut,
      builder: (_, v, child) => Opacity(
        opacity: v,
        child: Transform.translate(
            offset: Offset(-10 * (1 - v), 0), child: child),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 18,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Text(label, style: AppTextStyles.headlineSmall),
        ],
      ),
    );
  }
}

// ── Save Bar ──────────────────────────────────────────────────────────────────

class _SaveBar extends StatelessWidget {
  final bool isSaving;
  final bool saved;
  final VoidCallback onSave;

  const _SaveBar({
    required this.isSaving,
    required this.saved,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 16,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: saved
                ? _SavedConfirmation()
                : AppButton(
                    label: 'Save Changes',
                    isLoading: isSaving,
                    onPressed: isSaving ? null : onSave,
                    icon: Icons.check_rounded,
                  ),
          ),
        ),
      ),
    );
  }
}

class _SavedConfirmation extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      decoration: BoxDecoration(
        color: AppColors.success.withAlpha(20),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.success.withAlpha(80)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle_rounded,
              color: AppColors.success, size: 20),
          const SizedBox(width: 8),
          Text(
            'Profile saved!',
            style: AppTextStyles.labelLarge.copyWith(
              color: AppColors.success,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Image Picker Sheet ────────────────────────────────────────────────────────

class _ImagePickerSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Text('Change Photo', style: AppTextStyles.headlineMedium),
          const SizedBox(height: 20),
          _PickerOption(
            icon: Icons.camera_alt_outlined,
            label: 'Take Photo',
            onTap: () => Navigator.pop(context),
          ),
          const SizedBox(height: 12),
          _PickerOption(
            icon: Icons.photo_library_outlined,
            label: 'Choose from Gallery',
            onTap: () => Navigator.pop(context),
          ),
          const SizedBox(height: 12),
          _PickerOption(
            icon: Icons.delete_outline_rounded,
            label: 'Remove Photo',
            color: AppColors.error,
            onTap: () => Navigator.pop(context),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _PickerOption extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final VoidCallback onTap;

  const _PickerOption({
    required this.icon,
    required this.label,
    this.color,
    required this.onTap,
  });

  @override
  State<_PickerOption> createState() => _PickerOptionState();
}

class _PickerOptionState extends State<_PickerOption> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? AppColors.textPrimary;
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: _pressed
                ? AppColors.surfaceVariant
                : AppColors.background,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: (widget.color ?? AppColors.primary).withAlpha(15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(widget.icon, size: 20, color: color),
              ),
              const SizedBox(width: 14),
              Text(widget.label,
                  style: AppTextStyles.titleMedium.copyWith(color: color)),
              const Spacer(),
              Icon(Icons.chevron_right_rounded,
                  size: 18, color: AppColors.textHint),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Location Picker Sheet ─────────────────────────────────────────────────────

class _LocationPickerSheet extends StatefulWidget {
  final String current;
  final ValueChanged<String> onSelect;

  const _LocationPickerSheet({
    required this.current,
    required this.onSelect,
  });

  @override
  State<_LocationPickerSheet> createState() => _LocationPickerSheetState();
}

class _LocationPickerSheetState extends State<_LocationPickerSheet> {
  final _searchCtrl = TextEditingController();
  final List<String> _allLocations = [
    'Mumbai, Maharashtra',
    'Delhi, NCR',
    'Bangalore, Karnataka',
    'Chennai, Tamil Nadu',
    'Kochi, Kerala',
    'Vadodara, Gujarat',
    'Pune, Maharashtra',
    'Hyderabad, Telangana',
    'Kolkata, West Bengal',
    'Jaipur, Rajasthan',
    'Ahmedabad, Gujarat',
    'Thiruvananthapuram, Kerala',
  ];
  List<String> _filtered = [];

  @override
  void initState() {
    super.initState();
    _filtered = _allLocations;
    _searchCtrl.addListener(() {
      final q = _searchCtrl.text.toLowerCase();
      setState(() {
        _filtered = q.isEmpty
            ? _allLocations
            : _allLocations
                .where((l) => l.toLowerCase().contains(q))
                .toList();
      });
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle + title
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 12, bottom: 16),
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Text('Select Location',
                    style: AppTextStyles.headlineMedium),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded,
                      color: AppColors.textSecondary),
                ),
              ],
            ),
          ),

          // Search bar
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 14),
                  const Icon(Icons.search, color: AppColors.textHint),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _searchCtrl,
                      style: AppTextStyles.bodyMedium,
                      decoration: InputDecoration(
                        hintText: 'Search city...',
                        hintStyle: AppTextStyles.bodyMedium
                            .copyWith(color: AppColors.textHint),
                        border: InputBorder.none,
                        isDense: true,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Location list
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _filtered.length,
              separatorBuilder: (context, index) =>
                  const Divider(height: 1, color: AppColors.divider),
              itemBuilder: (context, index) {
                final loc = _filtered[index];
                final isSelected = loc == widget.current;
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    Icons.location_on_outlined,
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.textSecondary,
                  ),
                  title: Text(
                    loc,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textPrimary,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check_rounded,
                          color: AppColors.primary, size: 18)
                      : null,
                  onTap: () {
                    widget.onSelect(loc);
                    Navigator.pop(context);
                  },
                )
                    .animate(
                      delay: Duration(milliseconds: index * 30),
                    );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Extend Widget to support the .animate() call without flutter_animate extension
extension _WidgetAnimate on Widget {
  Widget animate({Duration delay = Duration.zero}) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 250),
      builder: (_, v, child) =>
          Opacity(opacity: v, child: child),
      child: this,
    );
  }
}

// ── Date Picker Sheet ─────────────────────────────────────────────────────────

class _DatePickerSheet extends StatefulWidget {
  final DateTime initial;
  final ValueChanged<DateTime> onSelect;

  const _DatePickerSheet({required this.initial, required this.onSelect});

  @override
  State<_DatePickerSheet> createState() => _DatePickerSheetState();
}

class _DatePickerSheetState extends State<_DatePickerSheet> {
  late DateTime _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.initial;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Text('Date of Birth', style: AppTextStyles.headlineMedium),
          const SizedBox(height: 20),

          // Native calendar picker
          SizedBox(
            height: 300,
            child: CalendarDatePicker(
              initialDate: _selected,
              firstDate: DateTime(1950),
              lastDate: DateTime.now().subtract(
                const Duration(days: 365 * 13),
              ),
              onDateChanged: (date) => setState(() => _selected = date),
            ),
          ),

          const SizedBox(height: 16),

          AppButton(
            label: 'Confirm',
            onPressed: () {
              widget.onSelect(_selected);
              Navigator.pop(context);
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
