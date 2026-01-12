import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Widget for displaying and uploading business logo
class LogoUploadWidget extends StatelessWidget {
  const LogoUploadWidget({
    super.key,
    this.logoUrl,
    this.onUploadPressed,
    this.onRemovePressed,
    this.isLoading = false,
  });

  final String? logoUrl;
  final VoidCallback? onUploadPressed;
  final VoidCallback? onRemovePressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Business Logo',
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            // Logo preview
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.outline.withValues(alpha: 0.3),
                ),
              ),
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : logoUrl != null && logoUrl!.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(11),
                          child: CachedNetworkImage(
                            imageUrl: logoUrl!,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => const Center(
                              child: CircularProgressIndicator(),
                            ),
                            errorWidget: (context, url, error) => Icon(
                              Icons.business,
                              size: 32,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        )
                      : Icon(
                          Icons.business,
                          size: 32,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
            ),
            const SizedBox(width: 16),
            // Upload/Remove buttons
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FilledButton.tonalIcon(
                    onPressed: isLoading ? null : onUploadPressed,
                    icon: const Icon(Icons.upload, size: 18),
                    label: Text(
                      logoUrl != null ? 'Change Logo' : 'Upload Logo',
                    ),
                  ),
                  if (logoUrl != null && logoUrl!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: isLoading ? null : onRemovePressed,
                      icon: Icon(
                        Icons.delete_outline,
                        size: 18,
                        color: theme.colorScheme.error,
                      ),
                      label: Text(
                        'Remove',
                        style: TextStyle(color: theme.colorScheme.error),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Recommended: 200x200px PNG or JPG',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
