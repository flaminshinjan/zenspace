import 'package:flutter/material.dart';
import 'package:zenspace/core/config/app_config.dart';
import 'package:zenspace/core/config/flavor_config.dart';
import 'package:zenspace/main.dart';

void main() {
  FlavorConfig.initialize(Flavor.dev);
  runApp(const MyApp());
} 