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
    NSSet *cookies = [self.level shuffle];
    return cookies;
}


#pragma mark - Swipe Logic

- (NSDictionary *)swipe:(NSString *)swipeDirection column:(NSInteger)columnToSwipe row:(NSInteger)rowToSwipe {
    
    NSInteger x = [self returnColumnOrRowWithSwipeDirection:swipeDirection column:columnToSwipe row:rowToSwipe];
    NSArray *movements = [self movementsForSwipe:swipeDirection columnOrRow:x];
    
    
    NSDictionary *animationsToPerform = @{
                                          COMBOS : [@[] mutableCopy],
                                          MOVEMENTS : [@[] mutableCopy],
                                          MOVEMENTS_BATCH_2 : [@[] mutableCopy],
                                          DROP_MOVEMENTS : [@[] mutableCopy],
                                          POWERUPS : [@[] mutableCopy],
                                          NEW_STEEL_BLOCKER_TILES : [@[] mutableCopy],
                                          };
    
    //[self startSwipeInDirection:swipeDirection animations:animationsToPerform column:columnToSwipe row:rowToSwipe];
//    self.movesLeft = self.movesLeft - 1;
//    [self findComboChains:animationsToPerform[COMBOS] swipeDirection:swipeDirection];
//    [self scoreTheCombos:animationsToPerform[COMBOS]];
//    
//    //Move over the rest of the cookies
//    NSMutableArray *movementsTwo = animationsToPerform[MOVEMENTS_BATCH_2];
//    [movementsTwo addObjectsFromArray:[self batchTwoMovementsInDirection:swipeDirection column:columnToSwipe row:rowToSwipe]];
//    
//    //take care of new new steel blocker tiles
//    if (self.level.steelBlockerFactoryTiles) {
//        NSArray *blankTiles = [self findBlankTiles];
//        
//        if (self.level.steelBlockerFactoryTiles) {
//            NSMutableArray *newSteelBlockerTiles = animationsToPerform[NEW_STEEL_BLOCKER_TILES];
//            [newSteelBlockerTiles addObjectsFromArray:[self createNewSteelBlockerTilesWithBlankTiles:blankTiles]];
//        }
//    }
//    
//    //turn steel blocker tiles from combos into regular tiles
//    NSArray *combos = animationsToPerform[COMBOS];
//    [self turnSteelBlockerIntoRegularTilesForCombos:combos];
    
    return animationsToPerform;
}


//- (NSArray *)fillHoles {
//    NSMutableArray *columns = [NSMutableArray array];
//    
//    for (NSInteger column = 0; column < NumColumns; column ++) {
//        NSMutableArray *array;
//        
//        for (NSInteger row = 0; row < NumRows; row++) {
//            
//            BBQTile *tile = _tiles[column][row];
//            if (tile.tileType != 0 && _cookies[column][row] == nil) {
//                for (NSInteger lookup = row + 1; lookup < NumRows; lookup ++) {
//                    BBQCookie *cookie = _cookies[column][lookup];
//                    
//                    if (cookie != nil) {
//                        _cookies[column][lookup] = nil;
//                        _cookies[column][row] = cookie;
//                        cookie.row = row;
//                        
//                        if (!array) {
//                            array = [NSMutableArray array];
//                            [columns addObject:array];
//                        }
//                        [array addObject:cookie];
//                        
//                        break;
//                    }
//                    
//                }
//            }
//        }
//    }
//    return columns;
//}


//- (NSArray *)movementsForSwipe:(NSString *)swipeDirection columnOrRow:(NSInteger)columnOrRow {
//    
//    //Move the extra cookies in the chain to the root cookie position
//    NSSet *chains = [self.level chainsForColumnOrRow:columnOrRow swipeDirection:swipeDirection];
//    for (NSArray *chain in chains) {
//        BBQCookie *rootCookie = chain[0];
//        for (NSInteger i = 1; i < [chain count]; i++) {
//            BBQCookie *extraCookie = chain[i];
//            extraCookie.column = rootCookie.column;
//            extraCookie.row = rootCookie.row;
//            
//        }
//    }
//}

- (NSArray *)movementsForSwipe:(NSString *)swipeDirection columnOrRow:(NSInteger)columnOrRow {
    
    //Take a snapshot of the column or row as it is, before the model is changed
    NSArray *finalCookies = [self.level allCookiesInColumnOrRow:columnOrRow swipeDirection:swipeDirection];
    
    //Move everything in the model
    BOOL finished = NO;
    while (!finished) {
        NSArray *sections = [self.level breakColumnOrRowIntoSectionsForDirection:swipeDirection columnOrRow:columnOrRow];
        for (NSInteger sectionIndex = 0; sectionIndex < [sections count]; sectionIndex ++) {
            NSMutableArray *section = sections[sectionIndex];
            for (NSInteger index = 0; index < [section count] - 1; index++) {
                BBQCookie *cookie = section[index];
                BBQCookie *nextCookie = section[index + 1];
                
                if (index == [section count] - 2) {
                    finished = YES;
                }
                else {
                    finished = NO;
                }
                
                if (cookie.cookieType == nextCookie.cookieType) {
                    
                    for (NSInteger i = index + 1; i < [section count]; i++) {
                        BBQCookie *nextCookie = section[i];
                        [self moveCookieOneTileOver:nextCookie swipeDirection:swipeDirection];
                    }
                    
                    [section removeObject:cookie];
                    break;
                }
            }
        }
    }
    
    return finalCookies;
}

- (void)moveCookieOneTileOver:(BBQCookie *)nextCookie swipeDirection:(NSString *)swipeDirection {
    [self.level replaceCookieAtColumn:nextCookie.column row:nextCookie.row withCookie:nil];
    
    if ([swipeDirection isEqualToString:UP]) {
        [self.level replaceCookieAtColumn:nextCookie.column row:nextCookie.row + 1 withCookie:nextCookie];
        nextCookie.row = nextCookie.row + 1;
    }
    
    else if ([swipeDirection isEqualToString:DOWN]) {
        [self.level replaceCookieAtColumn:nextCookie.column row:nextCookie.row - 1 withCookie:nextCookie];
        nextCookie.row = nextCookie.row - 1;
    }
    
    else if ([swipeDirection isEqualToString:LEFT]) {
        [self.level replaceCookieAtColumn:nextCookie.column - 1 row:nextCookie.row withCookie:nextCookie];
        nextCookie.column = nextCookie.column - 1;
    }
    
    else if ([swipeDirection isEqualToString:RIGHT]) {
        [self.level replaceCookieAtColumn:nextCookie.column + 1 row:nextCookie.row withCookie:nextCookie];
        nextCookie.column = nextCookie.column + 1;
    }
    
}

- (NSArray *)createCookieMovementsForDirection:(NSString *)swipeDirection columnOrRow:(NSInteger)columnOrRow {
    NSMutableArray *finalCookies = [NSMutableArray array];
    
    if ([swipeDirection isEqualToString:UP]) {
        NSInteger column = columnOrRow;
        for (NSInteger row = NumRows - 1; row >= 0; row--) {
            [self createCookieMovements:finalCookies column:column row:row];
        }
    }
    
    else if ([swipeDirection isEqualToString:DOWN]) {
        NSInteger column = columnOrRow;
        for (NSInteger row = 0; row < NumRows; row++) {
            [self createCookieMovements:finalCookies column:column row:row];
        }
    }
    
    else if ([swipeDirection isEqualToString:LEFT]) {
        NSInteger row = columnOrRow;
        for (NSInteger column = 0; column < NumColumns; column ++) {
            [self createCookieMovements:finalCookies column:column row:row];
        }
    }
    
    else if ([swipeDirection isEqualToString:RIGHT]) {
        NSInteger row = columnOrRow;
        for (NSInteger column = NumColumns - 1; column >= 0; column--) {
            [self createCookieMovements:finalCookies column:column row:row];
        }
    }
    
    return [finalCookies copy];
}


- (void)startSwipeInDirection:(NSString *)swipeDirection animations:(NSDictionary *)animationsToPerform column:(NSInteger)columnToSwipe row:(NSInteger)rowToSwipe {
    
    //UP swipe
    if ([swipeDirection isEqualToString:UP]) {
        NSInteger column = columnToSwipe;
        for (int row = NumRows - 1; row > 0; row--) {
            BBQTile *tileB = [self.level tileAtColumn:column  row:row];
            if (tileB.requiresACookie) {
                //Find cookie B and if it is nil, move what would be cookie A to B's tile
                BBQCookie *cookieB = [self.level cookieAtColumn:column row:row];
                if (cookieB == nil) {
                    [self moveASingleCookieInDirection:UP toColumn:column row:row + 1];
                    cookieB = [self.level cookieAtColumn:column row:row];
                }
                
                BBQCookie *cookieA = [self findCookieABelowColumn:column row:row swipeDirection:swipeDirection];
                
                if (cookieA != nil) {
                    [self tryCombineCookieA:cookieA withCookieB:cookieB animations:animationsToPerform direction:swipeDirection];
                    
                    //if there was a combo or cookie A is the last cookie above a nil tile, move the cookie below tile A into tile A
                    [self moveASingleCookieInDirection:UP toColumn:column row:row];
                }
            }
        }
        
        //Now create the cookie movements for the sprites to match where the cookies are located in the model
        for (int row = NumRows - 1; row > 0; row--) {
            [self createCookieMovements:animationsToPerform[MOVEMENTS] column:column row:row];
        }
    }
    
    //DOWN swipe
    if ([swipeDirection isEqualToString:DOWN]) {
        NSInteger column = columnToSwipe;
        for (int row = 0; row < NumRows - 1; row++) {
            BBQTile *tileB = [self.level tileAtColumn:column  row:row];
            if (tileB.requiresACookie) {
                //Find cookie B and if it is nil move what would be cookie A to B's tile
                BBQCookie *cookieB = [self.level cookieAtColumn:column row:row];
                if (cookieB == nil) {
                    [self moveASingleCookieInDirection:DOWN toColumn:column row:row - 1];
                    cookieB = [self.level cookieAtColumn:column row:row];
                }
                
                BBQCookie *cookieA = [self findCookieABelowColumn:column row:row swipeDirection:swipeDirection];
                
                if (cookieA != nil) {
                    [self tryCombineCookieA:cookieA withCookieB:cookieB animations:animationsToPerform direction:swipeDirection];
                    
                    //if there was a combo or cookie A is the last cookie above a nil tile, move the cookie below tile A into tile A
                    [self moveASingleCookieInDirection:DOWN toColumn:column row:row];
                }
            }
        }
        
        //Now create the cookie movements for the sprites to match where the cookies are located in the model
        for (int row = 0; row < NumRows - 1; row++) {
            [self createCookieMovements:animationsToPerform[MOVEMENTS] column:column row:row];
        }
    }
    
    //LEFT swipe
    if ([swipeDirection isEqualToString:LEFT]) {
        NSInteger row = rowToSwipe;
        for (int column = 0; column < NumColumns - 1; column++) {
            BBQTile *tileB = [self.level tileAtColumn:column  row:row];
            if (tileB.requiresACookie) {
                //Find cookie B and if it is nil move what would be cookie A to B's tile
                BBQCookie *cookieB = [self.level cookieAtColumn:column row:row];
                if (cookieB == nil) {
                    [self moveASingleCookieInDirection:LEFT toColumn:column - 1 row:row];
                    cookieB = [self.level cookieAtColumn:column row:row];
                }
                
                BBQCookie *cookieA = [self findCookieABelowColumn:column row:row swipeDirection:swipeDirection];
                
                if (cookieA != nil) {
                    [self tryCombineCookieA:cookieA withCookieB:cookieB animations:animationsToPerform direction:swipeDirection];
                    
                    //if there was a combo or cookie A is the last cookie above a nil tile, move the cookie below tile A into tile A
                    [self moveASingleCookieInDirection:LEFT toColumn:column row:row];
                }
            }
        }
        
        //Now create the cookie movements for the sprites to match where the cookies are located in the model
        for (int column = 0; column < NumColumns - 1; column ++) {
            [self createCookieMovements:animationsToPerform[MOVEMENTS] column:column row:row];
        }
        
    }
    
    //RIGHT swipe
    if ([swipeDirection isEqualToString:RIGHT]) {
        NSInteger row = rowToSwipe;
        for (int column = NumColumns - 1; column > 0; column--) {
            BBQTile *tileB = [self.level tileAtColumn:column  row:row];
            if (tileB.requiresACookie) {
                //Find cookie B and if it is nil (as is case if its a shark tile underneath a blank tile), move what would be cookie A to B's tile
                BBQCookie *cookieB = [self.level cookieAtColumn:column row:row];
                if (cookieB == nil) {
                    [self moveASingleCookieInDirection:RIGHT toColumn:column + 1 row:row];
                    cookieB = [self.level cookieAtColumn:column row:row];
                }
                
                BBQCookie *cookieA = [self findCookieABelowColumn:column row:row swipeDirection:swipeDirection];
                
                if (cookieA != nil) {
                    [self tryCombineCookieA:cookieA withCookieB:cookieB animations:animationsToPerform direction:swipeDirection];
                    
                    //if there was a combo or cookie A is the last cookie above a nil tile, move the cookie below tile A into tile A
                    [self moveASingleCookieInDirection:RIGHT toColumn:column row:row];
                }
            }
        }
        
        //Now create the cookie movements for the sprites to match where the cookies are located in the model
        for (int column = NumColumns - 1; column > 0; column--) {
            [self createCookieMovements:animationsToPerform[MOVEMENTS] column:column row:row];
        }
    }
}

- (void)createCookieMovements:(NSMutableArray *)array column:(NSInteger)column row:(NSInteger)row {
    BBQCookie *cookie = [self.level cookieAtColumn:column row:row];
    if (cookie != nil) {
        BBQMoveCookie *movement = [[BBQMoveCookie alloc] initWithCookieA:cookie destinationColumn:cookie.column destinationRow:cookie.row];
        [array addObject:movement];
    }
}

- (NSMutableArray *)batchTwoMovementsInDirection:(NSString *)swipeDirection column:(NSInteger)columnToSwipe row:(NSInteger)rowToSwipe {
    NSMutableArray *batchTwoMovements = [@[] mutableCopy];
    
    //UP swipe
    if ([swipeDirection isEqualToString:UP]) {
        NSInteger column = columnToSwipe;
        for (int row = NumRows - 1; row > 0; row--) {
            BBQTile *tile = [self.level tileAtColumn:column row:row];
            if (tile.requiresACookie) {
                BBQCookie *cookie = [self.level cookieAtColumn:column row:row];
                if (cookie == nil) {
                    [self moveASingleCookieInDirection:swipeDirection toColumn:column row:row + 1];
                }
            }
            
            [self createCookieMovements:batchTwoMovements column:column row:row];
        }
    }
    
    //DOWN swipe
    if ([swipeDirection isEqualToString:DOWN]) {
        NSInteger column = columnToSwipe;
        for (int row = 0; row < NumRows - 1; row++) {
            BBQTile *tile = [self.level tileAtColumn:column row:row];
            if (tile.requiresACookie) {
                BBQCookie *cookie = [self.level cookieAtColumn:column row:row];
                if (cookie == nil) {
                    [self moveASingleCookieInDirection:swipeDirection toColumn:column row:row - 1];
                }
            }
            
            [self createCookieMovements:batchTwoMovements column:column row:row];
        }
    }
    
    //LEFT swipe
    if ([swipeDirection isEqualToString:LEFT]) {
        NSInteger row = rowToSwipe;
        for (int column = 0; column < NumColumns - 1; column++) {
            BBQTile *tile = [self.level tileAtColumn:column row:row];
            if (tile.requiresACookie) {
                BBQCookie *cookie = [self.level cookieAtColumn:column row:row];
                if (cookie == nil) {
                    [self moveASingleCookieInDirection:swipeDirection toColumn:column - 1 row:row];
                }
            }
            [self createCookieMovements:batchTwoMovements column:column row:row];
        }
    }
    
    //RIGHT swipe
    if ([swipeDirection isEqualToString:RIGHT]) {
        NSInteger row = rowToSwipe;
        for (int column = NumColumns - 1; column > 0; column--) {
            BBQTile *tile = [self.level tileAtColumn:column row:row];
            if (tile.requiresACookie) {
                BBQCookie *cookie = [self.level cookieAtColumn:column row:row];
                if (cookie == nil) {
                    [self moveASingleCookieInDirection:swipeDirection toColumn:column + 1 row:row];
                }
            }
            
            [self createCookieMovements:batchTwoMovements column:column row:row];
        }
        
    }
    
    return batchTwoMovements;

}

- (void)checkForMovementsColumn:(NSInteger)column row:(NSInteger)row swipeDirection:(NSString *)swipeDirection {
    BBQTile *tile = [self.level tileAtColumn:column row:row];
    if (tile.requiresACookie) {
        BBQCookie *cookie = [self.level cookieAtColumn:column row:row];
        if (cookie == nil) {
            [self moveASingleCookieInDirection:swipeDirection toColumn:column row:row];
        }
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
                BOOL isRootCombo = NO;
                if (i == 1) isRootCombo = YES;
                [self combineCookieA:localCookieA withcookieB:localCookieB destinationColumn:cookieB.column destinationRow:cookieB.row animations:animations isRootCombo:isRootCombo];
            }
        }
        
        //Remove the root cookie
        BBQCookie *rootCookie = [cookiesInChain objectAtIndex:0];
        [self.level replaceCookieAtColumn:rootCookie.column row:rootCookie.row withCookie:nil];
    }
    
}


- (void)combineCookieA:(BBQCookie *)cookieA withcookieB:(BBQCookie *)cookieB destinationColumn:(NSInteger)destinationColumn destinationRow:(NSInteger)destinationRow animations:(NSDictionary *)animations isRootCombo:(BOOL)isRootCombo {
    //Upgrade count and check whether the new count will turn it into an upgrade
    BBQComboAnimation *combo;
    
    combo = [[BBQComboAnimation alloc] initWithCookieA:cookieA cookieB:cookieB destinationColumn:destinationColumn destinationRow:destinationRow];
    combo.isRootCombo = isRootCombo;
    
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
    if ([direction isEqualToString:UP]) {
        
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
    if ([direction isEqualToString:DOWN]) {
        
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
    if ([direction isEqualToString:LEFT]) {
        
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
    if ([direction isEqualToString:RIGHT]) {
        
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
    
    if ([direction isEqualToString:UP]) {
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
    
    else if ([direction isEqualToString:DOWN]) {
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
    
    else if ([direction isEqualToString:LEFT]) {
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
    
    else if ([direction isEqualToString:RIGHT]) {
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
    //Put logic in here
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

#pragma mark - General Helper methods

- (NSInteger)returnColumnOrRowWithSwipeDirection:(NSString *)swipeDirection column:(NSInteger)column row:(NSInteger)row {
    NSInteger x;
    if ([swipeDirection isEqualToString:UP] || [swipeDirection isEqualToString:DOWN]) {
        x = column;
    }
    else {
        x = row;
    }
    return x;
}















@end
