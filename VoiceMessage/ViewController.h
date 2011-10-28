//
//  ViewController.h
//  VoiceMessage
//
//  Created by Johan Karlsteen on 2011-10-28.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AQPlayer.h"
#import "AQRecorder.h"

@interface ViewController : UIViewController {
    IBOutlet UIButton *recordButton;
    IBOutlet UIButton *playButton;
    AQPlayer*					player;
	AQRecorder*					recorder;
    BOOL						playbackWasInterrupted;
	BOOL						playbackWasPaused;
	
	CFStringRef					recordFilePath;	
}
@property (retain, nonatomic) IBOutlet UIButton *recordButton;
@property (retain, nonatomic) IBOutlet UIButton *playButton;
@property (readonly)			AQPlayer			*player;
@property (readonly)			AQRecorder			*recorder;
@property						BOOL				playbackWasInterrupted;

- (IBAction)play:(id)sender;
- (IBAction)record:(id)sender;
- (void)initializeAudio;
void interruptionListener(	void *	inClientData,
                          UInt32	inInterruptionState);
void propListener(	void *                  inClientData,
                  AudioSessionPropertyID	inID,
                  UInt32                  inDataSize,
                  const void *            inData);
@end
