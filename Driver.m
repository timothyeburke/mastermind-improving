//
//  Driver.m
//  MM
//
//  Tim Burke and Tom Davis
//


#import "Driver.h"
#import "BiasLearner.h"

@implementation Driver

@synthesize game;
@synthesize player;
@synthesize black;
@synthesize white;
@synthesize guess;
@synthesize code;


- (id)initWithSlots:(int)slots colors:(int)colors  bias:(int)iBias{
	if(self = [super init]) {
		self.game = [Gamekeeper gamekeeperWithSlots:slots colors:colors bias:iBias];
		self.player = [Player playerWithSlots:slots colors:colors];
		
		// Pass the task arguments from the game keeper into the player
		// for the bias learner.  The player DOES NOT read hte arguments,
		// it only passes them to the learner.
		self.player.taskArguments = [self.game.task arguments];
	}
	return self;
}


+ (id)driverWithSlots:(int)slots colors:(int)colors  bias:(int)iBias{
	return [[[Driver alloc] initWithSlots:slots colors:colors bias:iBias] autorelease];
}

// Run the game.  This function loops until the player returns the correct code.
// The driver passes code guesses from the player to the gamekeeper, and also
// passes the number of black and white pegs from the gamekeeper to the player.
// When a win is detected, it prints out statistics about the game that was
// just played.  
- (void)go {
	while (YES) {
		[self.player guessWithBlack:self.black white:self.white];
		[self.game guessWithArray:self.player.theGuess];
		self.black = self.game.black;
		self.white = self.game.white;
		self.guess = self.game.guessIndex;
		if(self.black == self.game.numberOfSlots) {
			
			
			NSLog(@"Player Bias: %d", self.player.bias);
			NSLog(@"Actual Bias:  %d", self.game.bias);
			NSLog(@"Got it!  Guess: %d.", self.guess);
			
			self.code = [NSString stringWithString:@""];
			for(int i = 0; i < self.game.numberOfSlots; i++) {
				code = [NSString stringWithFormat:@"%@ %@", code, [self.game.theCode objectAtIndex:i]];
			}
			NSLog(@"Gamekeeper Code:%@", code);
			code = [NSString stringWithString:@""];
			
			code = [self.player.guessRecord lastObject];
			
			NSMutableArray *temp = [NSMutableArray arrayWithArray:[code componentsSeparatedByString:@":"]];
			
			code = [temp componentsJoinedByString:@" "];
			
			NSLog(@"Player Guess:    %@", code);
			
			break;
		}
	}
}


- (void)dealloc {
	self.game = nil;
	self.player = nil;
	self.code = nil;
	[super dealloc];
}


@end
