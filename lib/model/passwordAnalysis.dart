// ignore_for_file: file_names

class PasswordAnalysis {
  final int id;
  final int user;
  final String analysisDate;
  final int reusedPasswordsCount;
  final int similarPasswordsCount;
  final int breachedPasswordsCount;
  final int totalLoginInfos;
  final List<Issue> issues;

  PasswordAnalysis({
    required this.id,
    required this.user,
    required this.analysisDate,
    required this.reusedPasswordsCount,
    required this.similarPasswordsCount,
    required this.breachedPasswordsCount,
    required this.totalLoginInfos,
    required this.issues,
  });

  // Factory method to parse JSON
  factory PasswordAnalysis.fromJson(Map<String, dynamic> json) {
    return PasswordAnalysis(
      id: json['id'],
      user: json['user'],
      analysisDate: json['analysis_date'],
      reusedPasswordsCount: json['reused_passwords_count'],
      similarPasswordsCount: json['similar_passwords_count'],
      breachedPasswordsCount: json['breached_passwords_count'],
      totalLoginInfos: json['total_login_infos'],
      issues: (json['issues'] as List).map((i) => Issue.fromJson(i)).toList(),
    );
  }
}

class Issue {
  final int id;
  final String issueType;
  final String loginUsername;
  final double? similarityScore;
  final Map<String, dynamic> details;

  Issue({
    required this.id,
    required this.issueType,
    required this.loginUsername,
    this.similarityScore,
    required this.details,
  });

  // Factory method to parse JSON
  factory Issue.fromJson(Map<String, dynamic> json) {
    return Issue(
      id: json['id'],
      issueType: json['issue_type'],
      loginUsername: json['login_username'],
      similarityScore: json['similarity_score']?.toDouble(),
      details: json['details'],
    );
  }
}
