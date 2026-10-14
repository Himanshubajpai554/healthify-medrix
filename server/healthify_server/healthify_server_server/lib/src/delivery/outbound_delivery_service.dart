import 'dart:convert';
import 'dart:io';

import 'package:serverpod/serverpod.dart';

/// Models for outbound messaging across email, SMS, and push notification channels.
class OutboundEmail {
  final String to;
  final String subject;
  final String textBody;
  final String? htmlBody;
  final String? from;

  const OutboundEmail({
    required this.to,
    required this.subject,
    required this.textBody,
    this.htmlBody,
    this.from,
  });
}

class OutboundSms {
  final String toPhone;
  final String message;

  const OutboundSms({
    required this.toPhone,
    required this.message,
  });
}

class OutboundPush {
  final String userIdentifier;
  final String title;
  final String body;
  final Map<String, dynamic> data;

  const OutboundPush({
    required this.userIdentifier,
    required this.title,
    required this.body,
    this.data = const {},
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Abstract Provider Interfaces
// ─────────────────────────────────────────────────────────────────────────────

abstract class EmailDeliveryProvider {
  Future<bool> sendEmail(Session session, OutboundEmail email);
}

abstract class SmsDeliveryProvider {
  Future<bool> sendSms(Session session, OutboundSms sms);
}

abstract class PushDeliveryProvider {
  Future<bool> sendPush(Session session, OutboundPush push);
}

// ─────────────────────────────────────────────────────────────────────────────
// Console Providers (Development / Fallback)
// ─────────────────────────────────────────────────────────────────────────────

class ConsoleEmailProvider implements EmailDeliveryProvider {
  const ConsoleEmailProvider();

  @override
  Future<bool> sendEmail(Session session, OutboundEmail email) async {
    session.log(
      '[OutboundEmail:CONSOLE] To: ${email.to} | Subject: "${email.subject}"\n'
      'Body: ${email.textBody}',
      level: LogLevel.info,
    );
    return true;
  }
}

class ConsoleSmsProvider implements SmsDeliveryProvider {
  const ConsoleSmsProvider();

  @override
  Future<bool> sendSms(Session session, OutboundSms sms) async {
    session.log(
      '[OutboundSMS:CONSOLE] To: ${sms.toPhone} | Message: ${sms.message}',
      level: LogLevel.info,
    );
    return true;
  }
}

class ConsolePushProvider implements PushDeliveryProvider {
  const ConsolePushProvider();

  @override
  Future<bool> sendPush(Session session, OutboundPush push) async {
    session.log(
      '[OutboundPush:CONSOLE] Target: ${push.userIdentifier} | "${push.title}" - ${push.body}',
      level: LogLevel.info,
    );
    return true;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HTTP REST Providers (SendGrid, Twilio, FCM)
// ─────────────────────────────────────────────────────────────────────────────

class SendGridEmailProvider implements EmailDeliveryProvider {
  final String apiKey;
  final String defaultFrom;

  SendGridEmailProvider({
    required this.apiKey,
    this.defaultFrom = 'no-reply@healthify.app',
  });

  @override
  Future<bool> sendEmail(Session session, OutboundEmail email) async {
    final client = HttpClient();
    try {
      final request = await client.postUrl(
        Uri.parse('https://api.sendgrid.com/v3/mail/send'),
      );
      request.headers.set('Authorization', 'Bearer $apiKey');
      request.headers.set('Content-Type', 'application/json');

      final payload = jsonEncode({
        'personalizations': [
          {
            'to': [
              {'email': email.to}
            ],
            'subject': email.subject,
          }
        ],
        'from': {'email': email.from ?? defaultFrom, 'name': 'Healthify Clinical'},
        'content': [
          {'type': 'text/plain', 'value': email.textBody},
          if (email.htmlBody != null)
            {'type': 'text/html', 'value': email.htmlBody},
        ],
      });

      request.write(payload);
      final response = await request.close();

      if (response.statusCode >= 200 && response.statusCode < 300) {
        session.log('[SendGrid] Email dispatched to ${email.to}', level: LogLevel.info);
        return true;
      } else {
        final body = await response.transform(utf8.decoder).join();
        session.log(
          '[SendGrid] Failed with HTTP ${response.statusCode}: $body',
          level: LogLevel.error,
        );
        return false;
      }
    } catch (e, st) {
      session.log('[SendGrid] Dispatch error: $e', level: LogLevel.error, exception: e, stackTrace: st);
      return false;
    } finally {
      client.close();
    }
  }
}

class TwilioSmsProvider implements SmsDeliveryProvider {
  final String accountSid;
  final String authToken;
  final String fromNumber;

  TwilioSmsProvider({
    required this.accountSid,
    required this.authToken,
    required this.fromNumber,
  });

  @override
  Future<bool> sendSms(Session session, OutboundSms sms) async {
    final client = HttpClient();
    try {
      final uri = Uri.parse(
        'https://api.twilio.com/2010-04-01/Accounts/$accountSid/Messages.json',
      );
      final request = await client.postUrl(uri);
      final authHeader = base64Encode(utf8.encode('$accountSid:$authToken'));
      request.headers.set('Authorization', 'Basic $authHeader');
      request.headers.set(
        'Content-Type',
        'application/x-www-form-urlencoded; charset=utf-8',
      );

      final form = {
        'To': sms.toPhone,
        'From': fromNumber,
        'Body': sms.message,
      };
      final body = form.entries
          .map((e) => '${Uri.encodeQueryComponent(e.key)}=${Uri.encodeQueryComponent(e.value)}')
          .join('&');

      request.write(body);
      final response = await request.close();

      if (response.statusCode >= 200 && response.statusCode < 300) {
        session.log('[Twilio] SMS dispatched to ${sms.toPhone}', level: LogLevel.info);
        return true;
      } else {
        final resp = await response.transform(utf8.decoder).join();
        session.log('[Twilio] SMS failed HTTP ${response.statusCode}: $resp', level: LogLevel.error);
        return false;
      }
    } catch (e, st) {
      session.log('[Twilio] SMS error: $e', level: LogLevel.error, exception: e, stackTrace: st);
      return false;
    } finally {
      client.close();
    }
  }
}

class FcmPushProvider implements PushDeliveryProvider {
  final String serverKey;

  FcmPushProvider({required this.serverKey});

  @override
  Future<bool> sendPush(Session session, OutboundPush push) async {
    final client = HttpClient();
    try {
      final request = await client.postUrl(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
      );
      request.headers.set('Authorization', 'key=$serverKey');
      request.headers.set('Content-Type', 'application/json');

      final payload = jsonEncode({
        'to': '/topics/user_${push.userIdentifier}',
        'notification': {
          'title': push.title,
          'body': push.body,
        },
        'data': push.data,
      });

      request.write(payload);
      final response = await request.close();
      return response.statusCode == 200;
    } catch (e) {
      session.log('[FCM] Push dispatch error: $e', level: LogLevel.error);
      return false;
    } finally {
      client.close();
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Central Delivery Manager
// ─────────────────────────────────────────────────────────────────────────────

class DeliveryManager {
  static final DeliveryManager instance = DeliveryManager._internal();
  factory DeliveryManager() => instance;
  DeliveryManager._internal();

  EmailDeliveryProvider? _emailProvider;
  SmsDeliveryProvider? _smsProvider;
  PushDeliveryProvider? _pushProvider;

  void initialize({
    EmailDeliveryProvider? emailProvider,
    SmsDeliveryProvider? smsProvider,
    PushDeliveryProvider? pushProvider,
  }) {
    _emailProvider = emailProvider;
    _smsProvider = smsProvider;
    _pushProvider = pushProvider;
  }

  EmailDeliveryProvider getEmailProvider(Session session) {
    if (_emailProvider != null) return _emailProvider!;

    final sendGridKey = session.serverpod.getPassword('sendgrid_api_key') ??
        Platform.environment['SENDGRID_API_KEY'];
    if (sendGridKey != null && sendGridKey.trim().isNotEmpty) {
      return SendGridEmailProvider(apiKey: sendGridKey.trim());
    }
    return const ConsoleEmailProvider();
  }

  SmsDeliveryProvider getSmsProvider(Session session) {
    if (_smsProvider != null) return _smsProvider!;

    final sid = session.serverpod.getPassword('twilio_account_sid') ??
        Platform.environment['TWILIO_ACCOUNT_SID'];
    final token = session.serverpod.getPassword('twilio_auth_token') ??
        Platform.environment['TWILIO_AUTH_TOKEN'];
    final from = session.serverpod.getPassword('twilio_from_number') ??
        Platform.environment['TWILIO_FROM_NUMBER'];

    if (sid != null && token != null && from != null && sid.isNotEmpty) {
      return TwilioSmsProvider(
        accountSid: sid.trim(),
        authToken: token.trim(),
        fromNumber: from.trim(),
      );
    }
    return const ConsoleSmsProvider();
  }

  PushDeliveryProvider getPushProvider(Session session) {
    if (_pushProvider != null) return _pushProvider!;

    final fcmKey = session.serverpod.getPassword('fcm_server_key') ??
        Platform.environment['FCM_SERVER_KEY'];
    if (fcmKey != null && fcmKey.trim().isNotEmpty) {
      return FcmPushProvider(serverKey: fcmKey.trim());
    }
    return const ConsolePushProvider();
  }

  // High-level operational triggers
  Future<bool> sendRegistrationCode(
    Session session, {
    required String email,
    required String code,
  }) async {
    final provider = getEmailProvider(session);
    return provider.sendEmail(
      session,
      OutboundEmail(
        to: email,
        subject: 'Healthify: Verify Your Email Address',
        textBody: 'Your verification code is: $code\n\n'
            'This code expires in 15 minutes. If you did not request this code, '
            'please ignore this message.',
        htmlBody: '''
          <div style="font-family: sans-serif; max-width: 520px; margin: 0 auto; padding: 24px;">
            <h2 style="color: #0D9488;">Welcome to Healthify</h2>
            <p>Please enter the verification code below to verify your patient account:</p>
            <div style="font-size: 32px; font-weight: bold; letter-spacing: 4px; color: #0D9488; background: #F0FDFA; padding: 16px; border-radius: 8px; text-align: center; margin: 24px 0;">
              $code
            </div>
            <p style="color: #64748B; font-size: 13px;">This code will expire in 15 minutes. For your security, do not share this code with anyone.</p>
          </div>
        ''',
      ),
    );
  }

  Future<bool> sendPasswordResetCode(
    Session session, {
    required String email,
    required String code,
  }) async {
    final provider = getEmailProvider(session);
    return provider.sendEmail(
      session,
      OutboundEmail(
        to: email,
        subject: 'Healthify: Password Reset Code',
        textBody: 'Your password reset code is: $code\n\n'
            'This code expires in 15 minutes. If you did not request a password reset, '
            'contact your hospital administrator immediately.',
        htmlBody: '''
          <div style="font-family: sans-serif; max-width: 520px; margin: 0 auto; padding: 24px;">
            <h2 style="color: #0D9488;">Password Reset Request</h2>
            <p>You recently requested to reset the password for your Healthify account:</p>
            <div style="font-size: 32px; font-weight: bold; letter-spacing: 4px; color: #0D9488; background: #F0FDFA; padding: 16px; border-radius: 8px; text-align: center; margin: 24px 0;">
              $code
            </div>
            <p style="color: #64748B; font-size: 13px;">If you did not request this, please contact support or ignore this message.</p>
          </div>
        ''',
      ),
    );
  }

  Future<bool> sendSmsAlert(
    Session session, {
    required String toPhone,
    required String message,
  }) async {
    final provider = getSmsProvider(session);
    return provider.sendSms(session, OutboundSms(toPhone: toPhone, message: message));
  }

  Future<bool> sendPushNotification(
    Session session, {
    required String userIdentifier,
    required String title,
    required String body,
    Map<String, dynamic> data = const {},
  }) async {
    final provider = getPushProvider(session);
    return provider.sendPush(
      session,
      OutboundPush(
        userIdentifier: userIdentifier,
        title: title,
        body: body,
        data: data,
      ),
    );
  }
}
