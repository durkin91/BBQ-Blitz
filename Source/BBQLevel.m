//
//  BBQLevel.m
//  BbqBlitz
//
//  Created by Nikki Durkin on 1/14/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "BBQLevel.h"
#import "BBQGameLogic.h"
#import "BBQCookieOrder.h"
#import "BBQTileObstacle.h"
#import "BBQStraightMovement.h"
#import "BBQDiagonalMovement.h"
#import "BBQPauseMovement.h"

@interface BBQLevel ()

@property (strong, nonatomic) NSSet *possibleChains;

@end

@implementation BBQLevel {
    BBQCookie *_cookies[NumColumns][NumRows];
    BBQTile *_tiles[NumColumns][NumRows];
    NSArray *_beginningCookieData;
}

- (BBQCookie *)cookieAtColumn:(NSInteger)column row:(NSInteger)row {
    NSAssert1(column >= 0 && column < NumColumns, @"Invalid column: %ld", (long)column);
    NSAssert1(row >= 0 && row < NumRows, @"Invalid row: %ld", (long)row);
    
    return _cookies[column][row];
}

- (void)replaceCookieAtColumn:(int)column row:(int)row withCookie:(BBQCookie *)cookie {
    NSAssert1(column >= 0 && column < NumColumns, @"Invalid column: %ld", (long)column);
    NSAssert1(row >= 0 && row < NumRows, @"Invalid row: %ld", (long)row);

    _cookies[column][row] = cookie;
}


- (NSSet *)shuffle {
    NSSet *set = [self createCookiesInBlankTiles];
    self.possibleChains = [self detectPossibleChains];
    while ([self.possibleChains count] == 0) {
        set = [self createCookiesInBlankTiles];
        self.possibleChains = [self detectPossibleChains];
    }
    
    return set;
}

- (NSSet *)detectPossibleChains {
    NSMutableSet *possibleChains = [NSMutableSet set];
    
    for (NSInteger column = 0; column < NumColumns; column ++) {
        for (NSInteger row = 0; row < NumRows; row ++) {
            BBQCookie *middleCookie = _cookies[column][row];
            if (middleCookie) {
                NSArray *matchingCookies = [self nearestMatchingCookieInAllDirections:middleCookie];
                for (NSInteger i = 0; i < [matchingCookies count]; i++ ) {
                    BBQCookie *firstCookie = matchingCookies[i];
                    for (NSInteger x = i + 1; i < [matchingCookies count] - 1; i++) {
                        BBQCookie *lastCookie = matchingCookies[x];
                        BBQChain *chain = [[BBQChain alloc] init];
                        chain.cookieType = middleCookie.cookieType;
                        chain.cookiesInChain = [NSMutableArray arrayWithObjects:firstCookie, middleCookie, lastCookie, nil];
                        [possibleChains addObject:chain];
                    }
                }
            }
        }
    }
    
    return possibleChains;
}

- (NSArray *)nearestMatchingCookieInAllDirections:(BBQCookie *)cookie {
    NSMutableArray *array = [NSMutableArray array];
    BBQCookie *testCookie;
    
    //UP
    for (NSInteger i = cookie.row + 1; i < NumRows; i++) {
        testCookie = _cookies[cookie.column][i];
        if ([cookie canBeChainedToCookie:testCookie isFirstCookieInChain:YES]) {
            [array addObject:testCookie];
            break;
        }
        else if (!testCookie) {
            break;
        }
    }
    
    //RIGHT
    for (NSInteger i = cookie.column + 1; i < NumColumns; i++) {
        testCookie = _cookies[i][cookie.row];
        if ([cookie canBeChainedToCookie:testCookie isFirstCookieInChain:YES]) {
            [array addObject:testCookie];
            break;
        }
        else if (!testCookie) {
            break;
        }
    }
    
    //DOWN
    for (NSInteger i = cookie.row - 1; i >= 0; i --) {
        testCookie = _cookies[cookie.column][i];
        if ([cookie canBeChainedToCookie:testCookie isFirstCookieInChain:YES]) {
            [array addObject:testCookie];
            break;
        }
        else if (!testCookie) {
            break;
        }
    }
    
    
    //LEFT
    for (NSInteger i = cookie.column - 1; i >= 0; i++ ) {
        testCookie = _cookies[i][cookie.row];
        if ([cookie canBeChainedToCookie:testCookie isFirstCookieInChain:YES]) {
            [array addObject:testCookie];
            break;
        }
        else if (!testCookie) {
            break;
        }
    }
    
    return array;
}

- (NSArray *)allValidCookiesThatCanBeChainedToCookie:(BBQCookie *)cookie direction:(NSString *)direction existingChain:(BBQChain *)existingChain {
    NSMutableArray *array = [NSMutableArray array];
    
    //If it can only be joined with one cookie (e.g. a multicookie) then return an empty array
    if ([existingChain isATwoCookieChain] || existingChain.isClosedChain) {
        return array;
    }
    
    if ([direction isEqualToString:UP]) {
        //look above cookie
        for (NSInteger i = cookie.row + 1; i < NumRows; i++) {
            BBQCookie *potentialCookie = _cookies[cookie.column][i];
            BOOL isFinished = [self checkIfCookieIsValid:potentialCookie rootCookie:cookie existingChain:existingChain array:array];
            if (isFinished) break;
        }
    }
    
    else if ([direction isEqualToString:DOWN]) {
        //look below cookie
        for (NSInteger i = cookie.row - 1; i >= 0; i--) {
            BBQCookie *potentialCookie = _cookies[cookie.column][i];
            BOOL isFinished = [self checkIfCookieIsValid:potentialCookie rootCookie:cookie existingChain:existingChain array:array];
            if (isFinished) break;
        }

    }
    
    else if ([direction isEqualToString:LEFT]) {
        //look to left of cookie
        for (NSInteger i = cookie.column - 1; i >= 0; i--) {
            BBQCookie *potentialCookie = _cookies[i][cookie.row];
            BOOL isFinished = [self checkIfCookieIsValid:potentialCookie rootCookie:cookie existingChain:existingChain array:array];
            if (isFinished) break;
        }

    }
    
    else if ([direction isEqualToString:RIGHT]) {
        //look to right of cookie
        for (NSInteger i = cookie.column + 1; i < NumColumns; i++) {
            BBQCookie *potentialCookie = _cookies[i][cookie.row];
            BOOL isFinished = [self checkIfCookieIsValid:potentialCookie rootCookie:cookie existingChain:existingChain array:array];
            if (isFinished) break;
        }

    }
    
    return array;

}

//Returns whether you need to break the for loop and stop looking for cookies
- (BOOL)checkIfCookieIsValid:(BBQCookie *)potentialCookie rootCookie:(BBQCookie *)rootCookie existingChain:(BBQChain *)existingChain array:(NSMutableArray *)array {
    
    if (!potentialCookie) {
        return YES;
    }
    
    else if ([potentialCookie isEqual:[existingChain.cookiesInChain firstObject]] && [existingChain.cookiesInChain count] >= 4 && [rootCookie canBeChainedToCookie:potentialCookie isFirstCookieInChain:NO]) {
        [array addObject:potentialCookie];
        return YES;
    }
    
    else if (potentialCookie && [existingChain.cookiesInChain containsObject:potentialCookie]) {
        return YES;
    }
    
    else if ([[existingChain.cookiesInChain firstObject] isEqual:rootCookie] && [existingChain.cookiesInChain count] == 1 && [rootCookie canBeChainedToCookie:potentialCookie isFirstCookieInChain:YES]) {
        [array addObject:potentialCookie];
        
        if ([rootCookie.activePowerup isAMultiCookie] || [potentialCookie.activePowerup isAMultiCookie]) {
            return YES;
        }
        
        else if (([rootCookie.activePowerup isATypeSixPowerup] || [rootCookie.activePowerup isACrissCross] || [rootCookie.activePowerup isABox]) && ([potentialCookie.activePowerup isATypeSixPowerup] || [potentialCookie.activePowerup isACrissCross] || [potentialCookie.activePowerup isABox])) {
            return YES;
        }
        
        else return NO;
    }
    
    else if ([rootCookie canBeChainedToCookie:potentialCookie isFirstCookieInChain:NO]) {
        [array addObject:potentialCookie];
        return NO;
    }
    
    else return NO;
}

- (NSDictionary *)rootCookieLimits:(BBQCookie *)cookie {
    NSMutableDictionary *limits = [NSMutableDictionary dictionary];
    
    //look above cookie
    [limits setObject:cookie forKey:UP];
    for (NSInteger i = cookie.row + 1; i < NumRows; i++) {
        BBQCookie *potentialCookie = _cookies[cookie.column][i];
        if (potentialCookie) {
            [limits setObject:potentialCookie forKey:UP];
        }
        else if (!potentialCookie) {
            break;
        }
    }
    
    
    
    //look below cookie
    [limits setObject:cookie forKey:DOWN];
    for (NSInteger i = cookie.row - 1; i >= 0; i--) {
        BBQCookie *potentialCookie = _cookies[cookie.column][i];
        if (potentialCookie) {
            [limits setObject:potentialCookie forKey:DOWN];
        }
        else if (!potentialCookie) {
            break;
        }
    }
    
    //look to left of cookie
    [limits setObject:cookie forKey:LEFT];
    for (NSInteger i = cookie.column - 1; i >= 0; i--) {
        BBQCookie *potentialCookie = _cookies[i][cookie.row];
        if (potentialCookie) {
            [limits setObject:potentialCookie forKey:LEFT];
        }
        else if (!potentialCookie) {
            break;
        }
    }
    
    //look to right of cookie
    [limits setObject:cookie forKey:RIGHT];
    for (NSInteger i = cookie.column + 1; i < NumColumns; i++) {
        BBQCookie *potentialCookie = _cookies[i][cookie.row];
        if (potentialCookie) {
            [limits setObject:potentialCookie forKey:RIGHT];
        }
        else if (!potentialCookie) {
            break;
        }
    }
    
    return limits;
}

- (BOOL)cookieFormsACrissCross:(BBQCookie *)cookie chain:(BBQChain *)chain {
    //Find the previous cookie in the chain
    NSInteger indexOfCookie = [chain.cookiesInChain indexOfObject:cookie];
    BBQCookie *previousCookie;
    if (indexOfCookie > 0) {
        previousCookie = chain.cookiesInChain[indexOfCookie - 1];
    }
    
    //If the cookies are vertical, check on the left for a cookie
    if (cookie.column == previousCookie.column) {
        
        //Find out the top and bottom cookie
        BBQCookie *bottomCookie;
        BBQCookie *topCookie;
        if (cookie.row > previousCookie.row) {
            bottomCookie = previousCookie;
            topCookie = cookie;
        }
        else {
            bottomCookie = cookie;
            topCookie = previousCookie;
        }
        
        for (NSInteger column = bottomCookie.column - 1; column >= 0; column --) {
            for (NSInteger row = bottomCookie.row + 1; row < topCookie.row; row ++) {
                BBQCookie *testCookie = _cookies[column][row];
                if ([chain.cookiesInChain containsObject:testCookie]) {
                    NSInteger testCookieIndex = [chain.cookiesInChain indexOfObject:testCookie];
                    
                    //Check along that row for a matching cookie in the chain
                    for (NSInteger i = bottomCookie.column + 1; i < NumColumns; i++) {
                        BBQCookie *testCookieTwo = _cookies[i][row];
                        if ([chain.cookiesInChain containsObject:testCookieTwo]) {
                            NSInteger testCookieTwoIndex = [chain.cookiesInChain indexOfObject:testCookieTwo];
                            NSInteger difference = ABS(testCookieIndex - testCookieTwoIndex);
                            
                            if (difference == 1) {
                                return YES;
                            }
                        }
                    }
                }
            }
        }
    }
    
    //If the cookies are vertical, check on the left for a cookie
    else if (cookie.row == previousCookie.row) {
        
        //Find out the left and right cookie (named bottom and top)
        BBQCookie *bottomCookie;
        BBQCookie *topCookie;
        if (cookie.column > previousCookie.column) {
            bottomCookie = previousCookie;
            topCookie = cookie;
        }
        else {
            bottomCookie = cookie;
            topCookie = previousCookie;
        }
        
        for (NSInteger row = bottomCookie.row - 1; row >= 0; row --) {
            for (NSInteger column = bottomCookie.column + 1; column < topCookie.column; column ++) {
                BBQCookie *testCookie = _cookies[column][row];
                if ([chain.cookiesInChain containsObject:testCookie]) {
                    NSInteger testCookieIndex = [chain.cookiesInChain indexOfObject:testCookie];
                    
                    //Check along that row for a matching cookie in the chain
                    for (NSInteger i = bottomCookie.row + 1; i < NumRows; i++) {
                        BBQCookie *testCookieTwo = _cookies[column][i];
                        if ([chain.cookiesInChain containsObject:testCookieTwo]) {
                            NSInteger testCookieTwoIndex = [chain.cookiesInChain indexOfObject:testCookieTwo];
                            NSInteger difference = ABS(testCookieIndex - testCookieTwoIndex);
                            
                            if (difference == 1) {
                                return YES;
                            }
                        }
                    }
                }
            }
        }
    }
    
    return NO;
}

- (NSSet *)createCookiesInBlankTiles {
    NSMutableSet *set = [NSMutableSet set];
    
    if (_beginningCookieData) {
        [_beginningCookieData enumerateObjectsUsingBlock:^(NSArray *array, NSUInteger row, BOOL *stop) {
            
            //Loop through the columns in the current row
            [array enumerateObjectsUsingBlock:^(NSNumber *value, NSUInteger column, BOOL *stop) {
                
                //Note that in cocos (0,0) is at the bottom of the screen so we need to read this file upside down
                NSInteger tileRow = NumRows - row - 1;
                
                //create a tile object depending on the type of tile
                BBQTile *tile = _tiles[column][tileRow];
                if (tile && tile.requiresACookie) {
                    NSInteger number = [value integerValue];
                    if (number == 1) {
                        [self createIndividualRandomCookieForColumn:column row:tileRow set:set];
                    }
                    else if (number >= 11 && number <= 10 + NumStartingCookies) {
                        NSInteger cookieType = number - 10;
                        BBQCookie *cookie = [self createCookieAtColumn:column row:tileRow withType:cookieType];
                        [set addObject:cookie];
                    }
                }
                
            }];
        }];
        
        _beginningCookieData = nil;
        
    }
    
    else {
        //loop through rows and columns
        for (NSInteger row = 0; row < NumRows; row++) {
            for (NSInteger column = 0; column < NumColumns; column++) {
                BBQTile *tile = _tiles[column][row];
                if (_cookies[column][row] == nil && tile.requiresACookie == YES) {
                    [self createIndividualRandomCookieForColumn:column row:row set:set];
                }
                
            }
        }
    }
    
    return set;
}

- (void)createIndividualRandomCookieForColumn:(NSInteger)column row:(NSInteger)row set:(NSMutableSet *)set {
    NSUInteger cookieType;
    do {
        cookieType = arc4random_uniform(NumStartingCookies) + 1;
    }
    
    while ((column >= 2 &&
            _cookies[column - 1][row].cookieType == cookieType &&
            _cookies[column - 2][row].cookieType == cookieType)
           ||
           (row >= 2 &&
            _cookies[column][row - 1].cookieType == cookieType &&
            _cookies[column][row - 2].cookieType == cookieType));
    
    BBQCookie *cookie = [self createCookieAtColumn:column row:row withType:cookieType];
    
    [set addObject:cookie];
}



- (BBQCookie *)createCookieAtColumn:(NSInteger)column row:(NSInteger)row withType:(NSUInteger)cookieType {
    BBQCookie *cookie = [[BBQCookie alloc] init];
    cookie.cookieType = cookieType;
    cookie.column = column;
    cookie.row = row;
    _cookies[column][row] = cookie;
    return cookie;
}


//- (NSArray *)fillHoles {
//    NSMutableArray *columns = [NSMutableArray array];
//    
//    [self sectionsForCookieMovements];
//    
//    for (NSArray *section in [self sectionsForCookieMovements]) {
//        NSMutableArray *array;
//        for (NSInteger i = [section count] - 1; i >= 0; i--) {
//            BBQTile *tile = section[i];
//            if (tile.requiresACookie && _cookies[tile.column][tile.row] == nil) {
//                for (NSInteger lookup = i - 1; lookup >= 0 ; lookup --) {
//                    BBQTile *tileAbove = section[lookup];
//                    BBQCookie *cookie = _cookies[tileAbove.column][tileAbove.row];
//                    
//                    if (cookie != nil) {
//                        _cookies[tileAbove.column][tileAbove.row] = nil;
//                        _cookies[tile.column][tile.row] = cookie;
//                        cookie.row = tile.row;
//                        
//                        if (!array) {
//                            array = [NSMutableArray array];
//                            [columns addObject:array];
//                        }
//                        [array addObject:cookie];
//                        
//                        break;
//                    }
//                }
//
//            }
//        }
//    }
//    
//    return columns;
//}

- (NSArray *)fillHoles {
    NSMutableArray *cookiesToMove = [NSMutableArray array];
    
    //Push all cookies down
    for (NSInteger column = 0; column < NumColumns; column++) {
        for (NSInteger row = 0; row < NumRows; row++) {
            if (_tiles[column][row].requiresACookie && _cookies[column][row] == nil) {
                for (NSInteger lookup = row + 1; lookup < NumRows; lookup++) {
                    BBQTile *tile = _tiles[column][lookup];
                    if (tile.isABlocker) {
                        break;
                    }
                    
                    BBQCookie *cookie = _cookies[column][lookup];
                    if (cookie != nil) {
                        _cookies[column][lookup] = nil;
                        _cookies[column][row] = cookie;
                        cookie.row = row;
                        
                        BBQStraightMovement *movement = [[BBQStraightMovement alloc] initWithDestinationColumn:column row:row];
                        [cookie addMovement:movement];
                        if ([cookiesToMove containsObject:cookie] == NO) {
                            [cookiesToMove addObject:cookie];
                        }
                        break;
                    }
                }
            }
        }
    }
    
    //Add in new cookies
    NSUInteger cookieType = 0;
    for (BBQTile *startingTile in [self startingTilesForToppingUpWithNewCookies]) {
        NSInteger column = startingTile.column;
        for (NSInteger row = startingTile.row; row < NumRows; row++) {
            if (_tiles[column][row].requiresACookie && _cookies[column][row] == nil) {
                NSUInteger newCookieType;
                do {
                    newCookieType = arc4random_uniform(NumStartingCookies) + 1;
                }
                while (newCookieType == cookieType);
                cookieType = newCookieType;
                
                BBQCookie *newCookie = [self createCookieAtColumn:column row:row withType:cookieType];
                _cookies[column][row] = newCookie;
                
                BBQStraightMovement *movement = [[BBQStraightMovement alloc] initWithDestinationColumn:column row:row];
                movement.isNewCookie = YES;
                movement.numberOfTilesToPauseForNewCookie = row - startingTile.row;
                [newCookie addMovement:movement];
                
                if ([cookiesToMove containsObject:newCookie] == NO) {
                    [cookiesToMove addObject:newCookie];
                }
            }
        }
    }
    
    
    
    
//    NSUInteger cookieType = 0;
//    for (NSInteger column = 0; column < NumColumns; column++) {
//        for (NSInteger row = NumRows - 1; row >= 0; row --) {
//            BBQTile *tile = _tiles[column][row];
//            if (tile.isABlocker || _cookies[column][row] != nil) {
//                break;
//            }
//            else if (tile.requiresACookie && _cookies[column][row] == nil) {
//                NSUInteger newCookieType;
//                do {
//                    newCookieType = arc4random_uniform(NumStartingCookies) + 1;
//                }
//                while (newCookieType == cookieType);
//                cookieType = newCookieType;
//                
//                _cookies[column][row] = [self createCookieAtColumn:column row:row withType:cookieType];
//                [cookiesToMove addObject:_cookies[column][row]];
//            }
//        }
//    }
    
    
    
    return cookiesToMove;
    
}


//- (NSDictionary *)fillHoles {
//    NSDictionary *dictionary = @{ STRAIGHT_MOVEMENTS : [NSMutableArray array],
//                                  DIAGONAL_MOVEMENTS : [NSMutableArray array],
//                                  NEW_COOKIES : [NSMutableArray array],
//                                  };
//    for (NSInteger column = 0; column < NumColumns; column ++) {
//        for (NSInteger row = 0; row < NumRows - 1; row++) {
//            BBQTile *tile = _tiles[column][row];
//            if (tile.requiresACookie && _cookies[column][row] == nil) {
//                for (NSInteger lookup = row + 1; lookup < NumRows; lookup++) {
//                    BBQTile *tileAbove = _tiles[column][lookup];
//                    if (tileAbove.isABlocker) {
//                        row = tileAbove.row + 1;
//                        break;
//                    }
//                    else {
//                        BBQCookie *cookieAbove = _cookies[column][lookup];
//                        if (cookieAbove) {
//                            _cookies[column][lookup] = nil;
//                            _cookies[column][lookup - 1] = cookieAbove;
//                            cookieAbove.row = lookup - 1;
//                            [dictionary[STRAIGHT_MOVEMENTS] addObject:cookieAbove];
//                            break;
//                        }
//                    }
//                }
//            }
//        }
//    }
//    
//    for (NSInteger column = 0; column < NumColumns; column++) {
//        for (NSInteger row = NumRows - 1; row >= 0; row --) {
//            BBQTile *tile = _tiles[column][row];
//            if (tile.isABlocker == NO) {
//                BBQTile *tileToFill = [self tileToFillWithNewCookieFromTopTile:tile];
//                if (tileToFill) {
//                    BBQCookie *cookie = _cookies[tileToFill.column][tileToFill.row];
//                    if (cookie == nil) {
//                        NSUInteger newCookieType = newCookieType = arc4random_uniform(NumStartingCookies) + 1;
//                        _cookies[tileToFill.column][tileToFill.row] = [self createCookieAtColumn:tileToFill.column row:tileToFill.row withType:newCookieType];
//                        [dictionary[NEW_COOKIES] addObject:_cookies[tileToFill.column][tileToFill.row]];
//                    }
//                }
//                else {
//                    break;
//                }
//            }
//        }
//    }
//    return dictionary;
//}
//
//- (BBQTile *)tileToFillWithNewCookieFromTopTile:(BBQTile *)topTile {
//    if (topTile.requiresACookie) {
//        return topTile;
//    }
//    else {
//        for (NSInteger lookDown = topTile.row - 1; lookDown >= 0; lookDown --) {
//            BBQTile *tileBelow = _tiles[topTile.column][lookDown];
//            if (tileBelow.requiresACookie) {
//                return tileBelow;
//            }
//            else if (tileBelow.isABlocker) {
//                return nil;
//            }
//        }
//        return nil;
//    }
//}

- (NSArray *)topUpCookiesWithOptionalUpgradedMultiCookie:(BBQCookie *)multiCookie poweruppedCookieChainedToMulticookie:(BBQCookie *)poweruppedCookie {
    
    NSMutableArray *potentialCookiesToUpgrade;
    
    NSMutableArray *columns = [NSMutableArray array];
    NSUInteger cookieType = 0;
    
    for (BBQTile *tile in [self startingTilesForToppingUpWithNewCookies]) {
        NSInteger column = tile.column;
        NSMutableArray *array;
        for (NSInteger row = NumRows - 1; row >= tile.row && _cookies[column][row] == nil; row--) {
            if (_tiles[column][row] != nil) {
                NSUInteger newCookieType;
                do {
                    newCookieType = arc4random_uniform(NumStartingCookies) + 1;
                }
                while (newCookieType == cookieType);
                cookieType = newCookieType;
                
                BBQCookie *cookie = [self createCookieAtColumn:column row:row withType:cookieType];
                
                //Add a powerup if required
                if (multiCookie && cookieType == poweruppedCookie.cookieType) {
                    if (!potentialCookiesToUpgrade) {
                        potentialCookiesToUpgrade = [NSMutableArray array];
                    }
                    [potentialCookiesToUpgrade addObject:cookie];
                    
                }
                
                if (!array) {
                    array = [NSMutableArray array];
                    [columns addObject:array];
                }
                [array addObject:cookie];
                
            }
        }
    }
    
    while ([multiCookie.activePowerup.upgradedMuliticookiePowerupCookiesThatNeedreplacing count] > 0 && [potentialCookiesToUpgrade count] > 0) {
        NSInteger randomIndex = arc4random_uniform([potentialCookiesToUpgrade count]);
        BBQCookie *cookie = potentialCookiesToUpgrade[randomIndex];
        
        NSInteger random = arc4random_uniform(2) + 1;
        NSString *direction;
        if (random == 1) {
            direction = RIGHT;
        }
        else {
            direction = UP;
        }
        
        cookie.activePowerup = [[BBQPowerup alloc] initWithType:poweruppedCookie.activePowerup.type direction:direction];
        
        [multiCookie.activePowerup.upgradedMuliticookiePowerupCookiesThatNeedreplacing removeLastObject];
        [potentialCookiesToUpgrade removeObject:cookie];
        
        [multiCookie.activePowerup addNewlyCreatedPowerupToArraysOfPowerupsToDetonate:cookie];
    }
    
    return columns;
}

- (NSArray *)sectionsForCookieMovements {
    NSMutableArray *sections = [NSMutableArray array];
    for (NSInteger column = 0; column < NumColumns; column ++) {
        BOOL startNewSection = YES;
        NSMutableArray *section;
        for (NSInteger row = NumRows - 1; row >= 0; row --) {
            BBQTile *tile = _tiles[column][row];
            
            if (startNewSection && tile.isABlocker == NO) {
                section = [NSMutableArray array];
                [sections addObject:section];
                startNewSection = NO;
            }
            
            if (tile.isABlocker == NO) {
                [section addObject:tile];
            }
            else {
                startNewSection = YES;
            }
        }
    }
    return sections;
}

//- (NSArray *)sectionsForToppingUpWithNewCookies {
//    NSMutableArray *sections = [NSMutableArray array];
//    for (NSInteger column = 0; column < NumColumns; column ++) {
//        NSMutableArray *section;
//        for (NSInteger row = NumRows - 1; row >= 0; row --) {
//            BBQTile *tile = _tiles[column][row];
//            
//            if (tile.isABlocker == NO) {
//                [section addObject:tile];
//            }
//            else {
//                break;
//            }
//        }
//    }
//    return sections;
//}

- (NSArray *)startingTilesForToppingUpWithNewCookies {
    NSMutableArray *array = [NSMutableArray array];
    for (NSInteger column = 0; column < NumColumns; column++) {
        BBQTile *startingTile;
        for (NSInteger row = NumRows - 1; row >= 0; row --) {
            BBQTile *tile = _tiles[column][row];
            if (tile.requiresACookie && _cookies[tile.column][tile.row] == nil) {
                startingTile = tile;
            }
            else if (tile.isABlocker || _cookies[tile.column][tile.row]) {
                break;
            }
        }
        if (startingTile) {
            [array addObject:startingTile];
        }
    }
    return array;
}


#pragma mark - Level loading methods

//Load the level JSON files
- (NSDictionary *)loadJSON:(NSString *)filename {
    NSString *path = [[NSBundle mainBundle] pathForResource:filename ofType:@"json"];
    if (path == nil) {
        NSLog(@"Could not find level file: %@", filename);
        return nil;
    }
    
    NSError *error;
    NSData *data = [NSData dataWithContentsOfFile:path options:0 error:&error];
    if (data == nil) {
        NSLog(@"Could not load level file: %@, error: %@", filename, error);
        return nil;
    }
    
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    if (dictionary == nil || ![dictionary isKindOfClass:[NSDictionary class]]) {
        NSLog(@"Level file '%@' is not valid JSON: %@", filename, error);
        return nil;
    }
    
    return dictionary;
}

- (instancetype)initWithFile:(NSString *)filename {
    self = [super init];
    if (self != nil) {
        NSDictionary *dictionary = [self loadJSON:filename];
        
        //Bottom tiles
        [dictionary[@"bottomTiles"] enumerateObjectsUsingBlock:^(NSArray *array, NSUInteger row, BOOL *stop) {
            
            //Loop through the columns in the current row
            [array enumerateObjectsUsingBlock:^(NSNumber *value, NSUInteger column, BOOL *stop) {
                
                //Note that in cocos (0,0) is at the bottom of the screen so we need to read this file upside down
                NSInteger tileRow = NumRows - row - 1;
                
                //create a tile object depending on the type of tile
                if ([value integerValue] == 0) {
                    _tiles[column][tileRow] = [[BBQTile alloc] initWithTileType:0 column:column row:tileRow];
                }
                
                else if ([value integerValue] >= 1) {
                    _tiles[column][tileRow] = [[BBQTile alloc] initWithTileType:1 column:column row:tileRow];
                    BBQTile *tile = _tiles[column][tileRow];
                    
                    //Set up obstacles
                    if ([value integerValue] == 2) {
                        [tile addTileObstacles:[NSArray arrayWithObjects:GOLD_PLATED_TILE, nil]];
                    }
                    
                    else if ([value integerValue] == 3) {
                        [tile addTileObstacles:[NSArray arrayWithObjects:GOLD_PLATED_TILE, SILVER_PLATED_TILE, nil]];
                    }
                }
                
            }];
        }];
        
        //Top obstacles
        [dictionary[@"topObstacles"] enumerateObjectsUsingBlock:^(NSArray *array, NSUInteger row, BOOL *stop) {
            
            //Loop through the columns in the current row
            [array enumerateObjectsUsingBlock:^(NSNumber *value, NSUInteger column, BOOL *stop) {
                
                //Note that in cocos (0,0) is at the bottom of the screen so we need to read this file upside down
                NSInteger tileRow = NumRows - row - 1;
                
                //create a tile object depending on the type of tile
                BBQTile *tile = _tiles[column][tileRow];
                if (tile.tileType != 0) {
                    
                    if ([value integerValue] == 1) {
                        [tile addTileObstacles:[NSArray arrayWithObjects:WAD_OF_CASH_ONE, nil]];
                    }
                    else if ([value integerValue] == 2) {
                        [tile addTileObstacles:[NSArray arrayWithObjects:WAD_OF_CASH_ONE, WAD_OF_CASH_TWO, nil]];
                    }
                    else if ([value integerValue] == 3) {
                        [tile addTileObstacles:[NSArray arrayWithObjects:WAD_OF_CASH_ONE, WAD_OF_CASH_TWO, WAD_OF_CASH_THREE, nil]];
                    }
                }
                
            }];
        }];

        _beginningCookieData = dictionary[@"cookies"];
        self.targetScore = [dictionary[@"targetScore"] unsignedIntegerValue];
        self.maximumMoves = [dictionary[@"moves"] unsignedIntegerValue];
        
        //Setup Orders
        NSArray *orderData = dictionary[@"orderData"];
        self.cookieOrders = [NSMutableArray array];
        NSMutableArray *array = [NSMutableArray array];
        
        for (NSDictionary *data in orderData) {
            NSInteger quantity = [data[@"quantity"] unsignedIntegerValue];
            
            //Order is an obstacle
            if ([data[@"type"] isEqualToString:@"obstacle"]) {
                NSString *obstacleName = data[@"id"];
                BBQCookieOrder *obstacleOrder = [[BBQCookieOrder alloc] initWithObstacle:obstacleName startingAmount:quantity];
                [array addObject:obstacleOrder];
            }
            
            //Order is a cookie
            else if ([data[@"type"] isEqualToString:@"cookie"]) {
                NSInteger type = [data[@"id"] unsignedIntegerValue];
                BBQCookieOrder *cookieOrder = [[BBQCookieOrder alloc] initWithCookieType:type startingAmount:quantity];
                [array addObject:cookieOrder];
            }
            
            else {
                NSLog(@"Order is neither an obstacle or a cookie");
            }
            
        }
        
        self.cookieOrders = array;
        

    }
    
    return self;
}

- (BBQTile *)tileAtColumn:(NSInteger)column row:(NSInteger)row {
    NSAssert1(column >= 0 && column < NumColumns, @"Invalid column: %ld", (long)column);
    NSAssert1(row >= 0 && row < NumRows, @"Invalid row: %ld", (long)row);
    
    return _tiles[column][row];
}






@end
