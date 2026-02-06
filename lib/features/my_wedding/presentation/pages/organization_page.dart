import 'package:flutter/material.dart';
import '/core/design/design.dart';
import 'agenda_page.dart';
import 'budget_page.dart';

/// Organization Page - Unified view of agenda and budget with tabs
class OrganizationPage extends StatefulWidget {
  const OrganizationPage({
    super.key,
    required this.weddingId,
    this.budgetMin,
    this.budgetMax,
    this.currency,
    this.initialTab = 0,
  });

  final String weddingId;
  final double? budgetMin;
  final double? budgetMax;
  final String? currency;
  final int initialTab;

  @override
  State<OrganizationPage> createState() => _OrganizationPageState();
}

class _OrganizationPageState extends State<OrganizationPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTab,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LynewedColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            const Divider(height: 1, color: LynewedColors.gray200),
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Agenda tab - embed AgendaPage content directly
                  _AgendaTabContent(weddingId: widget.weddingId),
                  // Budget tab - embed BudgetPage content directly
                  _BudgetTabContent(
                    weddingId: widget.weddingId,
                    budgetMin: widget.budgetMin,
                    budgetMax: widget.budgetMax,
                    currency: widget.currency,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 20, 20, 12),
      child: Row(
        children: [
          LynewedComponentStyles.backButton(context),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              'ORGANIZATION',
              style: LynewedTextStyles.sheetTitle.copyWith(fontSize: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: LynewedColors.gray200, width: 1),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: LynewedColors.textPrimary,
        unselectedLabelColor: LynewedColors.textSecondary,
        labelStyle: LynewedTextStyles.bodyMedium.copyWith(
          fontWeight: FontWeight.w500,
        ),
        unselectedLabelStyle: LynewedTextStyles.bodyMedium,
        indicatorColor: LynewedColors.primary,
        indicatorWeight: 2,
        tabs: const [
          Tab(text: 'Agenda'),
          Tab(text: 'Budget'),
        ],
      ),
    );
  }
}

/// Wrapper that embeds AgendaPage content without its own Scaffold/header.
/// Uses a Navigator to contain the AgendaPage as a standalone widget.
class _AgendaTabContent extends StatelessWidget {
  const _AgendaTabContent({required this.weddingId});

  final String weddingId;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: Navigator(
        onGenerateRoute: (settings) => MaterialPageRoute(
          builder: (context) => AgendaPage(
            weddingId: weddingId,
            showHeader: false,
          ),
        ),
      ),
    );
  }
}

/// Wrapper that embeds BudgetPage content without its own Scaffold/header.
class _BudgetTabContent extends StatelessWidget {
  const _BudgetTabContent({
    required this.weddingId,
    this.budgetMin,
    this.budgetMax,
    this.currency,
  });

  final String weddingId;
  final double? budgetMin;
  final double? budgetMax;
  final String? currency;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: Navigator(
        onGenerateRoute: (settings) => MaterialPageRoute(
          builder: (context) => BudgetPage(
            weddingId: weddingId,
            budgetMin: budgetMin,
            budgetMax: budgetMax,
            currency: currency,
            showHeader: false,
          ),
        ),
      ),
    );
  }
}
