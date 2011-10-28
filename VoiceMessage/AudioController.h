//
//  AudioController.h
//  VoiceMessage
//
//  Created by Johan Karlsteen on 2011-10-28.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "CAStreamBasicDescription.h"


@interface AudioController : NSObject {
    // Audio Graph Members
	AUGraph   mGraph;
	AudioUnit mMixer;
    
	// Audio Stream Descriptions
	CAStreamBasicDescription outputCASBD;	
    
	// Sine Wave Phase marker
	double sinPhase;
}

- (void)initializeAUGraph;
- (void)startAUGraph;
- (void)stopAUGraph;

@end
