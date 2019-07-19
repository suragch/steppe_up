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

class VerticalParagraph {
  VerticalParagraph._(this._paragraphStyle, this._textStyle, this._text);

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
    _calculateIntrinsicSize();
  }

  void _calculateRuns() {

  }

  void _calculateLineBreaks(double maxLineLength) {

  }

  void _calculateWidth() {

  }

  void _calculateIntrinsicSize() {

  }

  void draw(Canvas canvas, Offset offset) {

  }
}

// This class is adapted from Flutter's ParagraphConstraints
class VerticalParagraphConstraints {
  const VerticalParagraphConstraints({
    this.height,
  }) : assert(height != null);

  final double height;

  @override
  bool operator ==(dynamic other) {
    if (other.runtimeType != runtimeType) return false;
    final VerticalParagraphConstraints typedOther = other;
    return typedOther.height == height;
  }

  @override
  int get hashCode => height.hashCode;

  @override
  String toString() => '$runtimeType(height: $height)';
}

// This class is adapted from Flutter's ParagraphBuilder
class VerticalParagraphBuilder {
  VerticalParagraphBuilder(ui.ParagraphStyle style) {
    _paragraphStyle = style;
  }

  ui.ParagraphStyle _paragraphStyle;
  ui.TextStyle _textStyle;
  String _text = '';

  static final _defaultParagraphStyle = ui.ParagraphStyle(
    textAlign: TextAlign.start,
    textDirection: TextDirection.ltr,
    fontSize: 30,
  );

  static final _defaultTextStyle = ui.TextStyle(
    color: Color(0xFF000000),
    textBaseline: TextBaseline.alphabetic,
    fontSize: 30,
  );

  set textStyle(TextStyle style) {
    _textStyle = style.getTextStyle();
  }

  set text(String text) {
    _text = text;
  }

  VerticalParagraph build() {
    assert(_text != null);
    if (_paragraphStyle == null) {
      _paragraphStyle = _defaultParagraphStyle;
    }
    if (_textStyle == null) {
      _textStyle = _defaultTextStyle;
    }
    return VerticalParagraph._(_paragraphStyle, _textStyle, _text);
  }
}
