//
//  Driver.h
//  MM
//
//  Tim Burke and Tom Davis
//


#import <Foundation/Foundation.h>
#import "Gamekeeper.h"
#import "Player.h"


@interface Driver : NSObject {

}

@property (nonatomic, retain) Gamekeeper *game;
@property (nonatomic, retain) Player *player;
@property (nonatomic, assign) int black;
@property (nonatomic, assign) int white;
@property (nonatomic, assign) int guess;
@property (nonatomic, retain) NSString *code;

- (id)initWithSlots:(int)slots colors:(int)colors bias:(int)iBias;

+ (id)driverWithSlots:(int)slots colors:(int)colors bias:(int)iBias;

- (void)go;


@end
