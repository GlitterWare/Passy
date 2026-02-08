import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:chewie_media_kit/chewie.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:passy/common/common.dart';
import 'package:passy/passy_data/file_utils.dart';
import 'package:passy/passy_data/loaded_account.dart';
import 'package:passy/passy_flutter/passy_flutter.dart';
import 'package:passy/screens/common.dart';
import 'package:passy/screens/log_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:pdfrx/pdfrx.dart';

import 'outline_view.dart';
import 'text_search_view.dart';
import 'thumbnails_view.dart';

class PassyFileWidget extends StatefulWidget {
  final String path;
  final String name;
  final bool isEncrypted;
  final FileEntryType type;
  final StreamController<String> _errorStreamController =
      StreamController<String>();
  Stream<String> get errorStream => _errorStreamController.stream;

  PassyFileWidget({
    super.key,
    required this.path,
    required this.name,
    required this.isEncrypted,
    required this.type,
  });

  @override
  State<StatefulWidget> createState() => _PassyFileWidget();
}

class _PassyFileWidget extends State<PassyFileWidget> {
  final LoadedAccount _account = data.loadedAccount!;
  Widget? _widget;
  bool _isLoaded = false;
  HttpServer? _server;
  Player? _player;
  final documentRef = ValueNotifier<PdfDocumentRef?>(null);
  final controller = PdfViewerController();
  final showLeftPane = ValueNotifier<bool>(false);
  final outline = ValueNotifier<List<PdfOutlineNode>?>(null);
  late final textSearcher = PdfTextSearcher(controller)..addListener(_update);

  void _update() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    widget._errorStreamController;
    _player?.dispose();
    _server?.close();
    textSearcher.removeListener(_update);
    textSearcher.dispose();
    showLeftPane.dispose();
    outline.dispose();
    documentRef.dispose();
    super.dispose();
  }

  Widget _buildErrorWidget(e, s) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      PassyPadding(Text(localizations.failedToDisplayFile)),
      PassyPadding(ThreeWidgetButton(
        left: const Icon(Icons.error_outline),
        center: Text(
          localizations.details,
          textAlign: TextAlign.center,
        ),
        right: const Icon(Icons.arrow_forward_ios_rounded),
        onPressed: () {
          Navigator.pushNamed(context, LogScreen.routeName,
              arguments: e.toString() + '\n' + s.toString());
        },
      )),
    ]);
  }

  void _playMedia({required String resource, required password}) {
    _player
        ?.open(Media(resource, httpHeaders: {'password': password}),
            play: false)
        .then((_) {
      if (!mounted) {
        return null;
      }
      return _player
          ?.play()
          .then((_) => Future.delayed(const Duration(seconds: 1), () {
                if (!mounted) {
                  return null;
                }
                return _player?.seek(const Duration(milliseconds: 1));
              }));
    });
  }

  Future<Widget?> _loadWidget() async {
    if (widget.type == FileEntryType.unknown ||
        widget.type == FileEntryType.file) {
      throw 'Unknown entry type.';
    }
    Uint8List data;
    if (widget.isEncrypted) {
      data = await _account.readFileAsBytes(widget.path, useIsolate: true);
    } else {
      data = await File(widget.path).readAsBytes();
    }
    switch (widget.type) {
      // #region Unknown
      case FileEntryType.unknown:
        throw 'Unknown entry type.';
      case FileEntryType.folder:
        throw 'Unknown entry type.';
      case FileEntryType.file:
        throw 'Unknown entry type.';
      // #endregion

      // #region Text
      case FileEntryType.plainText:
        String text = await compute<Uint8List, String>(
            (data) => utf8.decode(data, allowMalformed: true), data);
        return SingleChildScrollView(
            child: Center(child: SelectableText(text)));
      case FileEntryType.markdown:
        String text =
            await compute<Uint8List, String>((data) => utf8.decode(data), data);
        return SingleChildScrollView(
            child: Center(child: PassyMarkdownBody(data: text)));
      // #endregion

      // #region Photo
      case FileEntryType.photo:
        Widget imageViewer;
        if (widget.name.endsWith('.svg')) {
          imageViewer = InteractiveViewer(
            minScale: 1,
            maxScale: 100,
            child: SvgPicture.memory(
              data,
              height: 10000000000000,
              width: 10000000000000,
            ),
          );
        } else {
          imageViewer = InteractiveViewer(
            minScale: 1,
            maxScale: 100,
            child: Image.memory(
              data,
              errorBuilder: (context, error, stackTrace) =>
                  _buildErrorWidget(error, stackTrace),
              scale: 0.0000000000001,
              height: 10000000000000,
              width: 10000000000000,
            ),
          );
        }
        return InkWell(
            onTap: () => showSnackBar(
                  message: localizations.scrollOrPinchToZoom,
                  icon: const Icon(Icons.zoom_in),
                ),
            splashFactory: InkRipple.splashFactory,
            splashColor: Colors.white24,
            hoverColor: Colors.transparent,
            mouseCursor: SystemMouseCursors.zoomIn,
            child: imageViewer);
      // #endregion

      // #region Audio
      case FileEntryType.audio:
        FilePageResult pageResult = await createOctetStreamPage(data);
        _server = pageResult.server;
        Player player = Player(
            configuration: const PlayerConfiguration(
                bufferSize: 128 * 1024 * 1024 * 1024));
        _player = player;
        player.stream.error.listen((e) => widget._errorStreamController.add(e));
        VideoController controller = VideoController(player);
        _playMedia(
            resource: pageResult.uri.toString(), password: pageResult.password);
        return PassyAudioProgressBar(
          controller: controller,
          colors: ChewieProgressColors(
            playedColor: PassyTheme.of(context).accentContentColor,
            handleColor: PassyTheme.of(context).highlightContentColor,
          ),
          iconColor: PassyTheme.of(context).highlightContentColor,
        );
      // #endregion

      // #region Video
      case FileEntryType.video:
        FilePageResult pageResult = await createOctetStreamPage(data);
        _server = pageResult.server;
        Player player = Player(
            configuration: const PlayerConfiguration(
                bufferSize: 128 * 1024 * 1024 * 1024));
        _player = player;
        player.stream.error.listen((e) => widget._errorStreamController.add(e));
        VideoController controller = VideoController(player);
        _playMedia(
            resource: pageResult.uri.toString(), password: pageResult.password);
        return Chewie(
          controller: ChewieController(
            cupertinoProgressColors: ChewieProgressColors(
              playedColor: PassyTheme.of(context).accentContentColor,
              handleColor: PassyTheme.of(context).highlightContentColor,
            ),
            videoPlayerController: controller,
            hideControlsTimer: const Duration(seconds: 2),
            showControlsFade: false,
            customControls: CupertinoControls(
              backgroundColor: PassyTheme.of(context).contentColor,
              iconColor: PassyTheme.of(context).highlightContentColor,
              showPlayButtonWhilePlaying: true,
            ),
          ),
        );
      // #endregion

      // #region PDF
      case FileEntryType.pdf:
        FilePageResult pageResult = await createPdfPage(data);
        _server = pageResult.server;
        return Scaffold(
          backgroundColor: PassyTheme.of(context).secondaryContentColor,
          appBar: AppBar(
            leading: IconButton(
              padding: PassyTheme.appBarButtonPadding,
              splashRadius: PassyTheme.appBarButtonSplashRadius,
              icon: const Icon(Icons.menu),
              onPressed: () {
                showLeftPane.value = !showLeftPane.value;
              },
            ),
            title: const Text('Encrypted PDF View'),
            actions: [
              IconButton(
                padding: PassyTheme.appBarButtonPadding,
                splashRadius: PassyTheme.appBarButtonSplashRadius,
                icon: const Icon(Icons.zoom_in),
                onPressed: () => controller.zoomUp(),
              ),
              IconButton(
                padding: PassyTheme.appBarButtonPadding,
                splashRadius: PassyTheme.appBarButtonSplashRadius,
                icon: const Icon(Icons.zoom_out),
                onPressed: () => controller.zoomDown(),
              ),
              IconButton(
                padding: PassyTheme.appBarButtonPadding,
                splashRadius: PassyTheme.appBarButtonSplashRadius,
                icon: const Icon(Icons.first_page),
                onPressed: () => controller.goToPage(pageNumber: 1),
              ),
              IconButton(
                padding: PassyTheme.appBarButtonPadding,
                splashRadius: PassyTheme.appBarButtonSplashRadius,
                icon: const Icon(Icons.last_page),
                onPressed: () =>
                    controller.goToPage(pageNumber: controller.pageCount),
              ),
            ],
          ),
          body: Row(
            children: [
              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                child: ValueListenableBuilder(
                  valueListenable: showLeftPane,
                  builder: (context, showLeftPane, child) => SizedBox(
                    width: showLeftPane ? 300 : 0,
                    child: child!,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(1, 0, 4, 0),
                    child: DefaultTabController(
                      length: 3,
                      child: Column(
                        children: [
                          TabBar(tabs: [
                            const Tab(icon: Icon(Icons.image), text: 'Pages'),
                            Tab(
                                icon: const Icon(Icons.search),
                                text: localizations.search),
                            const Tab(icon: Icon(Icons.menu_book), text: 'TOC'),
                          ]),
                          Expanded(
                            child: TabBarView(
                              children: [
                                // NOTE: documentRef is not explicitly used but it indicates that
                                // the document is changed.
                                ValueListenableBuilder(
                                  valueListenable: documentRef,
                                  builder: (context, documentRef, child) =>
                                      ThumbnailsView(
                                    documentRef: documentRef,
                                    controller: controller,
                                  ),
                                ),
                                ValueListenableBuilder(
                                  valueListenable: documentRef,
                                  builder: (context, documentRef, child) =>
                                      TextSearchView(
                                    textSearcher: textSearcher,
                                  ),
                                ),
                                ValueListenableBuilder(
                                  valueListenable: outline,
                                  builder: (context, outline, child) =>
                                      OutlineView(
                                    outline: outline,
                                    controller: controller,
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
              Expanded(
                child: Stack(
                  children: [
                    PdfViewer.uri(
                      pageResult.uri,
                      // PdfViewer.file(
                      //   r"D:\pdfrx\example\assets\hello.pdf",
                      // PdfViewer.uri(
                      //   Uri.parse(
                      //       'https://opensource.adobe.com/dc-acrobat-sdk-docs/pdfstandards/PDF32000_2008.pdf'),
                      // Set password provider to show password dialog
                      //passwordProvider: () => passwordDialog(context),
                      controller: controller,
                      params: PdfViewerParams(
                        maxScale: 8,
                        backgroundColor:
                            PassyTheme.of(context).secondaryContentColor,
                        // facing pages algorithm
                        // layoutPages: (pages, params) {
                        //   // They should be moved outside function
                        //   const isRightToLeftReadingOrder = false;
                        //   const needCoverPage = true;
                        //   final width = pages.fold(
                        //       0.0, (prev, page) => max(prev, page.width));

                        //   final pageLayouts = <Rect>[];
                        //   double y = params.margin;
                        //   for (int i = 0; i < pages.length; i++) {
                        //     const offset = needCoverPage ? 1 : 0;
                        //     final page = pages[i];
                        //     final pos = i + offset;
                        //     final isLeft = isRightToLeftReadingOrder
                        //         ? (pos & 1) == 1
                        //         : (pos & 1) == 0;

                        //     final otherSide = (pos ^ 1) - offset;
                        //     final h = 0 <= otherSide && otherSide < pages.length
                        //         ? max(page.height, pages[otherSide].height)
                        //         : page.height;

                        //     pageLayouts.add(
                        //       Rect.fromLTWH(
                        //         isLeft
                        //             ? width + params.margin - page.width
                        //             : params.margin * 2 + width,
                        //         y + (h - page.height) / 2,
                        //         page.width,
                        //         page.height,
                        //       ),
                        //     );
                        //     if (pos & 1 == 1 || i + 1 == pages.length) {
                        //       y += h + params.margin;
                        //     }
                        //   }
                        //   return PdfPageLayout(
                        //     pageLayouts: pageLayouts,
                        //     documentSize: Size(
                        //       (params.margin + width) * 2 + params.margin,
                        //       y,
                        //     ),
                        //   );
                        // },
                        //
                        onViewSizeChanged: (viewSize, oldViewSize, controller) {
                          if (oldViewSize != null) {
                            //
                            // Calculate the matrix to keep the center position during device
                            // screen rotation
                            //
                            // The most important thing here is that the transformation matrix
                            // is not changed on the view change.
                            final centerPosition =
                                controller.value.calcPosition(oldViewSize);
                            final newMatrix =
                                controller.calcMatrixFor(centerPosition);
                            // Don't change the matrix in sync; the callback might be called
                            // during widget-tree's build process.
                            Future.delayed(
                              const Duration(milliseconds: 200),
                              () => controller.goTo(newMatrix),
                            );
                          }
                        },
                        viewerOverlayBuilder: (context, size, handleLinkTap) =>
                            [
                          //
                          // Example use of GestureDetector to handle custom gestures
                          //
                          GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            // If you use GestureDetector on viewerOverlayBuilder, it breaks link-tap handling
                            // and you should manually handle it using onTapUp callback
                            onTapUp: (details) {
                              handleLinkTap(details.localPosition);
                            },
                            onDoubleTap: () {
                              controller.zoomUp(loop: true);
                            },
                            // Make the GestureDetector covers all the viewer widget's area
                            // but also make the event go through to the viewer.
                            child: IgnorePointer(
                              child: SizedBox(
                                  width: size.width, height: size.height),
                            ),
                          ),
                          //
                          // Scroll-thumbs example
                          //
                          // Show vertical scroll thumb on the right; it has page number on it
                          PdfViewerScrollThumb(
                            controller: controller,
                            orientation: ScrollbarOrientation.right,
                            thumbSize: const Size(40, 25),
                            thumbBuilder:
                                (context, thumbSize, pageNumber, controller) =>
                                    Container(
                              color: PassyTheme.of(context).contentColor,
                              child: Center(
                                child: Text(
                                  pageNumber.toString(),
                                  style: TextStyle(
                                      color: PassyTheme.of(context)
                                          .contentTextColor),
                                ),
                              ),
                            ),
                          ),
                          // Just a simple horizontal scroll thumb on the bottom
                          PdfViewerScrollThumb(
                            controller: controller,
                            orientation: ScrollbarOrientation.bottom,
                            thumbSize: const Size(80, 30),
                            thumbBuilder:
                                (context, thumbSize, pageNumber, controller) =>
                                    Container(
                              color: Colors.red,
                            ),
                          ),
                        ],
                        //
                        // Loading progress indicator example
                        //
                        loadingBannerBuilder:
                            (context, bytesDownloaded, totalBytes) => Center(
                          child: CircularProgressIndicator(
                            value: totalBytes != null
                                ? bytesDownloaded / totalBytes
                                : null,
                            backgroundColor: Colors.grey,
                          ),
                        ),
                        //
                        // Link handling example
                        //
                        linkHandlerParams: PdfLinkHandlerParams(
                          onLinkTap: (link) {
                            if (link.url != null) {
                              openUrl(link.url.toString());
                            } else if (link.dest != null) {
                              controller.goToDest(link.dest);
                            }
                          },
                        ),
                        pagePaintCallbacks: [
                          textSearcher.pageTextMatchPaintCallback,
                        ],
                        onDocumentChanged: (document) async {
                          if (document == null) {
                            documentRef.value = null;
                            outline.value = null;
                          }
                        },
                        onViewerReady: (document, controller) async {
                          documentRef.value = controller.documentRef;
                          outline.value = await document.loadOutline();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      // #endregion
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoaded) {
      _isLoaded = true;
      _loadWidget().then((value) {
        if (!mounted) return;
        setState(() => _widget = value);
      }, onError: (e, s) {
        if (!mounted) return;
        setState(() => _widget = _buildErrorWidget(e, s));
      });
    }
    return _widget ??
        CircularProgressIndicator(
          color: PassyTheme.of(context).highlightContentColor,
        );
  }
}
