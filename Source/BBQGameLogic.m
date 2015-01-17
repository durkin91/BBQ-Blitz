//
//  BBQSwipe.m
//  BbqBlitz
//
//  Created by Nikki Durkin on 1/14/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "BBQGameLogic.h"
#import "BBQCookie.h"
#import "BBQTile.h"
#import "BBQCombo.h"

@implementation BBQGameLogic

- (NSDictionary *)swipe:(NSString *)swipeDirection forLevel:(BBQLevel *)level {
    
    NSDictionary *animationsToPerform = @{
                                          COMBOS : [@[] mutableCopy],
                                          MOVEMENTS : [@[] mutableCopy],
                                          };
    
    //UP swipe
    if ([swipeDirection isEqualToString:@"Up"]) {
        for (int column = 0; column < NumColumns ; column++) {
            //starts checking in first column, second row from the top
            for (int row = NumRows - 2; row >= 0; row--) {
                BBQTile *tileA = [level tileAtColumn:column row:row];
                if (tileA != nil) {
                    BBQCookie *cookieA = [level cookieAtColumn:column row:row];
                    BBQTile *tileB = [level tileAtColumn:column row:row + 1];
                    if (tileB != nil && cookieA != nil) {
                        BBQCookie *cookieB = [level cookieAtColumn:column row:row + 1];
                        [self tryCombineCookieA:cookieA withCookieB:cookieB forLevel:level column:column row:row animations:animationsToPerform swipeDirection:@"Up"];
                        
                    }
                }
            }
        }
    }
    
    //DOWN swipe
    if ([swipeDirection isEqualToString:@"Down"]) {
        for (int column = 0; column < NumColumns ; column++) {
            //starts checking in first column, second row from the bottom
            for (int row = 1; row <= NumRows - 1; row++) {
                BBQTile *tileA = [level tileAtColumn:column row:row];
                if (tileA != nil) {
                    BBQCookie *cookieA = [level cookieAtColumn:column row:row];
                    BBQTile *tileB = [level tileAtColumn:column row:row - 1];
                    if (tileB != nil && cookieA != nil) {
                        BBQCookie *cookieB = [level cookieAtColumn:column row:row - 1];
                        [self tryCombineCookieA:cookieA withCookieB:cookieB forLevel:level column:column row:row animations:animationsToPerform swipeDirection:@"Down"];
                        
                    }
                }
            }
        }
    }

    
    
    
    NSLog(@"Animations to perform: %@", animationsToPerform);
    return animationsToPerform;
}

//tries to combine the cookies, and either combines them, does nothing or moves the cookie to the right place.
- (void)tryCombineCookieA:(BBQCookie *)cookieA withCookieB:(BBQCookie *)cookieB forLevel:(BBQLevel *)level column:(int)column row:(int)row animations:(NSDictionary *)animations swipeDirection:(NSString *)direction {
    
    if (cookieA.cookieType == cookieB.cookieType) {
        NSLog(@"combining cookie A: %@ with cookie B: %@", cookieA, cookieB);
        
        //create the combo object
        BBQCombo *combo = [[BBQCombo alloc] initWithCookieA:(BBQCookie *)cookieA cookieB:(BBQCookie *)cookieB];
        NSMutableArray *combos = animations[COMBOS];
        [combos addObject:combo];
        
        //Perform combo will return the cookie movements that resulted from the combo.
        NSMutableArray *cookieMovements = [level performCombo:combo swipeDirection:direction];
        [animations[MOVEMENTS] addObjectsFromArray:cookieMovements];
    }
}



@end
