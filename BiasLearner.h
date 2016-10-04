//
//  BiasLearner.h
//  MM
//
//  Tim Burke and Tom Davis
//

#import <Foundation/Foundation.h>


@interface BiasLearner : NSObject {

}

@property (nonatomic, assign) int numberOfColors;
@property (nonatomic, assign) int numberOfSlots;
@property (nonatomic, retain) NSArray *taskArguments;
@property (nonatomic, assign) int biasColors;


- (id)initWithSlots:(int)slots colors:(int)colors;

+ (id)biasLearnerWithSlots:(int)slots colors:(int)colors;

- (int)learnBias;




@end
