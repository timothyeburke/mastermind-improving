//
//  Gamekeeper.m
//  MM
//
//  Tim Burke and Tom Davis
//


#import "Gamekeeper.h"


@implementation Gamekeeper

#pragma mark -
#pragma mark Class Variables

@synthesize theCode;
@synthesize numberOfColors;
@synthesize numberOfSlots;
@synthesize guessIndex;

@synthesize theCodeCopy;
@synthesize guessI;
@synthesize codeAtJ;
@synthesize guessStr;
@synthesize codesStr;

@synthesize black;
@synthesize white;

@synthesize bias;
@synthesize task;


#pragma mark -
#pragma mark Initialization


// Initialize a gamekeeper object with slots/colors
- (id)initWithSlots:(int)slots colors:(int)colors bias:(int)iBias {
	if(self = [super init]) {
		self.theCode = nil;
		self.numberOfColors = colors;
		self.numberOfSlots = slots;
		self.guessIndex = 0;
		self.bias = iBias;
		if(self.bias == -1) {
			self.bias = arc4random() % 5;
		}
	}

	// Run the mmcodes.py to generate a code for the player to discover
	self.task = [[[NSTask alloc] init] autorelease];
	[self.task setLaunchPath: @"/usr/bin/python"];
	NSString *command = [NSString stringWithString:@"/Users/belcorriko/Dropbox/mmcodes.py"];
	NSArray *arguments = [NSArray arrayWithObjects: 
						  command, 

						  // Bias
						  @"-b",
						  [NSString stringWithFormat:@"%d", self.bias],
						  //@"3",
						  
						  // Seed
						  @"-s",
						  [NSString stringWithFormat:@"%d", arc4random() % 1000000000],
						  //@"1",
						  
						  @"-c", 
						  [NSString stringWithFormat:@"%d", colors], 
						  @"-p", 
						  [NSString stringWithFormat:@"%d", slots], 
						  nil];
	[self.task setArguments: arguments];
	NSPipe *pipe = [NSPipe pipe];
	[self.task setStandardOutput: pipe];
	NSFileHandle *file = [pipe fileHandleForReading];
	[self.task launch];
	NSData *data = [file readDataToEndOfFile];
	NSString *string = [[[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding] autorelease];
	self.theCode = [NSMutableArray arrayWithArray:[string componentsSeparatedByString: @" "]];
	return self;
}

// Create a new Gamekeeper Object with slots/colors
+ (id)gamekeeperWithSlots:(int)slots colors:(int)colors bias:(int)iBias {
	return [[[Gamekeeper alloc] initWithSlots:slots colors:colors bias:iBias] autorelease];
}


// The driver passes in the guess from the player, and this function analyzes
// the guess and determines the number of 
- (void)guessWithArray:(NSArray *)guess {
	if ([guess count] != [self.theCode count]) {
		NSLog(@"Bad Guess length!  Received guess of length %d, but code is length %d.", [guess count], [self.theCode count]);
		exit(-1);
	}
	self.guessIndex += 1;
	
	// Reset the number of black and white pegs
	self.black = 0;
	self.white = 0;
	
	// Make a copy of the code
	self.theCodeCopy = [NSMutableArray arrayWithArray:self.theCode];
	
	// Determine the number of white pegs
	for(int i = 0; i < [guess count] - 1; i++) {
		self.guessI = [guess objectAtIndex:i];
		for(int j = 0; j < [theCodeCopy count] - 1; j++) {
			self.codeAtJ = [self.theCodeCopy objectAtIndex:j];
			if([self.codeAtJ intValue] == [self.guessI intValue]) {
				[self.theCodeCopy removeObjectAtIndex:j];
				self.white += 1;
				break;
			}
		}
	}
	
	// Determine the number of black pegs
	for(int i = 0; i < [guess count] - 1; i++) {
		self.guessStr = [guess objectAtIndex:i];
		self.codesStr = [self.theCode objectAtIndex:i];
		if([self.guessStr intValue] == [self.codesStr intValue]) {
			self.black += 1;
			self.white -= 1;
		}
	}
}





#pragma mark -
#pragma mark Memory Management

- (void)dealloc {
	self.theCode = nil;
	self.theCodeCopy = nil;
	self.guessI = nil;
	self.codeAtJ = nil;
	self.guessStr = nil;
	self.codesStr = nil;
	[super dealloc];
}





@end
