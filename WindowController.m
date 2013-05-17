//
//  ContentViewController.m
//
//  Created by xnav on 6/16/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "WindowController.h"

//#import "GCDAsyncSocket.h"

int fd;
struct termios oldtio, newtio;
//unsigned char	gotoPassive = 0x80;
unsigned char gotoPassive[] = "SWT13;SWT13;FT1;UPB5;RT0;XT0;RX;";
unsigned char txQuery[] = "FT0;RT0;XT0;LN0;SB0;SW000;";
unsigned char getVFOAfreq[] = "FA;";
unsigned char setTXmode[] ="TX;";
unsigned char clrTXmode[] ="RX;";
//unsigned char K3Get[] = "DS;";
unsigned char K3Get[] = "SM;";
unsigned char	playSong[] = {0x8d,0x01};
unsigned char	doStop[] = {0x89,0x00,0x00,0x80,0x00};
unsigned char	doForward[] = {0x89,0x00,0x32,0x80,0x00};
unsigned char	doBack[] = {0x89,0xff,0xce,0x7f,0xff};
unsigned char	doLeft[] = {0x89,0x00,0x32,0x00,0x01};
unsigned char	doRight[] = {0x89,0x00,0x32,0xff,0xff};
unsigned char	getDistance[] = {0x8e,0x13};
unsigned char	getButtons[] = {0x8e,0x12};
unsigned char	goSafe[] = {0x80,0x83};
unsigned char	defSong[] = {0x8c,0x01,0x04,0x3e,0x0c,0x42,0x0c,0x45,0x0c,0x4a,0x24};


#define kMyErrReturn            -1

@implementation WindowController
{
	dispatch_queue_t vfo_queue;
};

@synthesize myTXLABEL;
@synthesize myTXFIELD;
 

@synthesize myWindow, speedSlide, speedCur, mmDistance, totalDist, ttySelect, fileOpening, freqReadout;
@synthesize buttonStop, buttonTXMODE, buttonRXMODE, buttonFreq, buttonRight;




















////////////////////////////////////////////////////////////
// awakeFromNib
////////////////////////////////////////////////////////////
- (void)awakeFromNib {
	kern_return_t			kernResult; 
    CFMutableDictionaryRef	classesToMatch;
	io_object_t		modemService;
	io_iterator_t	matchingServices;
		
	[myWindow setDelegate:self];
	[speedCur setIntValue:45];
	[ttySelect removeAllItems];
	[ttySelect addItemWithTitle:@"Select K3 Port"];
	
	classesToMatch = IOServiceMatching(kIOSerialBSDServiceValue);
    if (classesToMatch == NULL)
    {
        NSLog(@"IOServiceMatching returned a NULL dictionary.");
    }
    else {
		CFDictionarySetValue(classesToMatch,
                             CFSTR(kIOSerialBSDTypeKey),
							 CFSTR(kIOSerialBSDRS232Type));
	}
	kernResult = IOServiceGetMatchingServices(kIOMasterPortDefault, classesToMatch, &matchingServices);    
    if (KERN_SUCCESS != kernResult)
    {
        NSLog(@"IOServiceGetMatchingServices returned %d", kernResult);
    }
	while ((modemService = IOIteratorNext(matchingServices))){
		CFTypeRef	bsdPathAsCFString;
		bsdPathAsCFString = IORegistryEntryCreateCFProperty(modemService,
                                                            CFSTR(kIODialinDeviceKey),
                                                            kCFAllocatorDefault,
                                                            0);
		[ttySelect addItemWithTitle:(NSString *)bsdPathAsCFString];
	}
	(void) IOObjectRelease(modemService);
	
	NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
	[numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
	[[totalDist cell] setFormatter:numberFormatter];
	[[mmDistance cell] setFormatter:numberFormatter];
	[numberFormatter release];
	
//[NSThread detachNewThreadSelector:@selector(aMethod:) toTarget:[MyObject class] withObject:nil];
//	[NSThread detachNewThreaSelector:@selector(g)]
	
}


////////////////////////////////////////////////////////////
// ttyPicked
////////////////////////////////////////////////////////////
- (IBAction)ttyPicked:(id)sender {
	unsigned char buffer[256];
	int	bytes = 0;
	BOOL retryOpen = TRUE;
	
	do {  
		[fileOpening startAnimation:self];
		fd = open([[ttySelect titleOfSelectedItem] cStringUsingEncoding:NSUTF8StringEncoding], O_RDWR | O_NOCTTY | O_NDELAY);
NSLog(@"OPEN!");
		[fileOpening stopAnimation:self];
		if (fd < 0)
		{
			NSAlert *alert = [[NSAlert alloc] init];
			[alert addButtonWithTitle:@"OK"];
			[alert addButtonWithTitle:@"Cancel"];
			[alert setMessageText:@"Try open again?"];
			[alert setInformativeText:[NSString stringWithUTF8String:strerror(errno)]];
			[alert setAlertStyle:NSWarningAlertStyle];
			
			if ([alert runModal] == NSAlertFirstButtonReturn) {
				// OK clicked, try open again
				retryOpen = TRUE;
			}
			else {
				retryOpen = FALSE;
			}

			[alert release];
		}
		else {
			retryOpen = FALSE;
			tcgetattr(fd, &oldtio);
			bzero(&newtio, sizeof(newtio));
			newtio.c_cflag = CS8 | CLOCAL | CREAD;
			
			
			NSLog(@"OLD c_cflag: %lu", oldtio.c_cflag);

			
			
			
			newtio.c_iflag = 0;
			newtio.c_oflag = 0;
			newtio.c_lflag = 0;
			newtio.c_ispeed = B38400;
			newtio.c_ospeed = B38400;
			
//			newtio.c_cflag &= ~CDTR_IFLOW;
//			newtio.c_cflag &= ~CRTS_IFLOW;
			
//			newtio.c_cflag &= ~CRTS_IFLOW;
//			newtio.c_cflag &= ~CDTR_IFLOW;
			
			
//			newtio.c_cflag &= ~CRTSCTS;
//			newtio.c_cflag &= ~CCTS_OFLOW;
			
			NSLog(@"NEW c_cflag: %lu", newtio.c_cflag);

			
			tcsetattr(fd, TCSAFLUSH, &newtio);
				///tcflush(fd, TCIFLUSH);
			
			// Clear Data Terminal Ready (DTR)
			if (ioctl(fd, TIOCCDTR) == kMyErrReturn)
			{
				NSLog(@"*** Error clearing DTR.\n");
			}
			

//			if (ioctl(fd, TIOCSDTR) == kMyErrReturn)
//				// Assert Data Terminal Ready (DTR)
//			{
//				NSLog(@"Error asserting\n");
//			}
//
//			write(fd, &Hello, sizeof(Hello));
//
//			if (ioctl(fd, TIOCCDTR) == kMyErrReturn)
//				// Clear Data Terminal Ready (DTR)
//			{
//				NSLog(@"*** Error clearing DTR.\n");
//			}
			
			
//			write(fd, &txQuery, sizeof(txQuery));
//			write(fd, &getButtons, sizeof(getButtons));  //get any waiting power up msg
			
			write(fd, &getVFOAfreq, sizeof(getVFOAfreq));
			
			[NSThread sleepForTimeInterval:.25];
			bytes = read(fd, &buffer, sizeof(buffer));  //read power up msg if it's there
			if (bytes > 1) {
				buffer[bytes] = 0x00;
				NSLog(@"Message is >%s",buffer);
			}
			else {
				NSLog(@"bytes not > 1: %s", buffer);
			}
			
			write(fd, &gotoPassive, sizeof(gotoPassive));
//			write(fd, &txQuery, sizeof(txQuery));
			//write(fd, &defSong, sizeof(defSong));
			//write(fd, &goSafe, sizeof(goSafe));
			//write(fd, &playSong, sizeof(playSong));
			[buttonRXMODE setEnabled:YES];
			[buttonStop setEnabled:YES];
			[buttonTXMODE setEnabled:YES];
			[buttonFreq setEnabled:YES];
			[buttonRight setEnabled:YES];
//			[myTXFIELD setEnabled:YES];


			vfo_queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
			dispatch_async(vfo_queue, ^{
				
				 char buffer[256];				
				 char prevFreq[256];
				
				int bytes = 0;
				
				// Start the thread running...
				while(1)
				{
					sleep(1);
					write(fd, &getVFOAfreq, sizeof(getVFOAfreq));
					[NSThread sleepForTimeInterval:.25];

					bytes = read(fd, &buffer, sizeof(buffer));  //Read freq from K3
					
					if (bytes > 1) {
						buffer[bytes] = 0x00; // Terminate so we can print it.
						// NSLog(@"FREQ: %s",buffer);

						// Has the freq changed?
						if (strcmp (prevFreq,buffer) != 0)
						{
						
							///////////////////////////////////////////////
							//
							// CALL MAIN THREAD
							//
							///////////////////////////////////////////////
							dispatch_async(dispatch_get_main_queue(), ^{
								char buffer[256];

								write(fd, &getVFOAfreq, sizeof(getVFOAfreq));
								[NSThread sleepForTimeInterval:.25];
								int bytes = read(fd, &buffer, sizeof(buffer));  //Read freq from K3
								if (bytes > 1) {
									buffer[bytes] = 0x00; // Terminate so we can print it.

									myTXLABEL.stringValue = [NSString stringWithFormat:@"%s", buffer];
									//myTXFIELD.stringValue = [NSString stringWithFormat:@"%s", "in_thread"];
									myTXFIELD.stringValue = [NSString stringWithFormat:@"%s", buffer];
								} // if
							}); // dispatch_async()
							
						} // if
						
					}
					strcpy(prevFreq, buffer);
				}
				
				
				
				
			});

			
			
			
			
		}
	} while (retryOpen);
}

////////////////////////////////////////////////////////////
// VFOmovement
////////////////////////////////////////////////////////////
- (IBAction)VFOmovement:(id)sender {
	unsigned char buffer[256];
	
	int	bytes = 0;
	
	[myWindow makeFirstResponder:sender];
	
	write(fd, &getVFOAfreq, sizeof(getVFOAfreq));
	[NSThread sleepForTimeInterval:.25];
	
	
	bytes = read(fd, &buffer, sizeof(buffer));  //Read freq from K3
	if (bytes > 1) {
		buffer[bytes] = 0x00; // Terminate so we can print it.
		NSLog(@"FREQ: %s",buffer);
	}
	else {
		NSLog(@"Bad Freq request - bytes not > 1: %s", buffer);
	}
	
    myTXLABEL.stringValue = [NSString stringWithFormat:@"%s", buffer];	
	myTXFIELD.stringValue = [NSString stringWithFormat:@"%s", buffer];

}

- (IBAction)telnetConnect:(id)sender {
	char mybuff[] = "This is a telnet test";
	myTelnetField.stringValue = [NSString stringWithFormat:@"%s", mybuff];
	NSLog(@"telnetConnect called");
	
	
	
	
	
}

////////////////////////////////////////////////////////////
// goStop
////////////////////////////////////////////////////////////
- (IBAction)goStop:(id)sender {
	unsigned char buffer[12];
	// needed to break a short integer into its bytes because of the way the robot sends sense data in
	union{
		short intInt;
		struct{
			unsigned char Byte2;
			unsigned char Byte1;
		}intBytes;
	}distance;
	
	
	distance.intInt = 0;
	
	[myWindow makeFirstResponder:sender];
	write(fd, &txQuery, sizeof(txQuery));
	NSLog(@"TX RECV SENT");
//	write(fd, &doStop, sizeof(doStop));
//	write(fd, &getDistance, sizeof(getDistance));
//	[NSThread sleepForTimeInterval:.5];
//	int bytes = read(fd, &buffer, sizeof(buffer));
//	if (bytes == 2) {
//		distance.intBytes.Byte1 = buffer[0];
//		distance.intBytes.Byte2 = buffer[1];
//
//		[mmDistance setIntValue:distance.intInt];
//		[totalDist setIntValue:[totalDist intValue] + abs(distance.intInt)];
	//	NSLog(@"TX RECV SENT");
//	}
}

////////////////////////////////////////////////////////////
// clrTX
////////////////////////////////////////////////////////////
- (IBAction)clrTX:(id)sender {
	[myWindow makeFirstResponder:sender];
	doBack[2] = 256 - [speedSlide intValue];
//	write(fd, &doBack, sizeof(doBack));
	write(fd, &clrTXmode, sizeof(clrTXmode));
}

////////////////////////////////////////////////////////////
// setTX
////////////////////////////////////////////////////////////
- (IBAction)setTX:(id)sender {
	[myWindow makeFirstResponder:sender];
	doForward[2] = [speedSlide intValue];
//	write(fd, &doForward, sizeof(doForward));
	write(fd, &setTXmode, sizeof(setTXmode));
}

////////////////////////////////////////////////////////////
// getFreq
////////////////////////////////////////////////////////////
- (IBAction)getFreq:(id)sender {
	unsigned char buffer[256];
//	NSTextField *buffer;
	int	bytes = 0;
	
	[myWindow makeFirstResponder:sender];
//	doLeft[2] = [speedSlide intValue];
//	write(fd, &doLeft, sizeof(doLeft));
	write(fd, &getVFOAfreq, sizeof(getVFOAfreq));
	[NSThread sleepForTimeInterval:.25];
	
	
	bytes = read(fd, &buffer, sizeof(buffer));  //Read freq from K3
	if (bytes > 1) {
		buffer[bytes] = 0x00; // Terminate so we can print it.
		NSLog(@"FREQ: %s",buffer);
	}
	else {
		NSLog(@"Bad Freq request - bytes not > 1: %s", buffer);
	}


//myTXLABEL.stringValue = buffer;
    myTXLABEL.stringValue = [NSString stringWithFormat:@"%s", buffer];
//NSLog(@"%@",self.freqReadout.value);

myTXFIELD.stringValue = [NSString stringWithFormat:@"%s", buffer];


}

////////////////////////////////////////////////////////////
// goRight
////////////////////////////////////////////////////////////
- (IBAction)goRight:(id)sender {
	[myWindow makeFirstResponder:sender];
	doRight[2] = [speedSlide intValue];
	unsigned char foo[100];
	foo[0] = [speedSlide intValue];
	NSLog(@"SLIDER: %c", doRight[2]);
	NSLog(@"SLIDER2: %s", foo);
//	write(fd, &doRight, sizeof(doRight));
}

////////////////////////////////////////////////////////////
// speedChange
////////////////////////////////////////////////////////////
- (IBAction)speedChange:(id)sender {
	[speedCur setIntegerValue:[speedSlide intValue]];
}

////////////////////////////////////////////////////////////
// windowWillClose
////////////////////////////////////////////////////////////
- (void)windowWillClose:(NSNotification *)notification {
	//close up the port
//	write(fd, &gotoPassive, sizeof(gotoPassive));
	tcsetattr(fd, TCSANOW, &oldtio);
	close(fd);
}

////////////////////////////////////////////////////////////
// dealloc
////////////////////////////////////////////////////////////
- (void)dealloc
{
	
    [super dealloc];
}

@end
