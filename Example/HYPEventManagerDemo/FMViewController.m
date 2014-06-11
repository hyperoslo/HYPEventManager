//
//  FMViewController.m
//  HYPEventManagerDemo
//
//  Created by Felipe Baytelman on 6/10/14.
//  Copyright (c) 2014 fitmob inc. All rights reserved.
//

#import "FMViewController.h"
#import <HYPEventManager.h>

@interface FMViewController ()
@property int eventCount;
@end

@implementation FMViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.eventCount = 0;
    
    [self addEvents];
}

- (void)addEvents
{
    if (self.eventCount >= 3) {
        return;
    }
    
    self.eventCount++;
    
    NSString * eventTitle = [@"My event " stringByAppendingString:@(self.eventCount).description];
    
    [[HYPEventManager sharedManager] createEventWithTitle:eventTitle
                                                startDate:[NSDate dateWithTimeIntervalSinceNow:60*60]
                                                 duration:0.5
                                               completion:^(NSString *eventIdentifier, NSError *error) {
                                                   NSLog(@"Event created %@", eventIdentifier);
                                                   
                                                   dispatch_after(0.5, dispatch_get_main_queue(), ^{
                                                       [[HYPEventManager sharedManager] updateEvent:eventIdentifier
                                                                                          withTitle:[eventTitle stringByAppendingString:@" (updated)"]
                                                                                          startDate:[NSDate dateWithTimeIntervalSinceNow:60*60*3]
                                                                                           duration:1
                                                                                         completion:^(NSString *updatedIdentifier, NSError *error) {
                                                                                             NSLog(@"Event updated %@", updatedIdentifier);
                                                                                             [self addEvents];
                                                                                         }];
                                                   });
                                               }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
