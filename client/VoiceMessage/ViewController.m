//
//  ViewController.m
//  VoiceMessage
//
//  Created by Johan Karlsteen on 2011-10-28.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"
#import "ASIFormDataRequest.h"

@implementation ViewController
@synthesize statusLabel;
@synthesize recordButton;
@synthesize playButton;
@synthesize uploadButton;
@synthesize progressIndicator;
@synthesize codeTextField;
@synthesize shareButton;
@synthesize player;
@synthesize recorder;
@synthesize playbackWasInterrupted;

// Which VoiceMessageServer should we use (http://localhost:8080 if we debug GAE)
NSString *MESSAGESERVER = @"http://voicemessageserver.appspot.com";
NSString *filePath = [NSTemporaryDirectory() stringByAppendingPathComponent: @"recordedFile.caf"];
NSString *currentCode;
bool sharingIsPossible = NO;
bool uploadIsPossible = NO;
enum {
    upload = 0,
    download
};

#pragma mark Cleanup
- (void)dealloc
{
	delete player;
	delete recorder;
	[recordButton release];
	[playButton release];
    [uploadButton release];
    [statusLabel release];
    [statusLabel release];
    [progressIndicator release];
    [codeTextField release];
    [codeTextField release];
    [shareButton release];
    [shareButton release];
	[super dealloc];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initializeAudio];
}

- (void)viewDidUnload
{
    [self setRecordButton:nil];
    [self setPlayButton:nil];
    [self setUploadButton:nil];
    [statusLabel release];
    statusLabel = nil;
    [self setStatusLabel:nil];
    [self setProgressIndicator:nil];
    [codeTextField release];
    codeTextField = nil;
    [self setCodeTextField:nil];
    [shareButton release];
    shareButton = nil;
    [self setShareButton:nil];
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Only portrait
    if (interfaceOrientation == UIDeviceOrientationPortrait) {
        return YES;
    } else {
        return NO;
    }
}

#pragma mark Playback routines
-(void)stopPlayQueue
{
	player->StopQueue();
	[recordButton setEnabled:YES];
    [shareButton setEnabled:sharingIsPossible];
    [codeTextField setEnabled:YES];
    [uploadButton setEnabled:uploadIsPossible];
}

-(void)pausePlayQueue
{
	player->PauseQueue();
	playbackWasPaused = YES;
}

- (void)stopRecord
{
	recorder->StopRecord();
	
	// dispose the previous playback queue
	player->DisposeQueue(true);
    
	// now create a new queue for the recorded file
	recordFilePath = (CFStringRef)filePath;
    
	player->CreateQueueForFile(recordFilePath);
    
	// Set the button's state back to "record"
	[recordButton setTitle:@"1. Record"];
	[playButton setEnabled:YES];
    uploadIsPossible = YES;
    [uploadButton setEnabled:YES];
    sharingIsPossible = NO;
    [codeTextField setEnabled:YES];
}

- (IBAction)play:(id)sender
{
	if (player->IsRunning())
	{
		if (playbackWasPaused) {
			OSStatus result = player->StartQueue(true);
			if (result == noErr)
				[[NSNotificationCenter defaultCenter] postNotificationName:@"playbackQueueResumed" object:self];
		}
		else
			[self stopPlayQueue];
	}
	else
	{		
		OSStatus result = player->StartQueue(false);
		if (result == noErr)
			[[NSNotificationCenter defaultCenter] postNotificationName:@"playbackQueueResumed" object:self];
	}
}

- (IBAction)record:(id)sender
{
	if (recorder->IsRunning()) // If we are currently recording, stop and save the file.
	{
		[self stopRecord];
	}
	else // If we're not recording, start.
	{
		[playButton setEnabled:NO];
        [uploadButton setEnabled:NO];
        [codeTextField setEnabled:NO];
        [shareButton setEnabled:NO];
		
		// Set the button's state to "stop"
		[recordButton setTitle:@"Stop"];
        
		// Start the recorder
		recorder->StartRecord(CFSTR("recordedFile.caf"));
    }	
}

// Disable all gui components
- (void) disableGui {
    [playButton setEnabled:NO];
    [recordButton setEnabled:NO];
    [uploadButton setEnabled:NO];
    [codeTextField setEnabled:NO];
    [shareButton setEnabled:NO];
}

/*
 * Uploads the last recorded audiofile to the server
 */
- (IBAction)upload:(id)sender
{
    [self disableGui];
    [statusLabel setText:@"Uploading..."];

    // Create the request
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/upload", MESSAGESERVER]];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request addFile:filePath forKey:@"audiofile"];
    [request setRequestMethod:@"POST"];
    [request setUploadProgressDelegate:progressIndicator];
    [request setDelegate:self];

    // Show and reset progress indicator
    [progressIndicator setProgress:0.0];
    [progressIndicator setHidden:NO];
    phase = upload;
    
    NSLog(@"Uploading: %@", filePath);
    [request startAsynchronous];
}

/* Delegate that will try to download a voice message when the user 
 * presses Done on the keyboard for the codeTextField
 */
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    // We have only one textfield so we don't need to see who it is
    [textField resignFirstResponder];
    
    // Only try to download if there is something in the textfield that is 21 (kHashTagLength) characters long
    if (textField.text.length == kHashTagLength) {
        [self downloadToVoiceMessageWithId:codeTextField.text];
    }
    return NO;
}

#pragma mark http routines
/*
 * Used by both the AppDelegate when the user clicks a voicemessage:// link
 * and the UITextFieldDelegate method (textFieldShouldReturn)
 */
- (void)downloadToVoiceMessageWithId:(NSString*)voiceMessageId {
    [self disableGui];
    [statusLabel setText:@"Downloading..."];

    // Create the request
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/audio/%@", MESSAGESERVER, voiceMessageId]];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request setDownloadDestinationPath:filePath];
    [request setDownloadProgressDelegate:progressIndicator];
    [request setDelegate:self];
    
    // Show and reset progress indicator
    [progressIndicator setProgress:0.0];
    [progressIndicator setHidden:NO];
    phase = download;
    
    // Download synchronous since we cannot do anything
    // while we are waiting anyway
    NSLog(@"Downloading: %@ to: %@", [url absoluteString], filePath);
    [request startSynchronous];
    
}


/*
 * Called when ASIHTTPRequest has finished communicating
 * phase tells the application if it was upload or download
 */
- (void)requestFinished:(ASIHTTPRequest *)request
{
    [progressIndicator setHidden:YES];
    [recordButton setEnabled:YES];

    // Only process status 200 (everything is ok)
    if(request.responseStatusCode == 200) {
        [statusLabel setText:@"Done!"];

        // Enable some buttons
        sharingIsPossible = YES;
        [shareButton setEnabled:sharingIsPossible];
        [playButton setEnabled:YES];
        
        // After a successful up-/download we don't want to upload again
        uploadIsPossible = NO;

        if (phase == upload) {
            NSString *codeString = [request responseString];
            currentCode = codeString;
            NSLog(@"Code: %@", codeString);
            
            [codeTextField setText:codeString];
        } else if(phase == download) {
            currentCode = codeTextField.text;
            
            // dispose the previous playback queue and create a new one for the downloaded file
            player->DisposeQueue(true);
            recordFilePath = (CFStringRef)filePath;
            player->CreateQueueForFile(recordFilePath);
            
            // Start playing
            [self play:self];
        } 
    } else {
        // Error, should really take care of all possible error codes
        NSLog(@"Request failed with: %d", request.responseStatusCode);
        // Hide playbutton if download failed
        if (phase == download) {
            [playButton setEnabled:NO];
            [statusLabel setText:@"Invalid code"];
        } else {
            [statusLabel setText:@"Upload failed"];
        }
    }
}

/*
 * Called when a request to the server failed.
 * Should have more error code cases for different
 * errors (Radio off, server cannot be reached etc).
 */
- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
    NSLog(@"Error response: %d %@", [error code], 
          [error localizedDescription]);
    switch ([error code]) {
        case 1:
            // Connection failure
            [statusLabel setText:@"Connection failure"];            
            break;
            
        default:
            [statusLabel setText:@"Unknown error"];
            break;
    }
    [playButton setEnabled:YES];
    [recordButton setEnabled:YES];
    [uploadButton setEnabled:YES];
    [progressIndicator setHidden:YES];
}

#pragma mark Mail sharing
/*
 * Opens a new mail where the user can send a VoiceMessage code to someone
 */
- (IBAction)share:(id)sender {
    MFMailComposeViewController* controller = [[MFMailComposeViewController alloc] init];
    controller.mailComposeDelegate = self;
    [controller setSubject:@"You've got a VoiceMessage!"];
    NSString *message = [NSString stringWithFormat:@"Hi, I have recorded a VoiceMessage for you.\r\n\r\nYou can listen to it by having VoiceMessage installed and clicking this link: voicemessage://%@", codeTextField.text];
    [controller setMessageBody:message isHTML:NO]; 
    if (controller) [self presentModalViewController:controller animated:YES];
    [controller release];
}

/*
 * Delegate that is run when the mail view exits
 */
- (void)mailComposeController:(MFMailComposeViewController*)controller  
          didFinishWithResult:(MFMailComposeResult)result 
                        error:(NSError*)error;
{
    if (result == MFMailComposeResultSent) {
        [statusLabel setText:@"VoiceMessage sent!"];
    }
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark AudioSession listeners
/*
 * The rest of the code is copied from the example project SpeakHere
 * http://developer.apple.com/library/ios/#samplecode/SpeakHere/Introduction/Intro.html
 * with some minor changes
 */
void interruptionListener(	void *	inClientData,
                          UInt32	inInterruptionState)
{
	ViewController *THIS = (ViewController*)inClientData;
	if (inInterruptionState == kAudioSessionBeginInterruption)
	{
		if (THIS->recorder->IsRunning()) {
			[THIS stopRecord];
		}
		else if (THIS->player->IsRunning()) {
			//the queue will stop itself on an interruption, we just need to update the UI
			[[NSNotificationCenter defaultCenter] postNotificationName:@"playbackQueueStopped" object:THIS];
			THIS->playbackWasInterrupted = YES;
		}
	}
	else if ((inInterruptionState == kAudioSessionEndInterruption) && THIS->playbackWasInterrupted)
	{
		// we were playing back when we were interrupted, so reset and resume now
		THIS->player->StartQueue(true);
		[[NSNotificationCenter defaultCenter] postNotificationName:@"playbackQueueResumed" object:THIS];
		THIS->playbackWasInterrupted = NO;
	}
}

void propListener(	void *                  inClientData,
                  AudioSessionPropertyID	inID,
                  UInt32                  inDataSize,
                  const void *            inData)
{
	ViewController *THIS = (ViewController*)inClientData;
	if (inID == kAudioSessionProperty_AudioRouteChange)
	{
		CFDictionaryRef routeDictionary = (CFDictionaryRef)inData;			
		//CFShow(routeDictionary);
		CFNumberRef reason = (CFNumberRef)CFDictionaryGetValue(routeDictionary, CFSTR(kAudioSession_AudioRouteChangeKey_Reason));
		SInt32 reasonVal;
		CFNumberGetValue(reason, kCFNumberSInt32Type, &reasonVal);
		if (reasonVal != kAudioSessionRouteChangeReason_CategoryChange)
		{            
			if (reasonVal == kAudioSessionRouteChangeReason_OldDeviceUnavailable)
			{			
				if (THIS->player->IsRunning()) {
					[THIS pausePlayQueue];
					[[NSNotificationCenter defaultCenter] postNotificationName:@"playbackQueueStopped" object:THIS];
				}		
			}
            
			// stop the queue if we had a non-policy route change
			if (THIS->recorder->IsRunning()) {
				[THIS stopRecord];
			}
		}	
	}
	else if (inID == kAudioSessionProperty_AudioInputAvailable)
	{
		if (inDataSize == sizeof(UInt32)) {
			UInt32 isAvailable = *(UInt32*)inData;
			// disable recording if input is not available
			THIS->recordButton.enabled = (isAvailable > 0) ? YES : NO;
		}
	}
}

#pragma mark Initialization routines
- (void)initializeAudio
{		
	// Allocate our singleton instance for the recorder & player object
	recorder = new AQRecorder();
	player = new AQPlayer();
    
	OSStatus error = AudioSessionInitialize(NULL, NULL, interruptionListener, self);
	if (error) printf("ERROR INITIALIZING AUDIO SESSION! %ld\n", error);
	else 
	{
		UInt32 category = kAudioSessionCategory_PlayAndRecord;	
		error = AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(category), &category);
		if (error) printf("couldn't set audio category!");
        
		error = AudioSessionAddPropertyListener(kAudioSessionProperty_AudioRouteChange, propListener, self);
		if (error) printf("ERROR ADDING AUDIO SESSION PROP LISTENER! %ld\n", error);
		UInt32 inputAvailable = 0;
		UInt32 size = sizeof(inputAvailable);
		
		// we do not want to allow recording if input is not available
		error = AudioSessionGetProperty(kAudioSessionProperty_AudioInputAvailable, &size, &inputAvailable);
		if (error) printf("ERROR GETTING INPUT AVAILABILITY! %ld\n", error);
		recordButton.enabled = (inputAvailable) ? YES : NO;
		
		// we also need to listen to see if input availability changes
		error = AudioSessionAddPropertyListener(kAudioSessionProperty_AudioInputAvailable, propListener, self);
		if (error) printf("ERROR ADDING AUDIO SESSION PROP LISTENER! %ld\n", error);
        
		error = AudioSessionSetActive(true); 
		if (error) printf("AudioSessionSetActive (true) failed");
	}
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackQueueStopped:) name:@"playbackQueueStopped" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackQueueResumed:) name:@"playbackQueueResumed" object:nil];
	
	// disable the play button since we have no recording to play yet
	[playButton setEnabled:NO];
    [uploadButton setEnabled:NO];
	playbackWasInterrupted = NO;
	playbackWasPaused = NO;
}

# pragma mark Notification routines
- (void)playbackQueueStopped:(NSNotification *)note
{
	[playButton setTitle:@"2. Play" forState:UIControlStateNormal];
	[recordButton setEnabled:YES];
    [shareButton setEnabled:sharingIsPossible];
    [codeTextField setEnabled:YES];
    [uploadButton setEnabled:uploadIsPossible];
}

- (void)playbackQueueResumed:(NSNotification *)note
{
	[playButton setTitle:@"Stop" forState:UIControlStateNormal];
	[recordButton setEnabled:NO];
    [shareButton setEnabled:NO];
    [codeTextField setEnabled:NO];
    [uploadButton setEnabled:NO];
}
@end
