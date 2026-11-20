import 'package:flutter/widgets.dart';

import '../../core/services/ride_recorder.dart';
import '../../l10n/l10n_ext.dart';

/// Hands the recorder localized copy for its foreground notifications
/// (recording + armed). Call before start/arm.
void applyRideNotificationText(BuildContext context, RideRecorder recorder) {
  final l10n = context.l10n;
  recorder.notificationText = RideNotificationText(
    recording: l10n.rideNotifRecording,
    armed: l10n.rideNotifArmed,
  );
}
