//
//  MM.m
//  MM
//
//  Tim Burke and Tom Davis
//

#import <Foundation/Foundation.h>
#import "Driver.h"

// Configure

#define COLORS 6
#define SLOTS 4
#define GAMES 10

#define GAME_BIAS 0
// -1 - GAMEKEEPER:  Randomly Select Bias
//  0 - GAMEKEEPER:  Uniform selection 
//  1 - GAMEKEEPER:  Use exactly one color
//  2 - GAMEKEEPER:  Prefer colors with smaller numbers
//  3 - GAMEKEEPER:  Cycle through all of the colors in order
//  4 - GAMEKEEPER:  Unknown Bias from tournament


#define PLAYER_BIAS 999
// -1 - THE PLAYER:  Attempt to learn Bias
//  0 - THE PLAYER:  Mutation Algorithm with color space pruning
//  0 - THE PLAYER:  Uniform selection 
//  1 - THE PLAYER:  Bias: Use exactly one color
//  2 - THE PLAYER:  Bias: Prefer colors with smaller numbers
//  3 - THE PLAYER:  Bias: Cycle through all of the colors in order
//  4 - THE PLAYER:  Bias: Found a constant number of colors != 1 && != slots
//  6 - THE PLAYER:  Random Guesses with color space pruning 
//  7 - THE PLAYER:  Mutation Algorithm without color space pruning
//  8 - THE PLAYER:  Make random moves and do not repeat
//  9 - THE PLAYER:  Make random moves
//999 - THE PLAYER:  For Scaling colors

int main (int argc, const char * argv[]) {
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	[pool class];
    
	NSLog(@"Mastermind AI Driver:");
	
	int moveCount = 0;
	int games = GAMES;
	int maxMove = 0;
	int minMove = 1000000;
	
	NSLog(@"Number of Colors: %d", COLORS);
	NSLog(@"Number of Slots:  %d", SLOTS);
	
	time_t timeStart = time(nil);
	
	Driver *gameDriver = nil;
	
	for(int i = 0; i < games; i++) {
		NSLog(@"Game %d:", i + 1);
		gameDriver = [Driver driverWithSlots:SLOTS colors:COLORS bias:GAME_BIAS];
		gameDriver.player.bias = PLAYER_BIAS;
		[gameDriver go];
		
		moveCount += gameDriver.player.guessIndex;
		
		if(gameDriver.player.guessIndex > maxMove) {
			maxMove = gameDriver.player.guessIndex;
		}
		if(minMove > gameDriver.player.guessIndex) {
			minMove = gameDriver.player.guessIndex;
		}
		
		[gameDriver release];
	}
	
	NSLog(@"Average Number of moves after %d games:  %.2f", games, (double)moveCount / (double)games);
	NSLog(@"Worst Case:  %d", maxMove);
	NSLog(@"Best  Case:  %d", minMove);
	
	time_t timeEnd = time(nil);
	NSLog(@"Run Time:    %d seconds", (timeEnd - timeStart));
	
	
    //[pool drain];
    return 0;
}
