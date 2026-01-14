import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers/receipt_upload_provider.dart';

/// Widget for picking and displaying receipt images
class ReceiptPicker extends ConsumerWidget {
  /// The expense ID (null for new expenses)
  final String? expenseId;

  /// Called when receipt URL changes (for form state)
  final ValueChanged<String?>? onReceiptChanged;

  /// Initial receipt URL (for edit mode)
  final String? initialReceiptUrl;

  const ReceiptPicker({
    super.key,
    this.expenseId,
    this.onReceiptChanged,
    this.initialReceiptUrl,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final state = ref.watch(receiptUploadProvider(expenseId));
    final notifier = ref.read(receiptUploadProvider(expenseId).notifier);

    // Initialize with existing receipt on first build
    if (initialReceiptUrl != null && state.uploadedUrl == null && !state.isProcessing) {
      Future.microtask(() => notifier.setExistingReceipt(initialReceiptUrl));
    }

    // Notify parent when receipt changes
    ref.listen(receiptUploadProvider(expenseId), (prev, next) {
      if (prev?.uploadedUrl != next.uploadedUrl) {
        onReceiptChanged?.call(next.uploadedUrl);
      }
    });

    // Show error snackbar if there's an error
    if (state.errorMessage != null) {
      Future.microtask(() {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.errorMessage!),
            behavior: SnackBarBehavior.floating,
            backgroundColor: theme.colorScheme.error,
          ),
        );
        notifier.clearError();
      });
    }

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outlineVariant,
        ),
      ),
      child: _buildContent(context, ref, state, notifier, theme),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    ReceiptUploadState state,
    ReceiptUploadNotifier notifier,
    ThemeData theme,
  ) {
    // Show upload progress
    if (state.isUploading) {
      return _buildUploadProgress(state, theme);
    }

    // Show compression progress
    if (state.isCompressing) {
      return _buildProcessingIndicator('Compressing image...', theme);
    }

    // Show picking indicator
    if (state.isPickingImage) {
      return _buildProcessingIndicator('Opening camera...', theme);
    }

    // Show local image preview (before upload)
    if (state.localImagePath != null) {
      return _buildLocalImagePreview(context, state, notifier, theme);
    }

    // Show uploaded image
    if (state.uploadedUrl != null) {
      return _buildUploadedImage(context, state, notifier, theme);
    }

    // Show empty state with add buttons
    return _buildEmptyState(context, notifier, theme);
  }

  Widget _buildProcessingIndicator(String message, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadProgress(ReceiptUploadState state, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          LinearProgressIndicator(
            value: state.uploadProgress,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 12),
          Text(
            'Uploading... ${(state.uploadProgress * 100).toInt()}%',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocalImagePreview(
    BuildContext context,
    ReceiptUploadState state,
    ReceiptUploadNotifier notifier,
    ThemeData theme,
  ) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(11),
          child: Image.file(
            File(state.localImagePath!),
            width: double.infinity,
            height: 200,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: Row(
            children: [
              _ActionChip(
                icon: Icons.close,
                label: 'Remove',
                onTap: () => notifier.clearLocalImage(),
                backgroundColor: theme.colorScheme.surface,
              ),
            ],
          ),
        ),
        Positioned(
          bottom: 8,
          left: 8,
          right: 8,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 16,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Image will be uploaded when you save',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUploadedImage(
    BuildContext context,
    ReceiptUploadState state,
    ReceiptUploadNotifier notifier,
    ThemeData theme,
  ) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(11),
          child: CachedNetworkImage(
            imageUrl: state.uploadedUrl!,
            width: double.infinity,
            height: 200,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              height: 200,
              color: theme.colorScheme.surfaceContainerHighest,
              child: const Center(child: CircularProgressIndicator()),
            ),
            errorWidget: (context, url, error) => Container(
              height: 200,
              color: theme.colorScheme.surfaceContainerHighest,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.broken_image, color: theme.colorScheme.error),
                  const SizedBox(height: 8),
                  Text(
                    'Failed to load image',
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: Row(
            children: [
              _ActionChip(
                icon: Icons.swap_horiz,
                label: 'Replace',
                onTap: () => _showImageSourcePicker(context, notifier),
                backgroundColor: theme.colorScheme.surface,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    ReceiptUploadNotifier notifier,
    ThemeData theme,
  ) {
    return InkWell(
      onTap: () => _showImageSourcePicker(context, notifier),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              Icons.receipt_long,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Add Receipt Photo',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    'Tap to take photo or choose from gallery',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.add_photo_alternate_outlined,
              color: theme.colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }

  void _showImageSourcePicker(BuildContext context, ReceiptUploadNotifier notifier) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.pop(context);
                notifier.pickFromCamera();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                notifier.pickFromGallery();
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color backgroundColor;

  const _ActionChip({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor.withValues(alpha: 0.9),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16),
              const SizedBox(width: 4),
              Text(label, style: const TextStyle(fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}
