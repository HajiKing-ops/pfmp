final Map<String, String> _memoryStorage = {};

String _enabledKey(int userId) => 'pfmp_journal_reminder_enabled_$userId';
String _alertDateKey(int userId) => 'pfmp_journal_reminder_alert_date_$userId';
String _checkDateKey(int userId) => 'pfmp_journal_reminder_check_date_$userId';

bool readJournalReminderEnabled(int userId) {
  return _memoryStorage[_enabledKey(userId)] == 'true';
}

void writeJournalReminderEnabled(int userId, bool enabled) {
  _memoryStorage[_enabledKey(userId)] = enabled.toString();
}

String? readLastJournalReminderAlertDate(int userId) {
  return _memoryStorage[_alertDateKey(userId)];
}

void writeLastJournalReminderAlertDate(int userId, String date) {
  _memoryStorage[_alertDateKey(userId)] = date;
}

String? readLastJournalReminderCheckDate(int userId) {
  return _memoryStorage[_checkDateKey(userId)];
}

void writeLastJournalReminderCheckDate(int userId, String date) {
  _memoryStorage[_checkDateKey(userId)] = date;
}
