//
//  Gamekeeper.h
//  MM
//
//  Tim Burke and Tom Davis
//


#import <Foundation/Foundation.h>


@interface Gamekeeper : NSObject {

}

@property (nonatomic, retain) NSMutableArray *theCode;
@property (nonatomic, assign) int numberOfColors;
@property (nonatomic, assign) int numberOfSlots;
@property (nonatomic, assign) int guessIndex;

@property (nonatomic, retain) NSMutableArray *theCodeCopy;
@property (nonatomic, retain) NSString *guessI;
@property (nonatomic, retain) NSString *codeAtJ;
@property (nonatomic, retain) NSString *guessStr;
@property (nonatomic, retain) NSString *codesStr;

@property (nonatomic, assign) int black;
@property (nonatomic, assign) int white;

@property (nonatomic, assign) int bias;
@property (nonatomic, retain) NSTask *task;

- (id)initWithSlots:(int)slots colors:(int)colors bias:(int)iBias;

+ (id)gamekeeperWithSlots:(int)slots colors:(int)colors bias:(int)iBias;

- (void)guessWithArray:(NSArray *)guess;


@end
