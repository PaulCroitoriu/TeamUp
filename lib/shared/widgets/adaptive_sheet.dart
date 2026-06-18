import 'package:flutter/material.dart';
import 'package:teamup/core/theme/design_tokens.dart';

/// True when the layout is narrow enough that sheets should render as bottom
/// sheets rather than centered dialogs.
bool isMobileWidth(BuildContext context) => MediaQuery.sizeOf(context).width < 600;

/// Presents [builder] as a **centered modal dialog** on wider (non-mobile)
/// layouts and a **bottom sheet** on mobile — matching the redesign's
/// "centered modal on desktop, bottom sheet on mobile" sheet behavior.
Future<T?> showAdaptiveSheet<T>(BuildContext context, {required WidgetBuilder builder}) {
  const barrier = Color(0x6B071E12); // rgba(7, 30, 18, .42)

  if (!isMobileWidth(context)) {
    return showDialog<T>(
      context: context,
      barrierColor: barrier,
      builder: (ctx) => Dialog(
        backgroundColor: TUColors.surface,
        insetPadding: const EdgeInsets.all(24),
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(TUColors.rXl)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: builder(ctx),
        ),
      ),
    );
  }

  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    backgroundColor: TUColors.surface,
    barrierColor: barrier,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(TUColors.rXl)),
    ),
    builder: builder,
  );
}
