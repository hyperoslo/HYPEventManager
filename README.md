HYPEventManager
===============

HYPEventManager is the easiest way to add, update and remove iOS calendar events.

### How to create an event with **HYPEventManager**?

``` objc
- (void)createEventWithTitle:(NSString *)title 
                   startDate:(NSDate *)startDate 
                    duration:(NSInteger)duration 
                  completion:(void (^)(NSString *eventIdentifier, NSError *error))completion;
```

### How to update an event with **HYPEventManager**?

``` objc
- (void)updateEvent:(NSString *)eventIdentifier 
          withTitle:(NSString *)title 
          startDate:(NSDate *)startDate 
            endDate:(NSDate *)endDate 
         completion:(void (^)(NSString *eventIdentifier, NSError *error))completion;
```

### How to delete an event with **HYPEventManager**?

``` objc
- (void)deleteEventWithIdentifier:(NSString *)identifier 
                       completion:(void (^)(NSError *error))completion;
```

### How to check if an event exists with **HYPEventManager**?

``` objc
- (void)isEventInCalendar:(NSString *)eventIdentifier 
               completion:(void (^)(BOOL found))completion;
```

###TODO:
- Make Demo project.

License
=======

HYPEventManager is fully open source under the MIT license. Check [LICENSE](https://github.com/hyperoslo/HYPEventManager/blob/master/LICENSE.md) for details.

Contributions
=============

If there's something you would like to improve please create a friendly and constructive issue, getting your feedback would be awesome. Have a great day.
