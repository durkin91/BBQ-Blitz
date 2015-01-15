//
//  BBQSwipe.m
//  BbqBlitz
//
//  Created by Nikki Durkin on 1/14/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "BBQSwipe.h"
#import "BBQCookie.h"
#import "BBQTile.h"

@implementation BBQSwipe

- (instancetype)initWithDirection:(NSString *)swipeDirection forLevel:(BBQLevel *)level {
    self = [super init];
    if (self != nil) {
        
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
                            //[self tryCombineCookieA:cookieA withCookieB:cookieB];
                            
                            //Check that there is a cookie to combine with
                            if (cookieB == nil) {
                                NSLog(@"moving %@ up one space", cookieA);
                                [level replaceCookieAtColumn:column row:row+1 withCookie:cookieA];
                            }
                            
                            if (cookieA.cookieType == cookieB.cookieType) {
                                NSLog(@"combining cookie A: %@ with cookie B: %@", cookieA, cookieB);
                                cookieB.cookieType = cookieB.cookieType + 1;
                                [level replaceCookieAtColumn:column row:row withCookie:nil];
                            }

                        }
                    }
                }
            }
        }
    }
    return self;
}

- (void)tryCombineCookieA:(BBQCookie *)cookieA withCookieB:(BBQCookie *)cookieB {
    
    //Check that there is a cookie to combine with
    if (cookieB == nil) {
        NSLog(@"moving %@ up one space", cookieA);
        cookieA = cookieB;
    }
    
    if (cookieA.cookieType == cookieB.cookieType) {
        NSLog(@"combining cookie A: %@ with cookie B: %@", cookieA, cookieB);
        cookieB.cookieType = cookieB.cookieType + 1;
        cookieA = nil;
    }
}



@end
