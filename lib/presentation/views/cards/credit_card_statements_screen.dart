import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../viewmodels/credit_card_statement_viewmodel.dart';
import '../../../data/models/credit_card_statement_model.dart';
import '../../../data/models/account_card_model.dart';

class CreditCardStatementsScreen extends StatefulWidget {
  final AccountCardModel card;
  const CreditCardStatementsScreen({super.key, required this.card});

  @override
  State<CreditCardStatementsScreen> createState() => _CreditCardStatementsScreenState();
}

class _CreditCardStatementsScreenState extends State<CreditCardStatementsScreen> {
  late CreditCardStatementViewModel _statementVM;

  @override
  void initState() {
    super.initState();
    _statementVM = CreditCardStatementViewModel();
    // Refresh statements when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _statementVM.fetchStatements(widget.card.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _statementVM,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Statements for ${widget.card.name}'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                _statementVM.fetchStatements(widget.card.id);
              },
            ),
          ],
        ),
        body: Consumer<CreditCardStatementViewModel>(
          builder: (context, vm, child) {
            if (vm.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (vm.error != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Error: ${vm.error}'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => vm.fetchStatements(widget.card.id),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }
            final now = DateTime.now();
            if (now.isBefore(widget.card.firstStatementDate!)) {
              final daysLeft = widget.card.firstStatementDate!.difference(now).inDays;
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Your first statement will be generated on ${_formatDate(widget.card.firstStatementDate!)} (in $daysLeft days).'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => vm.fetchStatements(widget.card.id),
                      child: const Text('Refresh'),
                    ),
                  ],
                ),
              );
            }
            if (vm.statements.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('No statements yet.'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => vm.fetchStatements(widget.card.id),
                      child: const Text('Refresh'),
                    ),
                  ],
                ),
              );
            }
            return RefreshIndicator(
              onRefresh: () async {
                await vm.fetchStatements(widget.card.id);
              },
              child: ListView.builder(
                itemCount: vm.statements.length,
                itemBuilder: (context, index) {
                  final statement = vm.statements[index];
                  return ListTile(
                    title: Text(_formatPeriod(statement.periodStart, statement.periodEnd)),
                    subtitle: Text('Due: ${_formatDate(statement.periodEnd)}'),
                    trailing: Icon(Icons.chevron_right),
                    onTap: () => _showStatementDetail(context, statement, widget.card),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  String _formatPeriod(DateTime start, DateTime end) {
    return '${_formatDate(start)} - ${_formatDate(end)} Statement';
  }

  String _formatDate(DateTime date) {
    return '${date.day} ${_monthName(date.month)} ${date.year}';
  }

  String _monthName(int month) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month];
  }

  void _showStatementDetail(BuildContext context, CreditCardStatementModel statement, AccountCardModel card) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _StatementDetailSheet(statement: statement, card: card),
    );
  }
}

class _StatementDetailSheet extends StatelessWidget {
  final CreditCardStatementModel statement;
  final AccountCardModel card;
  const _StatementDetailSheet({required this.statement, required this.card});

  @override
  Widget build(BuildContext context) {
    final totalSpent = statement.transactions.fold(0.0, (sum, t) => sum + t.amount);
    final totalRepaid = statement.repayments.fold(0.0, (sum, t) => sum + t.amount);
    
    // Calculate the original limit: current balance + total spent in this period
    final originalLimit = card.balance + totalSpent - totalRepaid;
    
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${card.name} (${card.number})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 8),
            Text('Period: ${_formatPeriod(statement.periodStart, statement.periodEnd)}'),
            Text('Total Limit: ${originalLimit.toStringAsFixed(2)}'), // Original limit you set
            Text('Spent: ${totalSpent.toStringAsFixed(2)}'),
            Text('Repaid: ${totalRepaid.toStringAsFixed(2)}'),
            Text('Remaining: ${card.balance.toStringAsFixed(2)}'), // Current balance
            if (statement.interestCharged > 0)
              Text('Interest Charged: ${statement.interestCharged.toStringAsFixed(2)}', style: const TextStyle(color: Colors.red)),
            const Divider(),
            const Text('Transactions:', style: TextStyle(fontWeight: FontWeight.bold)),
            if (statement.transactions.isEmpty)
              const Text('No transactions in this period')
            else
              ...statement.transactions.map((t) => ListTile(
                title: Text(t.category),
                subtitle: Text(t.description),
                trailing: Text('-${t.amount.toStringAsFixed(2)}'),
              )),
            const Divider(),
            const Text('Repayments:', style: TextStyle(fontWeight: FontWeight.bold)),
            if (statement.repayments.isEmpty)
              const Text('No repayments in this period')
            else
              ...statement.repayments.map((t) => ListTile(
                title: Text('Repayment'),
                subtitle: Text(t.description),
                trailing: Text('+${t.amount.toStringAsFixed(2)}'),
              )),
          ],
        ),
      ),
    );
  }

  String _formatPeriod(DateTime start, DateTime end) {
    return '${start.day} ${_monthName(start.month)} - ${end.day} ${_monthName(end.month)} ${end.year}';
  }

  String _monthName(int month) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month];
  }
} 