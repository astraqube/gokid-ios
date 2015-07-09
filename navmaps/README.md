To integrate navMaps
1) Include MapKit.framework, and CoreLocation.framework into your project
2) Copy the Resources/Fonts folder to your project
3) Copy the navmaps/Resources NavMap.storyboard into your project
4) Open the project, and navigate to the Images.xcassets folder- option-DRAG the "map" asset subfolder to your project's assets folder
5) add the NSLocationWhenInUseUsageDescription key to your info.plist, with value "GoKid uses your location for navigation"
![Requesting location permission gif](http://i.imgur.com/lTThTzk.gif)
6) Copy navMaps' info plist key/value pair for UIAppFonts to your info.plist

Changelog
July 8
Now have navigation mode, allowing toggling pickups and getting apple maps directions
Now have multiple pickup, multiple dropoff support with intelligent routing
