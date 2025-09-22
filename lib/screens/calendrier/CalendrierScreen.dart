import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/CommandeProvider.dart';
import 'CommandeCard.dart';

class CalendrierScreen extends StatefulWidget {
  const CalendrierScreen({super.key});

  @override
  State<CalendrierScreen> createState() => _CalendrierScreenState();
}

class _CalendrierScreenState extends State<CalendrierScreen> {
  DateTime selectedDate = DateTime.now();
  DateTime currentMonth = DateTime(DateTime.now().year, DateTime.now().month);
  final List<String> jours = ["Lun", "Mar", "Mer", "Jeu", "Ven", "Sam", "Dim"];

  // fonction pour mettre la première lettre en majuscule
  String capitalize(String s) =>
      s.isNotEmpty ? s[0].toUpperCase() + s.substring(1) : s;

  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<CommandeProvider>(context, listen: false).fetchCommandes());
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CommandeProvider>(context);
    final commandes = provider.commandes;

    final sdf = DateFormat("yyyy-MM-dd");

    final firstDayOfMonth = DateTime(currentMonth.year, currentMonth.month, 1);
    final daysInMonth =
        DateTime(currentMonth.year, currentMonth.month + 1, 0).day;
    final startOffset =
        (firstDayOfMonth.weekday + 6) % 7; // commence lundi

    final commandesDuJour = commandes.where((c) {
      try {
        final date = sdf.parse(c.date);
        return date.year == selectedDate.year &&
            date.month == selectedDate.month &&
            date.day == selectedDate.day;
      } catch (_) {
        return false;
      }
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      bottomNavigationBar: Container(
        height: 60,
        color: const Color(0xFF1E1E1E),
        child: const Center(
          child: Text(
            "Navigation",
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // mois et navigation
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon:
                      const Icon(Icons.chevron_left, color: Colors.white),
                      onPressed: () {
                        setState(() {
                          currentMonth = DateTime(
                              currentMonth.year, currentMonth.month - 1);
                        });
                      },
                    ),
                    Text(
                      "${capitalize(DateFormat.MMMM('fr').format(currentMonth))} ${currentMonth.year}",
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
                    ),
                    IconButton(
                      icon:
                      const Icon(Icons.chevron_right, color: Colors.white),
                      onPressed: () {
                        setState(() {
                          currentMonth = DateTime(
                              currentMonth.year, currentMonth.month + 1);
                        });
                      },
                    ),
                  ],
                ),
              ),
              // jours de la semaine
              Row(
                children: jours
                    .map((j) => Expanded(
                    child: Text(
                      j,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey),
                    )))
                    .toList(),
              ),
              const SizedBox(height: 4),

              // calendrier
              Column(
                children: [
                  for (int week = 0;
                  week < ((startOffset + daysInMonth) / 7).ceil();
                  week++)
                    Row(
                      children: List.generate(7, (dayIndex) {
                        int boxIndex = week * 7 + dayIndex;
                        int dayNumber = boxIndex - startOffset + 1;
                        if (boxIndex < startOffset ||
                            dayNumber > daysInMonth) {
                          return const Expanded(child: SizedBox());
                        } else {
                          final date = DateTime(
                              currentMonth.year, currentMonth.month, dayNumber);
                          final isToday = DateTime.now().year == date.year &&
                              DateTime.now().month == date.month &&
                              DateTime.now().day == date.day;
                          final isSelected = selectedDate.year == date.year &&
                              selectedDate.month == date.month &&
                              selectedDate.day == date.day;
                          final commandesPourLeJour = commandes.where((c) {
                            try {
                              final d = sdf.parse(c.date);
                              return d.year == date.year &&
                                  d.month == date.month &&
                                  d.day == date.day;
                            } catch (_) {
                              return false;
                            }
                          }).length;

                          return Expanded(
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  selectedDate = date;
                                });
                              },
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? const Color(0xFFFFC107)
                                          : Colors.transparent,
                                      shape: BoxShape.circle,
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      dayNumber.toString(),
                                      style: TextStyle(
                                        color: isSelected
                                            ? Colors.black
                                            : isToday
                                            ? const Color(0xFFFFC107)
                                            : Colors.white,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  if (commandesPourLeJour > 0 && !isSelected)
                                    Wrap(
                                      alignment: WrapAlignment.center,
                                      children: List.generate(
                                        commandesPourLeJour.clamp(0, 5),
                                            (_) => Container(
                                          width: 6,
                                          height: 6,
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 1),
                                          decoration: const BoxDecoration(
                                            color: Color(0xFFFFC107),
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      ),
                                    )
                                  else
                                    const SizedBox(height: 6),
                                ],
                              ),
                            ),
                          );
                        }
                      }),
                    ),
                ],
              ),

              // label du jour sélectionné
              Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Text(
                  "Commandes du ${selectedDate.day} ${capitalize(DateFormat.MMMM('fr').format(selectedDate))} ${selectedDate.year}",
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16),
                ),
              ),

              // commandes du jour
              ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: commandesDuJour.length,
                shrinkWrap: true, // prend juste l’espace nécessaire
                physics:
                const NeverScrollableScrollPhysics(), // désactive scroll interne
                separatorBuilder: (_, __) => const SizedBox(height: 6),
                itemBuilder: (_, index) =>
                    CommandeCard(commandesDuJour[index]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
