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
    
    if (self.chain.isClosedChain) {
        self.chain.isClosedChain = NO;
        BBQCookie *firstCookie = [self.chain.cookiesInChain firstObject];
        firstCookie.temporaryPowerup = nil;
    }

    NSMutableArray *cookiesToRemove = [NSMutableArray array];
    for (NSInteger i = [self.chain.cookiesInChain indexOfObject:cookie] + 1; i < [self.chain.cookiesInChain count]; i++) {
        BBQCookie *cookieToRemove = self.chain.cookiesInChain[i];
        [cookiesToRemove addObject:cookieToRemove];
    }
    for (BBQCookie *cookieToRemove in cookiesToRemove) {
        [self.chain.cookiesInChain removeObject:cookieToRemove];
        cookieToRemove.temporaryPowerup = nil;
    }
    return cookiesToRemove;
}

- (BBQChain *)removeCookiesInChain {
    for (BBQCookie *cookie in self.chain.cookiesInChain) {
        
        if (cookie.activePowerup) {
            cookie.activePowerup.isReadyToDetonate = YES;
        }
        
        else if (cookie.temporaryPowerup) {
            cookie.activePowerup = cookie.temporaryPowerup;
            cookie.activePowerup.isReadyToDetonate = NO;
            cookie.temporaryPowerup = nil;
        }
        
        else {
            [self.level replaceCookieAtColumn:cookie.column row:cookie.row withCookie:nil];
        }
    }
    
    return self.chain;
}

- (void)activatePowerupForCookie:(BBQCookie *)cookie {
    
    [self.chain upgradePowerupsIfNecessary];
    
    BBQCookie *cookieTypeToCollect;
    if ([cookie.activePowerup isAMultiCookie]) {
        cookieTypeToCollect = [self.chain.cookiesInChain lastObject];
        if ([cookieTypeToCollect.activePowerup isAMultiCookie] == YES) {
            cookieTypeToCollect = [self.chain.cookiesInChain firstObject];
        }
    }
    
    [self.level replaceCookieAtColumn:cookie.column row:cookie.row withCookie:nil];
    [cookie.activePowerup performPowerupWithLevel:self.level cookie:cookie cookieTypeToCollect:cookieTypeToCollect];
    [cookie.activePowerup scorePowerup];
    
    if ([cookie.activePowerup isAMultiCookie] == YES && [self.chain isAMultiCookieUpgradedPowerupChain] == YES) {
        return;
    }
    else {
        [cookie.activePowerup addCookieOrders:self.level.cookieOrders];
    }
}

- (void)addPowerupScoreToCurrentScore:(BBQPowerup *)powerup {
    self.currentScore = self.currentScore + powerup.totalScore;
}

- (BOOL)doesCookieNeedRemoving:(BBQCookie *)cookie {
    if (cookie.activePowerup && cookie.activePowerup.isReadyToDetonate == NO) {
        return NO;
    }
    else return YES;
}

- (void)calculateScoreForChain {
    
    for (BBQCookie *cookie in self.chain.cookiesInChain) {
        [cookie setScoreForCookieInChain:self.chain];
        self.chain.score = self.chain.score + cookie.score;
    }
    self.currentScore = self.currentScore + self.chain.score;
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
    if ([self.chain isATwoCookieChain]) {
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
    
    if (cookie.activePowerup) return;
    
    NSInteger index = [self.chain.cookiesInChain indexOfObject:cookie];
    
    NSString *direction = [self directionOfPreviousCookieInChain:cookie];

    //The 6th cookie in a chain will blast out a row or column
    if (index == 5) {
        cookie.temporaryPowerup = [[BBQPowerup alloc] initWithType:6 direction:direction];
    }
    
    //The 9th cookie will turn into a pivot pad
    else if (index == 8) {
        cookie.temporaryPowerup = [[BBQPowerup alloc] initWithType:9 direction:direction];
    }
    
    //The 12th cookie will turn into a multi cookie, which will collect all like cookies on the board. Also every 3rd cookie from then on.
    else if (index >= 11 && (index + 1) % 3 == 0) {
        cookie.temporaryPowerup = [[BBQPowerup alloc] initWithType:12 direction:direction];
    }
    
    //Create a criss cross powerup
    else if (index > 3 && [self.level cookieFormsACrissCross:cookie chain:self.chain]) {
        cookie.temporaryPowerup = [[BBQPowerup alloc] initWithType:20 direction:direction];
    }
    
    //Create a box powerup
    else if (self.chain.isClosedChain && [self isFirstCookieInChain:cookie]) {
        cookie.temporaryPowerup = [[BBQPowerup alloc] initWithType:30 direction:direction];
    }

}

- (BOOL)isAnUpgradedMultiCookiePowerup:(BBQCookie *)cookie {
    BBQCookie *cookieTypeToCollect = [self.chain.cookiesInChain lastObject];
    if ([cookieTypeToCollect.activePowerup isAMultiCookie] == YES) {
        cookieTypeToCollect = [self.chain.cookiesInChain firstObject];
    }
    
    if ([cookie.activePowerup isAMultiCookie] && ([cookieTypeToCollect.activePowerup isATypeSixPowerup] || [cookieTypeToCollect.activePowerup isACrissCross] || [cookieTypeToCollect.activePowerup isABox])) {
        return YES;
    }
    
    else return NO;
}

- (NSArray *)topUpCookiesWithMultiCookie:(BBQCookie *)multiCookie {
    NSArray *columns;
    if (multiCookie) {
        BBQCookie *upgradedPowerup = [self.chain returnPowerupJoinedToMultiCookie];
        columns = [self.level topUpCookiesWithOptionalUpgradedMultiCookie:multiCookie poweruppedCookieChainedToMulticookie:upgradedPowerup];
    }
    
    else {
        columns = [self.level topUpCookiesWithOptionalUpgradedMultiCookie:nil poweruppedCookieChainedToMulticookie:nil];
    }

    return columns;
}

- (BBQTileObstacle *)removeObstacleOnTileForColumn:(NSInteger)column row:(NSInteger)row {
    BBQTile *tile = [self.level tileAtColumn:column row:row];
    BBQTileObstacle *obstacle = [tile.obstacles lastObject];
    [tile removeTileObstacle:obstacle];
    return obstacle;
}

- (BBQTileObstacle *)activeObstacleForTileAtColumn:(NSInteger)column row:(NSInteger)row {
    BBQTile *tile = [self.level tileAtColumn:column row:row];
    BBQTileObstacle *obstacle = [tile.obstacles lastObject];
    return obstacle;
}

- (NSArray *)removeObstaclesAroundTileForColumn:(NSInteger)column row:(NSInteger)row {
    NSMutableArray *obstacles = [NSMutableArray array];
    
    //Above
    if (row + 1 < NumRows) {
        [self addAdjacentObstacleAtColumn:column row:row + 1 array:obstacles];
    }
    
    //Below
    if (row - 1 >= 0) {
        [self addAdjacentObstacleAtColumn:column row:row - 1 array:obstacles];
    }
    
    //Left
    if (column - 1 >= 0) {
        [self addAdjacentObstacleAtColumn:column - 1  row:row array:obstacles];
    }
    
    //Right
    if (column + 1 < NumColumns) {
        [self addAdjacentObstacleAtColumn:column + 1 row:row array:obstacles];
    }
    return obstacles;
}

- (void)addAdjacentObstacleAtColumn:(NSInteger)column row:(NSInteger)row array:(NSMutableArray *)array {
    BBQTile *tile = [self.level tileAtColumn:column row:row];
    BBQTileObstacle *obstacle = [tile.obstacles lastObject];
    if (obstacle.detonatesWhenAdjacentToCookie == YES) {
        [tile removeTileObstacle:obstacle];
        [array addObject:obstacle];
    }
}


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
