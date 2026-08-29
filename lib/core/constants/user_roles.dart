enum UserRole {
  admin,
  police,
}

extension UserRoleExtension on UserRole {
  String get displayName {
    switch (this) {
      case UserRole.admin:
        return 'Admin (Command Control)';
      case UserRole.police:
        return 'Police (Law & Security)';
    }
  }

  String get shortName {
    switch (this) {
      case UserRole.admin:
        return 'Admin';
      case UserRole.police:
        return 'Police';
    }
  }

  bool get canAccessHaltReadiness => this == UserRole.admin;
  bool get canAccessSupplies => this == UserRole.admin;
  bool get canFlagRestrictedEntry => true; // Both Admin and Police
  bool get canDispatchVolunteers => true; // Both Admin and Police
  bool get canManageLostFound => true; // Both Admin and Police
}
