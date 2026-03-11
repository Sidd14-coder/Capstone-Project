// ================= FILTER TYPE =================

enum FilterType { weekly, monthly }

// Current selected filter (used across dashboard, transactions, analytics)
FilterType currentFilter = FilterType.monthly;

// ================= FINANCIAL TOTALS =================

// Total money spent (debit)
double totalDebit = 0;

// Total money received (credit)
double totalCredit = 0;

// Used mainly on dashboard (same as totalDebit)
double globalTotalSpent = 0;

// ================= USER DETAILS =================

String loggedInUserEmail = '';
String loggedInUserName = 'User';

// ================= SPENDING CONTROL (75% APPROACH) =================

// Percentage of income allowed to spend
// 0.75 = 75%
double spendingLimitPercentage = 0.75;

// Calculated allowed spending based on income
double get spendingLimit {
  return totalCredit * spendingLimitPercentage;
}

// Indicates whether user has crossed safe spending zone
bool get isHighSpending {
  return totalCredit > 0 && totalDebit >= spendingLimit;
}

// Indicates critical condition (expense > income)
bool get isCriticalSpending {
  return totalCredit > 0 && totalDebit > totalCredit;
}

// ================= DAILY DATA MAPS =================

Map<DateTime, double> dailyDebitMap = {};
Map<DateTime, double> dailyCreditMap = {};

// ================= TEMP REGISTERED USER (DEMO PURPOSE) =================

// Stored after successful registration (no backend, UI-level auth)
String registeredEmail = '';
String registeredPassword = '';

Map<String, double> bankBalances = {}; 
Map<String, String> bankAccounts = {}; 
Map<String, int> bankLastSmsTime = {};