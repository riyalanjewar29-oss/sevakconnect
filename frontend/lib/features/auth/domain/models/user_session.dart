/// Temporary in-memory session and onboarding state for SevakConnect
class UserOnboardingState {
  String fullName;
  String mobileNumber;
  String? mainRole; // 'Volunteer' | 'Administrator'
  String? administratorRole; // 'Police' | 'NGO Head' | 'Dindi Pramukh' | 'Management Head'
  String? affiliation;

  UserOnboardingState({
    this.fullName = '',
    this.mobileNumber = '',
    this.mainRole,
    this.administratorRole,
    this.affiliation,
  });

  @override
  String toString() {
    return 'UserOnboardingState(name: $fullName, mobile: $mobileNumber, mainRole: $mainRole, adminRole: $administratorRole, affiliation: $affiliation)';
  }
}

/// Global in-memory user session holder
class UserSession {
  static final UserSession instance = UserSession._internal();
  UserSession._internal();

  UserOnboardingState userState = UserOnboardingState();

  void reset() {
    userState = UserOnboardingState();
  }
}
