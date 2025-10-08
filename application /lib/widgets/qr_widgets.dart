import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'dart:convert';
import '../models/token_model.dart';

/// QR Code display widget
class QRDisplayWidget extends StatelessWidget {
  final String data;
  final double size;

  const QRDisplayWidget({
    super.key,
    required this.data,
    this.size = 200.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: QrImageView(
        data: data,
        version: QrVersions.auto,
        size: size,
        backgroundColor: Colors.white,
      ),
    );
  }
}

/// QR Code scanner widget
class QRScannerWidget extends StatefulWidget {
  final Function(String) onQRScanned;

  const QRScannerWidget({
    super.key,
    required this.onQRScanned,
  });

  @override
  State<QRScannerWidget> createState() => _QRScannerWidgetState();
}

class _QRScannerWidgetState extends State<QRScannerWidget> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  bool _hasScanned = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Code'),
        centerTitle: true,
        backgroundColor: Colors.black87,
      ),
      body: Column(
        children: [
          Expanded(
            flex: 5,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
              overlay: QrScannerOverlayShape(
                borderColor: Theme.of(context).colorScheme.primary,
                borderRadius: 10,
                borderLength: 30,
                borderWidth: 10,
                cutOutSize: 300,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              color: Colors.black87,
              child: const Center(
                child: Text(
                  'Align QR code within frame',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      if (!_hasScanned && scanData.code != null) {
        _hasScanned = true;
        controller.pauseCamera();
        widget.onQRScanned(scanData.code!);
        Navigator.pop(context);
      }
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}

/// Invoice QR generation dialog
class InvoiceQRDialog extends StatefulWidget {
  final String deviceId;
  final Function(String to, int amount, int ttl) onGenerate;

  const InvoiceQRDialog({
    super.key,
    required this.deviceId,
    required this.onGenerate,
  });

  @override
  State<InvoiceQRDialog> createState() => _InvoiceQRDialogState();
}

class _InvoiceQRDialogState extends State<InvoiceQRDialog> {
  final _toController = TextEditingController();
  final _amountController = TextEditingController();
  final _ttlController = TextEditingController(text: '10');
  String? _generatedQR;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Generate Invoice QR'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_generatedQR != null) ...[
              QRDisplayWidget(data: _generatedQR!, size: 200),
              const SizedBox(height: 16),
              Text(
                'Show this QR to sender',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 16),
            ] else ...[
              TextField(
                controller: _toController,
                decoration: const InputDecoration(
                  labelText: 'To (Device ID)',
                  hintText: 'Leave blank for quick demo',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _ttlController,
                decoration: const InputDecoration(
                  labelText: 'TTL (Hops)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ],
        ),
      ),
      actions: [
        if (_generatedQR != null)
          TextButton(
            onPressed: () {
              setState(() {
                _generatedQR = null;
              });
            },
            child: const Text('New Invoice'),
          ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
        if (_generatedQR == null)
          ElevatedButton(
            onPressed: _generateInvoice,
            child: const Text('Generate'),
          ),
      ],
    );
  }

  void _generateInvoice() {
    final to =
        _toController.text.isEmpty ? widget.deviceId : _toController.text;
    final amount = int.tryParse(_amountController.text) ?? 0;
    final ttl = int.tryParse(_ttlController.text) ?? 10;

    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter valid amount')),
      );
      return;
    }

    // Create invoice data
    final invoiceData = {
      'type': 'invoice',
      'to': to,
      'amount': amount,
      'ttl': ttl,
    };

    setState(() {
      _generatedQR = jsonEncode(invoiceData);
    });

    widget.onGenerate(to, amount, ttl);
  }

  @override
  void dispose() {
    _toController.dispose();
    _amountController.dispose();
    _ttlController.dispose();
    super.dispose();
  }
}

/// Token QR display dialog
class TokenQRDialog extends StatelessWidget {
  final Token token;

  const TokenQRDialog({
    super.key,
    required this.token,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Payment Token QR'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          QRDisplayWidget(
            data: token.toCompactBase64(),
            size: 250,
          ),
          const SizedBox(height: 16),
          Text(
            'Transaction: ${token.txId.substring(0, 8)}...',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          Text(
            'Amount: ${token.amount}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          Text(
            'TTL: ${token.ttl} hops',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
