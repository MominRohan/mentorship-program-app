import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/about_constrants.dart';


class AboutScreen extends StatelessWidget {
  const AboutScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // App Header Section
            _buildAppHeader(context),
            const SizedBox(height: 24),
            
            // App Description
            _buildDescriptionSection(context),
            const SizedBox(height: 24),
            
            // Key Features
            _buildAboutSection(context),
            const SizedBox(height: 24),
            
            // Contact & Support
            _buildContactSection(context),
            const SizedBox(height: 24),
            
            // Legal Information
            _buildLegalSection(context),
            const SizedBox(height: 24),
            
            // App Actions
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildAppHeader(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            // App Icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.school,
                size: 40,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 16),
            // App Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppConstants.appName,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Version ${AppConstants.appVersion}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(//can remove revolviz from here
                    AppConstants.companyName,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5),
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

  Widget _buildDescriptionSection(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                const Text(
                  'About This App',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              AppConstants.appDescription,
              style: const TextStyle(
                fontSize: 16,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutSection(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.star_outline, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                const Text(
                  'Key Features',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...AppConstants.keyFeatures.map((feature) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    color: Colors.green[600],
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      feature,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            )).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildContactSection(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.contact_support_outlined, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                const Text(
                  'Contact & Support',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildContactCard(
              context,
              'Email Support',
              'Get help via email',
              Icons.email_outlined,
              () => _showComingSoon(context, 'Email Support'),
            ),
            _buildContactCard(
              context,
              'Phone Support',
              'Get help via phone',
              Icons.phone_outlined,
              () => _showComingSoon(context, 'Phone Support'),
            ),
            _buildContactCard(
              context,
              'Website',
              'Visit our official website',
              Icons.web_outlined,
              () => _showComingSoon(context, 'Website'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard(BuildContext context, String title, String subtitle, IconData icon, VoidCallback onTap) {
    return Card(
      elevation: 1,
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).primaryColor),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
        contentPadding: EdgeInsets.zero,
      ),
    );
  }

  Widget _buildLegalSection(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.gavel_outlined, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                const Text(
                  'Legal Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildLegalItem(
              title: 'Privacy Policy',
              onTap: () => _launchUrl(AppConstants.privacyPolicyUrl, context),
            ),
            _buildLegalItem(
              title: 'Terms of Service',
              onTap: () => _launchUrl(AppConstants.termsOfServiceUrl, context),
            ),
            const SizedBox(height: 12),
            Text(
              AppConstants.copyrightText,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              AppConstants.licenseText,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegalItem({
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _launchUrl(AppConstants.playStoreUrl, context),
                icon: const Icon(Icons.star_rate),
                label: const Text('Rate App'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFBA8900), // primaryColor
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _launchUrl(AppConstants.playStoreUrl, context),
                icon: const Icon(Icons.share),
                label: const Text('Share App'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[600],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),

                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _launchUrl(AppConstants.supportEmail, context),
            icon: const Icon(Icons.feedback_outlined),
            label: const Text('Send Feedback'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              side: BorderSide(color: Theme.of(context).primaryColor),
              foregroundColor: Theme.of(context).primaryColor,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _launchUrl(String url, BuildContext context) async {
    // Copy URL to clipboard and show message
    await Clipboard.setData(ClipboardData(text: url));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('URL copied to clipboard: $url'),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _shareApp(BuildContext context) {
    const String shareText = 
        'Check out ${AppConstants.appName}! '
        '${AppConstants.appDescription} '
        'Download it from: ${AppConstants.playStoreUrl}';
    
    // You can implement share functionality here
    // For now, we'll show a snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Share functionality would open here'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature coming soon!')),
    );
  }
}