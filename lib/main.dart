import 'package:flutter/material.dart';
import 'core/di/injector.dart';
import 'app.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://wyrxnfsjzhvskfzzbwzf.supabase.co', // from Supabase dashboard
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Ind5cnhuZnNqemh2c2tmenpid3pmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzUwMzI2NTEsImV4cCI6MjA5MDYwODY1MX0.XcjA1mSQJ_Er3DDWGh-Qn6y5_bo9xYUE6PH60A31Spc', // from Supabase dashboard
  );

  await init();

  runApp(const MyApp());
}
