import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';
import 'package:second_brain/colors.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:second_brain/common/widgets/loader.dart';
import 'package:second_brain/models/document_model.dart';
import 'package:second_brain/models/error_model.dart';
import 'package:second_brain/repository/auth_repository.dart';
import 'package:second_brain/repository/document_repository.dart';
import 'package:second_brain/repository/socket_repository.dart';

class DocumentScreen extends ConsumerStatefulWidget {
  final String id;
  const DocumentScreen({
    Key? key,
    required this.id,
  }) : super(key: key);

  @override
  ConsumerState createState() => _DocumentScreenState();
}

class _DocumentScreenState extends ConsumerState<DocumentScreen> {
  TextEditingController titleController =
      TextEditingController(text: 'Untitled Document');
  quill.QuillController? _controller;

  ErrorModel? errorModel;
  SocketRepository socketRepository = SocketRepository();

  @override
  void initState() {
    super.initState();
    socketRepository.joinRoom(widget.id);
    fetchDocumentData();

    socketRepository.changeListener((data) {
      _controller?.compose(
          quill.Delta.fromJson(data['delta']),
          _controller?.selection??const TextSelection.collapsed(offset: 0),
          quill.ChangeSource.REMOTE,
      );
    });

    Timer.periodic(const Duration(seconds: 2), (timer) {
      socketRepository.autoSave(<String, dynamic>{
        'delta': _controller!.document.toDelta(),
        'room': widget.id,
      });
    });

  }


  void fetchDocumentData() async {
    errorModel = await ref.read(documentRepositoryProvider).getDocumentById(
          ref.read(userProvider)!.token,
          widget.id,
        );
    if(errorModel!.data! !=null) {
      titleController.text = (errorModel!.data as DocumentModel).title;
      _controller = quill.QuillController(
          document: errorModel!.data.content.isEmpty ? quill.Document(): quill.Document.fromDelta(quill.Delta.fromJson(errorModel!.data.content)),
          selection: const TextSelection.collapsed(offset: 0)
      );
      setState(() {});
    }

    _controller!.document.changes.listen((event) {
      // there are different types of deltas
      /**
       * the first delta is the the entire content of the document
       * the second is the changes that are meade from the previous part
       * the third is the local changes
       * */

      if(event.item3 == quill.ChangeSource.LOCAL) {
        Map<String, dynamic> map = {
          'delta': event.item2,
          'room': widget.id,
        };
        socketRepository.typing(map);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    titleController.dispose();
  }

  void updateTitle(WidgetRef ref, String title) {
    ref.read(documentRepositoryProvider).updateDocumentTitle(
        token: ref.read(userProvider)!.token, id: widget.id, title: title);
  }

  @override
  Widget build(BuildContext context) {
    if(_controller==null) {
      return const Scaffold(
        body: Loader(),
      );
    }
    return Scaffold(
        appBar: AppBar(
          backgroundColor: darkPrimary,
          elevation: 0,
          actions: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: ElevatedButton.icon(
                  onPressed: () {
                    Clipboard.setData(
                      ClipboardData(text:'http://localhost:3000/#/document/${widget.id}')
                    ).then((value) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Link Copied!'),),);
                    },);
                  },
                  icon: const Icon(Icons.lock, size: 16),
                  label: const Text('Share'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kBlueColor,
                  )),
            )
          ],
          title: Padding(
            padding: const EdgeInsets.symmetric(vertical: 9.0),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    Routemaster.of(context).replace('/');
                  },
                  child: Image.asset(
                    'assets/images/google_docs.png',
                    height: 40,
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                SizedBox(
                  width: 250,
                  child: TextField(
                    controller: titleController,
                    style: const TextStyle(
                      color: lightPrimary
                    ),
                    decoration: const InputDecoration(
                        border: InputBorder.none,
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                          color: lightPrimary,
                        )),
                        contentPadding: EdgeInsets.only(left: 10)),
                    onSubmitted: (value) => updateTitle(ref, value),
                  ),
                )
              ],
            ),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(
              decoration: BoxDecoration(
                  border: Border.all(
                color: kGrayColor,
                width: 0.1,
              )),
            ),
          ),
        ),
        body: Center(
          child: Column(
            children: [
              const SizedBox(
                height: 10,
              ),
              quill.QuillToolbar.basic(
                  controller: _controller!,
                showHeaderStyle: true
              ),
              const SizedBox(
                height: 10,
              ),
              Expanded(
                child: SizedBox(
                  width: 750,
                  child: Card(
                    color: lightPrimary,
                    elevation: 5,
                    child: Padding(
                      padding: const EdgeInsets.all(30.0),
                      child: quill.QuillEditor.basic(
                        controller: _controller!,
                        readOnly: false, // true for view only mode
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}
