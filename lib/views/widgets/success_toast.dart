// class SuccessToast {
//   void _showSuccessToast(BuildContext context, String message) {
//   showCupertinoDialog(
//     context: context,
//     barrierDismissible: true,
//     builder: (context) {
//       Future.delayed(const Duration(seconds: 2), () {
//         if (context.mounted) Navigator.pop(context);
//       });
//       return CupertinoAlertDialog(
//         content: Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Icon(CupertinoIcons.check_mark_circled, color: CupertinoColors.activeGreen),
//             const SizedBox(width: 10),
//             Text(message),
//           ],
//         ),
//       );
//     },
//   );
// }
// }