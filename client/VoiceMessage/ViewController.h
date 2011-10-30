//
//  ViewController.h
//  VoiceMessage
//
//  Created by Johan Karlsteen on 2011-10-28.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "AQPlayer.h"
#import "AQRecorder.h"

@interface ViewController : UIViewController<UITextFieldDelegate, MFMailComposeViewControllerDelegate> {
    AQPlayer*					player;
	AQRecorder*					recorder;
    BOOL						playbackWasInterrupted;
	BOOL						playbackWasPaused;
    NSInteger                   phase;
	CFStringRef                 recordFilePath;
}
@property (retain, nonatomic) IBOutlet UILabel *statusLabel;
@property (retain, nonatomic) IBOutlet UIBarButtonItem *recordButton;
@property (retain, nonatomic) IBOutlet UIButton *playButton;
@property (retain, nonatomic) IBOutlet UIBarButtonItem *uploadButton;
@property (retain, nonatomic) IBOutlet UIProgressView *progressIndicator;
@property (retain, nonatomic) IBOutlet UITextField *codeTextField;
@property (retain, nonatomic) IBOutlet UIButton *shareButton;
@property (readonly)			AQPlayer			*player;
@property (readonly)			AQRecorder			*recorder;
@property						BOOL				playbackWasInterrupted;

// IBActions
- (IBAction)play:(id)sender;
- (IBAction)record:(id)sender;
- (IBAction)upload:(id)sender;
- (IBAction)share:(id)sender;

// Helper method to initialize audio (borrowed from SpeakHere)
- (void)initializeAudio;

- (void)downloadToVoiceMessageWithId:(NSString*)voiceMessageId;

void interruptionListener(	void *	inClientData,
                          UInt32	inInterruptionState);
void propListener(	void *                  inClientData,
                  AudioSessionPropertyID	inID,
                  UInt32                  inDataSize,
                  const void *            inData);
@end
