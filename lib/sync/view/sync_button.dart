import 'package:flutter/material.dart';
import 'sync_model.dart';

class SyncButton extends StatefulWidget {
  const SyncButton({super.key});

  @override
  State<SyncButton> createState() => _SyncButton();
}

class _SyncButton extends State<SyncButton> {
  final model = SyncModel();

  @override
  void initState() {
    super.initState();

    model.onStatusChanged = (s) {
      setState(() {});
    };
    model.init();
  }

  @override
  void dispose() {
    model.deinit();
    super.dispose();
  }

  IconData iconByStatus(s) {
    switch (s) {
      case SyncStatus.notsynced:
        return Icons.cloud_queue;
      case SyncStatus.running:
        return Icons.cloud_sync;
      case SyncStatus.synced:
        return Icons.cloud_done;
    }

    return Icons.sync_problem;
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(iconByStatus(model.status())),
      tooltip: 'Sync',
      onPressed: () {
        model.startSync();
      },
    );
  }
}
