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
#import "BBQMovement.h"
#import "BBQPowerup.h"
#import "BBQCombo.h"
#import "BBQCookieOrder.h"

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

- (void)startChainWithCookie:(BBQCookie *)cookie {
    self.chain = [[BBQChain alloc] init];
    [self.chain addCookie:cookie];
}

- (NSArray *)tryAddingCookieToChain:(BBQCookie *)cookie inDirection:(NSString *)direction {
    BBQCookie *lastCookieInChain = [_chain.cookiesInChain lastObject];
    NSArray *potentialCookies = [self.level allValidCookiesThatCanBeChainedToCookie:lastCookieInChain direction:direction existingChain:self.chain];
    
    //Return an array of cookies that need to be highlighted on the path to the touched cookie
    NSMutableArray *array;
    if ([potentialCookies containsObject:cookie]) {
        array = [NSMutableArray array];
        for (NSInteger i = 0; i <= [potentialCookies indexOfObject:cookie]; i++) {
            BBQCookie *cookieToActivate = potentialCookies[i];
            if ([[self.chain.cookiesInChain firstObject] isEqual:cookieToActivate] == NO) {
                [self.chain addCookie:cookieToActivate];
            }
            else {
                self.chain.isClosedChain = YES;
            }
            [array addObject:cookieToActivate];
            [self checkForPowerups:cookieToActivate];
        }
    }
    
    return array;
}

- (BOOL)isCookieABackTrack:(BBQCookie *)cookie {
    BBQCookie *lastCookieInChain = [self.chain.cookiesInChain lastObject];
    
    //Check if the player is trying to make a box powerup
    if ([self.chain.cookiesInChain count] >= 4 &&
        (cookie.column == lastCookieInChain.column || cookie.row == lastCookieInChain.row) &&
        [[self.chain.cookiesInChain firstObject] isEqual:cookie]) {
        return NO;
    }
    
    if ([self.chain containsCookie:cookie]) {
        return YES;
    }
    
    else return NO;
}

- (NSArray *)backtrackedCookiesForCookie:(BBQCookie *)cookie {
    self.chain.isClosedChain = NO;
    NSMutableArray *cookiesToRemove = [NSMutableArray array];
    for (NSInteger i = [self.chain.cookiesInChain indexOfObject:cookie] + 1; i < [self.chain.cookiesInChain count]; i++) {
        BBQCookie *cookieToRemove = self.chain.cookiesInChain[i];
        [cookiesToRemove addObject:cookieToRemove];
    }
    for (BBQCookie *cookieToRemove in cookiesToRemove) {
        [self.chain.cookiesInChain removeObject:cookieToRemove];
        if (cookieToRemove.powerup.isCurrentlyTemporary == YES) {
            cookieToRemove.powerup = nil;
        }
    }
    return cookiesToRemove;
}

- (BBQChain *)removeCookiesInChain {
    [self.chain addCookieOrders:self.level.cookieOrders];
    for (BBQCookie *cookie in self.chain.cookiesInChain) {

        if (cookie.powerup && cookie.powerup.isCurrentlyTemporary == NO) {
            cookie.powerup.isReadyToDetonate = YES;
        }
        else if (cookie.powerup && cookie.powerup.isCurrentlyTemporary == YES) {
            cookie.powerup.isCurrentlyTemporary = NO;
        }
        else if (!cookie.powerup) {
            [self.level replaceCookieAtColumn:cookie.column row:cookie.row withCookie:nil];
        }
    }
    
    return self.chain;
}

- (void)activatePowerupForCookie:(BBQCookie *)cookie {
    
    NSInteger cookieTypeToCollect = 0;
    if ([cookie.powerup isAMultiCookie]) {
        BBQCookie *cookieType = [self.chain.cookiesInChain lastObject];
        cookieTypeToCollect = cookieType.cookieType;
    }
    
    [self.level replaceCookieAtColumn:cookie.column row:cookie.row withCookie:nil];
    [cookie.powerup performPowerupWithLevel:self.level cookie:cookie cookieTypeToCollect:cookieTypeToCollect];
    [cookie.powerup removeDuplicateCookiesFromChainsCookies:self.chain.cookiesInChain];
    [cookie.powerup scorePowerup];
    [cookie.powerup addCookieOrders:self.level.cookieOrders];
}

- (void)addPowerupScoreToCurrentScore:(BBQPowerup *)powerup {
    self.currentScore = self.currentScore + powerup.totalScore;
}

- (BOOL)doesCookieNeedRemoving:(BBQCookie *)cookie {
    if (!cookie.powerup || cookie.powerup.isReadyToDetonate) {
        return YES;
    }
    else return NO;
}

- (void)calculateScoreForChain {
    _chain.scorePerCookie = 30 + (([_chain.cookiesInChain count] - 2) * 10);
    _chain.score = _chain.scorePerCookie * [_chain.cookiesInChain count];
    self.currentScore = self.currentScore + _chain.score;
}

- (BBQCookie *)lastCookieInChain {
    return [self.chain.cookiesInChain lastObject];
}

- (BBQCookie *)previousCookieToCookieInChain:(BBQCookie *)cookie {
    NSInteger i = [self.chain.cookiesInChain indexOfObject:cookie];
    BBQCookie *previousCookie;
    if (i > 0) {
        previousCookie = self.chain.cookiesInChain[i - 1];
    }
    
    else if (self.chain.isClosedChain && i == 0) {
        previousCookie = [self.chain.cookiesInChain lastObject];
    }
    return previousCookie;
}

- (NSDictionary *)rootCookieLimits:(BBQCookie *)cookie {
    return [self.level rootCookieLimits:cookie];
}

- (NSString *)directionOfPreviousCookieInChain:(BBQCookie *)cookie {
    BBQCookie *previousCookie = [self previousCookieToCookieInChain:cookie];
    NSString *direction;
    
    if (previousCookie) {
        if (previousCookie.column == cookie.column && previousCookie.row > cookie.row) {
            direction = UP;
        }
        
        else if (previousCookie.column == cookie.column && previousCookie.row < cookie.row) {
            direction = DOWN;
        }
        
        else if (previousCookie.row == cookie.row && previousCookie.column > cookie.column) {
            direction = RIGHT;
        }
        else if (previousCookie.row == cookie.row && previousCookie.column < cookie.column) {
            direction = LEFT;
        }
    }
    return direction;
}

- (BOOL)doesNotRequireInProgressLine {
    BBQCookie *firstCookie = [self.chain.cookiesInChain firstObject];
    if ([self.chain.cookiesInChain count] >= 2 && ([firstCookie.powerup isAMultiCookie] || [firstCookie.powerup isARobbersSack])) {
        return  YES;
    }
    
    else if (self.chain.isClosedChain) {
        return YES;
    }
    
    else {
        return NO;
    }
}

- (BOOL)isFirstCookieInChain:(BBQCookie *)cookie {
    if ([[self.chain.cookiesInChain firstObject] isEqual:cookie]) {
        return YES;
    }
    else return NO;
}

#pragma mark - Powerup Methods

- (void)checkForPowerups:(BBQCookie *)cookie {
    
    NSString *direction = [self directionOfPreviousCookieInChain:cookie];

    //The 6th cookie in a chain will blast out a row or column
    if ([self.chain.cookiesInChain indexOfObject:cookie] == 5 && !cookie.powerup) {
        cookie.powerup = [[BBQPowerup alloc] initWithType:6 direction:direction];
    }
    
    //The 9th cookie will turn into a pivot pad
    else if ([self.chain.cookiesInChain indexOfObject:cookie] == 8 && !cookie.powerup) {
        cookie.powerup = [[BBQPowerup alloc] initWithType:9 direction:direction];
    }
    
    //The 12th cookie will turn into a multi cookie, which will collect all like cookies on the board
    else if ([self.chain.cookiesInChain indexOfObject:cookie] == 11 && !cookie.powerup) {
        cookie.powerup = [[BBQPowerup alloc] initWithType:12 direction:direction];
    }
    
    //The 15th cookie will turn into a robbers sack that collects all jewels
    else if ([self.chain.cookiesInChain indexOfObject:cookie] == 14 && !cookie.powerup) {
        cookie.powerup = [[BBQPowerup alloc] initWithType:15 direction:direction];
    }
    
    //Create a criss cross powerup
    else if ([self.chain.cookiesInChain indexOfObject:cookie] > 3 && [self.level cookieFormsACrissCross:cookie chain:self.chain]) {
        cookie.powerup = [[BBQPowerup alloc] initWithType:20 direction:direction];
    }
    
    //Create a box powerup
    else if (self.chain.isClosedChain && [self isFirstCookieInChain:cookie]) {
        cookie.powerup = [[BBQPowerup alloc] initWithType:30 direction:direction];
    }

}


#pragma mark - Obstacle methods

//- (void)explodeSteelBlockerTiles:(BBQComboAnimation *)combo {
//    
//    NSMutableArray *adjacentTiles = [@[] mutableCopy];
//    if (!combo.cookieB.isInStaticTile) {
//        
//        if (combo.cookieB.row < NumRows - 1) {
//            BBQTile *above = [self.level tileAtColumn:combo.cookieB.column row:combo.cookieB.row + 1];
//            [adjacentTiles addObject:above];
//        }
//        
//        if (combo.cookieB.row > 0) {
//            BBQTile *below = [self.level tileAtColumn:combo.cookieB.column row:combo.cookieB.row - 1];
//            [adjacentTiles addObject:below];
//        }
//        
//        if (combo.cookieB.column > 0) {
//            BBQTile *left = [self.level tileAtColumn:combo.cookieB.column - 1 row:combo.cookieB.row];
//            [adjacentTiles addObject:left];
//        }
//        
//        if (combo.cookieB.column < NumColumns - 1) {
//            BBQTile *right = [self.level tileAtColumn:combo.cookieB.column + 1 row:combo.cookieB.row];
//            [adjacentTiles addObject:right];
//        }
//        
//        for (BBQTile *tile in adjacentTiles) {
//            if (tile.tileType == 5) {
//                if (!combo.steelBlockerTiles) {
//                    combo.steelBlockerTiles = [@[] mutableCopy];
//                }
//                [combo.steelBlockerTiles addObject:tile];
//            }
//        }
//    }
//}

//- (void)turnSteelBlockerIntoRegularTilesForCombos:(NSArray *)combos {
//    for (BBQComboAnimation *combo in combos) {
//        for (BBQTile *tile in combo.steelBlockerTiles) {
//            tile.tileType = 1;
//        }
//    }
//}

//- (NSArray *)createNewSteelBlockerTilesWithBlankTiles:(NSArray *)blankTiles {
//    NSMutableArray *newTiles = [@[] mutableCopy];
//    
//    for (int i = 0; i < [self.level.steelBlockerFactoryTiles count]; i ++) {
//        NSUInteger randomTileIndex = arc4random_uniform([blankTiles count]);
//        BBQTile *chosenTile = [blankTiles objectAtIndex:randomTileIndex];
//        chosenTile.tileType = 5;
//        [newTiles addObject:chosenTile];
//    }
//    return newTiles;
//}



#pragma mark - Methods for end of swipe


- (BOOL)isLevelComplete {
    //Put logic in here
    BOOL isComplete = YES;
    
    for (BBQCookieOrder *order in self.level.cookieOrders) {
        if (order.quantityLeft > 0) {
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

- (void)resetEverythingForNextTurn {
    self.chain = nil;
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
