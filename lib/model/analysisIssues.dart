

class AnalysisIssue {
  final LoginInfo loginInfo;
  final List<Issue1> issues;

  AnalysisIssue({
    required this.loginInfo,
    required this.issues,
  });

  factory AnalysisIssue.fromJson(Map<String, dynamic> json) {
    return AnalysisIssue(
      loginInfo: LoginInfo.fromJson(json['login_info']),
      issues: (json['issues'] as List)
          .map((issue) => Issue1.fromJson(issue))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'login_info': loginInfo.toJson(),
      'issues': issues.map((issue) => issue.toJson()).toList(),
    };
  }
}

class LoginInfo {
  final int id;
  final String loginUsername;

  LoginInfo({
    required this.id,
    required this.loginUsername,
  });

  factory LoginInfo.fromJson(Map<String, dynamic> json) {
    return LoginInfo(
      id: json['id'],
      loginUsername: json['login_username'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'login_username': loginUsername,
    };
  }
}

class Issue1 {
  final String issueType;
  final double? similarityScore;
  final Details details;

  Issue1({
    required this.issueType,
    this.similarityScore,
    required this.details,
  });

  factory Issue1.fromJson(Map<String, dynamic> json) {
    return Issue1(
      issueType: json['issue_type'],
      similarityScore: json['similarity_score'] != null
          ? (json['similarity_score'] as num).toDouble()
          : null,
      details: Details.fromJson(json['details']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'issue_type': issueType,
      'similarity_score': similarityScore,
      'details': details.toJson(),
    };
  }
}

class Details {
  final List<String>? reusedIn;
  final int? reuseCount;
  final double? similarityPercentage;
  final int? timesExposed;

  Details({
    this.reusedIn,
    this.reuseCount,
    this.similarityPercentage,
    this.timesExposed,
  });

  factory Details.fromJson(Map<String, dynamic> json) {
    return Details(
      reusedIn: json['reused_in'] != null
          ? List<String>.from(json['reused_in'])
          : null,
      reuseCount: json['reuse_count'],
      similarityPercentage: json['similarity_percentage'] != null
          ? (json['similarity_percentage'] as num).toDouble()
          : null,
      timesExposed: json['times_exposed'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reused_in': reusedIn,
      'reuse_count': reuseCount,
      'similarity_percentage': similarityPercentage,
      'times_exposed': timesExposed,
    };
  }
}
