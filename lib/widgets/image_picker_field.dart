import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../core/constants/app_colors.dart';

/// Widget reutilizável para selecionar imagem da galeria.
///
/// Exibe a imagem atual (via URL) ou um preview do arquivo selecionado.
/// [onChanged] é chamado com o XFile escolhido, ou null se o usuário remover.
class ImagePickerField extends StatefulWidget {
  final String? currentImageUrl;
  final void Function(XFile?) onChanged;
  final String label;
  final double previewHeight;

  const ImagePickerField({
    super.key,
    this.currentImageUrl,
    required this.onChanged,
    this.label = 'Imagem',
    this.previewHeight = 180,
  });

  @override
  State<ImagePickerField> createState() => _ImagePickerFieldState();
}

class _ImagePickerFieldState extends State<ImagePickerField> {
  final _picker = ImagePicker();
  Uint8List? _pickedBytes;

  Future<void> _pick() async {
    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (file == null) return;
    final bytes = await file.readAsBytes();
    setState(() => _pickedBytes = bytes);
    widget.onChanged(file);
  }

  void _remove() {
    setState(() => _pickedBytes = null);
    widget.onChanged(null);
  }

  @override
  Widget build(BuildContext context) {
    final hasPickedPreview = _pickedBytes != null;
    final hasCurrentUrl =
        widget.currentImageUrl != null && widget.currentImageUrl!.isNotEmpty;
    final showImage = hasPickedPreview || hasCurrentUrl;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
        ),
        const SizedBox(height: 8),
        Container(
          height: widget.previewHeight,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderLight),
          ),
          clipBehavior: Clip.antiAlias,
          child: showImage
              ? Stack(
                  fit: StackFit.expand,
                  children: [
                    hasPickedPreview
                        ? Image.memory(_pickedBytes!, fit: BoxFit.cover)
                        : Image.network(
                            widget.currentImageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => _Placeholder(
                              icon: Icons.broken_image_outlined,
                            ),
                          ),
                    // Barra inferior com botões
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Container(
                        color: Colors.black54,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 6,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            if (hasPickedPreview)
                              TextButton.icon(
                                onPressed: _remove,
                                icon: const Icon(Icons.close, size: 16),
                                label: const Text('Remover'),
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                  ),
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                              ),
                            TextButton.icon(
                              onPressed: _pick,
                              icon: const Icon(Icons.photo_library_outlined,
                                  size: 16),
                              label: Text(
                                hasPickedPreview ? 'Trocar' : 'Trocar imagem',
                              ),
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (hasPickedPreview)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.shade700,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'Nova imagem selecionada',
                            style: TextStyle(color: Colors.white, fontSize: 11),
                          ),
                        ),
                      ),
                  ],
                )
              : _Placeholder(
                  icon: Icons.add_photo_alternate_outlined,
                  onTap: _pick,
                ),
        ),
        if (!showImage)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: TextButton.icon(
              onPressed: _pick,
              icon: const Icon(Icons.photo_library_outlined, size: 18),
              label: const Text('Escolher imagem'),
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ),
      ],
    );
  }
}

class _Placeholder extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _Placeholder({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 40, color: AppColors.textSecondary),
            const SizedBox(height: 8),
            Text(
              'Toque para selecionar',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
