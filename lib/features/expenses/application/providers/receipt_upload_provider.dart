import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

import '../../domain/repositories/i_expense_repository.dart';
import 'expense_providers.dart';

/// State for receipt upload operations
@immutable
class ReceiptUploadState {
  final bool isPickingImage;
  final bool isCompressing;
  final bool isUploading;
  final double uploadProgress;
  final String? errorMessage;
  final String? localImagePath;
  final String? uploadedUrl;

  const ReceiptUploadState({
    this.isPickingImage = false,
    this.isCompressing = false,
    this.isUploading = false,
    this.uploadProgress = 0.0,
    this.errorMessage,
    this.localImagePath,
    this.uploadedUrl,
  });

  bool get isProcessing => isPickingImage || isCompressing || isUploading;

  ReceiptUploadState copyWith({
    bool? isPickingImage,
    bool? isCompressing,
    bool? isUploading,
    double? uploadProgress,
    String? errorMessage,
    String? localImagePath,
    String? uploadedUrl,
    bool clearError = false,
    bool clearLocalImage = false,
    bool clearUploadedUrl = false,
  }) {
    return ReceiptUploadState(
      isPickingImage: isPickingImage ?? this.isPickingImage,
      isCompressing: isCompressing ?? this.isCompressing,
      isUploading: isUploading ?? this.isUploading,
      uploadProgress: uploadProgress ?? this.uploadProgress,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      localImagePath:
          clearLocalImage ? null : (localImagePath ?? this.localImagePath),
      uploadedUrl: clearUploadedUrl ? null : (uploadedUrl ?? this.uploadedUrl),
    );
  }
}

/// Notifier for receipt upload operations
class ReceiptUploadNotifier extends StateNotifier<ReceiptUploadState> {
  final IExpenseRepository _repository;
  final ImagePicker _imagePicker;

  ReceiptUploadNotifier(this._repository)
      : _imagePicker = ImagePicker(),
        super(const ReceiptUploadState());

  /// Maximum image dimension after compression
  static const int maxImageDimension = 1920;

  /// Target quality for compression (0-100)
  static const int compressionQuality = 80;

  /// Maximum file size in bytes (1MB)
  static const int maxFileSize = 1024 * 1024;

  /// Reset state to initial
  void reset() {
    state = const ReceiptUploadState();
  }

  /// Clear any error message
  void clearError() {
    state = state.copyWith(clearError: true);
  }

  /// Set an existing receipt URL (for edit mode)
  void setExistingReceipt(String? url) {
    state = state.copyWith(uploadedUrl: url, clearUploadedUrl: url == null);
  }

  /// Pick image from camera
  Future<void> pickFromCamera() async {
    await _pickImage(ImageSource.camera);
  }

  /// Pick image from gallery
  Future<void> pickFromGallery() async {
    await _pickImage(ImageSource.gallery);
  }

  Future<void> _pickImage(ImageSource source) async {
    state = state.copyWith(isPickingImage: true, clearError: true);

    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: maxImageDimension.toDouble(),
        maxHeight: maxImageDimension.toDouble(),
        imageQuality: compressionQuality,
      );

      if (pickedFile == null) {
        // User cancelled
        state = state.copyWith(isPickingImage: false);
        return;
      }

      state = state.copyWith(
        isPickingImage: false,
        isCompressing: true,
        localImagePath: pickedFile.path,
      );

      // Compress the image
      final compressedPath = await _compressImage(pickedFile.path);

      state = state.copyWith(
        isCompressing: false,
        localImagePath: compressedPath,
      );
    } catch (e) {
      state = state.copyWith(
        isPickingImage: false,
        isCompressing: false,
        errorMessage: _getErrorMessage(e),
      );
    }
  }

  Future<String> _compressImage(String imagePath) async {
    final file = File(imagePath);
    final fileSize = await file.length();

    // If file is already small enough, return original
    if (fileSize <= maxFileSize) {
      return imagePath;
    }

    // Get temp directory for compressed file
    final tempDir = await getTemporaryDirectory();
    final fileName = path.basenameWithoutExtension(imagePath);
    final targetPath = path.join(tempDir.path, '${fileName}_compressed.jpg');

    // Compress the image
    final result = await FlutterImageCompress.compressAndGetFile(
      imagePath,
      targetPath,
      quality: compressionQuality,
      minWidth: maxImageDimension,
      minHeight: maxImageDimension,
    );

    if (result == null) {
      throw Exception('Failed to compress image');
    }

    return result.path;
  }

  /// Upload the selected image to Firebase Storage
  Future<String?> uploadReceipt(String expenseId) async {
    if (state.localImagePath == null) {
      state = state.copyWith(errorMessage: 'No image selected');
      return null;
    }

    state = state.copyWith(
      isUploading: true,
      uploadProgress: 0.0,
      clearError: true,
    );

    try {
      // Simulate progress updates (actual progress would come from Firebase)
      state = state.copyWith(uploadProgress: 0.3);

      final url =
          await _repository.uploadReceipt(expenseId, state.localImagePath!);

      state = state.copyWith(uploadProgress: 1.0);

      // Small delay to show completion
      await Future<void>.delayed(const Duration(milliseconds: 200));

      state = state.copyWith(
        isUploading: false,
        uploadedUrl: url,
        clearLocalImage: true,
      );

      return url;
    } catch (e) {
      state = state.copyWith(
        isUploading: false,
        errorMessage: _getErrorMessage(e),
      );
      return null;
    }
  }

  /// Delete the current receipt
  Future<bool> deleteReceipt(String expenseId) async {
    if (state.uploadedUrl == null) return true;

    try {
      await _repository.deleteReceipt(expenseId, state.uploadedUrl!);
      state = state.copyWith(clearUploadedUrl: true, clearLocalImage: true);
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: _getErrorMessage(e));
      return false;
    }
  }

  /// Clear the locally selected image without deleting from server
  void clearLocalImage() {
    state = state.copyWith(clearLocalImage: true);
  }

  String _getErrorMessage(Object error) {
    final errorStr = error.toString().toLowerCase();
    if (errorStr.contains('permission') || errorStr.contains('denied')) {
      return 'Permission denied. Please grant camera/photo access in Settings.';
    }
    if (errorStr.contains('network') || errorStr.contains('connection')) {
      return 'Network error. Please check your internet connection.';
    }
    if (errorStr.contains('storage') || errorStr.contains('quota')) {
      return 'Storage error. Please try again later.';
    }
    if (errorStr.contains('compress')) {
      return 'Failed to process image. Please try a different photo.';
    }
    return 'Failed to upload receipt. Please try again.';
  }
}

/// Provider for receipt upload operations
/// Using family to scope by expense ID for proper isolation
final receiptUploadProvider = StateNotifierProvider.autoDispose
    .family<ReceiptUploadNotifier, ReceiptUploadState, String?>(
        (ref, expenseId) {
  final repository = ref.watch(expenseRepositoryProvider);
  return ReceiptUploadNotifier(repository);
});
