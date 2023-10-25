import 'package:flutter/material.dart';

/*
===Post Provider===
 */
class PostProvider with ChangeNotifier {
  String? _imageUrl;

  String? get imageUrl => _imageUrl;

  set imageUrl(String? url) {
    _imageUrl = url;
    notifyListeners();
  }
}