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

@interface ViewController : UIViewController<UITextFieldDelegate> {
    IBOutlet UIBarButtonItem *recordButton;
    IBOutlet UIButton *playButton;
    IBOutlet UIBarButtonItem *uploadButton;
    IBOutlet UILabel *statusLabel;
    IBOutlet UITextField *codeTextField;
    AQPlayer*					player;
	AQRecorder*					recorder;
    BOOL						playbackWasInterrupted;
	BOOL						playbackWasPaused;
    NSInteger                   phase;
	enum {
        upload = 0,
        download
    };
	CFStringRef					recordFilePath;	
}
@property (retain, nonatomic) IBOutlet UILabel *statusLabel;
@property (retain, nonatomic) IBOutlet UIBarButtonItem *recordButton;
@property (retain, nonatomic) IBOutlet UIButton *playButton;
@property (retain, nonatomic) IBOutlet UIBarButtonItem *uploadButton;
@property (retain, nonatomic) IBOutlet UIProgressView *progressIndicator;
@property (retain, nonatomic) IBOutlet UITextField *codeTextField;
@property (readonly)			AQPlayer			*player;
@property (readonly)			AQRecorder			*recorder;
@property						BOOL				playbackWasInterrupted;

- (IBAction)play:(id)sender;
- (IBAction)record:(id)sender;
- (IBAction)upload:(id)sender;
- (void)initializeAudio;
void interruptionListener(	void *	inClientData,
                          UInt32	inInterruptionState);
void propListener(	void *                  inClientData,
                  AudioSessionPropertyID	inID,
                  UInt32                  inDataSize,
                  const void *            inData);
@end
