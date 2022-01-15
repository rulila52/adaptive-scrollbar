library adaptive_scrollbar;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hovering/hovering.dart';
import 'package:rxdart/rxdart.dart';

// Scrollbar positions.
enum ScrollbarPosition { right, bottom, left, top }
// Scroll direction to the nearest click on bottom.
enum ToClickDirection { up, down }

/// Adaptive desktop-style scrollbar.
///
/// To add a scrollbar, simply wrap the widget that contains your [ScrollView] object
/// in a [AdaptiveScrollbar] and specify the [ScrollController] of your [ScrollView].
///
/// The scrollbar is placed on the specified [ScrollbarPosition]
/// and tracks the scrolls only of its [ScrollView] object,
/// via the specified [ScrollController].
class AdaptiveScrollbar extends StatefulWidget {
  /// Widget that contains your [ScrollView].
  final Widget child;

  /// [ScrollController] that attached to [ScrollView] object.
  final ScrollController controller;

  /// Position of [AdaptiveScrollbar] on the screen.
  final ScrollbarPosition position;

  /// Width of all [AdaptiveScrollBar].
  final double width;

  /// Height of slider. If you set this value,
  /// there will be this height. If not set, the height
  /// will be calculated based on the content, as usual
  final double? sliderHeight;

  /// Child widget for slider.
  final Widget? sliderChild;

  /// Under the slider part of the scrollbar color.
  final Color underColor;

  /// Default slider color.
  final Color sliderDefaultColor;

  /// Active slider color.
  late final Color sliderActiveColor;

  /// Under the slider part of the scrollbar decoration.
  late final BoxDecoration underDecoration;

  /// Slider decoration.
  late final BoxDecoration sliderDecoration;

  /// Slider decoration during pressing.
  late final BoxDecoration sliderActiveDecoration;

  /// Offset of the slider in the direction of the click.
  final double scrollToClickDelta;

  /// Duration of the first delay between scrolls in the click direction, in milliseconds.
  final int scrollToClickFirstDelay;

  /// Duration of the others delays between scrolls in the click direction, in milliseconds.
  final int scrollToClickOtherDelay;

  /// Under the slider part of the scrollbar spacing.
  /// If you choose [ScrollbarPosition.top] or [ScrollbarPosition.bottom] position,
  /// the scrollbar will be rotated 90 degrees, and the top
  /// will be on the left. Don't forget this when specifying the [underSpacing].
  final EdgeInsetsGeometry underSpacing;

  /// Slider spacing from bottom.
  /// If you choose [ScrollbarPosition.top] or [ScrollbarPosition.bottom] position,
  /// the scrollbar will be rotated 90 degrees, and the top
  /// will be on the left. Don't forget this when specifying the [sliderSpacing].
  final EdgeInsetsGeometry sliderSpacing;

  /// Wraps your [child] widget that contains [ScrollView] object,
  /// takes the position indicated by [position]
  /// and tracks scrolls only of this [ScrollView], via the specified [controller].
  AdaptiveScrollbar({
    required this.child,
    required this.controller,
    this.position = ScrollbarPosition.right,
    this.width = 16.0,
    this.sliderHeight,
    this.sliderChild,
    this.sliderDefaultColor = Colors.blueGrey,
    Color? sliderActiveColor,
    this.underColor = Colors.white,
    this.underSpacing = const EdgeInsets.all(0.0),
    this.sliderSpacing = const EdgeInsets.all(2.0),
    this.scrollToClickDelta = 100.0,
    this.scrollToClickFirstDelay = 400,
    this.scrollToClickOtherDelay = 100,
    BoxDecoration? underDecoration,
    BoxDecoration? sliderDecoration,
    BoxDecoration? sliderActiveDecoration,
  })  : assert(sliderSpacing.horizontal < width),
        assert(width > 0),
        assert(scrollToClickDelta >= 0),
        assert(scrollToClickFirstDelay >= 0),
        assert(scrollToClickOtherDelay >= 0) {
    if (sliderActiveColor == null) {
      this.sliderActiveColor = sliderDefaultColor.withRed(10);
    } else {
      this.sliderActiveColor = sliderActiveColor;
    }

    if (underDecoration == null) {
      this.underDecoration =
          BoxDecoration(shape: BoxShape.rectangle, color: underColor);
    } else {
      this.underDecoration = underDecoration;
    }

    if (sliderDecoration == null) {
      this.sliderDecoration =
          BoxDecoration(shape: BoxShape.rectangle, color: sliderDefaultColor);
    } else {
      this.sliderDecoration = sliderDecoration;
    }

    if (sliderActiveDecoration == null) {
      this.sliderActiveDecoration = BoxDecoration(
          shape: BoxShape.rectangle, color: this.sliderActiveColor);
    } else {
      this.sliderActiveDecoration = sliderActiveDecoration;
    }
  }

  @override
  _AdaptiveScrollbarState createState() => _AdaptiveScrollbarState();
}

class _AdaptiveScrollbarState extends State<AdaptiveScrollbar> {
  /// Used for transmitting information about scrolls to the [ScrollSlider].
  BehaviorSubject<bool> scrollSubject = BehaviorSubject<bool>();

  /// Used for transmitting information about clicks to the [ScrollSlider].
  BehaviorSubject<double> clickSubject = BehaviorSubject<double>();

  /// Alignment of scrollbar that depends on [ScrollbarPosition].
  Alignment alignment = Alignment(0, 0);

  /// Quarter turns of scrollbar that depends on [ScrollbarPosition].
  int quarterTurns = 0;

  @override
  void initState() {
    switch (widget.position) {
      case ScrollbarPosition.right:
        {
          alignment = Alignment.centerRight;
          quarterTurns = 0;
          break;
        }
      case ScrollbarPosition.bottom:
        {
          alignment = Alignment.bottomCenter;
          quarterTurns = 3;
          break;
        }
      case ScrollbarPosition.left:
        {
          alignment = Alignment.centerLeft;
          quarterTurns = 0;
          break;
        }
      case ScrollbarPosition.top:
        {
          alignment = Alignment.topCenter;
          quarterTurns = 3;
          break;
        }
    }
    super.initState();
  }

  @override
  void dispose() {
    scrollSubject.close();
    clickSubject.close();
    super.dispose();
  }

  /// Sending information about scrolls to the [ScrollSlider].
  sendToScrollUpdate() {
    scrollSubject.sink.add(true);
    return false;
  }

  /// Sending information about clicks to the [ScrollSlider].
  sendToClickUpdate(double position) {
    clickSubject.sink.add(position);
  }

  /// A flag that shows whether this is the first time we update the widget.
  /// Used to avoid the error "Controller is not attached to any [ScrollView]".
  bool firstRender = true;

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification notification) {
        return sendToScrollUpdate();
      },
      child: Stack(children: [
        widget.child,
        LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
          if (firstRender) {
            Future.delayed(Duration.zero, () async {
              setState(() {
                firstRender = false;
              });
            });
          }
          return !widget.controller.hasClients ||
                  widget.controller.position.maxScrollExtent == 0
              ? Container(
                  height: 0,
                  width: 0,
                )
              : Align(
                  alignment: alignment,
                  child: RotatedBox(
                      quarterTurns: quarterTurns,
                      child: Padding(
                          padding: widget.underSpacing,
                          child: GestureDetector(
                              onTapDown: (details) {
                                sendToClickUpdate(details.localPosition.dy);
                              },
                              onTapUp: (details) {
                                sendToClickUpdate(-1);
                              },
                              child: Container(
                                width: widget.width,
                                decoration: widget.underDecoration,
                                child: ScrollSlider(
                                  controller: widget.controller,
                                  sliderSpacing: widget.sliderSpacing,
                                  scrollSubject: scrollSubject,
                                  scrollToClickDelta: widget.scrollToClickDelta,
                                  scrollToClickFirstDelay:
                                      widget.scrollToClickFirstDelay,
                                  scrollToClickOtherDelay:
                                      widget.scrollToClickOtherDelay,
                                  clickSubject: clickSubject,
                                  sliderDecoration: widget.sliderDecoration,
                                  sliderHeight: widget.sliderHeight,
                                  sliderChild: widget.sliderChild,
                                  sliderActiveDecoration:
                                      widget.sliderActiveDecoration,
                                ),
                              )))));
        }),
      ]),
    );
  }
}

class ScrollSlider extends StatefulWidget {
  /// [ScrollController] that attached to [ScrollView] object.
  final ScrollController controller;

  /// Slider padding from bottom.
  /// If you choose [ScrollbarPosition.top] or [ScrollbarPosition.bottom] position,
  /// the scrollbar will be rotated 90 degrees, and the top
  /// will be on the left. Don't forget this when specifying the [sliderSpacing].
  final EdgeInsetsGeometry sliderSpacing;

  /// Used for receiving information about scrolls.
  final BehaviorSubject<bool> scrollSubject;

  /// Used for receiving information about clicks.
  final BehaviorSubject<double> clickSubject;

  /// Slider decoration.
  final BoxDecoration sliderDecoration;

  /// Slider decoration during pressing.
  late final BoxDecoration sliderActiveDecoration;

  /// Offset of the slider in the direction of click.
  final double scrollToClickDelta;

  /// Duration of the first delay between scrolls in the click direction, in milliseconds.
  final int scrollToClickFirstDelay;

  /// Duration of the others delays between scrolls in the click direction, in milliseconds.
  final int scrollToClickOtherDelay;

  /// Height of slider. If you set this value,
  /// there will be this height. If not set, the height
  /// will be calculated based on the content, as usual
  final double? sliderHeight;

  /// Child widget for slider.
  final Widget? sliderChild;

  /// Creates a slider.
  ScrollSlider(
      {required this.controller,
      required this.sliderSpacing,
      required this.sliderDecoration,
      required this.scrollToClickDelta,
      required this.scrollSubject,
      required this.clickSubject,
      required this.scrollToClickFirstDelay,
      required this.scrollToClickOtherDelay,
      required this.sliderHeight,
      required this.sliderChild,
      required this.sliderActiveDecoration});

  @override
  _ScrollSliderState createState() => _ScrollSliderState();
}

class _ScrollSliderState extends State<ScrollSlider> {
  /// Current slider offset.
  double sliderOffset = 0.0;

  /// Current [ScrollView] offset.
  double viewOffset = 0;

  /// Final slider height, installed or calculated value.
  double finalSliderHeight = 0;

  /// Slider minimal height.
  double minHeightScrollSlider = 10.0;

  /// Is the slider being pulled at the moment.
  bool isDragInProcess = false;

  /// A flag used to determine whether scrollToClick is executed for the first time in a row.
  bool isFirst = true;

  /// A subscription to the [scrollSubject].
  late StreamSubscription streamSubscriptionScroll;

  /// A subscription to the [clickSubject].
  late StreamSubscription streamSubscriptionClick;

  /// Timer used for smooth scrolling in the direction of the click.
  Timer timer = Timer(Duration(milliseconds: 400), () {});

  @override
  void initState() {
    streamSubscriptionScroll = widget.scrollSubject.listen((value) {
      onScrollUpdate();
    });
    streamSubscriptionClick = widget.clickSubject.listen((value) {
      if (value == -1) {
        timer.cancel();
      } else {
        if (sliderOffset + finalSliderHeight < value) {
          scrollToClick(value, ToClickDirection.down);
        } else {
          if (sliderOffset > value) {
            scrollToClick(value, ToClickDirection.up);
          }
        }
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    streamSubscriptionScroll.cancel();
    streamSubscriptionClick.cancel();
    super.dispose();
  }

  /// Maximal slider offset.
  double get sliderMaxScroll =>
      context.size!.height - finalSliderHeight - widget.sliderSpacing.vertical;

  /// Minimal slider offset.
  double get sliderMinScroll => 0.0;

  /// Maximal [ScrollView] offset.
  double get viewMaxScroll => widget.controller.position.maxScrollExtent;

  /// Minimal [ScrollView] offset.
  double get viewMinScroll => 0.0;

  /// Maximal slider offset during build.
  double sliderMaxScrollDuringBuild(double maxHeight) =>
      maxHeight - finalSliderHeight - widget.sliderSpacing.vertical;

  /// Maximal [ScrollView] offset during build.
  double viewMaxScrollDuringBuild(double maxHeight) =>
      widget.controller.position.maxScrollExtent;

  /// [ScrollView] offset in the direction of click.
  double getScrollViewDelta(
    double sliderDelta,
    double sliderMaxScroll,
    double viewMaxScroll,
  ) =>
      sliderDelta * viewMaxScroll / sliderMaxScroll;

  /// Scrolling in the direction of click
  void scrollToClick(double position, ToClickDirection direction) async {
    setState(() {
      if (direction == ToClickDirection.down) {
        sliderOffset += widget.scrollToClickDelta;
      } else {
        sliderOffset -= widget.scrollToClickDelta;
      }
      if (sliderOffset < sliderMinScroll) {
        sliderOffset = sliderMinScroll;
      }

      if (sliderOffset > sliderMaxScroll) {
        sliderOffset = sliderMaxScroll;
      }

      double viewDelta = getScrollViewDelta(
          direction == ToClickDirection.down
              ? widget.scrollToClickDelta
              : -widget.scrollToClickDelta,
          sliderMaxScroll,
          viewMaxScroll);

      viewOffset = widget.controller.position.pixels + viewDelta;

      if (viewOffset < viewMinScroll) {
        viewOffset = viewMinScroll;
      }

      if (viewOffset > viewMaxScroll) {
        viewOffset = viewMaxScroll;
      }
      widget.controller.jumpTo(viewOffset);
    });

    timer = Timer(
        Duration(
            milliseconds: isFirst
                ? widget.scrollToClickFirstDelay
                : widget.scrollToClickOtherDelay), () {
      isFirst = false;
      if (sliderOffset + finalSliderHeight < position &&
          direction == ToClickDirection.down) {
        scrollToClick(position, ToClickDirection.down);
      } else {
        if (sliderOffset > position && direction == ToClickDirection.up) {
          scrollToClick(position, ToClickDirection.up);
        } else {
          isFirst = true;
        }
      }
    });
  }

  /// Executed when the slider started to drag.
  void onDragStart(DragStartDetails details) {
    setState(() {
      isDragInProcess = true;
    });
  }

  /// Executed when the slider ended to drag.
  void onDragEnd(DragEndDetails details) {
    setState(() {
      isDragInProcess = false;
    });
  }

  /// Executed when the slider is dragged.
  void onDragUpdate(DragUpdateDetails details) {
    setState(() {
      sliderOffset += details.delta.dy;

      if (sliderOffset < sliderMinScroll) {
        sliderOffset = sliderMinScroll;
      }

      if (sliderOffset > sliderMaxScroll) {
        sliderOffset = sliderMaxScroll;
      }

      double viewDelta =
          getScrollViewDelta(details.delta.dy, sliderMaxScroll, viewMaxScroll);

      viewOffset = widget.controller.position.pixels + viewDelta;

      if (viewOffset < viewMinScroll) {
        viewOffset = viewMinScroll;
      }

      if (viewOffset > viewMaxScroll) {
        viewOffset = viewMaxScroll;
      }
      widget.controller.jumpTo(viewOffset);
    });
  }

  /// Executed when the [ScrollView] is dragged
  onScrollUpdate() {
    if (isDragInProcess) {
      return;
    }
    super.setState(() {
      setState(() {
        sliderOffset =
            widget.controller.position.pixels / viewMaxScroll * sliderMaxScroll;

        if (sliderOffset < sliderMinScroll) {
          sliderOffset = sliderMinScroll;
        }
        if (sliderOffset > sliderMaxScroll) {
          sliderOffset = sliderMaxScroll;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      finalSliderHeight = widget.sliderHeight ??
          constraints.maxHeight *
                  constraints.maxHeight /
                  (constraints.maxHeight +
                      viewMaxScrollDuringBuild(constraints.maxHeight)) -
              widget.sliderSpacing.vertical;

      if (finalSliderHeight < minHeightScrollSlider) {
        finalSliderHeight = minHeightScrollSlider;
      }

      if (viewMaxScrollDuringBuild(constraints.maxHeight) <= 0) {
        sliderOffset = 0;
      } else {
        sliderOffset = sliderMaxScrollDuringBuild(constraints.maxHeight) *
            widget.controller.position.pixels /
            viewMaxScrollDuringBuild(constraints.maxHeight);
      }

      if (sliderOffset < sliderMinScroll) {
        sliderOffset = sliderMinScroll;
      }

      if (sliderOffset > sliderMaxScrollDuringBuild(constraints.maxHeight)) {
        sliderOffset = sliderMaxScrollDuringBuild(constraints.maxHeight);
      }

      return GestureDetector(
          onVerticalDragUpdate: (details) {
            onDragUpdate(details);
          },
          onVerticalDragStart: onDragStart,
          onVerticalDragEnd: onDragEnd,
          child: Center(
              child: Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                      padding: widget.sliderSpacing,
                      child: Container(
                          height: finalSliderHeight,
                          margin: EdgeInsets.only(top: sliderOffset),
                          decoration: widget.sliderDecoration,
                          child: HoverContainer(
                              child: Container(
                                  constraints: BoxConstraints.expand(),
                                  child: widget.sliderChild ?? Container()),
                              hoverDecoration:
                                  widget.sliderActiveDecoration))))));
    });
  }
}
