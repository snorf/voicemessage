//
//  DelegateTests.m
//  VoiceMessage
//
//  Created by Johan Karlsteen on 2011-10-30.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "DelegateTests.h"

#import <UIKit/UIKit.h>
//#import "application_headers" as required

@implementation DelegateTests

// All code under test is in the iOS Application
- (void)testAppDelegate
{
    id yourApplicationDelegate = [[UIApplication sharedApplication] delegate];
    STAssertNotNil(yourApplicationDelegate, @"UIApplication failed to find the AppDelegate");
}

@end
