VoiceMessage

===========================================================================
DESCRIPTION:

This is a very simple VoiceMessage application developed during a weekend.

It is based on the iOS sample SpeakHere (http://developer.apple.com/library/ios/#samplecode/SpeakHere/Introduction/Intro.html) as well as ASIHTTPRequest (http://allseeing-i.com/ASIHTTPRequest/) as well as a lot of Googling, StackOverflow etc.

The application lets you record a short memo and after that you can play it back and/or upload it to the web.
The server code is included in the server subdirectory and is a Python GAE application.

After a successful upload the memo can be shared via the Share-arrow. This creates a new mail sending the unique voice message code to someone.

One change that I did to the SpeakHere sample was to lower the quality to The iLBC narrow band speech codec to allow longer messages to be recorded.

There is a lot missing as of now. First of all there is a limit of 1 MB in Google App Engine blobs which will let you record about 7-8 minutes of voice, after that the upload will fail.
Also there is minimal error handling when the server cannot be reached.

I would really like to add test cases but I haven't had time, I spent 4 hours with XCode 4.2 trying to understand why one project was able to run Application tests and the other one complained about logic tests. Suddenly everything started working and I think it had to do with the Application name, love XCode.

Keep in mind that this is a bedroom coded project, the code is not bulletproof.

===========================================================================
BUILD REQUIREMENTS:

Mac OS X v10.7.2, Xcode 4.1, iPhone OS 5.0


===========================================================================
RUNTIME REQUIREMENTS:

Simulator: Mac OS X v10.7.2
iPhone: iPhone OS 5.0


===========================================================================
PACKAGING LIST:

AppDelegate.h
AppDelegate.m

The AppDelegate class defines the application delegate object, responsible for instantiating the application's view.

ViewController.h
ViewController.m

The ViewController class acts as the applcation's view controller.
It also performs the upload/download tasks as well as talkin to the recorder/player.
This should probably be put in a separate class.

ASI*.{h,m} and Reachability.{h,m}
These are the ASIHTTPRequest classes. Just a minor change here to get rid of a C++ compilation warning
 
================================================================================
 2011-10-30 Johan Karlsteen
