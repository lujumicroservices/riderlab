import '../core/models/share_visibility.dart';
import 'app_localizations.dart';

extension ShareVisibilityL10n on AppLocalizations {
  String visibilityOptionLabel(ShareVisibility v) => switch (v) {
    ShareVisibility.private => rideDetailVisibilityPrivate,
    ShareVisibility.friends => rideDetailVisibilityFriends,
    ShareVisibility.public => rideDetailVisibilityPublic,
  };

  String visibilityOptionHelp(ShareVisibility v) => switch (v) {
    ShareVisibility.private => rideDetailVisibilityPrivateHelp,
    ShareVisibility.friends => rideDetailVisibilityFriendsHelp,
    ShareVisibility.public => rideDetailVisibilityPublicHelp,
  };
}
