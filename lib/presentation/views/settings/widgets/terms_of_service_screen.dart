import 'package:finance_tracker/widgets/shared_app_bar.dart';
import 'package:flutter/material.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: SharedAppbar(title: 'Terms of Service'),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Terms of Service',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
            SizedBox(height: 16),
            Text(
              '1. Use of the Service\nYou agree to use the Service only for lawful purposes and in compliance with all applicable laws and regulations. You must be at least 18 years old to use NetWorth+.',
              style: TextStyle(fontSize: 12, color: Colors.black),
            ),
            SizedBox(height: 8),
            Text(
              '2. Account Registration\nTo access certain features, you may be required to create an account. You agree to provide accurate and complete information during registration and to keep your account credentials confidential. You are responsible for all activities that occur under your account.',
              style: TextStyle(fontSize: 12, color: Colors.black),
            ),
            SizedBox(height: 8),
            Text(
              '3. User Content\nYou retain ownership of the data and information you input into the Service (“User Content”). By using the Service, you grant NetWorth+ a non-exclusive, worldwide, royalty-free license to use, store, and process your User Content to provide and improve the Service.',
              style: TextStyle(fontSize: 12, color: Colors.black),
            ),
            SizedBox(height: 8),
            Text(
              '4. Privacy\nYour privacy is important to us. Please review our Privacy Policy, which explains how we collect, use, and protect your personal information.',
              style: TextStyle(fontSize: 12, color: Colors.black),
            ),
            SizedBox(height: 8),
            Text(
              '5. Prohibited Conduct\nYou agree not to:\n● Use the Service for any illegal or unauthorized purpose.\n● Attempt to gain unauthorized access to other users’ accounts or the Service.\n● Interfere with the operation or security of the Service.\n● Upload or distribute viruses or harmful code.',
              style: TextStyle(fontSize: 12, color: Colors.black),
            ),
            SizedBox(height: 8),
            Text(
              '6. Intellectual Property\nAll intellectual property rights in the Service and its content are owned by or licensed to NetWorth+. You may not copy, modify, distribute, or create derivative works without prior written consent.',
              style: TextStyle(fontSize: 12, color: Colors.black),
            ),
            SizedBox(height: 8),
            Text(
              '7. Third-Party Services\nNetWorth+ may integrate with third-party services. Your use of these services is subject to their terms and privacy policies. We are not responsible for third-party services’ actions or policies.',
              style: TextStyle(fontSize: 12, color: Colors.black),
            ),
            SizedBox(height: 8),
            Text(
              '8. Disclaimers and Limitation of Liability\nThe Service is provided “as is” without warranties of any kind. We do not guarantee accuracy, reliability, or availability. To the fullest extent permitted by law, NetWorth+ shall not be liable for any indirect, incidental, or consequential damages arising from your use of the Service. We advise you not to make any financial decisions arising from the use of NetWorth+.',
              style: TextStyle(fontSize: 12, color: Colors.black),
            ),
            SizedBox(height: 8),
            Text(
              '9. Termination\nWe may suspend or terminate your access to the Service at any time, without notice, for conduct that violates these Terms or is harmful to the Service or other users.',
              style: TextStyle(fontSize: 12, color: Colors.black),
            ),
            SizedBox(height: 8),
            Text(
              '10. Changes to Terms\nWe may update these Terms from time to time. We will notify users of significant changes. Continued use of the Service after updates constitutes acceptance of the revised Terms.',
              style: TextStyle(fontSize: 12, color: Colors.black),
            ),
            SizedBox(height: 8),
            Text(
              '11. Contact Us\nFor questions or concerns regarding these Terms, please contact us at milansureshbusiness@gmail.com.',
              style: TextStyle(fontSize: 12, color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }
}
