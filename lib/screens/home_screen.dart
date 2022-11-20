import 'dart:html';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';
import 'package:second_brain/colors.dart';
import 'package:second_brain/models/document_model.dart';
import 'package:second_brain/models/error_model.dart';
import 'package:second_brain/repository/auth_repository.dart';
import 'package:second_brain/repository/document_repository.dart';
import 'package:second_brain/repository/socket_repository.dart';

import '../common/widgets/loader.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  void signOut(WidgetRef ref) {
    ref.read(authRepositoryProvider).signOut();
    ref.read(userProvider.notifier).update((state) => null);
  }

  void createDocument(BuildContext context, WidgetRef ref) async {
    String token = ref.read(userProvider)!.token;
    final navigator = Routemaster.of(context);
    final snackbar = ScaffoldMessenger.of(context);

    final errorModel =
        await ref.read(documentRepositoryProvider).createDocument(token);

    if (errorModel.data != null) {
      navigator.push('/document/${errorModel.data.id}');
    } else {
      snackbar.showSnackBar(SnackBar(content: Text(errorModel.error!)));
    }
  }

  void navigateToDocument(BuildContext context, String docId) {
    Routemaster.of(context).push('/document/$docId');
  }

  Future<ErrorModel?> getNotes(WidgetRef ref, String searchText) async {
    return await ref
        .watch(documentRepositoryProvider)
        .getDocuments(ref.watch(userProvider)!.token, searchText);
  }

  @override
  State<StatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  void signOut(WidgetRef ref) {
    ref.read(authRepositoryProvider).signOut();
    ref.read(userProvider.notifier).update((state) => null);
  }

  void createDocument(BuildContext context, WidgetRef ref) async {
    String token = ref.read(userProvider)!.token;
    final navigator = Routemaster.of(context);
    final snackbar = ScaffoldMessenger.of(context);

    final errorModel =
        await ref.read(documentRepositoryProvider).createDocument(token);

    if (errorModel.data != null) {
      _filteredList.add(errorModel.data);
      navigator.push('/document/${errorModel.data.id}');
    } else {
      snackbar.showSnackBar(SnackBar(content: Text(errorModel.error!)));
    }
  }

  void navigateToDocument(BuildContext context, String docId) {
    Routemaster.of(context).push('/document/$docId');
  }

  void filterList(WidgetRef ref, String searchText) async  {
    ErrorModel response = await ref.watch(documentRepositoryProvider)
      .getFilteredDocuments( ref.watch(userProvider)!.token, searchText);
    _filteredList = response.data;
  }

  void pinDocument(BuildContext context, WidgetRef ref, DocumentModel document) async {
    setState(() {
      _pinnedList.add(document);
      _filteredList.remove(document);
    });

    ref.watch(documentRepositoryProvider)
        .updateDocumentPinned( ref.watch(userProvider)!.token, document.id, true);
  }
  void unpinDocument(BuildContext context, WidgetRef ref, DocumentModel document) async {
    setState(() {
      _pinnedList.remove(document);
      _filteredList.add(document);
    });

    ref.watch(documentRepositoryProvider)
        .updateDocumentPinned( ref.watch(userProvider)!.token, document.id, false);
  }

  favoriteDocument(WidgetRef ref, DocumentModel document, bool fav) {
    setState(() {
      if(fav) {
        _favList.add(document);
      } else {
        _favList.remove(document);
      }
    });
    ref.watch(documentRepositoryProvider).updateDocumentFavorite(ref.watch(userProvider)!.token, document.id, fav);
  }

  void deleteDocument(BuildContext context, WidgetRef ref, DocumentModel document) async {
    setState(() {
      _filteredList.remove(document);
    });
    ref.watch(documentRepositoryProvider)
        .deleteDocument(
        ref.watch(userProvider)!.token,
        document.id);

  }

  void useFiltered(List fromRef, List filtered) {
    setState(() {
      _filteredList = filtered.isEmpty ? fromRef : filtered;
    });
  }

  List _filteredList = [];
  List _pinnedList = [];
  List _favList = [];
  double _height = 0.0;
  double _width = 0.0;

  SocketRepository socketRepository = SocketRepository();
  bool dataLoaded = false;
  bool showSearchBar = false;

  @override
  Widget build(BuildContext context) {
    TextEditingController searchController = TextEditingController();

    return Consumer(builder: (context, ref, child) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: lightSecondary,
          elevation: 0,
          actions: [
            IconButton(
                onPressed: () {
                  setState(() {
                    showSearchBar = !showSearchBar;
                    _height = !showSearchBar?  0.0: 130.0;
                    _width = !showSearchBar? 0.0: 300.0;
                  });
                },
                icon: const Icon(Icons.search, color: lightPrimary)),
            IconButton(
                onPressed: () => createDocument(context, ref),
                icon: const Icon(Icons.add, color: lightPrimary)),
            IconButton(
                onPressed: () => signOut(ref),
                icon: const Icon(
                  Icons.logout,
                  color: accent,
                ))
          ],
        ),
        body: FutureBuilder<ErrorModel?>(
          future: ref.watch(documentRepositoryProvider).getDocuments(
              ref.watch(userProvider)!.token, searchController.text),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Loader();
            } else {
              var data = snapshot.data!.data;
              if (dataLoaded == false && snapshot.hasData) {
                _filteredList = data[0];
                _pinnedList = data[1];
                _favList = data[2];
                dataLoaded = true;
              }
            }
            return Center(
                child: Column(
              children: [
                Center(
                  child: SizedBox(
                    width: 600,
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Container(
                        height: _height,
                        width: _width,
                        decoration: const BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            color: lightSecondary
                        ),
                        child: Form(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  decoration: const BoxDecoration(
                                      borderRadius: BorderRadius.all(Radius.circular(10)),
                                      color: lightPrimary
                                  ),
                                  child: TextFormField(
                                    textAlign: TextAlign.center,
                                    controller: searchController,
                                    style: const TextStyle(
                                      color: lightSecondary,
                                    ),
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      hintStyle: TextStyle(
                                        color: lightSecondary,
                                      ),
                                      hintText: 'Search For Your Notes',
                                    ),
                                    validator: (String? value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter some text';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ),
                              Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 16.0),
                                      child: ElevatedButton(
                                        onPressed: () {
                                          filterList(ref, searchController.text);
                                        },
                                        child: const Text('Submit'),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 16.0, horizontal: 10.0),
                                      child: ElevatedButton(
                                        onPressed: () {
                                          useFiltered(snapshot.data!.data, []);
                                        },
                                        child: const Text('Clear'),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                      width: 600,
                      margin: const EdgeInsets.only(top: 10),
                      child:Column(
                        children: [
                          if(_pinnedList.isNotEmpty) const Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                                "Pinned Notes",
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.w500,
                                fontSize: 15,
                                color: lightPrimary
                              ),
                            ),
                          ),
                          if(_pinnedList.isNotEmpty) Expanded(
                            child: ListView.builder(
                              itemCount: _pinnedList.length,
                                itemBuilder: (context, index) {
                                  DocumentModel document = _pinnedList[index];
                                  return InkWell(
                                    onTap: () => navigateToDocument(context, document.id),
                                    child: Column(
                                      children: [
                                        SizedBox(
                                            height: 50,
                                            child: Card(
                                                color: lightSecondary,
                                                child: Center(
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      if(!_favList.contains(document)) InkWell(
                                                        onTap: () => favoriteDocument(ref, document, true),
                                                        child: const Padding(
                                                          padding: EdgeInsets.all(8.0),
                                                          child: Icon(
                                                              Icons.star_outline,
                                                              color: lightPrimary
                                                          ),
                                                        ),
                                                      )
                                                      else
                                                        InkWell(
                                                          onTap: () => favoriteDocument(ref, document, false),
                                                          child: const Padding(
                                                            padding: EdgeInsets.all(8.0),
                                                            child: Icon(
                                                                Icons.star,
                                                                color: Colors.yellow
                                                            ),
                                                          ),
                                                        ),
                                                      Expanded(
                                                        child: Center(
                                                          child: Text(
                                                              document.title,
                                                              style: const TextStyle(
                                                                color: lightPrimary,
                                                                fontSize: 17,
                                                              )
                                                          ),
                                                        ),
                                                      ),
                                                      PopupMenuButton(
                                                        onSelected: (String value){
                                                          switch(value) {
                                                            case 'Delete':
                                                              deleteDocument(context, ref, document);
                                                              break;
                                                            case 'UnPin':
                                                              unpinDocument(context, ref, document);
                                                              break;
                                                          }
                                                        },
                                                        icon: const Icon(Icons.more_vert_rounded, color: lightPrimary),
                                                        itemBuilder: (BuildContext context) {
                                                          return {'Delete', 'UnPin'}.map((String choice) {
                                                            return PopupMenuItem(
                                                                value: choice,
                                                                child: Text(choice)
                                                            );
                                                          }).toList();
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                )
                                            )
                                        ),
                                      ],
                                    ),
                                  );
                                }
                            ),
                          ),
                          if(_pinnedList.isNotEmpty)const Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Unpinned Notes",
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                  fontStyle: FontStyle.italic,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 15,
                                  color: lightPrimary
                              ),
                            ),
                          ),
                          Expanded(
                            child: ListView.builder(
                              itemCount:_filteredList.length,
                              itemBuilder: (context, index) {
                                DocumentModel document = _filteredList[index];
                                return InkWell(
                                  onTap: () => navigateToDocument(context, document.id),
                                  child: Column(
                                    children: [
                                      SizedBox(
                                          height: 50,
                                          child: Card(
                                              color: lightSecondary,
                                              child: Center(
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    if(!_favList.contains(document)) InkWell(
                                                      onTap: () => favoriteDocument(ref, document, true),
                                                      child: const Padding(
                                                        padding: EdgeInsets.all(8.0),
                                                        child: Icon(
                                                              Icons.star_outline,
                                                                color: lightPrimary
                                                            ),
                                                      ),
                                                    )
                                                    else
                                                      InkWell(
                                                        onTap: () => favoriteDocument(ref, document, false),
                                                        child: const Padding(
                                                          padding: EdgeInsets.all(8.0),
                                                          child: Icon(
                                                              Icons.star,
                                                              color: Colors.yellow
                                                          ),
                                                        ),
                                                      ),
                                                    Expanded(
                                                      child: Center(
                                                        child: Text(
                                                            document.title,
                                                            style: const TextStyle(
                                                              color: lightPrimary,
                                                              fontSize: 17,
                                                            )
                                                        ),
                                                      ),
                                                    ),
                                                    PopupMenuButton(
                                                      onSelected: (String value){
                                                        switch(value) {
                                                          case 'Delete':
                                                            deleteDocument(context, ref, document);
                                                            break;
                                                          case 'Pin':
                                                            pinDocument(context, ref, document);
                                                            break;
                                                        }
                                                      },
                                                      icon: const Icon(Icons.more_vert_rounded, color: lightPrimary),
                                                      itemBuilder: (BuildContext context) {
                                                        return {'Delete', 'Pin'}.map((String choice) {
                                                          return PopupMenuItem(
                                                            value: choice,
                                                            child: Text(choice)
                                                          );
                                                        }).toList();
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              )
                                          )
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      )
                      ),
                ),
              ],
            ));
          },
        ),
      );
    });
  }

}
