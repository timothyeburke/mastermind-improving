//
//  Player.h
//  MM
//
//  Tim Burke and Tom Davis
//


#import <Foundation/Foundation.h>


@interface Player : NSObject {

}

@property (nonatomic, retain) NSMutableArray *guessRecord;
@property (nonatomic, assign) int numberOfColors;
@property (nonatomic, assign) int numberOfSlots;
@property (nonatomic, assign) int guessIndex;

@property (nonatomic, retain) NSMutableArray *theGuess;

// AI Variables
@property (nonatomic, retain) NSMutableArray *colorPool;
@property (nonatomic, retain) NSMutableArray *slotColorPools;
@property (nonatomic, assign) int remainingColors;

@property (nonatomic, retain) NSMutableArray *bestGuess;
@property (nonatomic, assign) int bestGuessScoreWhite;
@property (nonatomic, assign) int bestGuessScoreBlack;
@property (nonatomic, assign) int mutation;
@property (nonatomic, assign) BOOL allPegsFilled;
@property (nonatomic, assign) int bias;
@property (nonatomic, assign) int jump;
@property (nonatomic, assign) int constantColors;
@property (nonatomic, retain) NSArray *taskArguments;
@property (nonatomic, assign) int thisAlgorithmBecomingSkynetCost;

- (id)initWithSlots:(int)slots colors:(int)colors;

+ (id)playerWithSlots:(int)slots colors:(int)colors;

- (void)guessWithBlack:(int)black white:(int)white;

//- (void)generateSearchSpace;

- (NSMutableArray *)generateSearchSpaceWithSize:(int)size dictionary:(NSMutableArray *)alphabet;

-(void)determineBias;

@end
