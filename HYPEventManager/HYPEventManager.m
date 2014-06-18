//
//  HYPEventManager.m
//  DansaniPlus
//
//  Created by Elvis Nunez on 24/10/13.
//  Copyright (c) 2013 Hyper. All rights reserved.
//

#import "HYPEventManager.h"
@import EventKit;

@interface HYPEventManager ()
@property (nonatomic) BOOL hasAccessToEventsStore;
@property (nonatomic, strong) EKEventStore *eventStore;
@end

@implementation HYPEventManager

+ (instancetype)sharedManager
{
    static HYPEventManager *__sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __sharedInstance = [[HYPEventManager alloc] init];
    });
    
    return __sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.convertDatesToGMT = YES;
    }
    return self;
}

- (EKEventStore *)eventStore
{
    if (!_eventStore) {
        _eventStore = [[EKEventStore alloc] init];
    }
    return _eventStore;
}

- (void)deleteEventWithIdentifier:(NSString *)identifier completion:(void (^)(NSError *error))completion
{
    [self requestAccessToEventStoreWithCompletion:^(BOOL success, NSError *anError) {
        if (success) {
            EKEvent *event = [self.eventStore eventWithIdentifier:identifier];
            NSError *eventError = nil;
            [self.eventStore removeEvent:event span:EKSpanThisEvent error:&eventError];
            if (completion) {
                completion(eventError);
            }
        } else {
            if (completion) {
                completion(anError);
            }
        }
    }];
}

- (void)updateEvent:(NSString *)eventIdentifier withTitle:(NSString *)title startDate:(NSDate *)startDate duration:(NSInteger)duration completion:(void (^)(NSString *eventIdentifier, NSError *error))completion
{
    NSDate * endDate = [NSDate dateWithTimeInterval:3600 * duration sinceDate:startDate];
    if (self.convertDatesToGMT) {
        endDate = [self dateToGlobalTime:endDate];
    }
    [self updateEvent:eventIdentifier
            withTitle:title
            startDate:startDate
              endDate:endDate
           completion:completion];
}

- (void)updateEvent:(NSString *)eventIdentifier withTitle:(NSString *)title startDate:(NSDate *)aStartDate endDate:(NSDate *)endDate completion:(void (^)(NSString *eventIdentifier, NSError *error))completion
{
    [self requestAccessToEventStoreWithCompletion:^(BOOL success, NSError *anError) {
        if (success) {
            EKEvent *event = [self.eventStore eventWithIdentifier:eventIdentifier];
            if (event) {
                event.title = title;
                NSDate *startDate;
                if (self.convertDatesToGMT) {
                    startDate = [self dateToGlobalTime:aStartDate];
                } else {
                    startDate = aStartDate;
                }
                event.startDate = startDate;
                event.endDate = endDate;
                event.alarms = [NSArray arrayWithObject:[EKAlarm alarmWithAbsoluteDate:event.startDate]];
                
                NSError *eventError = nil;
                BOOL created = [self.eventStore saveEvent:event span:EKSpanThisEvent error:&eventError];
                if (created) {
                    if (completion) {
                        completion(event.eventIdentifier, nil);
                    }
                } else {
                    if (completion) {
                        completion(nil, eventError);
                    }
                }
            } else {
                NSDictionary *errorDictionary = @{ NSLocalizedDescriptionKey : @"Event not found in calendar" };
                NSError *eventError = [[NSError alloc] initWithDomain:NSPOSIXErrorDomain
                                                                 code:0 userInfo:errorDictionary];
                if (completion) {
                    completion(nil, eventError);
                }
            }
        } else {
            if (completion) {
                completion(nil, anError);
            }
        }
    }];
}

-(NSDate *)dateToGlobalTime:(NSDate *)date
{
    NSTimeZone *tz = [NSTimeZone localTimeZone];
    NSInteger seconds = -[tz secondsFromGMTForDate: date];
    return [NSDate dateWithTimeInterval: seconds sinceDate: date];
}

- (void)createEventWithTitle:(NSString *)title startDate:(NSDate *)aStartDate duration:(NSInteger)duration completion:(void (^)(NSString *eventIdentifier, NSError *error))completion
{
    [self requestAccessToEventStoreWithCompletion:^(BOOL success, NSError *anError) {
        if (success) {
            NSDate *startDate;
            if (self.convertDatesToGMT) {
                startDate = [self dateToGlobalTime:aStartDate];
            } else {
                startDate = aStartDate;
            }
            EKEvent *event = [EKEvent eventWithEventStore:self.eventStore];
            event.title = title;
            event.startDate = startDate;
            event.endDate = [NSDate dateWithTimeInterval:3600 * duration sinceDate:startDate];
            event.calendar = self.eventStore.defaultCalendarForNewEvents;
            event.alarms = [NSArray arrayWithObject:[EKAlarm alarmWithAbsoluteDate:event.startDate]];
            NSError *eventError = nil;
            BOOL created = [self.eventStore saveEvent:event span:EKSpanThisEvent error:&eventError];
            if (created) {
                if (completion) {
                    completion(event.eventIdentifier, nil);
                }
            } else if (eventError) {
                if (completion) {
                    completion(nil, eventError);
                }
            }
            
        } else {
            if (completion) {
                completion(nil, anError);
            }
        }
    }];
}

- (void)requestAccessToEventStoreWithCompletion:(void (^)(BOOL success, NSError *error))completion
{
    if (!self.hasAccessToEventsStore) {
        [self.eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
            if (error) {
                NSLog(@"error adding event to calendar: %@", [error localizedDescription]);
            }
            
            self.hasAccessToEventsStore = granted;
            if (completion) {
                completion(granted, error);
            }
        }];
    } else {
        if (completion) {
            completion(YES, nil);
        }
    }
}

@end

@implementation HYPEventManager (Access)

- (void)isEventInCalendar:(NSString *)eventIdentifier completion:(void (^)(BOOL found))completion
{
    [self requestAccessToEventStoreWithCompletion:^(BOOL success, NSError *error) {
        EKEvent *event = [self.eventStore eventWithIdentifier:eventIdentifier];
        if (completion) {
            if (event) {
                completion(YES);
            } else {
                completion(NO);
            }
        }
    }];
}

- (void)eventsInCalendarsBetweenStartDate:(NSDate*)startDate
                               andEndDate:(NSDate*)endDate
                                   filter:(BOOL (^)(EKEvent * event))filter
                             completition:(void (^)(NSArray * events))completion
{
    [self requestAccessToEventStoreWithCompletion:^(BOOL success, NSError *error) {
        if (success) {
            
            NSMutableArray * result = [NSMutableArray array];
            
            NSDate * start = startDate;
            if (!start) {
                start = [NSDate dateWithTimeIntervalSinceNow:-60*60*24*30];
            }
            NSDate * end = endDate;
            if (!end) {
                end = [NSDate dateWithTimeIntervalSinceNow:60*60*24*30];
            }
            
            NSPredicate * predicate = [self.eventStore predicateForEventsWithStartDate:start
                                                                               endDate:end
                                                                             calendars:nil];
            
            [self.eventStore enumerateEventsMatchingPredicate:predicate
                                                   usingBlock:^(EKEvent *event, BOOL *stop) {
                                                       if (filter && filter(event)) {
                                                           [result addObject:event];
                                                       }
                                                   }];
            if (completion) {
                completion(result.copy);
            }
        } else {
            if (completion) {
                completion(nil);
            }
        }
    }];
}

- (void)nearEventsInCalendarsWithFilter:(BOOL (^)(EKEvent * event))filter completition:(void (^)(NSArray * events))completion
{
    [self eventsInCalendarsBetweenStartDate:nil andEndDate:nil filter:filter completition:completion];
}

@end
