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
#import "BBQComboAnimation.h"
#import "BBQMoveCookie.h"
#import "BBQPowerup.h"

@implementation BBQGameLogic

#pragma mark - Setup Logic

- (NSSet *)setupGameLogicWithLevel:(NSInteger)level {
    NSString *directory = [NSString stringWithFormat:@"Level_%ld", (long)level];
    self.level = [[BBQLevel alloc] initWithFile:directory];
    self.movesLeft = self.level.maximumMoves;
    NSSet *cookies = [self.level createCookiesInBlankTiles];
    [self sortCookieSetIntoTypes:cookies];
    NSLog(@"in setup: %@", self.cookieTypeCount);
    return cookies;
}

- (void)sortCookieSetIntoTypes:(NSSet *)cookieSet {
    
    NSMutableArray *sortedCookies = [@[] mutableCopy];
    for (int i = 0; i < NumStartingCookies; i++) {
        [sortedCookies addObject:@(0)];
    }
    
    for (BBQCookie *cookie in cookieSet) {
        if (cookie.cookieType <= NumCookieTypes) {
            NSNumber *count = sortedCookies[cookie.cookieType - 1];
            NSInteger newCount = [count integerValue] + 1;
            sortedCookies[cookie.cookieType - 1] = [NSNumber numberWithInteger:newCount];
        }
    }
    
    self.cookieTypeCount = sortedCookies;
}

- (void)sortGoldenGooseCookies:(NSArray *)goldenGooseCookies {
    for (BBQCookie *cookie in goldenGooseCookies) {
        NSNumber *count = self.cookieTypeCount[cookie.cookieType - 1];
        NSInteger newCount = [count integerValue] + 1;
        self.cookieTypeCount[cookie.cookieType - 1] = [NSNumber numberWithInteger:newCount];
    }
}

#pragma mark - Swipe Logic

- (NSDictionary *)swipe:(NSString *)swipeDirection column:(NSInteger)columnToSwipe row:(NSInteger)rowToSwipe {
    
    NSDictionary *animationsToPerform = @{
                                          COMBOS : [@[] mutableCopy],
                                          MOVEMENTS : [@[] mutableCopy],
                                          POWERUPS : [@[] mutableCopy],
                                          GOLDEN_GOOSE_COOKIES : [@[] mutableCopy],
                                          NEW_STEEL_BLOCKER_TILES : [@[] mutableCopy],
                                          };
    
    [self startSwipeInDirection:swipeDirection animations:animationsToPerform column:columnToSwipe row:rowToSwipe];
    self.movesLeft = self.movesLeft - 1;
    [self findComboChains:animationsToPerform[COMBOS] swipeDirection:swipeDirection];
    [self scoreTheCombos:animationsToPerform[COMBOS]];
    NSLog(@"Moves left: %@", [NSString stringWithFormat:@"%ld", (long)self.movesLeft]);
    
    //take care of new golden goose cookies or new steel blocker tiles
    if (self.level.goldenGooseTiles || self.level.steelBlockerFactoryTiles) {
        NSArray *blankTiles = [self findBlankTiles];
        
        if (self.level.goldenGooseTiles) {
            NSMutableArray *goldenGooseCookies = animationsToPerform[GOLDEN_GOOSE_COOKIES];
            [goldenGooseCookies addObjectsFromArray:[self layGoldenGooseEggs:blankTiles]];
            [self sortGoldenGooseCookies:goldenGooseCookies];
        }
        
        if (self.level.steelBlockerFactoryTiles) {
            NSMutableArray *newSteelBlockerTiles = animationsToPerform[NEW_STEEL_BLOCKER_TILES];
            [newSteelBlockerTiles addObjectsFromArray:[self createNewSteelBlockerTilesWithBlankTiles:blankTiles]];
        }
    }
    
    //turn steel blocker tiles from combos into regular tiles
    NSArray *combos = animationsToPerform[COMBOS];
    [self turnSteelBlockerIntoRegularTilesForCombos:combos];
    
    //Get rid of final cookies
    [self removeCompletedCookies:combos];
    
    [self updateSecurityGuardCountdowns];
    
    return animationsToPerform;
}

- (void)startSwipeInDirection:(NSString *)swipeDirection animations:(NSDictionary *)animationsToPerform column:(NSInteger)columnToSwipe row:(NSInteger)rowToSwipe {
    
    //UP swipe
    if ([swipeDirection isEqualToString:@"Up"]) {
        NSInteger column = columnToSwipe;
        for (int row = NumRows - 1; row > 0; row--) {
            BBQTile *tileB = [self.level tileAtColumn:column  row:row];
            if (tileB.requiresACookie) {
                //Find cookie B and if it is nil, move what would be cookie A to B's tile
                BBQCookie *cookieB = [self.level cookieAtColumn:column row:row];
                if (cookieB == nil) {
                    [self moveASingleCookieInDirection:@"Up" toColumn:column row:row + 1];
                    cookieB = [self.level cookieAtColumn:column row:row];
                }
                
                BBQCookie *cookieA = [self findCookieABelowColumn:column row:row swipeDirection:swipeDirection];
                
                if (cookieA != nil) {
                    [self tryCombineCookieA:cookieA withCookieB:cookieB animations:animationsToPerform direction:swipeDirection];
                    
                    //if there was a combo or cookie A is the last cookie above a nil tile, move the cookie below tile A into tile A
                    [self moveASingleCookieInDirection:@"Up" toColumn:column row:row];
                }
            }
        }
        
        //Now create the cookie movements for the sprites to match where the cookies are located in the model
        for (int row = NumRows - 1; row > 0; row--) {
            [self createCookieMovements:animationsToPerform column:column row:row];
        }
    }
    
    //DOWN swipe
    if ([swipeDirection isEqualToString:@"Down"]) {
        NSInteger column = columnToSwipe;
        for (int row = 0; row < NumRows - 1; row++) {
            BBQTile *tileB = [self.level tileAtColumn:column  row:row];
            if (tileB.requiresACookie) {
                //Find cookie B and if it is nil move what would be cookie A to B's tile
                BBQCookie *cookieB = [self.level cookieAtColumn:column row:row];
                if (cookieB == nil) {
                    [self moveASingleCookieInDirection:@"Down" toColumn:column row:row - 1];
                    cookieB = [self.level cookieAtColumn:column row:row];
                }
                
                BBQCookie *cookieA = [self findCookieABelowColumn:column row:row swipeDirection:swipeDirection];
                
                if (cookieA != nil) {
                    [self tryCombineCookieA:cookieA withCookieB:cookieB animations:animationsToPerform direction:swipeDirection];
                    
                    //if there was a combo or cookie A is the last cookie above a nil tile, move the cookie below tile A into tile A
                    [self moveASingleCookieInDirection:@"Down" toColumn:column row:row];
                }
            }
        }
        
        //Now create the cookie movements for the sprites to match where the cookies are located in the model
        for (int row = 0; row < NumRows - 1; row++) {
            [self createCookieMovements:animationsToPerform column:column row:row];
        }
    }
    
    //LEFT swipe
    if ([swipeDirection isEqualToString:@"Left"]) {
        NSInteger row = rowToSwipe;
        for (int column = 0; column < NumColumns - 1; column++) {
            BBQTile *tileB = [self.level tileAtColumn:column  row:row];
            if (tileB.requiresACookie) {
                //Find cookie B and if it is nil move what would be cookie A to B's tile
                BBQCookie *cookieB = [self.level cookieAtColumn:column row:row];
                if (cookieB == nil) {
                    [self moveASingleCookieInDirection:@"Left" toColumn:column - 1 row:row];
                    cookieB = [self.level cookieAtColumn:column row:row];
                }
                
                BBQCookie *cookieA = [self findCookieABelowColumn:column row:row swipeDirection:swipeDirection];
                
                if (cookieA != nil) {
                    [self tryCombineCookieA:cookieA withCookieB:cookieB animations:animationsToPerform direction:swipeDirection];
                    
                    //if there was a combo or cookie A is the last cookie above a nil tile, move the cookie below tile A into tile A
                    [self moveASingleCookieInDirection:@"Left" toColumn:column row:row];
                }
            }
        }
        
        //Now create the cookie movements for the sprites to match where the cookies are located in the model
        for (int column = 0; column < NumColumns - 1; column ++) {
            [self createCookieMovements:animationsToPerform column:column row:row];
        }
        
    }
    
    //RIGHT swipe
    if ([swipeDirection isEqualToString:@"Right"]) {
        NSInteger row = rowToSwipe;
        for (int column = NumColumns - 1; column > 0; column--) {
            BBQTile *tileB = [self.level tileAtColumn:column  row:row];
            if (tileB.requiresACookie) {
                //Find cookie B and if it is nil (as is case if its a shark tile underneath a blank tile), move what would be cookie A to B's tile
                BBQCookie *cookieB = [self.level cookieAtColumn:column row:row];
                if (cookieB == nil) {
                    [self moveASingleCookieInDirection:@"Right" toColumn:column + 1 row:row];
                    cookieB = [self.level cookieAtColumn:column row:row];
                }
                
                BBQCookie *cookieA = [self findCookieABelowColumn:column row:row swipeDirection:swipeDirection];
                
                if (cookieA != nil) {
                    [self tryCombineCookieA:cookieA withCookieB:cookieB animations:animationsToPerform direction:swipeDirection];
                    
                    //if there was a combo or cookie A is the last cookie above a nil tile, move the cookie below tile A into tile A
                    [self moveASingleCookieInDirection:@"Right" toColumn:column row:row];
                }
            }
        }
        
        //Now create the cookie movements for the sprites to match where the cookies are located in the model
        for (int column = NumColumns - 1; column > 0; column--) {
            [self createCookieMovements:animationsToPerform column:column row:row];
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

- (void)tryCombineCookieA:(BBQCookie *)cookieA withCookieB:(BBQCookie *)cookieB animations:(NSDictionary *)animations direction:(NSString *)direction {
    
    if ((cookieA.cookieType == cookieB.cookieType && cookieA.cookieType != 11 && cookieA.cookieType != 10) ||
        (cookieA.cookieType == 10 && cookieB.cookieType == 11) ||
        (cookieA.cookieType == 11 && cookieB.cookieType == 10)) {
        
        BOOL finishedCheckingForBeginningCookieA = NO;
        NSMutableArray *cookiesInChain = [@[] mutableCopy];
        [cookiesInChain addObject:cookieB];
        [cookiesInChain addObject:cookieA];
        BBQCookie *beginningCookieA = cookieA;
        BBQTile *beginningTileA = [self.level tileAtColumn:cookieA.column row:cookieA.row];
        
        if (beginningTileA.staticTileCountdown <= 1) {
            
            //Find all cookies in the chain and put them in an array. 
            NSInteger numberOfChecks = 0;
            while (!finishedCheckingForBeginningCookieA) {
                beginningCookieA = [self findCookieABelowColumn:beginningCookieA.column row:beginningCookieA.row swipeDirection:direction];
                beginningTileA = [self.level tileAtColumn:beginningCookieA.column row:beginningCookieA.row];
                numberOfChecks ++;
                
                if (cookieA.cookieType == beginningCookieA.cookieType) {
                    [cookiesInChain addObject:beginningCookieA];
                    
                    if (beginningTileA.staticTileCountdown <= 1) {
                        finishedCheckingForBeginningCookieA = NO;
                    }
                    else {
                        finishedCheckingForBeginningCookieA = YES;
                    }
                }
                
                else {
                    finishedCheckingForBeginningCookieA = YES;
                }
            }
        }
        
        //Find the lowest cookie in the chain that ISNT in a static tile
        BBQCookie *lowestCookie;
        NSInteger lowestCookieIndex;
        for (BBQCookie *cookie in cookiesInChain) {
            if (cookie.isInStaticTile == NO) {
                lowestCookie = cookie;
                lowestCookieIndex = [cookiesInChain indexOfObjectIdenticalTo:lowestCookie];
            }
        }
        
        //Move up the chain creating combos
        if (lowestCookie) {
            for (int i = lowestCookieIndex; i >= 1; i--) {
                BBQCookie *localCookieA = cookiesInChain[i];
                BBQCookie *localCookieB = cookiesInChain[i - 1];
                [self combineCookieA:localCookieA withcookieB:localCookieB destinationColumn:cookieB.column destinationRow:cookieB.row animations:animations];
            }
        }
    }
    
}


- (void)combineCookieA:(BBQCookie *)cookieA withcookieB:(BBQCookie *)cookieB destinationColumn:(NSInteger)destinationColumn destinationRow:(NSInteger)destinationRow animations:(NSDictionary *)animations {
    //Upgrade count and check whether the new count will turn it into an upgrade
    BBQComboAnimation *combo;
    if (cookieB.isRopeOrSecurityGuard || cookieA.isRopeOrSecurityGuard) {
        combo = [[BBQComboAnimation alloc] initWithCookieA:cookieA cookieB:cookieB destinationColumn:destinationColumn destinationRow:destinationRow];
        BBQTile *tileB = [self.level tileAtColumn:cookieB.column row:cookieB.row];
        tileB.tileType = 9;
        [self.level replaceCookieAtColumn:cookieB.column row:cookieB.row withCookie:nil];
        [self.level replaceCookieAtColumn:cookieA.column row:cookieA.row withCookie:nil];
        
        //Remove the security guard from the array
        if (cookieB.cookieType == 10) {
            [self.level.securityGuardCookies removeObject:cookieB];
        }
        else {
            [self.level.securityGuardCookies removeObject:cookieA];
        }
    }
    
    else {
        combo = [[BBQComboAnimation alloc] initWithCookieA:cookieA cookieB:cookieB destinationColumn:destinationColumn destinationRow:destinationRow];
        combo.cookieB.isFinalCookie = [self isFinalCookie:combo];
    }
    
    NSMutableArray *combos = animations[COMBOS];
    [combos addObject:combo];
    [self.level replaceCookieAtColumn:cookieA.column row:cookieA.row withCookie:nil];
    
    //Explode steel blocker tiles
    [self explodeSteelBlockerTiles:combo];
    
    //take care of static tile
    if (cookieB.isInStaticTile) {
        [self breakOutOfStaticTile:combo];
    }
}

- (void)breakOutOfStaticTile:(BBQComboAnimation *)combo {
    //Break cookie B out of the tile
    BBQTile *tileB = [self.level tileAtColumn:combo.cookieB.column row:combo.cookieB.row];
    tileB.staticTileCountdown = tileB.staticTileCountdown - 1;
    
    if (tileB.staticTileCountdown <= 0) {
    combo.cookieB.isInStaticTile = NO;
    tileB.tileType = 1;
    }
    
    combo.didBreakOutOfStaticTile = YES;
}

#pragma mark - Obstacle methods

- (void)explodeSteelBlockerTiles:(BBQComboAnimation *)combo {
    
    NSMutableArray *adjacentTiles = [@[] mutableCopy];
    if (!combo.cookieB.isInStaticTile) {
        
        if (combo.cookieB.row < NumRows - 1) {
            BBQTile *above = [self.level tileAtColumn:combo.cookieB.column row:combo.cookieB.row + 1];
            [adjacentTiles addObject:above];
        }
        
        if (combo.cookieB.row > 0) {
            BBQTile *below = [self.level tileAtColumn:combo.cookieB.column row:combo.cookieB.row - 1];
            [adjacentTiles addObject:below];
        }
        
        if (combo.cookieB.column > 0) {
            BBQTile *left = [self.level tileAtColumn:combo.cookieB.column - 1 row:combo.cookieB.row];
            [adjacentTiles addObject:left];
        }
        
        if (combo.cookieB.column < NumColumns - 1) {
            BBQTile *right = [self.level tileAtColumn:combo.cookieB.column + 1 row:combo.cookieB.row];
            [adjacentTiles addObject:right];
        }
        
        for (BBQTile *tile in adjacentTiles) {
            if (tile.tileType == 5) {
                if (!combo.steelBlockerTiles) {
                    combo.steelBlockerTiles = [@[] mutableCopy];
                }
                [combo.steelBlockerTiles addObject:tile];
            }
        }
    }
}

- (void)turnSteelBlockerIntoRegularTilesForCombos:(NSArray *)combos {
    for (BBQComboAnimation *combo in combos) {
        for (BBQTile *tile in combo.steelBlockerTiles) {
            tile.tileType = 1;
        }
    }
}

- (NSArray *)layGoldenGooseEggs:(NSArray *)blankTiles {
    
    NSMutableArray *newCookies = [@[] mutableCopy];
    
    for (BBQTile *goldenGooseTile in self.level.goldenGooseTiles) {
        goldenGooseTile.goldenGooseTileCountdown --;
        
        if (goldenGooseTile.goldenGooseTileCountdown <= 0) {
            
            //pick a blank tile at random
            NSUInteger randomTileIndex = arc4random_uniform([blankTiles count]);
            BBQTile *chosenTile = [blankTiles objectAtIndex:randomTileIndex];
            
            //create the cookie
            NSUInteger cookieType = arc4random_uniform(NumStartingCookies) + 1;
            BBQCookie *newCookie = [self.level createCookieAtColumn:chosenTile.column row:chosenTile.row withType:cookieType];
            [newCookies addObject:newCookie];
            
            //reset the countdown
            goldenGooseTile.goldenGooseTileCountdown = goldenGooseMax;
        }
    }
    
    return newCookies;
}

- (NSArray *)createNewSteelBlockerTilesWithBlankTiles:(NSArray *)blankTiles {
    NSMutableArray *newTiles = [@[] mutableCopy];
    
    for (int i = 0; i < [self.level.steelBlockerFactoryTiles count]; i ++) {
        NSUInteger randomTileIndex = arc4random_uniform([blankTiles count]);
        BBQTile *chosenTile = [blankTiles objectAtIndex:randomTileIndex];
        chosenTile.tileType = 5;
        [newTiles addObject:chosenTile];
    }
    return newTiles;
}

- (NSArray *)findBlankTiles {
    //find the blank tiles
    NSMutableArray *blankTiles = [@[] mutableCopy];
    for (NSInteger row = 0; row < NumRows; row++) {
        for (NSInteger column = 0; column < NumColumns; column++) {
            BBQTile *tile = [self.level tileAtColumn:column row:row];
            if ([self.level cookieAtColumn:column row:row] == nil && tile.requiresACookie == YES) {
                [blankTiles addObject:tile];
            }
        }
    }
    return blankTiles;
}



#pragma mark - Movement methods

//Only moves the cookie in the model. Doesn't create the BBQCookieMovement object
- (void)moveASingleCookieInDirection:(NSString *)direction toColumn:(NSInteger)columnB row:(NSInteger)rowB {
    
    //UP Swipe
    if ([direction isEqualToString:@"Up"]) {
        
        //find the A cookie
        BBQCookie *cookieA = [self.level cookieAtColumn:columnB row:rowB - 1];
        BBQTile *tileA = [self.level tileAtColumn:columnB row:rowB - 1];
        int x = 2;
        while (tileA.requiresACookie && cookieA == nil && x <= rowB) {
            tileA = [self.level tileAtColumn:columnB row:rowB - x];
            cookieA = [self.level cookieAtColumn:columnB row:rowB - x];
            x ++;
        }
        
        //move cookie A if it isn't the cookie already directly below cookie B
        if (cookieA != nil && cookieA.row != rowB - 1 && cookieA.isInStaticTile == NO) {
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
        while (tileA.requiresACookie && cookieA == nil && rowB + x < NumRows) {
            tileA = [self.level tileAtColumn:columnB row:rowB + x];
            cookieA = [self.level cookieAtColumn:columnB row:rowB + x];
            x ++;
        }
        
        //move cookie A if it isn't the cookie already directly below cookie B
        if (cookieA != nil && cookieA.row != rowB + 1 && cookieA.isInStaticTile == NO) {
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
        while (tileA.requiresACookie && cookieA == nil && columnB + x < NumColumns) {
            tileA = [self.level tileAtColumn:columnB + x row:rowB];
            cookieA = [self.level cookieAtColumn:columnB + x row:rowB];
            x ++;
        }
        
        //move cookie A if it isn't the cookie already directly below cookie B
        if (cookieA != nil && cookieA.column != columnB + 1 && cookieA.isInStaticTile == NO) {
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
        while (tileA.requiresACookie && cookieA == nil && x <= columnB) {
            tileA = [self.level tileAtColumn:columnB - x row:rowB];
            cookieA = [self.level cookieAtColumn:columnB - x row:rowB];
            x ++;
        }
        
        //move cookie A if it isn't the cookie already directly below cookie B
        if (cookieA != nil && cookieA.column != columnB - 1 && cookieA.isInStaticTile == NO) {
            cookieA.column = columnB - 1;
            [self.level replaceCookieAtColumn:columnB - 1 row:rowB withCookie:cookieA];
            [self.level replaceCookieAtColumn:columnB - x + 1 row:rowB withCookie:nil];
        }
    }

}

- (BBQCookie *)findCookieABelowColumn:(NSInteger)column row:(NSInteger)row swipeDirection:(NSString *)direction {
    
    BBQCookie *cookieA;
    BBQTile *tileA;
    
    if ([direction isEqualToString:@"Up"]) {
        if (row > 0) {
            cookieA = [self.level cookieAtColumn:column row:row - 1];
            tileA = [self.level tileAtColumn:column row:row - 1];
            int x = 2;
            while (tileA.requiresACookie && cookieA == nil && x <= row) {
                tileA = [self.level tileAtColumn:column row:row - x];
                cookieA = [self.level cookieAtColumn:column row:row - x];
                x++;
            }
        }
    }
    
    else if ([direction isEqualToString:@"Down"]) {
        if (row < NumRows - 1) {
            cookieA = [self.level cookieAtColumn:column row:row + 1];
            tileA = [self.level tileAtColumn:column row:row + 1];
            int x = 2;
            while (tileA.requiresACookie && cookieA == nil && row + x < NumRows) {
                tileA = [self.level tileAtColumn:column row:row + x];
                cookieA = [self.level cookieAtColumn:column row:row + x];
                x++;
            }
        }
    }
    
    else if ([direction isEqualToString:@"Left"]) {
        if (column < NumColumns - 1) {
            cookieA = [self.level cookieAtColumn:column + 1 row:row];
            tileA = [self.level tileAtColumn:column + 1 row:row];
            int x = 2;
            while (tileA.requiresACookie && cookieA == nil && column + x < NumColumns) {
                tileA = [self.level tileAtColumn:column + x row:row];
                cookieA = [self.level cookieAtColumn:column + x row:row];
                x++;
            }
        }
    }
    
    else if ([direction isEqualToString:@"Right"]) {
        if (column > 0) {
            cookieA = [self.level cookieAtColumn:column - 1 row:row];
            tileA = [self.level tileAtColumn:column - 1 row:row];
            int x = 2;
            while (tileA.requiresACookie && cookieA == nil && x <= column) {
                tileA = [self.level tileAtColumn:column - x row:row];
                cookieA = [self.level cookieAtColumn:column - x row:row];
                x++;
            }
        }
    }
    
    return cookieA;
}

#pragma mark - Methods for end of swipe


- (BOOL)isLevelComplete {
    BOOL isComplete = YES;
    
    for (NSNumber *number in self.cookieTypeCount) {
        if ([number integerValue] > 1) {
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

- (void)updateSecurityGuardCountdowns {
    for (BBQCookie *securityGuard in self.level.securityGuardCookies) {
        securityGuard.countdown--;
    }
}

- (BOOL)isSecurityGuardAtZero {
    for (BBQCookie *securityGuard in self.level.securityGuardCookies) {
        if (securityGuard.countdown <=0) {
            return YES;
            
        }
    }
    return NO;
}

- (void)removeCompletedCookies:(NSArray *)combos {
    for (BBQComboAnimation *combo in combos) {
        if (combo.cookieB.isFinalCookie) {
            [self.level replaceCookieAtColumn:combo.cookieB.column row:combo.cookieB.row withCookie:nil];
        }
    }
}

- (BOOL)isFinalCookie:(BBQComboAnimation *)combo {
    
    //adjust the count
    NSNumber *count = self.cookieTypeCount[combo.cookieA.cookieType - 1];
    NSInteger newCount = [count integerValue] - 1;
    self.cookieTypeCount[combo.cookieA.cookieType - 1] = [NSNumber numberWithInteger:newCount];
    
    //check if its the final cookie of its type
    if (newCount == 1) return YES;
    else return NO;
}

#pragma mark - Combos

- (void)findComboChains:(NSArray *)combos swipeDirection:(NSString *)swipeDirection {
    
    NSInteger index = [combos count] - 1;
    while (index >= 0) {
        BBQComboAnimation *comboAnimation1 = combos[index];
        comboAnimation1.numberOfCookiesInCombo = 2;
        
        if (index <= 0) break;
        
        BBQComboAnimation *comboAnimation2 = combos[index - 1];
        
        NSInteger x = 2;
        while (comboAnimation1.destinationColumn == comboAnimation2.destinationColumn && comboAnimation1.destinationRow == comboAnimation2.destinationRow) {
            comboAnimation1.numberOfCookiesInCombo = x + 1;
            
            if (index - x < 0) break;
            
            comboAnimation2 = combos[index - x];
            x ++;
        }
        
        index = index - x;
    }
    
    //Apply the powerup
    for (BBQComboAnimation *combo in combos) {
        if (combo.numberOfCookiesInCombo >= 3) {
            BBQPowerup *powerup = [[BBQPowerup alloc] initWithCookie:combo.cookieB type:combo.numberOfCookiesInCombo direction:swipeDirection];
            [powerup performPowerupWithLevel:self.level];
            combo.powerup = powerup;
        }
    }
}

- (void)scoreTheCombos:(NSArray *)combos {
    NSInteger scoreForThisRound = 0;
    for (BBQComboAnimation *combo in combos) {
        if (combo.score > 0) {
            scoreForThisRound = scoreForThisRound + combo.score;
        }
    }
    self.currentScore = self.currentScore + scoreForThisRound;
}















@end
