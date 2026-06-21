import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_decorations.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../utils/ui_helpers.dart';
import '../../widgets/app_header.dart';
import '../../widgets/detail_widgets.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final _api = ApiService();
  final _picker = ImagePicker();
  bool _uploading = false;
  String? _profileImageUrl;

  @override
  void initState() {
    super.initState();
    _profileImageUrl = AuthService().currentUser?.profileImageUrl;
  }

  Future<void> _pickAndUpload() async {
    final user = AuthService().currentUser;
    if (user == null) return;

    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (file == null || !mounted) return;

    setState(() => _uploading = true);
    try {
      final result = await _api.uploadFile('/uploads/users/${user.id}', file);
      final newPath = (result as Map<String, dynamic>)['path']?.toString();
      if (newPath != null && mounted) {
        setState(() => _profileImageUrl = ApiService.buildImageUrl(newPath));
        showSuccessSnackBar(context, 'Foto de perfil atualizada.');
      }
    } on ApiException catch (e) {
      if (mounted) showErrorSnackBar(context, e.message);
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService().currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppHeader(title: 'Meu perfil'),
      body: user == null
          ? Center(
              child: Text(
                'Faça login para ver seu perfil.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Foto de perfil
                  Center(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 52,
                          backgroundColor: AppColors.borderLight,
                          backgroundImage: _profileImageUrl != null
                              ? NetworkImage(_profileImageUrl!)
                              : null,
                          child: _profileImageUrl == null
                              ? Text(
                                  user.name.isNotEmpty
                                      ? user.name[0].toUpperCase()
                                      : '?',
                                  style: const TextStyle(
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textSecondary,
                                  ),
                                )
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: _uploading ? null : _pickAndUpload,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.background,
                                  width: 2,
                                ),
                              ),
                              child: _uploading
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Icon(
                                      Icons.camera_alt,
                                      size: 16,
                                      color: Colors.white,
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  DetailHeroCard(
                    title: user.name,
                    subtitle: user.email,
                    icon: Icons.person_rounded,
                    badges: [
                      DetailBadge(label: user.userType),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: AppDecorations.borderRadiusLg,
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: Column(
                      children: [
                        DetailInfoRow(
                          icon: Icons.email_outlined,
                          label: 'E-mail',
                          value: user.email,
                        ),
                        DetailInfoRow(
                          icon: Icons.badge_outlined,
                          label: 'Tipo de conta',
                          value: user.userType,
                        ),
                        if (user.createdAt != null)
                          DetailInfoRow(
                            icon: Icons.calendar_today_outlined,
                            label: 'Membro desde',
                            value: user.createdAt.toString(),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
