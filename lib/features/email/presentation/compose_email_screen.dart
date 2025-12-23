import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chronus/core/theme/app_colors.dart';
import 'package:chronus/features/email/viewmodels/email_view_model.dart';

class ComposeEmailScreen extends StatefulWidget {
  const ComposeEmailScreen({super.key});

  @override
  State<ComposeEmailScreen> createState() => _ComposeEmailScreenState();
}

class _ComposeEmailScreenState extends State<ComposeEmailScreen> {
  final _formKey = GlobalKey<FormState>();
  final _toController = TextEditingController();
  final _subjectController = TextEditingController();
  final _bodyController = TextEditingController();

  @override
  void dispose() {
    _toController.dispose();
    _subjectController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<EmailViewModel>();

    return Scaffold(
      backgroundColor: AppColors.neutralWhite,
      appBar: AppBar(
        backgroundColor: AppColors.neutralWhite,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.neutralInk),
          onPressed: () => _confirmDiscard(context),
        ),
        title: const Text(
          'Compose',
          style: TextStyle(
            color: AppColors.neutralInk,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          if (vm.isSending)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.clay600),
                ),
              ),
            )
          else
            TextButton(
              onPressed: () => _sendEmail(context, vm),
              child: const Text(
                'Send',
                style: TextStyle(
                  color: AppColors.clay700,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // To field
              _buildTextField(
                controller: _toController,
                label: 'To',
                hint: 'recipient@example.com',
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter recipient email';
                  }
                  if (!_isValidEmail(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Subject field
              _buildTextField(
                controller: _subjectController,
                label: 'Subject',
                hint: 'Email subject',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter subject';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Body field
              _buildTextField(
                controller: _bodyController,
                label: 'Message',
                hint: 'Write your message...',
                maxLines: 15,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter message';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.neutralInk,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: const TextStyle(
            fontSize: 15,
            color: AppColors.neutralInk,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: AppColors.sidebarTextSecondary.withOpacity(0.5),
              fontSize: 15,
            ),
            filled: true,
            fillColor: AppColors.contentBg,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.mainBorder,
                width: 0.5,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.mainBorder,
                width: 0.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.clay500,
                width: 1.2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Colors.red,
                width: 1,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Colors.red,
                width: 1.2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  Future<void> _sendEmail(BuildContext context, EmailViewModel vm) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final success = await vm.sendEmail(
      to: _toController.text.trim(),
      subject: _subjectController.text.trim(),
      body: _bodyController.text.trim(),
    );

    if (!context.mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email sent successfully'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(vm.error ?? 'Failed to send email'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _confirmDiscard(BuildContext context) {
    final hasContent = _toController.text.isNotEmpty ||
        _subjectController.text.isNotEmpty ||
        _bodyController.text.isNotEmpty;

    if (!hasContent) {
      Navigator.pop(context);
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard draft?'),
        content: const Text('Are you sure you want to discard this email?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close compose screen
            },
            child: const Text(
              'Discard',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
