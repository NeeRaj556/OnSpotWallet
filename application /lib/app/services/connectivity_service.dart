import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  Stream<bool> checkRealConnection() async* {
    while (true) {
      try {
        final result = await InternetAddress.lookup('google.com');
        yield result.isNotEmpty && result[0].rawAddress.isNotEmpty;
      } on SocketException catch (_) {
        yield false;
      }
      await Future.delayed(const Duration(seconds: 1));
    }
  }

  Future<bool> isConnected() async {
    await Connectivity().checkConnectivity();
    // Check connectivity result
    // if (connectivityResult == ConnectivityResult.mobile) {
    //   return true;
    // } else if (connectivityResult == ConnectivityResult.wifi) {
    //   return true;
    // }
    return false;
  }
}
