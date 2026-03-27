import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'features/member/data/models/member_model.dart';
import 'features/member/presentation/pages/member_page.dart';
import 'features/member/presentation/providers/member_provider.dart';
import 'features/saving/data/models/saving_model.dart';
import 'features/saving/presentation/providers/saving_provider.dart';
import 'features/withdrawal/data/models/withdrawal_model.dart';
import 'features/withdrawal/presentation/providers/withdrawal_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(MemberAdapter());
  await Hive.openBox<Member>('members');

  Hive.registerAdapter(SavingAdapter());
  await Hive.openBox<Saving>('savings');

  Hive.registerAdapter(WithdrawalAdapter());
  await Hive.openBox<Withdrawal>('withdrawals');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MemberProvider()),
        ChangeNotifierProvider(create: (_) => SavingProvider()),
        ChangeNotifierProvider(create: (_) => WithdrawalProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: const MemberPage(),
      ),
    );
  }
}
