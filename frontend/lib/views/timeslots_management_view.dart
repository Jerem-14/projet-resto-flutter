import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import '../models/timeslot.dart';

enum ViewMode { list, table, grouped }

class TimeslotsManagementView extends StatefulWidget {
  const TimeslotsManagementView({super.key});

  @override
  State<TimeslotsManagementView> createState() =>
      _TimeslotsManagementViewState();
}

class _TimeslotsManagementViewState extends State<TimeslotsManagementView> {
  List<Timeslot> timeslots = [];
  bool isLoading = true;
  String? errorMessage;
  ViewMode currentViewMode = ViewMode.list;

  @override
  void initState() {
    super.initState();
    _loadTimeslots();
  }

  Future<void> _loadTimeslots() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    final authService = Provider.of<AuthService>(context, listen: false);
    if (authService.jwtToken == null) {
      setState(() {
        isLoading = false;
        errorMessage = 'Token d\'authentification manquant';
      });
      return;
    }

    try {
      final response = await ApiService.getTimeslots(authService.jwtToken!);

      if (response['success']) {
        final List<dynamic> data = response['data'];
        setState(() {
          timeslots = data.map((json) => Timeslot.fromJson(json)).toList();
          timeslots.sort((a, b) => a.compareTo(b));
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
          errorMessage = response['message'] ?? 'Erreur lors du chargement';
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Erreur de connexion: $e';
      });
    }
  }

  Future<void> _showAddTimeslotDialog() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => const TimeslotFormDialog(),
    );

    if (result != null) {
      await _createTimeslot(result['time'], result['isActive']);
    }
  }

  Future<void> _showEditTimeslotDialog(Timeslot timeslot) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => TimeslotFormDialog(
        initialTime: timeslot.displayTime,
        initialIsActive: timeslot.isActive,
        isEditing: true,
      ),
    );

    if (result != null) {
      await _updateTimeslot(timeslot.id, result['time'], result['isActive']);
    }
  }

  Future<void> _createTimeslot(String time, bool isActive) async {
    final authService = Provider.of<AuthService>(context, listen: false);

    try {
      final response = await ApiService.createTimeslot(
        token: authService.jwtToken!,
        startTime: time,
        isActive: isActive,
      );

      if (response['success']) {
        _showSnackBar('Créneau créé avec succès', Colors.green);
        await _loadTimeslots();
      } else {
        _showSnackBar(response['message'], Colors.red);
      }
    } catch (e) {
      _showSnackBar('Erreur lors de la création: $e', Colors.red);
    }
  }

  Future<void> _updateTimeslot(int id, String? time, bool? isActive) async {
    final authService = Provider.of<AuthService>(context, listen: false);

    try {
      final response = await ApiService.updateTimeslot(
        token: authService.jwtToken!,
        timeslotId: id,
        startTime: time,
        isActive: isActive,
      );

      if (response['success']) {
        _showSnackBar('Créneau mis à jour avec succès', Colors.green);
        await _loadTimeslots();
      } else {
        _showSnackBar(response['message'], Colors.red);
      }
    } catch (e) {
      _showSnackBar('Erreur lors de la mise à jour: $e', Colors.red);
    }
  }

  Future<void> _deleteTimeslot(Timeslot timeslot) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text(
          'Êtes-vous sûr de vouloir supprimer le créneau ${timeslot.displayTime} ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final authService = Provider.of<AuthService>(context, listen: false);

      try {
        final response = await ApiService.deleteTimeslot(
          token: authService.jwtToken!,
          timeslotId: timeslot.id,
        );

        if (response['success']) {
          _showSnackBar('Créneau supprimé avec succès', Colors.green);
          await _loadTimeslots();
        } else {
          _showSnackBar(response['message'], Colors.red);
        }
      } catch (e) {
        _showSnackBar('Erreur lors de la suppression: $e', Colors.red);
      }
    }
  }

  Future<void> _toggleTimeslotStatus(Timeslot timeslot) async {
    await _updateTimeslot(timeslot.id, null, !timeslot.isActive);
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Gestion des Créneaux',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.orange,
        elevation: 0,
        actions: [
          PopupMenuButton<ViewMode>(
            icon: const Icon(Icons.view_module, color: Colors.white),
            onSelected: (mode) {
              setState(() {
                currentViewMode = mode;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: ViewMode.list,
                child: Row(
                  children: [
                    Icon(Icons.list),
                    SizedBox(width: 8),
                    Text('Liste'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: ViewMode.table,
                child: Row(
                  children: [
                    Icon(Icons.table_rows),
                    SizedBox(width: 8),
                    Text('Tableau'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: ViewMode.grouped,
                child: Row(
                  children: [
                    Icon(Icons.group_work),
                    SizedBox(width: 8),
                    Text('Groupé'),
                  ],
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadTimeslots,
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTimeslotDialog,
        backgroundColor: Colors.orange,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.orange),
            SizedBox(height: 16),
            Text('Chargement des créneaux...'),
          ],
        ),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              errorMessage!,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadTimeslots,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              child: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    if (timeslots.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.schedule, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Aucun créneau configuré',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Appuyez sur + pour ajouter un créneau',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    switch (currentViewMode) {
      case ViewMode.list:
        return _buildListView();
      case ViewMode.table:
        return _buildTableView();
      case ViewMode.grouped:
        return _buildGroupedView();
    }
  }

  Widget _buildListView() {
    return RefreshIndicator(
      onRefresh: _loadTimeslots,
      color: Colors.orange,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: timeslots.length,
        itemBuilder: (context, index) {
          final timeslot = timeslots[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: timeslot.isActive
                    ? Colors.green.withOpacity(0.1)
                    : Colors.red.withOpacity(0.1),
                child: Icon(
                  Icons.schedule,
                  color: timeslot.isActive ? Colors.green : Colors.red,
                ),
              ),
              title: Text(
                timeslot.displayTime,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(timeslot.period),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: timeslot.isActive ? Colors.green : Colors.red,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          timeslot.isActive ? 'Actif' : 'Inactif',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              trailing: PopupMenuButton(
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'edit',
                    child: const Row(
                      children: [
                        Icon(Icons.edit),
                        SizedBox(width: 8),
                        Text('Modifier'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'toggle',
                    child: Row(
                      children: [
                        Icon(
                          timeslot.isActive
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        const SizedBox(width: 8),
                        Text(timeslot.isActive ? 'Désactiver' : 'Activer'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: const Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Supprimer', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
                onSelected: (value) {
                  switch (value) {
                    case 'edit':
                      _showEditTimeslotDialog(timeslot);
                      break;
                    case 'toggle':
                      _toggleTimeslotStatus(timeslot);
                      break;
                    case 'delete':
                      _deleteTimeslot(timeslot);
                      break;
                  }
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTableView() {
    return RefreshIndicator(
      onRefresh: _loadTimeslots,
      color: Colors.orange,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              child: Table(
                border: TableBorder.all(color: Colors.grey.shade300),
                columnWidths: const {
                  0: FlexColumnWidth(2),
                  1: FlexColumnWidth(2),
                  2: FlexColumnWidth(1.5),
                  3: FlexColumnWidth(2),
                },
                children: [
                  // Header
                  TableRow(
                    decoration: BoxDecoration(color: Colors.orange.shade50),
                    children: const [
                      Padding(
                        padding: EdgeInsets.all(12),
                        child: Text(
                          'Heure',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(12),
                        child: Text(
                          'Période',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(12),
                        child: Text(
                          'Statut',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(12),
                        child: Text(
                          'Actions',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  // Data rows
                  ...timeslots
                      .map(
                        (timeslot) => TableRow(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(12),
                              child: Text(
                                timeslot.displayTime,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(12),
                              child: Text(timeslot.period),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: timeslot.isActive
                                      ? Colors.green
                                      : Colors.red,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  timeslot.isActive ? 'Actif' : 'Inactif',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, size: 18),
                                    onPressed: () =>
                                        _showEditTimeslotDialog(timeslot),
                                    color: Colors.blue,
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      timeslot.isActive
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                      size: 18,
                                    ),
                                    onPressed: () =>
                                        _toggleTimeslotStatus(timeslot),
                                    color: Colors.orange,
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, size: 18),
                                    onPressed: () => _deleteTimeslot(timeslot),
                                    color: Colors.red,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                      .toList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupedView() {
    // Grouper les créneaux par période
    final groupedTimeslots = <String, List<Timeslot>>{};

    for (final timeslot in timeslots) {
      final period = timeslot.period;
      if (!groupedTimeslots.containsKey(period)) {
        groupedTimeslots[period] = [];
      }
      groupedTimeslots[period]!.add(timeslot);
    }

    // Ordre des périodes
    final periodOrder = ['Déjeuner', 'Dîner', 'Autre'];
    final sortedPeriods = groupedTimeslots.keys.toList();
    sortedPeriods.sort((a, b) {
      final indexA = periodOrder.indexOf(a);
      final indexB = periodOrder.indexOf(b);
      if (indexA == -1 && indexB == -1) return a.compareTo(b);
      if (indexA == -1) return 1;
      if (indexB == -1) return -1;
      return indexA.compareTo(indexB);
    });

    return RefreshIndicator(
      onRefresh: _loadTimeslots,
      color: Colors.orange,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: sortedPeriods.length,
        itemBuilder: (context, index) {
          final period = sortedPeriods[index];
          final periodsTimeslots = groupedTimeslots[period]!;

          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _getPeriodColor(period),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(_getPeriodIcon(period), color: Colors.white),
                      const SizedBox(width: 12),
                      Text(
                        period,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${periodsTimeslots.length} créneaux',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                ...periodsTimeslots
                    .map(
                      (timeslot) => ListTile(
                        leading: CircleAvatar(
                          radius: 16,
                          backgroundColor: timeslot.isActive
                              ? Colors.green.withOpacity(0.1)
                              : Colors.red.withOpacity(0.1),
                          child: Icon(
                            Icons.schedule,
                            size: 16,
                            color: timeslot.isActive
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                        title: Text(
                          timeslot.displayTime,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        subtitle: Container(
                          margin: const EdgeInsets.only(top: 4),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: timeslot.isActive
                                      ? Colors.green
                                      : Colors.red,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  timeslot.isActive ? 'Actif' : 'Inactif',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, size: 18),
                              onPressed: () =>
                                  _showEditTimeslotDialog(timeslot),
                              color: Colors.blue,
                            ),
                            IconButton(
                              icon: Icon(
                                timeslot.isActive
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                size: 18,
                              ),
                              onPressed: () => _toggleTimeslotStatus(timeslot),
                              color: Colors.orange,
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, size: 18),
                              onPressed: () => _deleteTimeslot(timeslot),
                              color: Colors.red,
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ],
            ),
          );
        },
      ),
    );
  }

  Color _getPeriodColor(String period) {
    switch (period) {
      case 'Déjeuner':
        return Colors.blue;
      case 'Dîner':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getPeriodIcon(String period) {
    switch (period) {
      case 'Déjeuner':
        return Icons.wb_sunny;
      case 'Dîner':
        return Icons.nights_stay;
      default:
        return Icons.schedule;
    }
  }
}

// Dialog pour ajouter/modifier un créneau
class TimeslotFormDialog extends StatefulWidget {
  final String? initialTime;
  final bool initialIsActive;
  final bool isEditing;

  const TimeslotFormDialog({
    super.key,
    this.initialTime,
    this.initialIsActive = true,
    this.isEditing = false,
  });

  @override
  State<TimeslotFormDialog> createState() => _TimeslotFormDialogState();
}

class _TimeslotFormDialogState extends State<TimeslotFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _timeController;
  late bool _isActive;

  @override
  void initState() {
    super.initState();
    _timeController = TextEditingController(text: widget.initialTime ?? '');
    _isActive = widget.initialIsActive;
  }

  @override
  void dispose() {
    _timeController.dispose();
    super.dispose();
  }

  void _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime:
          _parseTime(_timeController.text) ??
          const TimeOfDay(hour: 12, minute: 0),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(
              context,
            ).colorScheme.copyWith(primary: Colors.orange),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _timeController.text = _formatTime(picked);
      });
    }
  }

  TimeOfDay? _parseTime(String timeString) {
    if (timeString.isEmpty) return null;
    final parts = timeString.split(':');
    if (parts.length != 2) return null;

    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);

    if (hour == null || minute == null) return null;
    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) return null;

    return TimeOfDay(hour: hour, minute: minute);
  }

  String _formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  String? _validateTime(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez sélectionner une heure';
    }

    if (!Timeslot.isValidTime(value)) {
      return 'Format d\'heure invalide (HH:MM)';
    }

    if (!Timeslot.isInAllowedRange(value)) {
      return 'L\'heure doit être entre 12:00 et 23:59';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.isEditing ? 'Modifier le créneau' : 'Nouveau créneau',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _timeController,
              decoration: InputDecoration(
                labelText: 'Heure de début',
                hintText: 'HH:MM',
                prefixIcon: const Icon(Icons.schedule),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.access_time),
                  onPressed: _selectTime,
                ),
                border: const OutlineInputBorder(),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.orange),
                ),
              ),
              validator: _validateTime,
              readOnly: true,
              onTap: _selectTime,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('Statut:'),
                const SizedBox(width: 16),
                Expanded(
                  child: SwitchListTile(
                    value: _isActive,
                    onChanged: (value) {
                      setState(() {
                        _isActive = value;
                      });
                    },
                    title: Text(_isActive ? 'Actif' : 'Inactif'),
                    activeColor: Colors.orange,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.pop(context, {
                'time': _timeController.text,
                'isActive': _isActive,
              });
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
          ),
          child: Text(widget.isEditing ? 'Modifier' : 'Créer'),
        ),
      ],
    );
  }
}
