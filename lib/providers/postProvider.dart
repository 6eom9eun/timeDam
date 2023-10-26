import 'package:flutter/material.dart';

/*
===Post Provider===
 */
class PostProvider with ChangeNotifier {
  String? _imageUrl;
  String? _text;

  String? get imageUrl => _imageUrl;
  String? get text => _text;

  set imageUrl(String? url) {
    _imageUrl = url;
    notifyListeners();
  }

  set text(String? text) {
    _text = text;
    notifyListeners();
  }
}