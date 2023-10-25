import 'dart:async';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:uni_links/uni_links.dart';

import '../../../../../index.dart';

class HomeFragment extends StatefulWidget {
  const HomeFragment({
    super.key,
  });

  @override
  State<HomeFragment> createState() => _HomeFragmentState();
}

class _HomeFragmentState extends State<HomeFragment> {
  StreamSubscription? _sub;

  bool _initialUriIsHandled = false;

  @override
  void initState() {
    _handleIncomingLinks();
    _handleInitialUri();
    super.initState();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  Future<void> _handleInitialUri() async {
    if (!_initialUriIsHandled) {
      _initialUriIsHandled = true;
      try {
        final uri = await getInitialUri();
        if (uri != null) {
          setState(() {
            _routeByLink(uri);
          });
          log('Initial uri : $uri');
        }
      } catch (_) {
        log('Initial error : $_');
      }
    }
  }

  void _handleIncomingLinks() {
    if (!kIsWeb) {
      _sub = uriLinkStream.listen((uri) {
        if (uri != null) {
          setState(() {
            _routeByLink(uri);
          });
          log("Incoming link : $uri");
        }
      }, onError: (error) {
        log("Incoming error : $error");
      });
    }
  }

  void _routeByLink(Uri? uri) {
    if (uri != null) {
      final params = uri.queryParameters.entries.first;
      var key = params.key;
      var value = params.value;
      if (key == "CURRENT_KEY" && value.isNotEmpty) {
        /// TODO: DO SOMETHING WITH DEEP LINKING DATA
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const ResponsiveLayout(
      mobile: DashboardMobileBody(),
      desktop: DashboardDesktopBody(),
    );
  }
}
