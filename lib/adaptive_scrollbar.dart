library adaptive_scrollbar;

import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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

  /// Bottom color.
  final Color bottomColor;

  /// Default slider color.
  final Color sliderDefaultColor;

  /// Active slider color.
  final Color sliderActiveColor;

  /// Bottom decoration.
  final BoxDecoration bottomDecoration;

  /// Slider decoration.
  final BoxDecoration sliderDecoration;

  /// Bottom padding.
  /// If you choose [ScrollbarPosition.top] or [ScrollbarPosition.bottom] position,
  /// the scrollbar will be rotated 90 degrees, and the top
  /// will be on the left. Don't forget this when specifying the [bottomPadding].
  final EdgeInsetsGeometry bottomPadding;

  /// Slider padding from bottom.
  /// If you choose [ScrollbarPosition.top] or [ScrollbarPosition.bottom] position,
  /// the scrollbar will be rotated 90 degrees, and the top
  /// will be on the left. Don't forget this when specifying the [sliderPadding].
  final EdgeInsetsGeometry sliderPadding;

  /// Wraps your [child] widget that contains [ScrollView] object,
  /// takes the position indicated by [position]
  /// and tracks scrolls only of this [ScrollView], via the specified [controller].
  AdaptiveScrollbar(
      {@required this.child,
      @required this.controller,
      this.position = ScrollbarPosition.right,
      this.width = 16.0,
      this.sliderDefaultColor = Colors.blueGrey,
      this.sliderActiveColor,
      this.bottomColor = Colors.white,
      this.bottomPadding = const EdgeInsets.all(0),
      this.sliderPadding = const EdgeInsets.all(2),
      this.bottomDecoration,
      this.sliderDecoration})
      : assert(sliderPadding.horizontal < width),
        assert(width > 0),
        assert(bottomColor == null || bottomDecoration == null),
        assert(sliderDefaultColor == null || sliderDecoration == null);

  @override
  _AdaptiveScrollbarState createState() => _AdaptiveScrollbarState();
}

class _AdaptiveScrollbarState extends State<AdaptiveScrollbar> {
  /// Used for transmitting information about scrolls to the [ScrollSlider].
  BehaviorSubject<bool> scrollSubject = BehaviorSubject<bool>();

  /// Used for transmitting information about clicks to the [ScrollSlider].
  BehaviorSubject<double> clickSubject = BehaviorSubject<double>();

  /// Alignment of scrollbar that depends on [ScrollbarPosition].
  Alignment alignment;

  /// Quarter turns of scrollbar that depends on [ScrollbarPosition].
  int quarterTurns;

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
              ? Container()
              : Align(
                  alignment: alignment,
                  child: RotatedBox(
                    quarterTurns: quarterTurns,
                    child: Padding(
                      padding: widget.bottomPadding,
                      child: GestureDetector(
                        onTapDown: (details) {
                          sendToClickUpdate(details.localPosition.dy);
                        },
                        onTapUp: (details) {
                          sendToClickUpdate(-1);
                        },
                        child: Container(
                          width: widget.width,
                          decoration: widget.bottomDecoration == null
                              ? BoxDecoration(
                                  shape: BoxShape.rectangle,
                                  color: widget.bottomColor)
                              : widget.bottomDecoration,
                          child: ScrollSlider(
                              widget.sliderDefaultColor,
                              widget.sliderActiveColor,
                              widget.controller,
                              widget.sliderPadding,
                              widget.sliderDecoration,
                              scrollSubject,
                              clickSubject),
                        ),
                      ),
                    ),
                  ),
                );
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
  /// will be on the left. Don't forget this when specifying the [sliderPadding].
  final EdgeInsetsGeometry sliderPadding;

  /// Default slider color.
  final Color sliderDefaultColor;

  /// Active slider color.
  final Color sliderActiveColor;

  /// Used for receiving information about scrolls.
  final BehaviorSubject<bool> scrollSubject;

  /// Used for receiving information about clicks.
  final BehaviorSubject<double> clickSubject;

  /// Slider decoration.
  final BoxDecoration sliderDecoration;

  /// Creates a slider.
  ScrollSlider(
      this.sliderDefaultColor,
      this.sliderActiveColor,
      this.controller,
      this.sliderPadding,
      this.sliderDecoration,
      this.scrollSubject,
      this.clickSubject);

  @override
  _ScrollSliderState createState() => _ScrollSliderState();
}

class _ScrollSliderState extends State<ScrollSlider> {
  /// Current slider offset.
  double sliderOffset = 0.0;

  /// Current [ScrollView] offset.
  double viewOffset;

  /// Slider height.
  double heightScrollSlider;

  /// Slider minimal height.
  double minHeightScrollSlider = 10.0;

  /// Is the slider being pulled at the moment.
  bool isDragInProcess = false;

  /// A flag used to determine whether scrollToClick is executed for the first time in a row.
  bool isFirst = true;

  /// Offset of the slider in the direction of click.
  double scrollClickDelta = 100;

  /// Used for correct change of the slider color from active to default.
  FocusNode focusNode = FocusNode();

  /// A subscription to the [scrollSubject].
  StreamSubscription streamSubscriptionScroll;

  /// A subscription to the [clickSubject].
  StreamSubscription streamSubscriptionClick;

  /// Timer used for smooth scrolling in the direction of the click.
  Timer timer;

  @override
  void initState() {
    streamSubscriptionScroll = widget.scrollSubject.listen((value) {
      onScrollUpdate();
    });
    streamSubscriptionClick = widget.clickSubject.listen((value) {
      if (value == -1) {
        timer.cancel();
      } else {
        if (sliderOffset + heightScrollSlider < value) {
          scrollToClick(value, ToClickDirection.down);
        } else {
          scrollToClick(value, ToClickDirection.up);
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
      context.size.height - heightScrollSlider - widget.sliderPadding.vertical;

  /// Minimal slider offset.
  double get sliderMinScrollExtent => 0.0;

  /// Maximal [ScrollView] offset.
  double get viewMaxScroll => widget.controller.position.maxScrollExtent;

  /// Minimal [ScrollView] offset.
  double get viewMinScrollExtent => 0.0;

  /// Maximal slider offset during build.
  double sliderMaxScrollDuringBuild(double maxHeight) =>
      maxHeight - heightScrollSlider - widget.sliderPadding.vertical;

  /// Maximal [ScrollView] offset during build.
  double viewMaxScrollDuringBuild(double maxHeight) =>
      widget.controller.position.maxScrollExtent;

  /// [ScrollView] offset in the direction of click.
  double getScrollViewDelta(
    double sliderDelta,
    double sliderMaxScroll,
    double viewMaxScroll,
  ) {
    return sliderDelta * viewMaxScroll / sliderMaxScroll;
  }

  /// Scrolling in the direction of click
  void scrollToClick(double position, ToClickDirection direction) async {
    setState(() {
      if (direction == ToClickDirection.down) {
        sliderOffset += scrollClickDelta;
      } else {
        sliderOffset -= scrollClickDelta;
      }
      if (sliderOffset < sliderMinScrollExtent) {
        sliderOffset = sliderMinScrollExtent;
      }

      if (sliderOffset > sliderMaxScroll) {
        sliderOffset = sliderMaxScroll;
      }

      double viewDelta = getScrollViewDelta(
          direction == ToClickDirection.down
              ? scrollClickDelta
              : -scrollClickDelta,
          sliderMaxScroll,
          viewMaxScroll);

      viewOffset = widget.controller.position.pixels + viewDelta;

      if (viewOffset < viewMinScrollExtent) {
        viewOffset = viewMinScrollExtent;
      }

      if (viewOffset > viewMaxScroll) {
        viewOffset = viewMaxScroll;
      }
      widget.controller.jumpTo(viewOffset);
    });

    timer = Timer(Duration(milliseconds: isFirst ? 400 : 100), () {
      isFirst = false;
      if (sliderOffset + heightScrollSlider < position &&
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

      if (sliderOffset < sliderMinScrollExtent) {
        sliderOffset = sliderMinScrollExtent;
      }

      if (sliderOffset > sliderMaxScroll) {
        sliderOffset = sliderMaxScroll;
      }

      double viewDelta =
          getScrollViewDelta(details.delta.dy, sliderMaxScroll, viewMaxScroll);

      viewOffset = widget.controller.position.pixels + viewDelta;

      if (viewOffset < viewMinScrollExtent) {
        viewOffset = viewMinScrollExtent;
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

        if (sliderOffset < sliderMinScrollExtent) {
          sliderOffset = sliderMinScrollExtent;
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
      heightScrollSlider = constraints.maxHeight *
              constraints.maxHeight /
              (constraints.maxHeight +
                  viewMaxScrollDuringBuild(constraints.maxHeight)) -
          widget.sliderPadding.vertical;

      if (heightScrollSlider < minHeightScrollSlider) {
        heightScrollSlider = minHeightScrollSlider;
      }

      if (viewMaxScrollDuringBuild(constraints.maxHeight) <= 0) {
        sliderOffset = 0;
      } else {
        sliderOffset = sliderMaxScrollDuringBuild(constraints.maxHeight) *
            widget.controller.position.pixels /
            viewMaxScrollDuringBuild(constraints.maxHeight);
      }

      if (sliderOffset < sliderMinScrollExtent) {
        sliderOffset = sliderMinScrollExtent;
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
              child: Container(
                  height: heightScrollSlider,
                  margin:
                      EdgeInsets.only(top: sliderOffset) + widget.sliderPadding,
                  decoration: widget.sliderDecoration == null
                      ? BoxDecoration(
                          shape: BoxShape.rectangle,
                          color: widget.sliderDefaultColor)
                      : widget.sliderDecoration,
                  child: MouseRegion(
                    onEnter: (event) {
                      setState(() {
                        focusNode.unfocus();
                      });
                    },
                    child: TextButton(
                        onPressed: () {},
                        style: ButtonStyle(
                          overlayColor: MaterialStateProperty.all<Color>(
                              widget.sliderActiveColor == null
                                  ? widget.sliderDefaultColor.withRed(10)
                                  : widget.sliderActiveColor),
                        ),
                        focusNode: focusNode,
                        child: Container()),
                  ))),
        ),
      );
    });
  }
}
