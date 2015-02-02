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
#import "BBQCookieOrder.h"

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
                                          EATEN_COOKIES : [@[] mutableCopy],
                                          EATEN_COOKIES_FROM_ORDER : [@[] mutableCopy],
                                          };
    
    [self startSwipeInDirection:swipeDirection animations:animationsToPerform];

    //Take care of the eaten cookies and scoring
    [animationsToPerform[EATEN_COOKIES] addObjectsFromArray:[self eatCookies]];
    NSLog(@"Current score: %ld", (long)self.currentScore);
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
                            BBQMoveCookie *cookieMovementB = [self moveASingleCookieInDirection:@"Up" toColumn:column row:row + 1];
                            cookieB = [self.level cookieAtColumn:column row:row];
                            if (cookieMovementB) {
                                [animationsToPerform[MOVEMENTS] addObject:cookieMovementB];
                            }
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
                            BBQMoveCookie *cookieMovement = [self moveASingleCookieInDirection:@"Up" toColumn:column row:row];
                            if (cookieMovement) {
                                [animationsToPerform[MOVEMENTS] addObject:cookieMovement];
                            }
                        }
                        else {
                            didCombineSameCookies = NO;
                        }
                    }
                }
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
                            BBQMoveCookie *cookieMovementB = [self moveASingleCookieInDirection:@"Down" toColumn:column row:row - 1];
                            cookieB = [self.level cookieAtColumn:column row:row];
                            if (cookieMovementB) {
                                [animationsToPerform[MOVEMENTS] addObject:cookieMovementB];
                            }
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
                            BBQMoveCookie *cookieMovement = [self moveASingleCookieInDirection:@"Down" toColumn:column row:row];
                            if (cookieMovement) {
                                [animationsToPerform[MOVEMENTS] addObject:cookieMovement];
                            }
                        }
                        else {
                            didCombineSameCookies = NO;
                        }
                    }
                }
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
                            BBQMoveCookie *cookieMovementB = [self moveASingleCookieInDirection:@"Left" toColumn:column - 1 row:row];
                            cookieB = [self.level cookieAtColumn:column row:row];
                            if (cookieMovementB) {
                                [animationsToPerform[MOVEMENTS] addObject:cookieMovementB];
                            }
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
                            BBQMoveCookie *cookieMovement = [self moveASingleCookieInDirection:@"Left" toColumn:column row:row];
                            if (cookieMovement) {
                                [animationsToPerform[MOVEMENTS] addObject:cookieMovement];
                            }
                        }
                        
                        else {
                            didCombineSameCookies = NO;
                        }
                    }
                }
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
                            BBQMoveCookie *cookieMovementB = [self moveASingleCookieInDirection:@"Right" toColumn:column + 1 row:row];
                            cookieB = [self.level cookieAtColumn:column row:row];
                            if (cookieMovementB) {
                                [animationsToPerform[MOVEMENTS] addObject:cookieMovementB];
                            }
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
                            BBQMoveCookie *cookieMovement = [self moveASingleCookieInDirection:@"Right" toColumn:column row:row];
                            if (cookieMovement) {
                                [animationsToPerform[MOVEMENTS] addObject:cookieMovement];
                            }
                        }
                        else {
                            didCombineSameCookies = NO;
                        }
                    }
                }
            }
        }
    }
    
}



- (void)ORIGINALstartSwipeInDirection:(NSString *)swipeDirection animations:(NSDictionary *)animationsToPerform {
    
    //UP swipe
    if ([swipeDirection isEqualToString:@"Up"]) {
        for (int column = 0; column < NumColumns ; column++) {
            for (int row = NumRows - 1; row > 0; row--) {
                BBQTile *tileB = [self.level tileAtColumn:column  row:row];
                if (tileB != nil) {
                    
                    //Find cookie B and if it is nil (as is case if its a shark tile underneath a blank tile), move what would be cookie A to B's tile
                    BBQCookie *cookieB = [self.level cookieAtColumn:column row:row];
                    if (cookieB == nil) {
                        BBQMoveCookie *cookieMovementB = [self moveASingleCookieInDirection:@"Up" toColumn:column row:row + 1];
                        cookieB = [self.level cookieAtColumn:column row:row];
                        if (cookieMovementB) {
                            [animationsToPerform[MOVEMENTS] addObject:cookieMovementB];
                        }
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
                        [self tryCombineCookieA:cookieA withCookieB:cookieB animations:animationsToPerform];
                        
                        //if there was a combo or cookie A is the last cookie above a nil tile, move the cookie below tile A into tile A
                        BBQMoveCookie *cookieMovement = [self moveASingleCookieInDirection:@"Up" toColumn:column row:row];
                        if (cookieMovement) {
                            [animationsToPerform[MOVEMENTS] addObject:cookieMovement];
                        }
                    }
                }
            }
        }
    }
    
    //DOWN swipe
    if ([swipeDirection isEqualToString:@"Down"]) {
        for (int column = 0; column < NumColumns ; column++) {
            for (int row = 0; row < NumRows - 1; row++) {
                BBQTile *tileB = [self.level tileAtColumn:column  row:row];
                if (tileB != nil) {
                    
                    //Find cookie B and if it is nil move what would be cookie A to B's tile
                    BBQCookie *cookieB = [self.level cookieAtColumn:column row:row];
                    if (cookieB == nil) {
                        BBQMoveCookie *cookieMovementB = [self moveASingleCookieInDirection:@"Down" toColumn:column row:row - 1];
                        cookieB = [self.level cookieAtColumn:column row:row];
                        if (cookieMovementB) {
                            [animationsToPerform[MOVEMENTS] addObject:cookieMovementB];
                        }
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
                        [self tryCombineCookieA:cookieA withCookieB:cookieB animations:animationsToPerform];
                        
                        //if there was a combo or cookie A is the last cookie above a nil tile, move the cookie below tile A into tile A
                        BBQMoveCookie *cookieMovement = [self moveASingleCookieInDirection:@"Down" toColumn:column row:row];
                        if (cookieMovement) {
                            [animationsToPerform[MOVEMENTS] addObject:cookieMovement];
                        }
                    }
                }
            }
        }
    }
    
    //LEFT swipe
    if ([swipeDirection isEqualToString:@"Left"]) {
        for (int row = 0; row < NumRows ; row++) {
            for (int column = 0; column < NumColumns - 1; column++) {
                BBQTile *tileB = [self.level tileAtColumn:column  row:row];
                if (tileB != nil) {
                    
                    //Find cookie B and if it is nil move what would be cookie A to B's tile
                    BBQCookie *cookieB = [self.level cookieAtColumn:column row:row];
                    if (cookieB == nil) {
                        BBQMoveCookie *cookieMovementB = [self moveASingleCookieInDirection:@"Left" toColumn:column - 1 row:row];
                        cookieB = [self.level cookieAtColumn:column row:row];
                        if (cookieMovementB) {
                            [animationsToPerform[MOVEMENTS] addObject:cookieMovementB];
                        }
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
                        [self tryCombineCookieA:cookieA withCookieB:cookieB animations:animationsToPerform];
                        
                        //if there was a combo or cookie A is the last cookie above a nil tile, move the cookie below tile A into tile A
                        BBQMoveCookie *cookieMovement = [self moveASingleCookieInDirection:@"Left" toColumn:column row:row];
                        if (cookieMovement) {
                            [animationsToPerform[MOVEMENTS] addObject:cookieMovement];
                        }
                    }
                }
            }
        }
    }
    
    //RIGHT swipe
    if ([swipeDirection isEqualToString:@"Right"]) {
        for (int row = 0; row < NumRows ; row++) {
            for (int column = NumColumns - 1; column > 0; column--) {
                BBQTile *tileB = [self.level tileAtColumn:column  row:row];
                if (tileB != nil) {
                    
                    //Find cookie B and if it is nil (as is case if its a shark tile underneath a blank tile), move what would be cookie A to B's tile
                    BBQCookie *cookieB = [self.level cookieAtColumn:column row:row];
                    if (cookieB == nil) {
                        BBQMoveCookie *cookieMovementB = [self moveASingleCookieInDirection:@"Right" toColumn:column + 1 row:row];
                        cookieB = [self.level cookieAtColumn:column row:row];
                        if (cookieMovementB) {
                            [animationsToPerform[MOVEMENTS] addObject:cookieMovementB];
                        }
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
                        [self tryCombineCookieA:cookieA withCookieB:cookieB animations:animationsToPerform];
                        
                        //if there was a combo or cookie A is the last cookie above a nil tile, move the cookie below tile A into tile A
                        BBQMoveCookie *cookieMovement = [self moveASingleCookieInDirection:@"Right" toColumn:column row:row];
                        if (cookieMovement) {
                            [animationsToPerform[MOVEMENTS] addObject:cookieMovement];
                        }
                    }
                }
            }
        }
    }
    
}

- (BOOL)tryCombineCookieA:(BBQCookie *)cookieA withCookieB:(BBQCookie *)cookieB animations:(NSDictionary *)animations {
    
    BOOL didCombineSameCookies = NO;
    
    if (cookieA.cookieType == cookieB.cookieType) {
        
        //Upgrade count and check whether the new count will turn it into an upgrade
        cookieB.count = cookieB.count + cookieA.count;
        BBQCombo *combo;
        NSMutableArray *combos = animations[COMBOS];
        
        if (cookieB.count < NumCookiesToUpgrade) {
            combo = [[BBQCombo alloc] initWithCookieA:cookieA cookieB:cookieB upgradeType:SAME_TYPE_UPGRADE];
            didCombineSameCookies = YES;
        }
        
        else if (cookieB.count >= NumCookiesToUpgrade) {
            //create the combo object
            combo = [[BBQCombo alloc] initWithCookieA:(BBQCookie *)cookieA cookieB:(BBQCookie *)cookieB upgradeType:DIFFERENT_TYPE_UPGRADE];
            combo.cookieB.cookieType = combo.cookieB.cookieType + 1;
            combo.cookieB.count = 1;
        }
        
        [combos addObject:combo];
        [self.level replaceCookieAtColumn:cookieA.column row:cookieA.row withCookie:nil];
    }
    return didCombineSameCookies;
}

//- (void)ORIGINALtryCombineCookieA:(BBQCookie *)cookieA withCookieB:(BBQCookie *)cookieB animations:(NSDictionary *)animations {
//    
//    if (cookieA.cookieType == cookieB.cookieType) {
//        //NSLog(@"combining cookie A: %@ with cookie B: %@", cookieA, cookieB);
//        
//        //create the combo object
//        BBQCombo *combo = [[BBQCombo alloc] initWithCookieA:(BBQCookie *)cookieA cookieB:(BBQCookie *)cookieB];
//        NSMutableArray *combos = animations[COMBOS];
//        [combos addObject:combo];
//        
//        //Perform the combo model logic
//        NSInteger columnA = combo.cookieA.column;
//        NSInteger rowA = combo.cookieA.row;
//        
//        combo.cookieB.cookieType = combo.cookieB.cookieType + 1;
//        
//        [self.level replaceCookieAtColumn:columnA row:rowA withCookie:nil];
//    }
//}

- (BBQMoveCookie *)moveASingleCookieInDirection:(NSString *)direction toColumn:(NSInteger)columnB row:(NSInteger)rowB {
    
    BBQMoveCookie *moveCookie;
    
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
            moveCookie = [[BBQMoveCookie alloc] initWithCookieA:cookieA destinationColumn:columnB destinationRow:rowB - 1];
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
            moveCookie = [[BBQMoveCookie alloc] initWithCookieA:cookieA destinationColumn:columnB destinationRow:rowB + 1];
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
            moveCookie = [[BBQMoveCookie alloc] initWithCookieA:cookieA destinationColumn:columnB + 1 destinationRow:rowB];
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
            moveCookie = [[BBQMoveCookie alloc] initWithCookieA:cookieA destinationColumn:columnB - 1 destinationRow:rowB];
            cookieA.column = columnB - 1;
            [self.level replaceCookieAtColumn:columnB - 1 row:rowB withCookie:cookieA];
            [self.level replaceCookieAtColumn:columnB - x + 1 row:rowB withCookie:nil];
        }
    }


    
    return moveCookie;

}

- (NSMutableArray *)eatCookies {
    
    NSMutableArray *eatenCookies = [@[] mutableCopy];
    
    //find the eaten cookies
    for (NSInteger row = 0; row < NumRows; row ++) {
        for (NSInteger column = 0; column < NumColumns; column++) {
            BBQTile *tile = [self.level tileAtColumn:column row:row];
            BBQCookie *cookie = [self.level cookieAtColumn:column row:row];
            if (tile.tileType == 2 && cookie != nil) {
                [eatenCookies addObject:cookie];
                [self.level replaceCookieAtColumn:column row:row withCookie:nil];
                
                //update model for cookies eaten from order, and associate them with order so they can be animated
                for (BBQCookieOrder *order in self.level.cookieOrders) {
                    if (order.cookie.cookieType == cookie.cookieType) {
                        order.quantityLeft = order.quantityLeft - 1;
                    }
                }
            }
        }
    }
    
    //score the eaten cookies
    [self scoreEatenCookies:eatenCookies];
    return eatenCookies;
}

- (void)scoreEatenCookies:(NSArray *)eatenCookies {
    for (BBQCookie *cookie in eatenCookies) {
        NSInteger scoreForCookie = [self scoreForCookie:cookie];
        self.currentScore = self.currentScore + scoreForCookie;
    }
}

- (NSInteger)scoreForCookie:(BBQCookie *)cookie {
    NSInteger multiplier = pow(2.0, cookie.cookieType);
    NSInteger scoreForCookie = startingScoreForCookie * multiplier;
    return scoreForCookie;
}

- (BOOL)isLevelComplete {
    BOOL isComplete = NO;
    
    for (BBQCookieOrder *order in self.level.cookieOrders) {
        if (order.quantityLeft <= 0) {
            isComplete = YES;
        }
        else {
            isComplete = NO;
            break;
        }
    }
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
