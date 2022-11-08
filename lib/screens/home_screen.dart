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
  SocketRepository socketRepository = SocketRepository();
  bool dataLoaded = false;

  @override
  Widget build(BuildContext context) {
    TextEditingController searchController = TextEditingController();

    return Consumer(builder: (context, ref, child) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: darkPrimary,
          elevation: 0,
          actions: [
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
              if (dataLoaded == false && snapshot.data!.data.length >= 0) {
                _filteredList = snapshot.data!.data;
                dataLoaded = true;
              }
            }
            return Center(
                child: Column(
              children: [
                Center(
                  child: SizedBox(
                    width: 600,
                    child: Form(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextFormField(
                            controller: searchController,
                            style: const TextStyle(
                              color: lightPrimary,
                            ),
                            decoration: const InputDecoration(
                              hintStyle: TextStyle(
                                color: lightPrimary,
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
                          Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 16.0),
                                  child: ElevatedButton(
                                    onPressed: () {
                                      _filteredList.clear();
                                      List docs = snapshot.data!.data;
                                      for (int i = 0; i < docs.length; i++) {
                                        if (docs[i]
                                            .title
                                            .toLowerCase()
                                            .contains(searchController.text
                                                .toLowerCase())) {
                                          _filteredList.add(docs[i]);
                                        }
                                      }
                                      if (_filteredList.isEmpty &&
                                          searchController.text.isNotEmpty) {
                                        //when there are no results then return an empty list
                                        useFiltered(
                                          [],
                                          _filteredList,
                                        );
                                      } else {
                                        useFiltered(docs, _filteredList);
                                      }
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
                Expanded(
                  child: Container(
                      width: 600,
                      margin: const EdgeInsets.only(top: 10),
                      child:ListView.builder(
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
                                                  }
                                                },
                                                icon: const Icon(Icons.more_vert_rounded, color: lightPrimary),
                                                itemBuilder: (BuildContext context) {
                                                  return {'Delete'}.map((String choice) {
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
