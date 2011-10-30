//
//  VoiceMessageTests.m
//  VoiceMessageTests
//
//  Created by Johan Karlsteen on 2011-10-30.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "VoiceMessageTests.h"

@implementation VoiceMessageTests

- (void)setUp
{
    [super setUp];
    yourApplicationDelegate = [[UIApplication sharedApplication] delegate];
    viewController = [yourApplicationDelegate viewController];
    view = [viewController view];
}

- (void)testAppDelegate
{
    STAssertNotNil(yourApplicationDelegate, @"UIApplication failed to find the AppDelegate");
}

- (void)testViewController
{
    STAssertNotNil(viewController, @"UIApplication failed to find the View Controller");
}

- (void)testView
{
    STAssertNotNil(view, @"UIApplication failed to find the View");
}

@end
