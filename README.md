# adaptive_scrollbar

[![pub package](https://img.shields.io/pub/v/adaptive_scrollbar.svg)](https://pub.dev/packages/adaptive_scrollbar) [![GitHub stars](https://img.shields.io/github/stars/rulila52/adaptive-scrollbar)](https://github.com/rulila52/adaptive-scrollbar/stargazers) [![GitHub forks](https://img.shields.io/github/forks/rulila52/adaptive-scrollbar)](https://github.com/rulila52/adaptive-scrollbar/network)  [![GitHub license](https://img.shields.io/github/license/rulila52/adaptive-scrollbar)](https://github.com/rulila52/adaptive-scrollbar/blob/main/LICENSE)  [![GitHub issues](https://img.shields.io/github/issues/rulila52/adaptive-scrollbar)](https://github.com/rulila52/adaptive-scrollbar/issues)

Language: [English](README.md)

Adaptive Scrollbar is a library that allows you to create one or more desktop-style 
scrollbars on a single screen, each of which is bound only to its own object 
and placed in its own place on the screen.

- [How to use it](#how-to-use-it)
- [Multiple scrollbars](#multiple-scrollbars)
- [Customization](#customization)
- [Parameters](#parameters)

## How to use it

Just wrap with AdaptiveScrollbar your widget that contains your ScrollView 
object and specify the controller that is attached to this ScrollView object.

```dart
AdaptiveScrollbar(
  controller: controller,
  child: Center(
    child: ListView.builder(
      controller: controller,
      itemBuilder: (context, index) { 
        return Text(
            "Line " + index.toString());
      },
      itemCount: 50,
    ))),
```

## Multiple scrollbars

You can add multiple scrollbars to the screen at once. The controller 
is a required parameter in order to track changes to only one object 
if there are several ScrollView objects in your widget.

```dart
return AdaptiveScrollbar(
  controller: verticalScroll,
  width: width,
  child: AdaptiveScrollbar(
    controller: horizontalScroll,
    position: ScrollbarPosition.bottom,
    width: width,
    child: SingleChildScrollView(
    controller: horizontalScroll,
    scrollDirection: Axis.horizontal,
    child: Container(
      width: 2000,
      child: Container(
        color: Colors.lightBlueAccent,
        child: ListView.builder(
          controller: verticalScroll,
          itemCount: 30,
          itemBuilder: (context, index) {
            return Container(
              height: 30,
              child: Text("Line " + index.toString()));
          }))),
    )));
```

## Customization

You can position your scrollbar on any of the 4 sides of the screen. 
There is only one thing - if you choose ScrollbarPosition.top or 
ScrollbarPosition.bottom, your scrollbar will actually be rotated 90 degrees, 
and the top will be on the right. Do not forget about this if you specify
the paddings for bottom and slider. I'll think about how to simplify this.

```dart
AdaptiveScrollbar(
  controller: verticalScroll,
  width: verticalWidth,
  child: AdaptiveScrollbar(
    controller: horizontalScroll,
    position: ScrollbarPosition.bottom,
    
    //the horizontal scrollbar will have a padding
    // on the LEFT by the width of the vertical scrollbar
    bottomPadding: EdgeInsets.only(bottom: verticalWidth),
    
    width: horizontalWidth,
    child: ...
```
To set the width of the slider, you can set the horizontal sliderPadding. 
The vertical sliderPadding will determine the padding of the slider 
from the start and the end of the bottom. The height of the slider 
is determined automatically based on the size of the ScrollView object. 
If ScrollView object has nowhere to scroll, the scrollbar will not be displayed 
on the screen.

You can set colors for bottom and slider, or completely set 
the decorations for them.

## Parameters

| Parameter                  | Description                                                                           | Default value                                                                                                                                                                             |
| -------------------------- | ------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| child                      | Widget that contains your ScrollView.                                                 | required                                                                                                                                                                             |
| controller                 | Controller that attached to ScrollView object.                                        | required                      |       
| position                   | Position of scrollbar on the screen.                                                  | ScrollbarPosition.right                                                                                                                                                   |
| width                      | Width of all scrollBar.                                                               | 16.0                                                                                                                                                                  |
| bottomColor                | Bottom color.                                                                         | Colors.white                               |
| sliderDefaultColor         | Default slider color.                                                                 | Colors.blueGrey                                                   |
| sliderActiveColor          | Active slider color.                                                                  | sliderDefaultColor.withRed(10)                                                                                                                                                                          |
| bottomDecoration           | Bottom decoration.                                                                    | BoxDecoration(shape: BoxShape.rectangle, color: bottomColor)                                                                                                      |
| sliderDecoration           | Slider decoration.                                                                    | BoxDecoration(shape: BoxShape.rectangle, color: sliderDefaultColor)                                                                                                           |
| bottomPadding              | Bottom padding. Don't forget about rotation that depends on position.                 | const EdgeInsets.all(0)                                                                                                                                                                               |
| sliderPadding              | Slider padding from bottom. Don't forget about rotation that depends on position.     | const EdgeInsets.all(2)                                                                                                                                                                                 |




