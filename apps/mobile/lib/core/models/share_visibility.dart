/// Who can see a ride or route in the cloud.
enum ShareVisibility {
  /// Only the owner.
  private,

  /// Accepted friends only.
  friends,

  /// Anyone signed in (discoverable / compare).
  public;

  String get dbValue => name;

  static ShareVisibility fromDb(Object? raw, {bool? legacyIsShared}) {
    final s = raw?.toString().trim().toLowerCase();
    switch (s) {
      case 'private':
        return ShareVisibility.private;
      case 'friends':
        return ShareVisibility.friends;
      case 'public':
        return ShareVisibility.public;
    }
    if (legacyIsShared == true) return ShareVisibility.public;
    if (legacyIsShared == false) return ShareVisibility.private;
    return ShareVisibility.friends;
  }

  /// Legacy boolean: true only for fully public content.
  bool get legacyIsShared => this == ShareVisibility.public;
}
