library dots_indicator;

import 'dart:math';
import 'dart:ui';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:dots_indicator/src/dots_decorator.dart';
import 'package:flutter/material.dart';

typedef void OnTap(double position);

class DotsIndicator extends StatelessWidget {
  final ImageProvider? activeImage;
  final ImageProvider? inactiveImage;
  final int dotsCount;
  final double position;
  final DotsDecorator decorator;
  final Axis axis;
  final bool reversed;
  final OnTap? onTap;
  final MainAxisSize mainAxisSize;
  final MainAxisAlignment mainAxisAlignment;

  DotsIndicator({
    Key? key,
    required this.dotsCount,
    this.inactiveImage,
    this.position = 0.0,
    this.decorator = const DotsDecorator(),
    this.axis = Axis.horizontal,
    this.reversed = false,
    this.activeImage,
    this.mainAxisSize = MainAxisSize.min,
    this.mainAxisAlignment = MainAxisAlignment.center,
    this.onTap,
  })  : assert(dotsCount > 0, 'dotsCount must be superior to zero'),
        assert(position >= 0, 'position must be superior or equals to zero'),
        assert(
          position < dotsCount,
          "position must be less than dotsCount",
        ),
        assert(
          decorator.colors.isEmpty || decorator.colors.length == dotsCount,
          "colors param in decorator must empty or have same length as dotsCount parameter",
        ),
        assert(
          decorator.activeColors.isEmpty ||
              decorator.activeColors.length == dotsCount,
          "activeColors param in decorator must empty or have same length as dotsCount parameter",
        ),
        assert(
          decorator.sizes.isEmpty || decorator.sizes.length == dotsCount,
          "sizes param in decorator must empty or have same length as dotsCount parameter",
        ),
        assert(
          decorator.activeSizes.isEmpty ||
              decorator.activeSizes.length == dotsCount,
          "activeSizes param in decorator must empty or have same length as dotsCount parameter",
        ),
        assert(
          decorator.shapes.isEmpty || decorator.shapes.length == dotsCount,
          "shapes param in decorator must empty or have same length as dotsCount parameter",
        ),
        assert(
          decorator.activeShapes.isEmpty ||
              decorator.activeShapes.length == dotsCount,
          "activeShapes param in decorator must empty or have same length as dotsCount parameter",
        ),
        super(key: key);

  Widget _wrapInkwell(Widget dot, int index) {
    return InkWell(
      customBorder: position == index
          ? decorator.getActiveShape(index)
          : decorator.getShape(index),
      onTap: () => onTap!(index.toDouble()),
      child: dot,
    );
  }

  Widget _buildDot(BuildContext context, int index) {
    final lerpValue = min(1.0, (position - index).abs());

    final size = Size.lerp(
      decorator.getActiveSize(index),
      decorator.getSize(index),
      lerpValue,
    )!;

    final dot = Container(
      width: size.width,
      height: size.height,
      margin: decorator.spacing,
      decoration: ShapeDecoration(
        color: Color.lerp(
          decorator.getActiveColor(index) ?? Theme.of(context).primaryColor,
          decorator.getColor(index),
          lerpValue,
        ),
        shape: ShapeBorder.lerp(
          decorator.getActiveShape(index),
          decorator.getShape(index),
          lerpValue,
        )!,
      ),
    );
    return onTap == null ? dot : _wrapInkwell(dot, index);
  }

  Widget _buildIcon(BuildContext context, int index) {
    final lerpValue = min(1.0, (position - index).abs());

    final size = Size.lerp(
      decorator.getActiveSize(index),
      decorator.getSize(index),
      lerpValue,
    )!;

    final icon = Container(
      width: size.width,
      height: size.height,
      margin: decorator.spacing,
      decoration: BoxDecoration.lerp(
          BoxDecoration(image: DecorationImage(image: activeImage!)),
          BoxDecoration(image: DecorationImage(image: inactiveImage!)),
          lerpValue)!,
    );
    return onTap == null ? icon : _wrapInkwell(icon, index);
  }

  @override
  Widget build(BuildContext context) {
    final dotsList = List<Widget>.generate(dotsCount, (i) {
      if (activeImage != null && inactiveImage != null) {
        return _buildIcon(context, i);
      } else {
        return _buildDot(context, i);
      }
    });
    final dots = reversed ? dotsList.reversed.toList() : dotsList;

    return axis == Axis.vertical
        ? Column(
            mainAxisAlignment: mainAxisAlignment,
            mainAxisSize: mainAxisSize,
            children: dots,
          )
        : Row(
            mainAxisAlignment: mainAxisAlignment,
            mainAxisSize: mainAxisSize,
            children: dots,
          );
  }
}
