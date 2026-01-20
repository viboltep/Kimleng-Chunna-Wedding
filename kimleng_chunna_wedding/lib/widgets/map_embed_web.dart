import 'dart:ui_web' as ui;
import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

bool _mapViewRegistered = false;

Widget buildGoogleMapView(String embedUrl) {
  if (!_mapViewRegistered) {
    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(
      'google-map-embed',
      (viewId) {
        final iframe = web.HTMLIFrameElement()
          ..src = embedUrl
          ..style.border = '0'
          ..style.width = '100%'
          ..style.height = '100%'
          ..allowFullscreen = true;
        return iframe;
      },
    );
    _mapViewRegistered = true;
  }

  return const HtmlElementView(viewType: 'google-map-embed');
}
