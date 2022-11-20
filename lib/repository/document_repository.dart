import 'dart:convert';
import 'dart:html';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart';
import '../constants.dart';
import '../models/document_model.dart';
import '../models/error_model.dart';

final documentRepositoryProvider = Provider((ref) => DocumentRepository(client: Client()));

class DocumentRepository {
  final Client _client;
  DocumentRepository({
    required Client client,
  }): _client = client;

  Future<ErrorModel> createDocument(String token) async {
    ErrorModel error = ErrorModel(
      error: 'Some unexpected error occurred',
      data: null,
    );
    try {
        var res = await _client.post(
          Uri.parse('$host/doc/create'),
          body: jsonEncode({
            'createdAt': DateTime.now().millisecondsSinceEpoch,
          }),
          headers: {
            'Content-Type': "application/json; charset=UTF-8",
            'x-auth-token': token
          },
        );

        //todo: add advanced error handling
        switch(res.statusCode) {

          case 200:
            error = ErrorModel(error: null, data: DocumentModel.fromJson(res.body));
            break;
          default:
            error = ErrorModel(error: res.body, data: null);
        }

    } catch (e) {
      error = ErrorModel(error: e.toString(), data: null);
    }
    return error;
  }

  Future<ErrorModel> getFilteredDocuments(String token, searchText) async {
    ErrorModel error = ErrorModel(
      error: 'Some unexpected error occurred',
      data: null,
    );
    try {
      var res = await _client.get(
        Uri.parse('$host/doc/me'),
        headers: {
          'Content-Type': "application/json; charset=UTF-8",
          'x-auth-token': token
        },
      );

      switch(res.statusCode) {
        case 200:
          List<DocumentModel> ret = [];
          List documents = [];

          for(int i=0; i<jsonDecode(res.body).length; i++) {
            ret.add(DocumentModel.fromJson(jsonEncode(jsonDecode(res.body)[i])));
          }

          ret.forEach((element) {
            if(searchText.length > 0) {
              if(element.title.contains(searchText)) {
                documents.add(element);
              }
            }
          });

          error = ErrorModel(
            error: null,
            data: {documents},
          );
          break;
        default:
          error = ErrorModel(error: res.body, data: null);
      }

    } catch (e) {
      error = ErrorModel(error: e.toString(), data: null);
    }
    return error;
  }

  Future<ErrorModel> getDocuments(String token, searchText) async {
    ErrorModel error = ErrorModel(
      error: 'Some unexpected error occurred',
      data: null,
    );
    try {
      var res = await _client.get(
        Uri.parse('$host/doc/me'),
        headers: {
          'Content-Type': "application/json; charset=UTF-8",
          'x-auth-token': token
        },
      );

      //todo: add advanced error handling
      switch(res.statusCode) {
        case 200:
          List<DocumentModel> ret = [];
          List documents = [];
          List pinnedDocs = [];
          List favedDocs = [];

          for(int i=0; i<jsonDecode(res.body).length; i++) {
            ret.add(DocumentModel.fromJson(jsonEncode(jsonDecode(res.body)[i])));
          }

          ret.forEach((element) {
            if(element.pinned == true) {
              pinnedDocs.add(element);
            } else {
              documents.add(element);
            }
            if(element.favorite == true) {
              favedDocs.add(element);
            }
          });


          // print(documents);
          error = ErrorModel(
              error: null,
              data: [documents, pinnedDocs, favedDocs],
          );
          break;
        default:
          error = ErrorModel(error: res.body, data: null);
      }

    } catch (e) {
      error = ErrorModel(error: e.toString(), data: null);
    }
    return error;
  }

  Future<ErrorModel> getDocumentById(String token, String id) async {
    ErrorModel error = ErrorModel(
      error: 'Some unexpected error occurred',
      data: null,
    );
    try {
      var res = await _client.get(
        Uri.parse('$host/doc/$id'),
        headers: {
          'Content-Type': "application/json; charset=UTF-8",
          'x-auth-token': token
        },
      );

      //todo: add advanced error handling
      switch(res.statusCode) {
        case 200:
          error = ErrorModel(
            error: null,
            data: DocumentModel.fromJson(res.body),
          );
          break;
        default:
          throw 'This Document does not exist, please create a new one';
      }

    } catch (e) {
      error = ErrorModel(error: e.toString(), data: null);
    }
    return error;
  }

  Future<ErrorModel> updateDocumentPinned(String token, String id, bool pin) async {
    ErrorModel error = ErrorModel(
        error: "some unexpected error occurred",
        data: null
    );

    try {
      var res = await _client.put(
        Uri.parse('$host/doc/$id/pinned'),
        body: jsonEncode({
          'pinned': pin,
        }),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': token
        },
      );

      switch(res.statusCode) {
        case 200:
          error = ErrorModel(error: null, data: null);
          break;
        default:
          error = ErrorModel(error: res.body, data: null);
      }

    } catch(e) {
      error = ErrorModel(error: e.toString(), data: null);
    }
    return error;
  }

  Future<ErrorModel> updateDocumentFavorite(String token, String id, bool fav) async {
    ErrorModel error = ErrorModel(
        error: "some unexpected error occurred",
        data: null
    );

    try {
      var res = await _client.put(
        Uri.parse('$host/doc/$id/favorite'),
        body: jsonEncode({
          'favorite': fav,
        }),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': token
        },
      );

      switch(res.statusCode) {
        case 200:
          error = ErrorModel(error: null, data: null);
          break;
        default:
          error = ErrorModel(error: res.body, data: null);
      }

    } catch(e) {
      error = ErrorModel(error: e.toString(), data: null);
    }
    return error;
  }

  Future<ErrorModel> deleteDocument(String token, String id) async {
    ErrorModel error = ErrorModel(
        error: "some unexpected error occurred",
        data: null
    );

    try {
      var res = await _client.delete(
        Uri.parse('$host/doc/$id'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': token
        },
      );

      switch(res.statusCode) {
        case 200:
          error = ErrorModel(error: null, data: null);
          break;
        default:
          error = ErrorModel(error: res.body, data: null);
      }

    } catch(e) {
      error = ErrorModel(error: e.toString(), data: null);
    }
    return error;
  }

  Future<ErrorModel> updateDocumentTitle({required String token, required String id, required String title,}) async {
    ErrorModel error = ErrorModel(
      error: 'Some unexpected error occurred',
      data: null,
    );
    try {
      var res = await _client.post(
        Uri.parse('$host/doc/title'),
        body: jsonEncode({
          'id': id,
          'title': title,
        }),
        headers: {
          'Content-Type': "application/json; charset=UTF-8",
          'x-auth-token': token
        },
      );

      switch(res.statusCode) {
        case 200:
          error = ErrorModel(error: null, data: DocumentModel.fromJson(res.body));
          break;
        default:
          error = ErrorModel(error: res.body, data: null);
      }

    } catch (e) {
      error = ErrorModel(error: e.toString(), data: null);
    }
    return error;
  }
}