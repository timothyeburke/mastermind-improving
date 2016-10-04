//
//  Player.m
//  MM
//
//  Tim Burke and Tom Davis
//

#import "Player.h"
#import "BiasLearner.h"

@implementation Player

#pragma mark -
#pragma mark Class Variables

// Setup variables
@synthesize guessRecord;
@synthesize numberOfColors;
@synthesize numberOfSlots;
@synthesize guessIndex;

@synthesize theGuess;

// AI Function Variables
@synthesize colorPool;
@synthesize slotColorPools;
@synthesize remainingColors;
@synthesize bestGuess;
@synthesize bestGuessScoreWhite;
@synthesize bestGuessScoreBlack;
@synthesize mutation;
@synthesize allPegsFilled;
@synthesize bias;
@synthesize jump;
@synthesize constantColors;
@synthesize taskArguments;
@synthesize thisAlgorithmBecomingSkynetCost;


#pragma mark -
#pragma mark Initialization

// Initialize a player object with slots/colors
- (id)initWithSlots:(int)slots colors:(int)colors {
	if(self = [super init]) {
		self.guessRecord = [NSMutableArray array];
		self.numberOfColors = colors;
		self.numberOfSlots = slots;
		self.guessIndex = 0;
		self.remainingColors = colors;
		self.colorPool = [NSMutableArray arrayWithCapacity:colors];
		self.slotColorPools = [NSMutableArray arrayWithCapacity:self.numberOfSlots];
		self.mutation = 50;
		self.allPegsFilled = NO;
		self.bias = -1;
		self.jump = 1;
		
		// Generate an initial color pool
		for(int i = 1; i <= colors; i++) {
			[self.colorPool addObject:[NSString stringWithFormat:@"%d", i]];
		}
		
		// Place copies of the color pool into arrays for each of the slots
		for(int i = 0; i < self.numberOfSlots; i++) {
			[self.slotColorPools addObject:[NSMutableArray arrayWithArray:self.colorPool]];
		}
		
		//NSMutableArray *searchSpace = [self generateSearchSpaceWithSize:self.numberOfSlots dictionary:self.colorPool];
	}
	return self;
}

// Create a new player Object with slots/colors
+ (id)playerWithSlots:(int)slots colors:(int)colors {
	return [[[Player alloc] initWithSlots:slots colors:colors] autorelease];
}



#pragma mark -
#pragma mark Game Play Functions


/*
 Main game play function to generate guesses based on the feedback
 from the gamekeeper.
 */
- (void)guessWithBlack:(int)black white:(int)white {
	
	// Check on the bias
	[self determineBias];
	
	/*
	 Originally generated the entire search space here and then pruned it.  That was
	 extremely slow.  Changed to holding an array of possible colors for each slot and
	 then removing colors from those slots when we know that they are not possible for
	 that slot.  Has the same effect as removing from an enumerated search space, but
	 is significantly faster.  
	 */
	
	
	// No black No White pegs, remove all colors in prevous guess from the game
	if((self.guessIndex > 0) && (black == 0) && (white == 0)) {
		//NSLog(@"No black No White pegs, remove all colors from the game");
		for (NSMutableArray *temp in self.slotColorPools) {
			for(int i = 0; i < [self.theGuess count] - 1; i++) {
				if([temp containsObject:[self.theGuess objectAtIndex:i]]) {
					[temp removeObject:[self.theGuess objectAtIndex:i]];
				}
			}
		}
	}
	
	// No black pegs and some white pegs, remove colors from slots from prevous guess
	if((self.guessIndex > 0) && (black == 0) && (white > 0)) {
		//NSLog(@"No black pegs and some white pegs, remove colors from slots");
		for(int i = 0; i < self.numberOfSlots; i++) {
			[[self.slotColorPools objectAtIndex:i] removeObject:[self.theGuess objectAtIndex:i]];
		}
	}
	

	// If all of the pegs are filled as of the last guess, only update the best guess
	// if the number of black pegs has increased.  This code looks exactly the same
	// as the code just below it, but the case is different if the a full peg board
	// has not been identified yet.
	if(self.allPegsFilled) {
		if( black > self.bestGuessScoreBlack ) {
			self.bestGuess = [NSMutableArray arrayWithArray:self.theGuess];
			self.bestGuessScoreBlack = black;
			self.bestGuessScoreWhite = white;
		}
	} else {
		// If all pegs have not been filled yet...
		
		// check if the number of black pegs is better than the last best guess
		if( black > self.bestGuessScoreBlack ) {
			self.bestGuess = [NSMutableArray arrayWithArray:self.theGuess];
			self.bestGuessScoreBlack = black;
			self.bestGuessScoreWhite = white;
		}
		
		// Now, check if the new incoming black+white score is equal to the 
		// number of pegs.  If it is, the board is full and going forward
		// we want the guesser to try permutations of that arrangement of pegs.
		if( (black + white) == self.numberOfSlots ) {
			self.allPegsFilled = YES;
			self.bestGuess = [NSMutableArray arrayWithArray:self.theGuess];
			self.bestGuessScoreBlack = black;
			self.bestGuessScoreWhite = white;
		}
	}
	
	// Increment the guess counter
	self.guessIndex++;
	
	// Destroy the prevous guess
	self.theGuess = nil;
	
	if(self.bias == 9) {
		/*
		 Make random guesses only - no other logic.
		 */
		
		// Initialize the guess array empty.
		self.theGuess = [NSMutableArray array];
		
		// Make a random guess
		for(int i = 0; i < self.numberOfSlots; i++) {
			[self.theGuess addObject:[NSString stringWithFormat:@"%d", (arc4random() % self.numberOfColors) + 1]];
		}

	} else if(self.bias == 8) {
		/*
		 Make random guesses, but no repeats (keep history of prevous guesses).
		 
		 As the number of guesseses increases, checking to see if the guess exists in
		 the memory slows down as the search contains function is O(n) for each check.
		 */
		
		// Keep doing this until a break condition is met
		while (YES) {
			// Initialize the guess array empty.
			self.theGuess = [NSMutableArray array];
			
			// Make a random guess
			for(int i = 0; i < self.numberOfSlots; i++) {
				[self.theGuess addObject:[NSString stringWithFormat:@"%d", (arc4random() % self.numberOfColors) + 1]];
			}
			
			// Check that the code generated has not already been played, if so, 
			// continue in the while loop and generate a new code.
			if(![self.guessRecord containsObject:[self.theGuess componentsJoinedByString:@":"]]) {
				break;
			}
			
			// If we got to here, the code has already been played and we need to
			// generate a new code.  Repeat until a code that meets all the above
			// conditions is found.
			self.theGuess = nil;
		}
		
	} else if(self.bias == 7) {
		/*
		 Mutation Algorithm without color space pruning.
		 */
		
		// Do not become Skynet
		self.thisAlgorithmBecomingSkynetCost = 999999999;
		
		// Keep doing this until a break condition is met
		while (YES) {
			// Initialize the guess array empty.
			self.theGuess = [NSMutableArray array];
			
			// Make a random guess
			for(int i = 0; i < self.numberOfSlots; i++) {
				[self.theGuess addObject:[NSString stringWithFormat:@"%d", (arc4random() % self.numberOfColors) + 1]];
			}
			
			// Test to see how many pegs in the new code match the best guess code
			int match = 0;
			for(int i = 0; i < self.numberOfSlots; i++) {
				if([[self.bestGuess objectAtIndex:i] intValue] == [[self.theGuess objectAtIndex:i] intValue]) {
					match++;
				}
			}
			
			// Ensure at least the same number of pegs in specific positions between
			// the new code and best guess code.  If there is not a match, continue
			// in the while loop and generate a new code.
			if (match != self.bestGuessScoreBlack) {
				self.theGuess = nil;
				continue;
			}
			
			// Check that the code generated has not already been played, if so, 
			// continue in the while loop and generate a new code.
			if(![self.guessRecord containsObject:[self.theGuess componentsJoinedByString:@":"]]) {
				break;
			}
			
			// If we got to here, the code has already been played and we need to
			// generate a new code.  Repeat until a code that meets all the above
			// conditions is found.
			self.theGuess = nil;
		}
	} else if(self.bias == 6) {
		/*
		 Random Guesses with color space pruning 
		 */
		
		// Keep doing this until a break condition is met
		while(YES) {
			self.theGuess = [NSMutableArray array];
			for(int i = 0; i < self.numberOfSlots; i++) {
				NSMutableArray *slotCP = [NSMutableArray arrayWithArray:[self.slotColorPools objectAtIndex:i]];
				NSString *slotColor = [NSString stringWithString:[slotCP objectAtIndex:(arc4random() % [slotCP count])]];
				[self.theGuess addObject:[NSString stringWithString:slotColor]];
			}
			
			// Check that the code generated has not already been played, if so, 
			// continue in the while loop and generate a new code.
			if(![self.guessRecord containsObject:[self.theGuess componentsJoinedByString:@":"]]) {
				break;
			}
			
			// If we got to here, the code has already been played and we need to
			// generate a new code.  Repeat until a code that meets all the above
			// conditions is found.
			self.theGuess = nil;
		}
	
	} else if (self.allPegsFilled) {
		/*
		 This section of the code is a slightly modified version of the mutation algorithm
		 detailed below, but only uses the pegs collected in the current stored best guess.
		 */
		
		//NSLog(@"All Pegs Filled");
		
		// Do not become Skynet
		self.thisAlgorithmBecomingSkynetCost = 999999999;
		
		// Keep doing this until a break condition is met
		while(YES) {
			// Initialize the guess array empty.
			self.theGuess = [NSMutableArray array];
			
			// Make a copy of the current best guess
			NSMutableArray *tempBestGuess = [NSMutableArray arrayWithArray:self.bestGuess];
			[tempBestGuess removeLastObject];
			
			// Randomly generate a new code from the current best guess code
			for(int i = 0; i < self.numberOfSlots; i++) {
				int slot = arc4random() % [tempBestGuess count];
				[self.theGuess addObject:[tempBestGuess objectAtIndex:slot]];
				[tempBestGuess removeObjectAtIndex:slot];
			}
			
			// Test to see how many pegs in the new code match the best guess code
			int match = 0;
			for(int i = 0; i < self.numberOfSlots; i++) {
				if([[self.bestGuess objectAtIndex:i] intValue] == [[self.theGuess objectAtIndex:i] intValue	]) {
					match++;
				}
			}
			
			// Ensure at least the same number of pegs in specific positions between
			// the new code and best guess code.  If there is not a match, continue
			// in the while loop and generate a new code.
			if (match != self.bestGuessScoreBlack) {
				self.theGuess = nil;
				continue;
			}
			
			// Check that the code generated has not already been played, if so, 
			// continue in the while loop and generate a new code.
			if(![self.guessRecord containsObject:[self.theGuess componentsJoinedByString:@":"]]) {
				break;
			}
			
			// If we got to here, the code has already been played and we need to
			// generate a new code.  Repeat until a code that meets all the above
			// conditions is found.
			self.theGuess = nil;
		}
		
	} else if ((self.bias == 1) && (self.guessIndex - 1 < self.numberOfColors)) {
		/*
		 This section of the code supports a bias where the gamekeeper is expected
		 to generate codes that are all the same.  If that is the case, cycle through
		 all of the colors until the correct code is found.  IF this somehow fails
		 to find the correct code, after going through all of the possible colors,
		 default to using the mutation algorithm below.  This section will only run
		 as many times as there are colors.
		*/
		
		//NSLog(@"All one Color");
		
		// Initialize the guess array empty.
		self.theGuess = [NSMutableArray array];
		
		// Generate a code with all the same colors
		for(int i = 0; i < self.numberOfSlots; i++) {
			[self.theGuess addObject:[NSString stringWithFormat:@"%d", self.guessIndex]];
		}
		
	} else if ((self.bias == 2) && (self.guessIndex < ((self.numberOfColors / 2) + 1))) {
		/*
		 This section of the code supports a bias where the gamekeeper is expected
		 to generate codes that prefer lower numbers.  This section does the same
		 as the bias for all one color, but from highest color number downward.
		 This repeats for half of the number of colors.  The logic being, that 
		 higher valued colors will be pruned out of the search space, and then the
		 mutation algorithm below is utilized.  Sadly, this isn't very good.
		 */
		
		//NSLog(@"Colors with Smaller Numbers");
		
		// Initialize the guess array empty.
		self.theGuess = [NSMutableArray array];
		
		for(int i = 0; i < self.numberOfSlots; i++) {
			[self.theGuess addObject:[NSString stringWithFormat:@"%d", (self.numberOfColors - self.guessIndex) + 1]];
		}
		
	} else if ((self.bias == 3) && (self.guessIndex < (self.numberOfColors + 1))) {
		/* This section of the code supports a bias where the gamekeeper is expected
		 to generate codes that generate numbers in order.  This section will cycle
		 through all possible cycled permutations of the number of colors for the
		 number of pegs (1 + the number of colors worst case).  If after iterating
		 through that number of guesses, default to using the mutation algorithm.
		 */
		
		//NSLog(@"Numbers in Order");
		
		// Keep doing this until a break condition is met
		while (YES) {
			// Initialize the guess array empty.
			self.theGuess = [NSMutableArray array];
			
			// Pick a random starting point
			int start = (arc4random() % (self.numberOfColors)) + 1;
			
			// Make the code from that starting point, wrap around if necessary
			for(int i = 0; i < self.numberOfSlots; i++) {
				[self.theGuess addObject:[NSString stringWithFormat:@"%d", start]];
				start++;
				if(start > self.numberOfColors) {
					start = 1;
				}
			}
			
			// Check that the code generated has not already been played, if so, 
			// continue in the while loop and generate a new code.
			if(![self.guessRecord containsObject:[self.theGuess componentsJoinedByString:@":"]]) {
				break;
			}
			
			// If we got to here, the code has already been played and we need to
			// generate a new code.  Repeat until a code that meets all the above
			// conditions is found.
			self.theGuess = nil;
		}
		
	} else if ((self.bias == 999) && (self.guessIndex < (self.numberOfColors / self.numberOfSlots))) {
		/*
		 This section of the code is used for scaling a large number of colors by
		 moving upwards through the color space, in order, jumping up by the number
		 of slots for each move.  As the moves progress up, most of the colors will 
		 be removed from the search space, and once the initial moves are completed
		 the game moves on to using the mutation algorithm.
		 */
		
		//NSLog(@"Numbers in Order - For large color sets");
		self.theGuess = [NSMutableArray array];
		for(int i = 0; i < self.numberOfSlots; i++) {
			[self.theGuess addObject:[NSString stringWithFormat:@"%d", self.jump]];
			self.jump++;
		}
		
	} else {
		/* 
		 This section of the code uses a basic genetic mutation algorithm.  It works
		 by taking the best discovered guess so far (determined by the number of black
		 pegs that resulted from that guess), and making guesses from it.  As the
		 number of black pegs increases, the codes generated will be progressively
		 more similar to the best guess code until eventually the code is discovered
		 or all of the pegs become filled with white or black pegs, and then the
		 modified mutation algorithm for all pegs filled is utilized.
		 */
		
		//NSLog(@"Mutation Algorithm (kinda) %d", self.guessIndex);
		
		// Do not become Skynet
		self.thisAlgorithmBecomingSkynetCost = 999999999;
		
		// Keep doing this until a break condition is met
		while(YES) {
			// Initialize the guess array empty.
			self.theGuess = [NSMutableArray array];
			
			// Randomly generate a new code from the current best guess code
			for(int i = 0; i < self.numberOfSlots; i++) {
				NSMutableArray *slotCP = [NSMutableArray arrayWithArray:[self.slotColorPools objectAtIndex:i]];
				NSString *slotColor = [NSString stringWithString:[slotCP objectAtIndex:(arc4random() % [slotCP count])]];
				[self.theGuess addObject:[NSString stringWithString:slotColor]];
			}
			
			// Test to see how many pegs in the new code match the best guess code
			int match = 0;
			for(int i = 0; i < self.numberOfSlots; i++) {
				if([[self.bestGuess objectAtIndex:i] intValue] == [[self.theGuess objectAtIndex:i] intValue]) {
					match++;
				}
			}
			if (match != self.bestGuessScoreBlack && self.bestGuessScoreBlack > 0) {
				self.theGuess = nil;
				continue;
			}
			
			// If the bias is 4 (a constant number of colors), check to see if the
			// number of colors in the code match the learned number of constant
			// colors
			if(self.bias == 4) {
				int colorsFound = 0;
				NSMutableArray *tempColors = [NSMutableArray array];
				for(int i = 0; i < self.numberOfSlots; i++) {
					NSString *tString = [self.theGuess objectAtIndex:i];
					if(![tempColors containsObject:tString]) {
						[tempColors addObject:tString];
						colorsFound++;
					}
				}
				if (colorsFound != self.constantColors) {
					self.theGuess = nil;
					continue;
				}
			}
			
			// Check that the code generated has not already been played, if so, 
			// continue in the while loop and generate a new code.
			if(![self.guessRecord containsObject:[self.theGuess componentsJoinedByString:@":"]]) {
				break;
			}
			
			// If we got to here, the code has already been played and we need to
			// generate a new code.  Repeat until a code that meets all the above
			// conditions is found.
			self.theGuess = nil;
		}
	}
	
	// Add the guess to the guess record
	[self.guessRecord addObject:[self.theGuess componentsJoinedByString:@":"]];
	
	// Add a null color to the end of the guess, makes the gamekeeper happy
	[self.theGuess addObject:[NSString stringWithString:@"0"]];
}



/*
 This function is not used.  It was part of an earlier rendition of the player
 object that generated the entire search space.  This function recursively
 generates an array containing all possible codes with a size (number of
 pegs) with a given alphabet (colors as strings in an array).
 */
- (NSMutableArray *)generateSearchSpaceWithSize:(int)size dictionary:(NSMutableArray *)alphabet {
	if (size == 1) { // base case
		return alphabet;
	}
	NSMutableArray *all_smaller_strings = [self generateSearchSpaceWithSize:size-1 dictionary:alphabet];
	NSMutableArray *all_larger_strings = [NSMutableArray array];
	for (int i = 0; i < [alphabet count]; i++) {
		for (int j = 0; j < [all_smaller_strings count]; j++) {
			NSString *new_word = [NSString stringWithFormat:@"%@:%@", [alphabet objectAtIndex:i], [all_smaller_strings objectAtIndex:j]];
			[all_larger_strings addObject:new_word];
		}
	}
	return all_larger_strings;
}

/*
 This function is called by the guess function to determine the bias if it is not yet
 learned or set.
 */
-(void)determineBias {
	if (self.bias > -1) {
		return;
	}
	
	BiasLearner *learner = [BiasLearner biasLearnerWithSlots:self.numberOfSlots colors:self.numberOfColors];
	learner.taskArguments = self.taskArguments;
	self.bias = [learner learnBias];
	if (self.bias == 4) {
		self.constantColors = learner.biasColors;
	}
	
}


#pragma mark -
#pragma mark Memory Management


- (void)dealloc {
	
	self.guessRecord = nil;
	self.theGuess = nil;
	self.colorPool = nil;
	self.slotColorPools = nil;
	self.bestGuess = nil;
	self.taskArguments = nil;

	[super dealloc];
}



@end
