import 'dart:convert';

import 'package:clear_task/core/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:google_fonts/google_fonts.dart';

class RichTextEditor extends StatefulWidget {
  final String? initialDeltaJson;
  final ValueChanged<String?>? onChanged;
  final bool readOnly;
  final bool scrollable;
  final FocusNode? focusNode;

  const RichTextEditor({
    super.key,
    this.initialDeltaJson,
    this.onChanged,
    this.readOnly = false,
    this.scrollable = true,
    this.focusNode,
  });

  @override
  State<RichTextEditor> createState() => _RichTextEditorState();
}

class _RichTextEditorState extends State<RichTextEditor> {
  late final QuillController _controller;

  @override
  void initState() {
    super.initState();
    _controller = _buildController();
    _controller.readOnly = widget.readOnly; // 👈 Set initial readOnly state
    _controller.document.changes.listen((_) {
      if (widget.onChanged != null) {
        widget.onChanged!(deltaToJson(_controller.document));
      }
    });
  }

  @override
  void didUpdateWidget(covariant RichTextEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.readOnly != oldWidget.readOnly) {
      _controller.readOnly = widget.readOnly; // 👈 Sync readOnly state
    }
  }

  QuillController _buildController() {
    if (widget.initialDeltaJson != null && widget.initialDeltaJson!.isNotEmpty) {
      try {
        final json = jsonDecode(widget.initialDeltaJson!);
        final doc = Document.fromJson(json);
        return QuillController(
          document: doc,
          selection: const TextSelection.collapsed(offset: 0),
        );
      } catch (_) {}
    }
    return QuillController.basic();
  }

  /// Returns null if the document is effectively empty (just a newline).
  static String? deltaToJson(Document doc) {
    final text = doc.toPlainText().trim();
    if (text.isEmpty) return null;
    return jsonEncode(doc.toDelta().toJson());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Note",
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: context.primaryFontColor,
          ),
        ),
        const SizedBox(height: 8),
        if (!widget.readOnly) ...[
          Container(
            decoration: BoxDecoration(
              color: context.cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: context.inputBorderColor,
                width: 1.4,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            child: QuillSimpleToolbar(
              controller: _controller,
              config: const QuillSimpleToolbarConfig(
                showAlignmentButtons: false,
                showBackgroundColorButton: false,
                showCenterAlignment: false,
                showClearFormat: false,
                showCodeBlock: false,
                showDirection: false,
                showFontFamily: false,
                showFontSize: false,
                showIndent: false,
                showInlineCode: false,
                showJustifyAlignment: false,
                showLeftAlignment: false,
                showLink: false,
                showRightAlignment: false,
                showSearchButton: false,
                showStrikeThrough: false,
                showSubscript: false,
                showSuperscript: false,
                showQuote: false,
                showColorButton: false,
                showListCheck: true,
                showListBullets: true,
                showListNumbers: true,
                showBoldButton: true,
                showItalicButton: true,
                showUnderLineButton: true,
                showHeaderStyle: true,
                multiRowsDisplay: false,
                toolbarSize: 38,
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
        Container(
          constraints: BoxConstraints(
            minHeight: widget.readOnly ? 40 : 120,
            maxHeight: widget.readOnly ? double.infinity : 300, // 👈
          ),
          decoration: BoxDecoration(
            color: context.cardColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: context.inputBorderColor,
              width: 1.4,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: QuillEditor.basic(
            controller: _controller,
            focusNode: widget.focusNode,
            config: QuillEditorConfig(
              scrollable: widget.scrollable, // 👈
              showCursor: !widget.readOnly,
              placeholder: widget.readOnly ? null : 'Add a note…',
              readOnlyMouseCursor: SystemMouseCursors.basic,
              customStyles: DefaultStyles(
                paragraph: DefaultTextBlockStyle(
                  GoogleFonts.poppins(
                    fontSize: 14,
                    color: context.primaryFontColor,
                  ),
                  const HorizontalSpacing(0, 0),
                  const VerticalSpacing(4, 4),
                  const VerticalSpacing(0, 0),
                  null,
                ),
                placeHolder: DefaultTextBlockStyle(
                  GoogleFonts.poppins(
                    fontSize: 14,
                    color: context.secondaryFontColor.withValues(alpha: 0.6),
                  ),
                  const HorizontalSpacing(0, 0),
                  const VerticalSpacing(4, 4),
                  const VerticalSpacing(0, 0),
                  null,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}