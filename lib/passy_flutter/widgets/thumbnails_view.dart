//
// Super simple thumbnails view
//
import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';

class ThumbnailsView extends StatelessWidget {
  const ThumbnailsView(
      {super.key, required this.documentRef, required this.controller});

  final PdfDocumentRef? documentRef;
  final PdfViewerController? controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: documentRef == null
          ? null
          : PdfDocumentViewBuilder(
              documentRef: documentRef!,
              builder: (context, document) => ListView.builder(
                itemCount: document?.pages.length ?? 0,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.all(8),
                    height: 240,
                    child: Column(
                      children: [
                        SizedBox(
                          height: 200,
                          child: InkWell(
                            onTap: () => controller!.goToPage(
                              pageNumber: index + 1,
                              anchor: PdfPageAnchor.top,
                            ),
                            child: PdfPageView(
                              document: document,
                              pageNumber: index + 1,
                              alignment: Alignment.center,
                            ),
                          ),
                        ),
                        Text(
                          '${index + 1}',
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
    );
  }
}
