import 'dart:html' as html;

String _enabledKey(int userId) => 'pfmp_journal_reminder_enabled_$userId';
String _alertDateKey(int userId) => 'pfmp_journal_reminder_alert_date_$userId';
String _checkDateKey(int userId) => 'pfmp_journal_reminder_check_date_$userId';

bool readJournalReminderEnabled(int userId) {
  return html.window.localStorage[_enabledKey(userId)] == 'true';
}

void writeJournalReminderEnabled(int userId, bool enabled) {
  html.window.localStorage[_enabledKey(userId)] = enabled.toString();
}

String? readLastJournalReminderAlertDate(int userId) {
  return html.window.localStorage[_alertDateKey(userId)];
}

void writeLastJournalReminderAlertDate(int userId, String date) {
  html.window.localStorage[_alertDateKey(userId)] = date;
}

String? readLastJournalReminderCheckDate(int userId) {
  return html.window.localStorage[_checkDateKey(userId)];
}

void writeLastJournalReminderCheckDate(int userId, String date) {
  html.window.localStorage[_checkDateKey(userId)] = date;
}
