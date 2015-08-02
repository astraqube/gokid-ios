# GoKid in iOS - built with Swift

## Technologies
* Amazon Web Services
* Ruby on Rails
* PostgreSQL database
* Pusher API (real-time updates)
* Twilio (SMS messaging)
* Facebook API
* Google Maps

## Installation
1. Install CocoaPods `sudo gem install cocoapods`
2. Run `pod install`
3. Open in XCode, build, and run

## Changelog
AHL Aug 1:
now gives real departure advice on 'can't keep kids waiting'
improves copy on 'can't keep kids waiting'
stop ‘can’t keep kids waiting’ from showing for occurrences after occursat
You can now volunteer for carpools from the map itself
Added check-circ to calView and mapview
Made message button feel more responsive
Interactive tray background and UX effects
AHL July 31:
Carpool list sorted; carpool list tap brings to edit mode
Fixes bug with dropoff occurrences; fixes bug with routes after arrival
Now uses AI to always ensure the most optimal route. 
AHL July 30:
Created the new Image Fetch system for ImageManager that returns… UIImages! (based on NSOperations and NSOperationQueue)
Now gracefully fail empty carpools on maps
Pull to refresh on calendar, my drives and carpool list
actionsheet only showed for unvolunteer now
over the head camera for user tracking mod
AHL July 23:
got TimeToGoCell displaying with accurate ETA info on CalendarVC
onLocationUpdated callbacks every 10 seconds update the carpool location on server
Now trigger onPickupArrival notifications
Opt out & Edit Button work on Map View
AHL July 21:
Now show real data on mapview
AHL July 19:
Now eta calculation works
Now off-route recalculation works
AHL July 18:
Navigation works
AHL July 9:
Now you can tap on profile image on calendarview to open action, and pickup/dropoff icons work as expected
built those fun CalendarUserImageViews with backup text etc
Integrate NavMaps into screen flow (but not data flow)
Added new CalendarTimeToGoCell class
