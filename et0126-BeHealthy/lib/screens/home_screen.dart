import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/habit.dart';
import '../services/habit_service.dart';
import '../widgets/habit_canvas_progress.dart';
import 'crear_habito_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final HabitService _habitService = HabitService();
  List<Habit> _habits = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarHabitos();
  }

  Future<void> _cargarHabitos() async {
    setState(() => _isLoading = true);
    try {
      final habitosCargados = await _habitService.listar();
      if (mounted) {
        setState(() {
          _habits = habitosCargados;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _toggleHabit(int index) {
    setState(() {
      _habits[index].isCompleted = !_habits[index].isCompleted;
    });
  }

  Future<void> _cerrarSesion() async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (_) {
      // Ignora error si Firebase no estaba inicializado en web
    }
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    int completedCount = _habits.where((h) => h.isCompleted).length;
    double progress = _habits.isEmpty ? 0.0 : completedCount / _habits.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('BeHealthy - Hábitos'),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            tooltip: 'Cerrar sesión',
            icon: const Icon(Icons.logout),
            onPressed: _cerrarSesion,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                const SizedBox(height: 16),
                const Icon(
                  Icons.favorite,
                  size: 60,
                  color: Colors.teal,
                ),
                const SizedBox(height: 12),
                HabitCanvasProgress(progress: progress),
                const SizedBox(height: 12),
                Text(
                  'Completados: $completedCount de ${_habits.length}',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const Divider(height: 32, thickness: 1),
                Expanded(
                  child: _habits.isEmpty
                      ? const Center(
                          child: Text(
                            'No hay hábitos registrados.\n¡Agrega uno nuevo con el botón +!',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _habits.length,
                          itemBuilder: (context, index) {
                            final habit = _habits[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 6),
                              child: ListTile(
                                leading: Checkbox(
                                  value: habit.isCompleted,
                                  onChanged: (bool? value) =>
                                      _toggleHabit(index),
                                ),
                                title: Text(
                                  habit.title,
                                  style: TextStyle(
                                    decoration: habit.isCompleted
                                        ? TextDecoration.lineThrough
                                        : null,
                                  ),
                                ),
                                subtitle: Text('Categoría: ${habit.category}'),
                                trailing: Icon(
                                  habit.isCompleted
                                      ? Icons.check_circle
                                      : Icons.radio_button_unchecked,
                                  color: habit.isCompleted
                                      ? Colors.teal
                                      : Colors.grey,
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final seAgregoNuevo = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CrearHabitoScreen(),
            ),
          );

          if (seAgregoNuevo == true) {
            _cargarHabitos();
          }
        },
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add),
      ),
    );
  }
}
