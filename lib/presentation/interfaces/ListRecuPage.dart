import 'package:flutter/material.dart';
import '../../models/RecuModel.dart';
import '../../core/delayed_animation.dart';
import 'RecuDetailPage.dart';

class RapportRecuPage extends StatefulWidget {
  const RapportRecuPage({super.key});

  @override
  _RapportRecuPageState createState() => _RapportRecuPageState();
}

class _RapportRecuPageState extends State<RapportRecuPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Rapport des reçus"),
        backgroundColor: Colors.green,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "Jour"),
            Tab(text: "Semaine"),
            Tab(text: "Mois"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          buildList(getDailyRecu()),
          buildList(getWeeklyRecu()),
          buildList(getMonthlyRecu()),
        ],
      ),
    );
  }

  // ---------------------- FILTRAGE ---------------------- //

  List<Recu> getDailyRecu() {
    final today = DateTime.now();
    return RecuModel.recuList.where((r) =>
    r.date.year == today.year &&
        r.date.month == today.month &&
        r.date.day == today.day
    ).toList();
  }

  List<Recu> getWeeklyRecu() {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    return RecuModel.recuList
        .where((r) => r.date.isAfter(weekAgo) && r.date.isBefore(now))
        .toList();
  }

  List<Recu> getMonthlyRecu() {
    final now = DateTime.now();
    final monthAgo = now.subtract(const Duration(days: 30));
    return RecuModel.recuList
        .where((r) => r.date.isAfter(monthAgo) && r.date.isBefore(now))
        .toList();
  }

  // ---------------------- LISTE + TOTAL ---------------------- //

  Widget buildList(List<Recu> data) {
    double total = data.fold(0.0, (sum, r) => sum + r.total);

    return Column(
      children: [
        // ---- Bandeau Total ----
        Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "TOTAL",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "$total FC",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),

        // ---- Liste des reçus ----
        Expanded(
          child: data.isEmpty
              ? const Center(child: Text("Aucun reçu trouvé"))
              : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: data.length,
            itemBuilder: (context, index) {
              final recu = data[index];

              return DelayedAnimation(
                delay: index * 80,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RecuDetailPage(recu: recu),
                      ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Reçu ID
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Reçu N° ${recu.id}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 17,
                              ),
                            ),
                            const Icon(Icons.arrow_forward_ios, size: 18),
                          ],
                        ),

                        const SizedBox(height: 8),

                        // PDV & Employé
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(recu.pdv),
                            Text(
                              recu.employe,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 6),

                        // Date & Total
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "${recu.date.day}/${recu.date.month}/${recu.date.year}",
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                            Text(
                              "${recu.total} FC",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
