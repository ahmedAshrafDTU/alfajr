enum AgeGroup {
  kids(4, 12),
  teen(13, 17),
  adult(18, 59),
  elderly(60, 120);

  final int minAge;
  final int maxAge;

  const AgeGroup(this.minAge, this.maxAge);
}

enum UserRole {
  parent,
  child,
  individual
}

class UserProfile {
  final String id;
  final String name;
  final AgeGroup ageGroup;
  final UserRole role;
  final bool isNewMuslim;
  final String? avatarId;

  UserProfile({
    required this.id,
    required this.name,
    required this.ageGroup,
    required this.role,
    this.isNewMuslim = false,
    this.avatarId,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      name: json['name'],
      ageGroup: AgeGroup.values.firstWhere((e) => e.name == json['ageGroup']),
      role: UserRole.values.firstWhere((e) => e.name == json['role']),
      isNewMuslim: json['isNewMuslim'] ?? false,
      avatarId: json['avatarId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'ageGroup': ageGroup.name,
      'role': role.name,
      'isNewMuslim': isNewMuslim,
      'avatarId': avatarId,
    };
  }
}
