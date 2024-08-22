import 'dart:ui';
import 'package:flutter/foundation.dart' show kReleaseMode;
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../ui/ui_constants.dart';

final apiKey = dotenv.env['API_KEY'] ?? '';
const apiUrl = 'https://api.openai.com/v1/chat/completions';
