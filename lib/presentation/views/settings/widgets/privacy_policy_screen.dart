import 'package:finance_tracker/widgets/shared_app_bar.dart';
import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: SharedAppbar(title: 'Privacy Policy'),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Privacy Policy',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 16),
            Text(
              '1. Introduction\nNetWorth+ is a personal finance management application designed to help users track their expenses, monitor income, manage financial goals, and gain insights into their overall financial health.\nWe are committed to protecting the privacy and personal information of our users. This Privacy Policy outlines how we collect, use, disclose, and safeguard your information when you use our application or services. We encourage you to read this policy carefully to understand our practices regarding your personal data and how we will treat it.',
              style: TextStyle(fontSize: 12, color: Colors.black),
            ),
            SizedBox(height: 8),
            Text(
              '2. Information We Collect\nTo provide and improve the services offered through NetWorth+, we may collect the following types of information:\n\na. Personal Information\nWe may collect personally identifiable information such as your name, email address, phone number, and other contact details provided during account registration or usage.\n\nb. Financial Information\nWe collect financial data input by you or synced via third-party integrations. This may include bank account details, credit and debit card information, transaction history, income and expense records, and other relevant financial details.\n\nc. Device Information\nWhen you access NetWorth+, we may collect information about your device, including your IP address, device ID, operating system, browser type, and system configuration.\n\nd. Usage Data\nWe track user interaction with the app to understand feature usage and improve user experience. This may include the pages visited, features used, time spent within the app, and other usage patterns.\n\ne. Third-Party Data\nIf you choose to link external financial services (such as banks or investment platforms), we may access and collect relevant data as permitted by those services, solely for the purpose of delivering a seamless and integrated user experience.',
              style: TextStyle(fontSize: 12, color: Colors.black),
            ),
            SizedBox(height: 8),
            Text(
              '3. How We Use the Information\nWe use the information collected from users for the following purposes:\n\na. To Provide and Improve Our Services\nWe use your data to operate, maintain, and enhance features such as budget tracking, financial reporting, goal setting, and notification services.\n\nb. To Personalize the User Experience\nYour information helps us tailor the app’s content and functionality to better match your financial habits, preferences, and goals.\n\nc. For Customer Support\nWe may use your information to respond to inquiries, troubleshoot issues, and deliver technical support effectively.\n\nd. To Detect Fraud or Abuse\nWe monitor and analyze usage data to identify, prevent, and address any fraudulent activity or abuse of our services.\n\ne. To Send Updates or Marketing Communications\nWe may send product updates, promotional content, or service announcements. Users will have the option to opt out of marketing messages at any time.',
              style: TextStyle(fontSize: 12, color: Colors.black),
            ),
            SizedBox(height: 8),
            Text(
              '4. Data Sharing and Disclosure\nNetWorth+ does not sell, rent, or trade user data to third parties under any circumstances.\nWe may share user information only in the following situations:\n\na. With Service Providers\nWe may share data with trusted third-party service providers who assist in operating our application and services, such as cloud storage providers, analytics platforms, and payment processors. These partners are bound by contractual obligations to safeguard the data and use it solely for the purposes specified by NetWorth+.\n\nb. With Regulatory and Legal Authorities\nWe may disclose information if required to do so by law or in response to valid legal requests by public authorities, including to meet national security or law enforcement requirements.\n\nc. With Integrated Third-Party Partners\nIf users choose to connect or sync NetWorth+ with third-party financial tools or platforms, we may share necessary data to facilitate that integration. Such disclosures will only occur with the user\'s explicit consent and in accordance with applicable privacy safeguards.',
              style: TextStyle(fontSize: 12, color: Colors.black),
            ),
            SizedBox(height: 8),
            Text(
              '5. Third-Party Services\nOur platform may integrate with third-party services such as Plaid, Razorpay, and other service providers to provide enhanced functionality. Please be aware that these third-party providers may collect and use your data in accordance with their own privacy policies.\nWe encourage you to review the privacy terms of these services for more detailed information.',
              style: TextStyle(fontSize: 12, color: Colors.black),
            ),
            SizedBox(height: 8),
            Text(
              '6. Data Security\nWe implement a variety of security measures to protect your data, including encryption, firewalls, and the use of secure servers. While we strive to safeguard your information using industry-standard practices, please be aware that no security system can guarantee absolute protection. Nevertheless, we take all reasonable precautions to maintain the security and integrity of your data.',
              style: TextStyle(fontSize: 12, color: Colors.black),
            ),
            SizedBox(height: 8),
            Text(
              '7. Data Storage and Transfers\nYour data may be stored and processed in servers located within India or in other countries. In cases where data is transferred or stored outside India, we ensure full compliance with applicable Indian data protection laws, including the Digital Personal Data Protection Act, 2023, and other relevant regulations governing cross-border data transfers.',
              style: TextStyle(fontSize: 12, color: Colors.black),
            ),
            SizedBox(height: 8),
            Text(
              '8. Data Retention\nWe retain user data only for as long as necessary to fulfill the purposes for which it was collected, or as required by law. Upon receiving a valid request from a user, we will delete their data, subject to any legal or operational obligations that may require us to retain certain information.',
              style: TextStyle(fontSize: 12, color: Colors.black),
            ),
            SizedBox(height: 8),
            Text(
              '9. User Rights\nUsers have the right to access the personal data we hold about them. They may also request updates or corrections to their information. Additionally, users can delete their account along with all associated data. Users have the option to opt out of receiving marketing communications at any time.\nOur services are not intended for use by individuals under the age of 18. We do not knowingly collect personal data from minors. If we become aware that we have inadvertently collected data from a user under 18, we will take prompt steps to delete such information.',
              style: TextStyle(fontSize: 12, color: Colors.black),
            ),
            SizedBox(height: 8),
            Text(
              '10. Changes to This Policy\nWe may update this privacy policy from time to time to reflect changes in our practices or legal requirements. Any significant updates will be communicated appropriately. We encourage users to review this policy periodically to stay informed about how we protect their information.',
              style: TextStyle(fontSize: 12, color: Colors.black),
            ),
            SizedBox(height: 8),
            Text(
              '11. Contact Information\nFor any questions or concerns regarding this privacy policy or the handling of your personal data, please contact us via email at milansureshbusiness@gmail.com or through our support form available on our website.',
              style: TextStyle(fontSize: 12, color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }
}
