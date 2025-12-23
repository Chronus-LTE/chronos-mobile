import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:provider/provider.dart';
import 'package:chronus/core/theme/app_colors.dart';
import 'package:chronus/features/email/viewmodels/email_view_model.dart';
import 'package:intl/intl.dart';

class EmailDetailScreen extends StatelessWidget {
  const EmailDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<EmailViewModel>();
    final email = vm.selectedEmail;

    if (email == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Email'),
          backgroundColor: AppColors.neutralWhite,
        ),
        body: const Center(
          child: Text('No email selected'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.neutralWhite,
      appBar: AppBar(
        backgroundColor: AppColors.neutralWhite,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.neutralInk),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Email',
          style: TextStyle(
            color: AppColors.neutralInk,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              email.isStarred ? Icons.star : Icons.star_border,
              color: email.isStarred ? const Color(0xFFF59E0B) : AppColors.neutralInk,
            ),
            onPressed: () => vm.toggleStar(email.id, !email.isStarred),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: AppColors.neutralInk),
            onSelected: (value) {
              switch (value) {
                case 'mark_unread':
                  vm.markAsUnread(email.id);
                  Navigator.pop(context);
                  break;
                case 'delete':
                  _confirmDelete(context, vm, email.id);
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'mark_unread',
                child: Row(
                  children: [
                    Icon(Icons.mark_email_unread_outlined, size: 20),
                    SizedBox(width: 12),
                    Text('Mark as unread'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, size: 20, color: Colors.red),
                    SizedBox(width: 12),
                    Text('Delete', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Divider(height: 1, color: AppColors.mainBorder),

            // Email header
            _buildEmailHeader(email),

            const Divider(height: 1, color: AppColors.mainBorder),

            // Email body
            _buildEmailBody(email),

            // Attachments
            if (email.hasAttachments) ...[
              const Divider(height: 1, color: AppColors.mainBorder),
              _buildAttachments(email),
            ],
          ],
        ),
      ),
      bottomNavigationBar: _buildActionBar(context, vm, email),
    );
  }

  Widget _buildEmailHeader(email) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Subject
          Text(
            email.subject,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.neutralInk,
            ),
          ),
          const SizedBox(height: 16),

          // From
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.clay400, AppColors.clay500],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    email.getSenderInitials(),
                    style: const TextStyle(
                      color: AppColors.neutralWhite,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      email.getSenderName(),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.neutralInk,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'to ${email.to}',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.sidebarTextSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Text(
                DateFormat('MMM d, yyyy h:mm a').format(email.date),
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.sidebarTextSecondary,
                ),
              ),
            ],
          ),

          // CC if present
          if (email.cc != null && email.cc!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'CC: ${email.cc}',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.sidebarTextSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmailBody(email) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: email.bodyHtml != null && email.bodyHtml!.isNotEmpty
          ? Html(
              data: email.bodyHtml!,
              style: {
                'body': Style(
                  fontSize: FontSize(15),
                  lineHeight: const LineHeight(1.5),
                  color: AppColors.neutralInk,
                  margin: Margins.zero,
                  padding: HtmlPaddings.zero,
                ),
                'p': Style(
                  margin: Margins.only(bottom: 12),
                ),
                'a': Style(
                  color: AppColors.clay600,
                  textDecoration: TextDecoration.underline,
                ),
              },
            )
          : Text(
              email.bodyPlain ?? email.snippet,
              style: const TextStyle(
                fontSize: 15,
                height: 1.5,
                color: AppColors.neutralInk,
              ),
            ),
    );
  }

  Widget _buildAttachments(email) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Attachments (${email.attachments.length})',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.neutralInk,
            ),
          ),
          const SizedBox(height: 12),
          ...email.attachments.map((attachment) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.contentBg,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.mainBorder,
                    width: 0.5,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.attach_file,
                      size: 20,
                      color: AppColors.clay600,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            attachment.filename,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppColors.neutralInk,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            attachment.getFormattedSize(),
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.sidebarTextSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.download_outlined,
                      size: 20,
                      color: AppColors.clay600,
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildActionBar(BuildContext context, EmailViewModel vm, email) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.neutralWhite,
        border: Border(
          top: BorderSide(
            color: AppColors.mainBorder,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                // TODO: Implement reply
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Reply feature coming soon')),
                );
              },
              icon: const Icon(Icons.reply, size: 18),
              label: const Text('Reply'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.clay700,
                side: const BorderSide(color: AppColors.clay300),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                // TODO: Implement forward
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Forward feature coming soon')),
                );
              },
              icon: const Icon(Icons.forward, size: 18),
              label: const Text('Forward'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.clay700,
                side: const BorderSide(color: AppColors.clay300),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, EmailViewModel vm, int emailId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Email'),
        content: const Text('Are you sure you want to delete this email?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close detail screen
              vm.deleteEmail(emailId);
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
