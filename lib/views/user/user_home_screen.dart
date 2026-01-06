import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../models/field_model.dart';
import '../../models/user_model.dart';
import '../auth/login_screen.dart';
import '../auth/role_selection_screen.dart';
import './field_details_screen.dart';
import 'bookings_screen.dart';
import 'profile_screen.dart';
import '../../models/filter_model.dart';
import '../../providers/field_provider.dart';
import './filter_screen.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  int _currentIndex = 0;
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Load fields when the screen is created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FieldProvider>().loadFields();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _signOut() async {
    try {
      await Provider.of<AuthProvider>(context, listen: false).signOut();
      Provider.of<BookingProvider>(context, listen: false).clearAll();
      // If you have other providers to clear, do it here

      if (!mounted) return;

      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  Widget _buildHomeTab() {
    final fieldProvider = context.watch<FieldProvider>();
    final theme = Theme.of(context);

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Search Bar
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Rechercher un terrain...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            setState(() {
                              _searchController.clear();
                              _searchQuery = '';
                            });
                            fieldProvider.searchQuery = '';
                          },
                        )
                      : null,
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                  fieldProvider.searchQuery = value;
                },
              ),
              const SizedBox(height: 16),
              // Filter Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final result = await showModalBottomSheet<FilterModel>(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) => DraggableScrollableSheet(
                        initialChildSize: 0.9,
                        maxChildSize: 0.9,
                        minChildSize: 0.5,
                        builder: (context, scrollController) => Container(
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(20),
                            ),
                          ),
                          child: FilterScreen(
                            initialFilters: fieldProvider.currentFilters,
                          ),
                        ),
                      ),
                    );

                    if (result == null) {
                      fieldProvider.clearFilters();
                    } else {
                      fieldProvider.applyFilters(result);
                    }
                  },
                  icon: const Icon(Icons.filter_list),
                  label: const Text('Filtres'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Fields List
        Expanded(
          child: fieldProvider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : fieldProvider.error != null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 48,
                            color: theme.colorScheme.error,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            fieldProvider.error!,
                            style: theme.textTheme.titleLarge,
                          ),
                        ],
                      ),
                    )
                  : fieldProvider.fields.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.search_off,
                                size: 48,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Aucun terrain trouvé',
                                style: theme.textTheme.titleLarge,
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: fieldProvider.fields.length,
                          itemBuilder: (context, index) {
                            final field = fieldProvider.fields[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 16),
                              child: InkWell(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          FieldDetailsScreen(field: field),
                                    ),
                                  );
                                },
                                borderRadius: BorderRadius.circular(16),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    // Field Image
                                    ClipRRect(
                                      borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(16),
                                      ),
                                      child: field.images.isNotEmpty
                                          ? Image.network(
                                              field.images.first,
                                              height: 200,
                                              width: double.infinity,
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (context, error, stackTrace) {
                                                return Container(
                                                  height: 200,
                                                  color: theme.colorScheme
                                                      .surfaceVariant,
                                                  child: Icon(
                                                    Icons.sports_soccer,
                                                    size: 50,
                                                    color: theme.colorScheme
                                                        .onSurfaceVariant,
                                                  ),
                                                );
                                              },
                                            )
                                          : Container(
                                              height: 200,
                                              color: theme
                                                  .colorScheme.surfaceVariant,
                                              child: Icon(
                                                Icons.sports_soccer,
                                                size: 50,
                                                color: theme.colorScheme
                                                    .onSurfaceVariant,
                                              ),
                                            ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  field.name,
                                                  style: theme
                                                      .textTheme.titleLarge,
                                                ),
                                              ),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 12,
                                                  vertical: 6,
                                                ),
                                                decoration: BoxDecoration(
                                                  color:
                                                      theme.colorScheme.primary,
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                ),
                                                child: Text(
                                                  '${field.pricePerHour.toStringAsFixed(2)} TND/h',
                                                  style: TextStyle(
                                                    color: theme
                                                        .colorScheme.onPrimary,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            field.description,
                                            style: theme.textTheme.bodyMedium
                                                ?.copyWith(
                                              color: theme
                                                  .colorScheme.onSurfaceVariant,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 16),
                                          Wrap(
                                            spacing: 8,
                                            runSpacing: 8,
                                            children: [
                                              if (field.hasParking)
                                                _buildFeatureChip(
                                                  icon: Icons.local_parking,
                                                  label: 'Parking',
                                                ),
                                              if (field.hasLighting)
                                                _buildFeatureChip(
                                                  icon: Icons.lightbulb_outline,
                                                  label: 'Éclairage',
                                                ),
                                              if (field.hasShowers)
                                                _buildFeatureChip(
                                                  icon: Icons.shower_outlined,
                                                  label: 'Douches',
                                                ),
                                              if (field.hasChangingRooms)
                                                _buildFeatureChip(
                                                  icon: Icons
                                                      .dry_cleaning_outlined,
                                                  label: 'Vestiaires',
                                                ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
        ),
      ],
    );
  }

  Widget _buildFeatureChip({
    required IconData icon,
    required String label,
  }) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    final isGuest = user == null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('FieldReserve Tunisia'),
        leading: isGuest
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (_) => const RoleSelectionScreen(),
                    ),
                  );
                },
                tooltip: 'Retour',
              )
            : null,
        automaticallyImplyLeading: !isGuest,
        actions: [
          if (!isGuest)
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: _signOut,
            )
          else
            IconButton(
              icon: const Icon(Icons.login),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              },
              tooltip: 'Se connecter',
            ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildHomeTab(),
          if (!isGuest) const BookingsScreen() else _buildHomeTab(),
          if (!isGuest) const ProfileScreen() else _buildHomeTab(),
        ],
      ),
      bottomNavigationBar: isGuest
          ? null
          : NavigationBar(
              selectedIndex: _currentIndex,
              onDestinationSelected: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home),
                  label: 'Accueil',
                ),
                NavigationDestination(
                  icon: Icon(Icons.calendar_today_outlined),
                  selectedIcon: Icon(Icons.calendar_today),
                  label: 'Réservations',
                ),
                NavigationDestination(
                  icon: Icon(Icons.person_outline),
                  selectedIcon: Icon(Icons.person),
                  label: 'Profil',
                ),
              ],
            ),
    );
  }
}
