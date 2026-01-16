// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:ui_web' as ui;
import 'package:flutter/material.dart';

bool _mapViewRegistered = false;

Widget buildGoogleMapView(String embedUrl) {
  if (!_mapViewRegistered) {
    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(
      'google-map-embed',
      (viewId) {
        final iframe = html.IFrameElement()
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
