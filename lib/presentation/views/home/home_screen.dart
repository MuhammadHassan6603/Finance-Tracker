import 'package:finance_tracker/core/services/session_manager.dart';
import 'package:finance_tracker/presentation/views/home/widgets/account_cards_widget.dart';
import 'package:finance_tracker/presentation/views/home/widgets/analaytic_row_widget.dart';
import 'package:finance_tracker/presentation/views/home/widgets/balance_card_widget.dart';
import 'package:finance_tracker/presentation/views/home/widgets/net_value_row_widget.dart';
import 'package:finance_tracker/presentation/views/home/widgets/over_view_data_widget.dart';
import 'package:finance_tracker/presentation/views/home/widgets/upcoming_card_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../viewmodels/account_card_viewmodel.dart';
import '../../../viewmodels/credit_card_statement_viewmodel.dart';
import '../../../viewmodels/transaction_viewmodel.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Trigger statement check after build
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final accountCardVM = context.read<AccountCardViewModel>();
      final transactionVM = context.read<TransactionViewModel>();
      final statementVM = CreditCardStatementViewModel();
      
      // First, create initial statements for existing credit cards
      for (final card in accountCardVM.accountCards.where((c) => c.type == 'Credit Card')) {
        await statementVM.createInitialStatementForCard(card, card.balance);
      }
      
      // Then check and close statements
      await statementVM.checkAndCloseStatementsForCards(
        accountCardVM.accountCards,
        transactionVM.transactions,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 12),
          child: Column(
            spacing: 16,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              NetValueRowWidget(),
              AnalyticsRow(),
              AccountCardsWidget(),
              BalanceCard(),
              UpcomingPaymentsCard(),
              DataOverViewCard(),
            ],
          ),
        ),
      ),
    );
  }
}
