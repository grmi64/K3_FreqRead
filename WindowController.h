//
//  ContentViewController.h
//
//  Created by xnav on 6/16/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import <dispatch/dispatch.h>

#include <termios.h>
#include <stdio.h>
#include <unistd.h>
#include <fcntl.h>
#include <strings.h>
#include <sys/signal.h>
#include <sys/types.h>
#include <sys/ioctl.h>
#include <IOKit/serial/IOSerialKeys.h>
#include <IOKit/IOBSD.h>

@interface WindowController : NSWindowController <NSWindowDelegate> {
	IBOutlet NSWindow *myWindow;
	IBOutlet NSSlider *speedSlide;
	IBOutlet NSTextField *speedCur;
	IBOutlet NSTextField *mmDistance;
	IBOutlet NSTextField *totalDist;
	IBOutlet NSPopUpButton *ttySelect;
	IBOutlet NSButton *buttonStop;
	IBOutlet NSButton *buttonTXMODE;
	IBOutlet NSButton *buttonRXMODE;
	IBOutlet NSButton *buttonFreq;
	IBOutlet NSButton *buttonRight;
	IBOutlet NSProgressIndicator *fileOpening;
    IBOutlet NSTextField *freqReadout;
IBOutlet NSTextField *myTXLABEL;
IBOutlet NSTextField *myTXFIELD;
    IBOutlet NSTextField *FOUT;
    IBOutlet NSTextField *myTelnetField;
}


- (IBAction)goStop:(id)sender;
- (IBAction)setTX:(id)sender;
- (IBAction)clrTX:(id)sender;
- (IBAction)getFreq:(id)sender;
- (IBAction)goRight:(id)sender;
- (IBAction)speedChange:(id)sender;
- (IBAction)ttyPicked:(id)sender;
- (IBAction)VFOmovement:(id)sender;
- (IBAction)telnetConnect:(id)sender;

- (void)windowWillClose:(NSNotification *)notification;

@property (nonatomic, retain) NSSlider *speedSlide;
@property (nonatomic, retain) NSTextField *speedCur;
@property (nonatomic, retain) NSPopUpButton *ttySelect;
@property (nonatomic, retain) NSTextField *mmDistance;
@property (nonatomic, retain) NSTextField *totalDist;
@property (nonatomic, retain) NSWindow *myWindow;
@property (nonatomic, retain) NSButton *buttonStop;
@property (nonatomic, retain) NSButton *buttonTXMODE;
@property (nonatomic, retain) NSButton *buttonRXMODE;
@property (nonatomic, retain) NSButton *buttonFreq;
@property (nonatomic, retain) NSButton *buttonRight;
@property (nonatomic, retain) NSProgressIndicator *fileOpening;
@property (nonatomic, retain) NSTextField *freqReadout;

@property (assign) IBOutlet NSTextField *myTXLABEL;
@property (assign) IBOutlet NSTextField *myTXFIELD;

@end
