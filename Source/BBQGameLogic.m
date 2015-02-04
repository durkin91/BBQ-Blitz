//
//  BBQGameLogic.m
//  BbqBlitz
//
//  Created by Nikki Durkin on 1/14/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "BBQGameLogic.h"
#import "BBQCookie.h"
#import "BBQTile.h"
#import "BBQCombo.h"
#import "BBQMoveCookie.h"

@implementation BBQGameLogic

#pragma mark - Setup Logic

- (NSSet *)setupGameLogicWithLevel:(NSInteger)level {
    NSString *directory = [NSString stringWithFormat:@"Level_%ld", (long)level];
    self.level = [[BBQLevel alloc] initWithFile:directory];
    self.movesLeft = self.level.maximumMoves;
    return [self.level createCookiesInBlankTiles];
}

#pragma mark - Swipe Logic

- (NSDictionary *)swipe:(NSString *)swipeDirection {
    
    NSDictionary *animationsToPerform = @{
                                          COMBOS : [@[] mutableCopy],
                                          MOVEMENTS : [@[] mutableCopy],
                                          };
    
    [self startSwipeInDirection:swipeDirection animations:animationsToPerform];
    self.movesLeft = self.movesLeft - 1;
    
    return animationsToPerform;
}

- (void)startSwipeInDirection:(NSString *)swipeDirection animations:(NSDictionary *)animationsToPerform {
    
    //UP swipe
    if ([swipeDirection isEqualToString:@"Up"]) {
        for (int column = 0; column < NumColumns ; column++) {
            for (int row = NumRows - 1; row > 0; row--) {
                BBQTile *tileB = [self.level tileAtColumn:column  row:row];
                if (tileB != nil) {
                    BOOL didCombineSameCookies = YES;
                    while (didCombineSameCookies) {
                        //Find cookie B and if it is nil (as is case if its a shark tile underneath a blank tile), move what would be cookie A to B's tile
                        BBQCookie *cookieB = [self.level cookieAtColumn:column row:row];
                        if (cookieB == nil) {
                            [self moveASingleCookieInDirection:@"Up" toColumn:column row:row + 1];
                            cookieB = [self.level cookieAtColumn:column row:row];
                        }
                        
                        //Find cookie A
                        BBQCookie *cookieA = [self.level cookieAtColumn:column row:row - 1];
                        BBQTile *tileA = [self.level tileAtColumn:column row:row - 1];
                        int x = 2;
                        while (tileA != nil && cookieA == nil && x <= row) {
                            tileA = [self.level tileAtColumn:column row:row - x];
                            cookieA = [self.level cookieAtColumn:column row:row - x];
                            x++;
                        }
                        
                        if (cookieA != nil) {
                            didCombineSameCookies = [self tryCombineCookieA:cookieA withCookieB:cookieB animations:animationsToPerform];
                            
                            //if there was a combo or cookie A is the last cookie above a nil tile, move the cookie below tile A into tile A
                            [self moveASingleCookieInDirection:@"Up" toColumn:column row:row];
                        }
                        else {
                            didCombineSameCookies = NO;
                        }
                    }
                }
            }
            
            //Now create the cookie movements for the sprites to match where the cookies are located in the model
            for (int row = NumRows - 1; row > 0; row--) {
                [self createCookieMovements:animationsToPerform column:column row:row];
            }
        }
    }
    
    //DOWN swipe
    if ([swipeDirection isEqualToString:@"Down"]) {
        for (int column = 0; column < NumColumns ; column++) {
            for (int row = 0; row < NumRows - 1; row++) {
                BBQTile *tileB = [self.level tileAtColumn:column  row:row];
                if (tileB != nil) {
                    BOOL didCombineSameCookies = YES;
                    while (didCombineSameCookies) {
                        //Find cookie B and if it is nil move what would be cookie A to B's tile
                        BBQCookie *cookieB = [self.level cookieAtColumn:column row:row];
                        if (cookieB == nil) {
                            [self moveASingleCookieInDirection:@"Down" toColumn:column row:row - 1];
                            cookieB = [self.level cookieAtColumn:column row:row];
                        }
                        
                        //Find cookie A
                        BBQCookie *cookieA = [self.level cookieAtColumn:column row:row + 1];
                        BBQTile *tileA = [self.level tileAtColumn:column row:row + 1];
                        int x = 2;
                        while (tileA != nil && cookieA == nil && row + x < NumRows) {
                            tileA = [self.level tileAtColumn:column row:row + x];
                            cookieA = [self.level cookieAtColumn:column row:row + x];
                            x++;
                        }
                        
                        if (cookieA != nil) {
                            didCombineSameCookies = [self tryCombineCookieA:cookieA withCookieB:cookieB animations:animationsToPerform];
                            
                            //if there was a combo or cookie A is the last cookie above a nil tile, move the cookie below tile A into tile A
                            [self moveASingleCookieInDirection:@"Down" toColumn:column row:row];
                        }
                        else {
                            didCombineSameCookies = NO;
                        }
                    }
                }
            }
            
            //Now create the cookie movements for the sprites to match where the cookies are located in the model
            for (int row = 0; row < NumRows - 1; row++) {
                [self createCookieMovements:animationsToPerform column:column row:row];
            }

        }
    }
    
    //LEFT swipe
    if ([swipeDirection isEqualToString:@"Left"]) {
        for (int row = 0; row < NumRows ; row++) {
            for (int column = 0; column < NumColumns - 1; column++) {
                BBQTile *tileB = [self.level tileAtColumn:column  row:row];
                if (tileB != nil) {
                    BOOL didCombineSameCookies = YES;
                    while (didCombineSameCookies) {
                        //Find cookie B and if it is nil move what would be cookie A to B's tile
                        BBQCookie *cookieB = [self.level cookieAtColumn:column row:row];
                        if (cookieB == nil) {
                            [self moveASingleCookieInDirection:@"Left" toColumn:column - 1 row:row];
                            cookieB = [self.level cookieAtColumn:column row:row];
                        }
                        
                        //Find cookie A
                        BBQCookie *cookieA = [self.level cookieAtColumn:column + 1 row:row];
                        BBQTile *tileA = [self.level tileAtColumn:column + 1 row:row];
                        int x = 2;
                        while (tileA != nil && cookieA == nil && column + x < NumColumns) {
                            tileA = [self.level tileAtColumn:column + x row:row];
                            cookieA = [self.level cookieAtColumn:column + x row:row];
                            x++;
                        }
                        
                        if (cookieA != nil) {
                            didCombineSameCookies = [self tryCombineCookieA:cookieA withCookieB:cookieB animations:animationsToPerform];
                            
                            //if there was a combo or cookie A is the last cookie above a nil tile, move the cookie below tile A into tile A
                            [self moveASingleCookieInDirection:@"Left" toColumn:column row:row];
                        }
                        
                        else {
                            didCombineSameCookies = NO;
                        }
                    }
                }
            }
            
            //Now create the cookie movements for the sprites to match where the cookies are located in the model
            for (int column = 0; column < NumColumns - 1; column ++) {
                [self createCookieMovements:animationsToPerform column:column row:row];
            }
        }
    }
    
    //RIGHT swipe
    if ([swipeDirection isEqualToString:@"Right"]) {
        for (int row = 0; row < NumRows ; row++) {
            for (int column = NumColumns - 1; column > 0; column--) {
                BBQTile *tileB = [self.level tileAtColumn:column  row:row];
                if (tileB != nil) {
                    BOOL didCombineSameCookies = YES;
                    while (didCombineSameCookies) {
                        //Find cookie B and if it is nil (as is case if its a shark tile underneath a blank tile), move what would be cookie A to B's tile
                        BBQCookie *cookieB = [self.level cookieAtColumn:column row:row];
                        if (cookieB == nil) {
                            [self moveASingleCookieInDirection:@"Right" toColumn:column + 1 row:row];
                            cookieB = [self.level cookieAtColumn:column row:row];
                        }
                        
                        //Find cookie A
                        BBQCookie *cookieA = [self.level cookieAtColumn:column - 1 row:row];
                        BBQTile *tileA = [self.level tileAtColumn:column - 1 row:row];
                        int x = 2;
                        while (tileA != nil && cookieA == nil && x <= column) {
                            tileA = [self.level tileAtColumn:column - x row:row];
                            cookieA = [self.level cookieAtColumn:column - x row:row];
                            x++;
                        }
                        
                        if (cookieA != nil) {
                            didCombineSameCookies = [self tryCombineCookieA:cookieA withCookieB:cookieB animations:animationsToPerform];
                            
                            //if there was a combo or cookie A is the last cookie above a nil tile, move the cookie below tile A into tile A
                            [self moveASingleCookieInDirection:@"Right" toColumn:column row:row];
                        }
                        else {
                            didCombineSameCookies = NO;
                        }
                    }
                }
            }
            
            //Now create the cookie movements for the sprites to match where the cookies are located in the model
            for (int column = NumColumns - 1; column > 0; column--) {
                [self createCookieMovements:animationsToPerform column:column row:row];
            }
        }
    }
}

- (void)createCookieMovements:(NSDictionary *)animationsToPerform column:(NSInteger)column row:(NSInteger)row {
    BBQCookie *cookie = [self.level cookieAtColumn:column row:row];
    if (cookie != nil) {
        BBQMoveCookie *movement = [[BBQMoveCookie alloc] initWithCookieA:cookie destinationColumn:cookie.column destinationRow:cookie.row];
        [animationsToPerform[MOVEMENTS] addObject:movement];
    }
}

- (BOOL)tryCombineCookieA:(BBQCookie *)cookieA withCookieB:(BBQCookie *)cookieB animations:(NSDictionary *)animations {
    
    BOOL didCombineSameCookies = NO;
    
    if (cookieA.cookieType == cookieB.cookieType) {
        
        //Upgrade count and check whether the new count will turn it into an upgrade
        cookieB.count = cookieB.count + cookieA.count;
        BBQCombo *combo = combo = [[BBQCombo alloc] initWithCookieA:cookieA cookieB:cookieB destinationColumn:cookieB.column destinationRow:cookieB.row];
        NSMutableArray *combos = animations[COMBOS];
        [combos addObject:combo];
        [self.level replaceCookieAtColumn:cookieA.column row:cookieA.row withCookie:nil];
        didCombineSameCookies = YES;
    }
    return didCombineSameCookies;
}

//Only moves the cookie in the model. Doesn't create the BBQCookieMovement object
- (void)moveASingleCookieInDirection:(NSString *)direction toColumn:(NSInteger)columnB row:(NSInteger)rowB {
    
    //UP Swipe
    if ([direction isEqualToString:@"Up"]) {
        
        //find the A cookie
        BBQCookie *cookieA = [self.level cookieAtColumn:columnB row:rowB - 1];
        BBQTile *tileA = [self.level tileAtColumn:columnB row:rowB - 1];
        int x = 2;
        while (tileA != nil && cookieA == nil && x <= rowB) {
            tileA = [self.level tileAtColumn:columnB row:rowB - x];
            cookieA = [self.level cookieAtColumn:columnB row:rowB - x];
            x ++;
        }
        
        //move cookie A if it isn't the cookie already directly below cookie B
        if (cookieA != nil && cookieA.row != rowB - 1) {
            cookieA.row = rowB - 1;
            [self.level replaceCookieAtColumn:columnB row:rowB - 1 withCookie:cookieA];
            [self.level replaceCookieAtColumn:columnB row:rowB - x + 1 withCookie:nil];
        }
    }
    
    //DOWN Swipe
    if ([direction isEqualToString:@"Down"]) {
        
        //find the A cookie
        BBQCookie *cookieA = [self.level cookieAtColumn:columnB row:rowB + 1];
        BBQTile *tileA = [self.level tileAtColumn:columnB row:rowB + 1];
        int x = 2;
        while (tileA != nil && cookieA == nil && rowB + x < NumRows) {
            tileA = [self.level tileAtColumn:columnB row:rowB + x];
            cookieA = [self.level cookieAtColumn:columnB row:rowB + x];
            x ++;
        }
        
        //move cookie A if it isn't the cookie already directly below cookie B
        if (cookieA != nil && cookieA.row != rowB + 1) {
            cookieA.row = rowB + 1;
            [self.level replaceCookieAtColumn:columnB row:rowB + 1 withCookie:cookieA];
            [self.level replaceCookieAtColumn:columnB row:rowB + x - 1 withCookie:nil];
        }
    }
    
    //LEFT Swipe
    if ([direction isEqualToString:@"Left"]) {
        
        //find the A cookie
        BBQCookie *cookieA = [self.level cookieAtColumn:columnB + 1 row:rowB];
        BBQTile *tileA = [self.level tileAtColumn:columnB + 1 row:rowB];
        int x = 2;
        while (tileA != nil && cookieA == nil && columnB + x < NumColumns) {
            tileA = [self.level tileAtColumn:columnB + x row:rowB];
            cookieA = [self.level cookieAtColumn:columnB + x row:rowB];
            x ++;
        }
        
        //move cookie A if it isn't the cookie already directly below cookie B
        if (cookieA != nil && cookieA.column != columnB + 1) {
            cookieA.column = columnB + 1;
            [self.level replaceCookieAtColumn:columnB + 1 row:rowB withCookie:cookieA];
            [self.level replaceCookieAtColumn:columnB + x - 1 row:rowB withCookie:nil];
        }
    }
    
    //RIGHT Swipe
    if ([direction isEqualToString:@"Right"]) {
        
        //find the A cookie
        BBQCookie *cookieA = [self.level cookieAtColumn:columnB - 1 row:rowB];
        BBQTile *tileA = [self.level tileAtColumn:columnB - 1 row:rowB];
        int x = 2;
        while (tileA != nil && cookieA == nil && x <= columnB) {
            tileA = [self.level tileAtColumn:columnB - x row:rowB];
            cookieA = [self.level cookieAtColumn:columnB - x row:rowB];
            x ++;
        }
        
        //move cookie A if it isn't the cookie already directly below cookie B
        if (cookieA != nil && cookieA.column != columnB - 1) {
            cookieA.column = columnB - 1;
            [self.level replaceCookieAtColumn:columnB - 1 row:rowB withCookie:cookieA];
            [self.level replaceCookieAtColumn:columnB - x + 1 row:rowB withCookie:nil];
        }
    }

}

//- (NSMutableArray *)eatCookies {
//    
//    NSMutableArray *eatenCookies = [@[] mutableCopy];
//    
//    //find the eaten cookies
//    for (NSInteger row = 0; row < NumRows; row ++) {
//        for (NSInteger column = 0; column < NumColumns; column++) {
//            BBQTile *tile = [self.level tileAtColumn:column row:row];
//            BBQCookie *cookie = [self.level cookieAtColumn:column row:row];
//            if (tile.tileType == 2 && cookie != nil) {
//                [eatenCookies addObject:cookie];
//                [self.level replaceCookieAtColumn:column row:row withCookie:nil];
//                
//                //update model for cookies eaten from order, and associate them with order so they can be animated
//                for (BBQCookieOrder *order in self.level.cookieOrders) {
//                    if (order.cookie.cookieType == cookie.cookieType) {
//                        order.quantityLeft = order.quantityLeft - 1;
//                    }
//                }
//            }
//        }
//    }
//    
//    //score the eaten cookies
//    [self scoreEatenCookies:eatenCookies];
//    return eatenCookies;
//}

- (BOOL)isLevelComplete {
    BOOL isComplete = NO;
    
    
    return isComplete;
}

- (BOOL)areThereMovesLeft {
    BOOL movesLeft = NO;
    if (self.movesLeft > 0) {
        movesLeft = YES;
    }
    return movesLeft;
}






@end
