/*
Developer: Momin Rohan
User Verification Screen for Document Upload and Verification
*/

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../models/user_firebase.dart';
import '../providers/auth_provider.dart';

class UserVerificationScreen extends ConsumerStatefulWidget {
  @override
  _UserVerificationScreenState createState() => _UserVerificationScreenState();
}

class _UserVerificationScreenState extends ConsumerState<UserVerificationScreen> {
  final Map<String, File?> _uploadedDocuments = {
    'identity': null,
    'education': null,
    'experience': null,
  };
  
  final Map<String, String> _documentDescriptions = {
    'identity': 'Government-issued ID (Passport, Driver\'s License, etc.)',
    'education': 'Educational certificates or degrees',
    'experience': 'Work experience certificates or portfolio',
  };

  bool _isSubmitting = false;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(authProvider).user;
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Account Verification'),
        backgroundColor: Color(0xFFBA8900), // primaryColor
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Icon(Icons.verified_user, size: 48, color: Color(0xFFBA8900)), // primaryColor
                  SizedBox(height: 8),
                  Text(
                    'Verify Your Account',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFBA8900), // primaryColor
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Upload the required documents to verify your account and gain access to all features.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6)),
                  ),
                ],
              ),
            ),

            SizedBox(height: 24),

            // Current Status
            _buildStatusCard(currentUser),

            SizedBox(height: 24),

            // Document Upload Section
            Text(
              'Required Documents',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),

            // Document upload cards
            ..._documentDescriptions.entries.map((entry) => 
              _buildDocumentUploadCard(entry.key, entry.value)
            ),

            SizedBox(height: 24),

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _canSubmit() && !_isSubmitting ? _submitVerification : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFBA8900), // primaryColor
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isSubmitting
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text(
                        'Submit for Verification',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ),

            SizedBox(height: 16),

            // Help Text
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info, color: Colors.orange),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Verification typically takes 1-3 business days. You\'ll receive an email notification once your documents are reviewed.',
                      style: TextStyle(color: Colors.orange[800]),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(dynamic currentUser) {
    // This will be updated when Firebase user model is integrated
    UserVerificationStatus status = UserVerificationStatus.pending;
    Color statusColor = Colors.orange;
    String statusText = 'Pending Verification';
    IconData statusIcon = Icons.pending;

    switch (status) {
      case UserVerificationStatus.pending:
        statusColor = Colors.orange;
        statusText = 'Pending Verification';
        statusIcon = Icons.pending;
        break;
      case UserVerificationStatus.inReview:
        statusColor = Color(0xFFBA8900); // primaryColor
        statusText = 'Under Review';
        statusIcon = Icons.rate_review;
        break;
      case UserVerificationStatus.verified:
        statusColor = Colors.green;
        statusText = 'Verified';
        statusIcon = Icons.verified;
        break;
      case UserVerificationStatus.rejected:
        statusColor = Colors.red;
        statusText = 'Verification Rejected';
        statusIcon = Icons.cancel;
        break;
      case UserVerificationStatus.suspended:
        statusColor = Colors.red;
        statusText = 'Account Suspended';
        statusIcon = Icons.block;
        break;
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(statusIcon, color: statusColor, size: 32),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Verification Status',
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
                  ),
                ),
                Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentUploadCard(String documentType, String description) {
    final isUploaded = _uploadedDocuments[documentType] != null;
    
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getDocumentIcon(documentType),
                  color: isUploaded ? Colors.green : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getDocumentTitle(documentType),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        description,
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isUploaded)
                  Icon(Icons.check_circle, color: Colors.green),
              ],
            ),
            
            if (isUploaded) ...[
              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    Icon(Icons.attach_file, size: 16, color: Colors.green),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _uploadedDocuments[documentType]!.path.split('/').last,
                        style: TextStyle(color: Colors.green[800]),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, size: 16, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          _uploadedDocuments[documentType] = null;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ],

            SizedBox(height: 12),
            
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickDocument(documentType),
                    icon: Icon(Icons.upload_file),
                    label: Text(isUploaded ? 'Replace File' : 'Upload File'),
                  ),
                ),
                SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: () => _takePhoto(documentType),
                  icon: Icon(Icons.camera_alt),
                  label: Text('Camera'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getDocumentIcon(String documentType) {
    switch (documentType) {
      case 'identity':
        return Icons.badge;
      case 'education':
        return Icons.school;
      case 'experience':
        return Icons.work;
      default:
        return Icons.description;
    }
  }

  String _getDocumentTitle(String documentType) {
    switch (documentType) {
      case 'identity':
        return 'Identity Document';
      case 'education':
        return 'Educational Certificate';
      case 'experience':
        return 'Experience Certificate';
      default:
        return 'Document';
    }
  }

  Future<void> _pickDocument(String documentType) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      );

      if (result != null) {
        setState(() {
          _uploadedDocuments[documentType] = File(result.files.single.path!);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick file: $e')),
      );
    }
  }

  Future<void> _takePhoto(String documentType) async {
    try {
      final XFile? photo = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );

      if (photo != null) {
        setState(() {
          _uploadedDocuments[documentType] = File(photo.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to take photo: $e')),
      );
    }
  }

  bool _canSubmit() {
    return _uploadedDocuments['identity'] != null;
  }

  Future<void> _submitVerification() async {
    setState(() => _isSubmitting = true);

    try {
      // TODO: Implement actual submission when Firebase is configured
      await Future.delayed(Duration(seconds: 2)); // Simulate API call

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Verification documents submitted successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to submit verification: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }
}
