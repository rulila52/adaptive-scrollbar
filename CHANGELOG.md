## [0.1.0] - 09.04.2021
* Initial release.

## [0.1.1] - 09.04.2021
* Fixed a bug with setting the decorations. Minor changes in service files.

## [0.1.2] - 15.04.2021
* Some changes in instruction and example, added some pictures.

## [0.1.3] - 15.04.2021
* Fixed problem with pictures.

## [0.1.4] - 11.05.2021
* Starts update to null-safety. Version released by mistake, don't use it.

## [1.0.0] - 13.05.2021
* Update to null-safety. Fixing old errors. This version have this problems:
  https://github.com/rulila52/adaptive-scrollbar/issues/2.

## [1.0.1] - 17.05.2021
* Fixing errors of 1.0.0 version that are described in 
  https://github.com/rulila52/adaptive-scrollbar/issues/2 and some little changes.

## [1.1.1] - 19.05.2021
* Little more customization: now you can set your own speed parameters for moving 
  the slider in the direction of the click. Fixing not colored corners of slider 
  with active color in some cases. Correcting Timer declaring due to the sometimes 
  appearing exception.

## [2.0.0] - 08.10.2021
* Renamed bottomPadding to underSpacing, sliderPadding to sliderSpacing, bottomColor 
  to underColor and bottomDecoration to underDecoration so as not to get confused 
  with top/bottom and margin/padding. Some fixes in README.md

## [2.0.1] - 08.10.2021
* Some fixes in README.md - "...your scrollbar will actually be rotated 90 degrees,
  and the top will be on the left..."

## [2.0.2] - 08.10.2021
* Some fixes in CHANGELOG.md

## [2.1.0] - 23.10.2021
* Added the ability to set a fixed slider height. If not set, the height will be calculated 
  from the content, as usual. Added the ability to set the decoration for the active slider. 
  Also added the ability to pass a child widget for the slider, but it is experimental.
  Some updates in example

## [2.1.1] - 15.01.2022
* Fix - In some cases, the scrollbar child widget could take up more space than it needs 
  because of an empty container in the stack
