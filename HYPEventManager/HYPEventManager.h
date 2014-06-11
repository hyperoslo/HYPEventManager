//
//  HYPEventManager.h
//
//  Created by Elvis Nunez on 24/10/13.
//  Copyright (c) 2013 Hyper. All rights reserved.
//

@interface HYPEventManager : NSObject
@property BOOL convertDatesToGMT; // Default YES.

+ (instancetype)sharedManager;

- (void)createEventWithTitle:(NSString *)title startDate:(NSDate *)startDate duration:(NSInteger)duration completion:(void (^)(NSString *eventIdentifier, NSError *error))completion;

- (void)updateEvent:(NSString *)eventIdentifier withTitle:(NSString *)title startDate:(NSDate *)startDate endDate:(NSDate *)endDate completion:(void (^)(NSString *eventIdentifier, NSError *error))completion;

- (void)deleteEventWithIdentifier:(NSString *)identifier completion:(void (^)(NSError *error))completion;

- (void)isEventInCalendar:(NSString *)eventIdentifier completion:(void (^)(BOOL found))completion;

@end
