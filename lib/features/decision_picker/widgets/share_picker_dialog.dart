import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../models/decision_group.dart';
import '../services/share_service.dart';

class SharePickerDialog extends StatelessWidget {
  const SharePickerDialog({super.key, required this.picker});

  final DecisionGroup picker;

  @override
  Widget build(BuildContext context) {
    final url = ShareService.encodePickerToUrl(picker);

    return AlertDialog(
      title: Text('Share ${picker.name}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Scan this QR code to share the picker:'),
          const SizedBox(height: 16),
          SizedBox(
            width: 200,
            height: 200,
            child: Theme.of(context).brightness == Brightness.dark
              ? QrImageView(
                  data: url,
                  version: QrVersions.auto,
                  backgroundColor: Colors.white,
                )
              : QrImageView(
                  data: url,
                  version: QrVersions.auto,
                ),
          ),
          const SizedBox(height: 16),
          Text(
            'Others can scan this code to add the picker to their app',
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}