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
                for (int row = NumRows; row >= 0; row--) {
                    BBQTile *tileA = [level tileAtColumn:column row:row];
                    
                    if (row < NumRows && tileA != nil) {
                        BBQTile *tileB = [level tileAtColumn:column row:row + 1];
                        if (tileB != nil) {
                            BBQCookie *cookieA = [level cookieAtColumn:column row:row];
                            BBQCookie *cookieB = [level cookieAtColumn:column row:row + 1];
                            
                            if (cookieB == nil) {
                                cookieA = cookieB;
                            }
                            
                            else if (cookieA.cookieType == cookieB.cookieType) {
                                cookieA.cookieType == cookieA.cookieType + 1;
                                cookieB = nil;
                            }
                            
                        }
                    }
                }
            }
        }
    }
    return self;
}



@end
