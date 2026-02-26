import 'dart:io';
import 'package:flutter/material.dart';
import '../../core/delayed_animation.dart';
import '../../models/TicketItem.dart';
import '../../models/produit.dart';
import '../../models/categorie.dart';
import '../../service/db_helper.dart';
import '../../presentation/interfaces/ticket.dart';

class VentePage extends StatefulWidget {
  @override
  _VentePageState createState() => _VentePageState();
}

class _VentePageState extends State<VentePage> {
  List<Article> allArticles = [];
  List<Categorie> dbCategories = [];
  List<TicketItem> ticket = [];

  String selectedCategory = "Toutes les catégories";

  GlobalKey ticketKey = GlobalKey();
  OverlayEntry? overlayEntry;
  late GlobalKey<AnimatedTicketCounterState> counterKey;

  final TextEditingController searchController = TextEditingController();
  final FocusNode searchFocus = FocusNode();
  bool isSearching = false;
  bool dropdownOpen = false;

  @override
  void initState() {
    super.initState();
    counterKey = GlobalKey<AnimatedTicketCounterState>();
    loadData();
  }

  Future<void> loadData() async {
    final articles = await DBHelper().getAllArticles();
    final categoriesList = await DBHelper().getCategories(); // List<String>

    setState(() {
      allArticles = articles;
      dbCategories = categoriesList
          .where((c) => c != null)
          .map((c) => Categorie(nom: c.toString()))
          .toList();

      dbCategories.insert(0, Categorie(nom: "Toutes les catégories"));
    });
  }

  List<Article> get filteredArticles {
    String q = searchController.text.trim().toLowerCase();

    return allArticles.where((a) {
      bool matchCategory = selectedCategory == "Toutes les catégories"
          ? true
          : a.categorie == selectedCategory;

      bool matchSearch = q.isEmpty
          ? true
          : a.nom.toLowerCase().contains(q);

      return matchCategory && matchSearch;
    }).toList();
  }

  void addToTicket(Article article, BuildContext context, GlobalKey imageKey) {
    final renderBox = imageKey.currentContext!.findRenderObject() as RenderBox;
    final imagePosition = renderBox.localToGlobal(Offset.zero);
    final imageSize = renderBox.size;

    final ticketBox = ticketKey.currentContext?.findRenderObject() as RenderBox?;
    Offset ticketOffset = Offset.zero;
    if (ticketBox != null) {
      ticketOffset = ticketBox.localToGlobal(Offset.zero);
    }

    overlayEntry = OverlayEntry(
      builder: (context) {
        return AnimatedImageFly(
          startOffset: imagePosition,
          endOffset: ticketOffset,
          size: imageSize,
          image: article.image.isNotEmpty ? article.image : 'assets/no_image.png',
          onEnd: () {
            overlayEntry?.remove();
            overlayEntry = null;

            setState(() {
              final index = ticket.indexWhere((t) => t.article.id == article.id);
              if (index != -1) {
                ticket[index].quantite++;
              } else {
                ticket.add(TicketItem(article: article));
              }
            });

            counterKey.currentState?.pop();
          },
        );
      },
    );

    Overlay.of(context)?.insert(overlayEntry!);
  }

  Map<String, double> get totalByDevise {
    Map<String, double> totals = {};
    for (var item in ticket) {
      totals[item.article.devise] =
          (totals[item.article.devise] ?? 0.0) + item.total;
    }
    return totals;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80),
        child: DelayedAnimation(
          delay: 0,
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            automaticallyImplyLeading: false,
            flexibleSpace: Container(
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),

              child: SafeArea(
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: Icon(Icons.arrow_back, color: Colors.green, size: 28),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          "Vente",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    ),
                    IconButton(icon: Icon(Icons.person_add, color: Colors.white), onPressed: () {}),
                    IconButton(
                      icon: Icon(isSearching ? Icons.close : Icons.search, color: Colors.white),
                      onPressed: () => toggleSearch(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          SizedBox(height: 12),

          // TOTAL PAR DEVISE
          if (ticket.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: DelayedAnimation(
                delay: 100,
                child: Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.shade300),
                    boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 4)],
                  ),
                  child: Column(
                    children: totalByDevise.entries.map((e) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Total ${e.key}", style: TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.bold)),
                            Text("${e.value} ${e.key}", style: TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),

          SizedBox(height: 12),

          // Combo + Search
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                AnimatedSwitcher(
                  duration: Duration(milliseconds: 200),
                  child: isSearching ? _buildSearchBar() : _buildComboBar(),
                ),
              ],
            ),
          ),

          SizedBox(height: 12),

          // LISTE ARTICLES
          Expanded(
            child: ListView.separated(
              itemCount: filteredArticles.length,
              itemBuilder: (context, index) {
                final article = filteredArticles[index];
                final imageKey = GlobalKey();
                return DelayedAnimation(
                  delay: 300 + (index * 100),
                  child: GestureDetector(
                    onTap: () => addToTicket(article, context, imageKey),
                    child: ListTile(
                      leading: _buildImageOrColor(article, imageKey),
                      title: Text(article.nom),
                      subtitle: Text("En stock: ${article.quantite}"),
                      trailing: Text("${article.prix.toStringAsFixed(2)} ${article.devise}"),
                    ),
                  ),
                );
              },
              separatorBuilder: (_, __) => Divider(thickness: 1, color: Colors.grey.shade300),
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => TicketPage(ticketItems: ticket)),
              );
            },
            backgroundColor: Colors.green,
            child: AnimatedTicketCounter(count: ticket.length, keyCounter: counterKey, key: ticketKey),
          ),
          SizedBox(height: 6),
          Text("Ouvrir un ticket", style: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildImageOrColor(Article a, GlobalKey key) {
    if (a.image.isNotEmpty && a.image != 'assets/no_image.png') {
      return Container(
        key: key,
        child: Image.file(File(a.image), width: 40, height: 40, fit: BoxFit.cover),
      );
    } else if (a.couleur != null) {
      return Container(
        key: key,
        width: 40,
        height: 40,
        color: Color(a.couleur!),
      );
    } else {
      return Container(
        key: key,
        width: 40,
        height: 40,
        color: Colors.grey[300],
        child: Icon(Icons.image_not_supported),
      );
    }
  }

  Widget _buildComboBar() {
    return Container(
      key: ValueKey('combo'),
      padding: EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(35),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 3)),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.list, color: Colors.green),
          SizedBox(width: 10),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedCategory,
                isExpanded: true,
                items: dbCategories.map((c) {
                  return DropdownMenuItem(
                    value: c.nom,
                    child: Text(c.nom),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value == null) return;
                  setState(() {
                    selectedCategory = value;
                    searchController.clear();
                    dropdownOpen = false;
                  });
                },
              ),
            ),
          ),
          GestureDetector(
            onTap: () => toggleSearch(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Icon(Icons.search, color: Colors.green),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      key: ValueKey('search'),
      padding: EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(35),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 3)),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.search, color: Colors.green),
          SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: searchController,
              focusNode: searchFocus,
              decoration: InputDecoration(
                hintText: "Rechercher un article...",
                border: InputBorder.none,
              ),
              onChanged: (value) => setState(() {}),
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                isSearching = false;
                searchController.clear();
                dropdownOpen = false;
                FocusScope.of(context).unfocus();
              });
            },
            child: Icon(Icons.close, color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }

  void toggleSearch() {
    setState(() {
      isSearching = !isSearching;
      dropdownOpen = false;
      if (isSearching) {
        Future.delayed(Duration(milliseconds: 100), () {
          FocusScope.of(context).requestFocus(searchFocus);
        });
      } else {
        searchController.clear();
        FocusScope.of(context).unfocus();
      }
    });
  }
}
