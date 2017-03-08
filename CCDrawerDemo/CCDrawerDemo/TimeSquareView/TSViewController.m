//
//  TSViewController.m
//  TimeSquareView
//
//  Created by Andrew Herman on 10/6/13.
//  Copyright (c) 2013 APPEK, LLC. All rights reserved.
//

#import "TSViewController.h"

@implementation TSViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    TSQCalendarView *calendarView = [[TSQCalendarView alloc] initWithFrame:CGRectMake(20, 100, 280, 280)];
    calendarView.delegate = self;
    calendarView.firstDate = [NSDate date];
    calendarView.lastDate = [NSDate date];
    
    // This is a tiny modification to get scrolling to be disabled.  Basically I made
    // the tableView property public by moving it from the m-file to the h-file.
    calendarView.tableView.scrollEnabled = NO;
    
    [self.view addSubview:calendarView];
}

- (void)calendarView:(TSQCalendarView *)calendarView didSelectDate:(NSDate *)date
{
    NSLog(@"Cool date man!");
}

@end
