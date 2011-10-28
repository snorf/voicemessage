//
//  ViewController.h
//  VoiceMessage
//
//  Created by Johan Karlsteen on 2011-10-28.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AudioController.h"

@interface ViewController : UIViewController {
    IBOutlet AudioController *audioController;
}
@property (retain, nonatomic) IBOutlet UIButton *startButton;
@property (retain, nonatomic) IBOutlet UIButton *stopButton;
@property (readonly, nonatomic) AudioController *audioController;

- (IBAction)startAction:(id)sender;
- (IBAction)stopAction:(id)sender;
@end
