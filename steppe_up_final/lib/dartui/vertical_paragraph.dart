/*
 * Copyright (c) 2019 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
 * distribute, sublicense, create a derivative work, and/or sell copies of the
 * Software in any work that is designed, intended, or marketed for pedagogical or
 * instructional purposes related to programming, coding, application development,
 * or information technology.  Permission for such use, copying, modification,
 * merger, publication, distribution, sublicensing, creation of derivative works,
 * or sale is expressly withheld.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/painting.dart';
import 'package:steppe_up/model/line_info.dart';
import 'package:steppe_up/model/text_run.dart';
import 'package:steppe_up/model/vertical_paragraph_constraints.dart';
import 'package:steppe_up/util/line_breaker.dart';

/// This class contains the core logic to layout and paint text in vertical
/// lines which wrap from left to right. It is based on the idea of the Flutter
/// Paragraph class, but since that class is just a wrapper for the underlying
/// LibTxt library, the content of this class is much different. This class
/// breaks a string of text into one word text runs, measures them using the
/// Flutter Paragraph class, calculates how many words to use in each line, and
/// finally paints each line one word at a time rotated so that the words form
/// vertical columns. This is the standard way to orient Mongolian text.
class VerticalParagraph {
  VerticalParagraph(this._paragraphStyle, this._textStyle, this._text);

  ui.ParagraphStyle _paragraphStyle;
  ui.TextStyle _textStyle;
  String _text;

  double _width;
  double _height;
  double _minIntrinsicHeight;
  double _maxIntrinsicHeight;

  double get width => _width;

  double get height => _height;

  double get minIntrinsicHeight => _minIntrinsicHeight;

  double get maxIntrinsicHeight => _maxIntrinsicHeight;

  void layout(VerticalParagraphConstraints constraints) =>
      _layout(constraints.height);

  void _layout(double height) {
    if (height == _height) {
      return;
    }
    _calculateRuns();
    _calculateLineBreaks(height);
    _calculateWidth();
    _height = height;
    _calculateIntrinsicHeight();
  }

  List<TextRun> _runs = [];

  /// Runs are short substrings of text. A line breaker is used to determine
  /// where one run ends and the next one starts. In this case, the break
  /// location is after a space and before a non-space.
  void _calculateRuns() {
    if (_runs.isNotEmpty) {
      return;
    }

    final breaker = LineBreaker();
    breaker.text = _text;
    final int breakCount = breaker.computeBreaks();
    final breaks = breaker.breaks;

    int start = 0;
    int end;
    for (int i = 0; i < breakCount; i++) {
      end = breaks[i];
      _addRun(start, end);
      start = end;
    }
    end = _text.length;
    if (start < end) {
      _addRun(start, end);
    }
  }

  /// The run contains a reference to a Paragraph object, which we will use to
  /// get the size of the word in the run.
  void _addRun(int start, int end) {
    final builder = ui.ParagraphBuilder(_paragraphStyle)
      ..pushStyle(_textStyle)
      ..addText(_text.substring(start, end));
    final paragraph = builder.build();
    paragraph.layout(ui.ParagraphConstraints(width: double.infinity));
    final run = TextRun(start, end, paragraph);
    _runs.add(run);
  }

  List<LineInfo> _lines = [];

  /// Once we know the size of all of the words, that is, every text run, we can
  /// see how many will fit in a line given the [maxLineLength] constraint. The
  /// run index for the run at the start and end of the line is stored in an
  /// array that we can come back to when we are ready to paint. At this point
  /// the lines have not yet been rotated, so width and height here refer to the
  /// size of the line in horizontal orientation.
  void _calculateLineBreaks(double maxLineLength) {
    if (_runs.isEmpty) {
      return;
    }
    if (_lines.isNotEmpty) {
      _lines.clear();
    }

    int start = 0;
    int end;
    double lineWidth = 0;
    double lineHeight = 0;
    for (int i = 0; i < _runs.length; i++) {
      end = i;
      final run = _runs[i];
      final runWidth = run.paragraph.maxIntrinsicWidth;
      final runHeight = run.paragraph.height;
      if (lineWidth + runWidth > maxLineLength) {
        _addLine(start, end, lineWidth, lineHeight);
        start = end;
        lineWidth = runWidth;
        lineHeight = runHeight;
      } else {
        lineWidth += runWidth;
        lineHeight = math.max(lineHeight, run.paragraph.height);
      }
    }
    end = _runs.length;
    if (start < end) {
      _addLine(start, end, lineWidth, lineHeight);
    }
  }

  void _addLine(int start, int end, double width, double height) {
    final bounds = Rect.fromLTRB(0, 0, width, height);
    final LineInfo lineInfo = LineInfo(start, end, bounds);
    _lines.add(lineInfo);
  }

  /// The width of the paragraph is the sum of the line heights (since the lines
  /// will be rotated when they are painted).
  void _calculateWidth() {
    double sum = 0;
    for (LineInfo line in _lines) {
      sum += line.bounds.height;
    }
    _width = sum;
  }

  /// This is how tall the paragraph would like to be (in vertical text
  /// orientation) if it had as much space as it wanted.
  void _calculateIntrinsicHeight() {
    double sum = 0;
    double minRunWidth = double.infinity;
    for (TextRun run in _runs) {
      final width = run.paragraph.longestLine;
      minRunWidth = math.min(width, minRunWidth);
      sum += width;
    }
    _minIntrinsicHeight = minRunWidth;
    _maxIntrinsicHeight = sum;
  }

  /// Once the runs have been measured and the lines breaks calculated, we can
  /// draw the text in vertical lines.
  void draw(Canvas canvas, Offset offset) {
    canvas.save();

    // Move to the start location.
    canvas.translate(offset.dx, offset.dy);

    // Rotate the canvas 90 degrees
    canvas.rotate(math.pi / 2);

    // Draw each line one at a time.
    for (LineInfo line in _lines) {

      // Move to where the line should start.
      canvas.translate(0, -line.bounds.height);

      // Draw each run (word) one at a time.
      double dx = 0;
      for (int i = line.textRunStart; i < line.textRunEnd; i++) {

        // Draw the run. The offset is the location of the run on the line.
        canvas.drawParagraph(_runs[i].paragraph, Offset(dx, 0));
        dx += _runs[i].paragraph.longestLine;
      }
    }

    canvas.restore();
  }
}
