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

- (NSArray *)movementsForSwipe:(NSString *)swipeDirection columnOrRow:(NSInteger)columnOrRow {
    
    //Change around the cookies in the model
    NSArray *cookiesInColumnOrRow = [self.level allCookiesInColumnOrRow:columnOrRow swipeDirection:swipeDirection];
    
    
    BBQCookie *lastCookie = cookiesInColumnOrRow[[cookiesInColumnOrRow count] - 1];
    NSInteger lastCookieColumn = lastCookie.column;
    NSInteger lastCookieRow = lastCookie.row;
    for (NSInteger i = [cookiesInColumnOrRow count] - 1; i >= 0; i --) {
        BBQCookie *cookie = cookiesInColumnOrRow[i];
        if (i > 0) {
            BBQCookie *cookiePlusOne = cookiesInColumnOrRow[i - 1];
            [self.level replaceCookieAtColumn:cookiePlusOne.column row:cookiePlusOne.row withCookie:cookie];
            cookie.row = cookiePlusOne.row;
            cookie.column = cookiePlusOne.column;
        }
        else if (i == 0) {
            [self.level replaceCookieAtColumn:lastCookieColumn row:lastCookieRow withCookie:cookie];
            cookie.column = lastCookieColumn;
            cookie.row = lastCookieRow;
        }
        
    }
    
    //Now create the movements
    NSMutableArray *movements = [NSMutableArray array];
    NSArray *sections = [self.level breakColumnOrRowIntoSectionsForDirection:swipeDirection columnOrRow:columnOrRow];
    for (NSArray *section in sections) {
        for (NSInteger i = 0; i < [section count]; i++) {
            BBQCookie *cookie = section[i];
            BBQMovement *movement;
            
            //the middle cookies simply need to move up one space
            if (i >= 0 && i < [section count] - 1) {
                movement = [[BBQMovement alloc] initWithCookie:cookie destinationColumn:cookie.column destinationRow:cookie.row];
                movement.sprite = cookie.sprite;
                [movements addObject:movement];
            }
            //The first cookie needs to move one space then disappear
            else if (i == [section count] - 1) {
                BBQCookie *firstCookie = section[0];
                
                //Make an exiting movement
                if ([swipeDirection isEqualToString:UP]) {
                    movement = [[BBQMovement alloc] initWithCookie:cookie destinationColumn:firstCookie.column destinationRow:firstCookie.row + 1];
                }
                if ([swipeDirection isEqualToString:DOWN]) {
                    movement = [[BBQMovement alloc] initWithCookie:cookie destinationColumn:firstCookie.column destinationRow:firstCookie.row - 1];
                }
                if ([swipeDirection isEqualToString:LEFT]) {
                    movement = [[BBQMovement alloc] initWithCookie:cookie destinationColumn:firstCookie.column - 1 destinationRow:firstCookie.row];
                }
                if ([swipeDirection isEqualToString:RIGHT]) {
                    movement = [[BBQMovement alloc] initWithCookie:cookie destinationColumn:firstCookie.column + 1 destinationRow:firstCookie.row];
                }
                
                movement.sprite = cookie.sprite;
                movement.isExitingCookie = YES;
                [movements addObject:movement];
                
                //Make an entering movement
                BBQMovement *enteringMovement = [[BBQMovement alloc] initWithCookie:cookie destinationColumn:cookie.column destinationRow:cookie.row];
                enteringMovement.isEnteringCookie = YES;
                enteringMovement.sprite = nil;
                [movements addObject:enteringMovement];
            }
        }
    }
    
    
    
    //
//    
//    //Move all cookies to appropriate positions
//    NSArray *sections = [self.level breakColumnOrRowIntoSectionsForDirection:swipeDirection columnOrRow:columnOrRow];
//    for (NSInteger sectionIndex = 0; sectionIndex < [sections count]; sectionIndex++) {
//        NSMutableArray *section = sections[sectionIndex];
//        NSArray *chains = [self.level chainsInSection:section];
//        for (NSInteger i = 0; i < [chains count]; i++) {
//            NSArray *chain = chains[i];
//            BBQCookie *rootCookie = chain[0];
//            BBQCookieOrder *order = [self.level cookieOrderForType:rootCookie.cookieType];
//            if ([chain count] >= 2) {
//                for (NSInteger x = [chain count] - 1; x >= 0; x --) {
//                    BBQCookie *cookie = chain[x];
//                    [self.level replaceCookieAtColumn:cookie.column row:cookie.row withCookie:nil];
//                    
//                    //Attach a combo
//                    BBQCombo *combo = [[BBQCombo alloc] init];
//                    cookie.combo = combo;
//                    
//                    //Check to see if it is on cookie order, but not if it is the last cookie. Have to check that one afterwards, because it is the last sprite to dissappear
//                    if (order.quantityLeft > 0 && x < [chain count] - 1) {
//                        order.quantityLeft --;
//                        cookie.combo.cookieOrder = order;
//                    }
//                    
//                    //Set the number of tiles the animation needs to be delayed by, before the cookie dissapears. So the sequence is move > delay > cookie dissappears
//                    NSInteger chainCount = [chain count];
//                    NSInteger delay = chainCount - x - 1;
//                    cookie.combo.numberOfTilesToDelayBy = delay;
//                    
//                    //move over the last cookie in the chain
//                    if (x == [chain count] - 1) {
//                        cookie.column = rootCookie.column;
//                        cookie.row = rootCookie.row;
//                        combo.isLastCookieInChain = YES;
//                    }
//
//                    
//                    //move all cookies after this one, over one space
//                    for (NSInteger y = i + 1; y < [chains count]; y++) {
//                        NSArray *chainToMove = chains[y];
//                        for (BBQCookie *cookie in chainToMove) {
//                            [self moveCookieOneTileOver:cookie swipeDirection:swipeDirection];
//                        }
//
//                    }
//                }
//                
//                //Update cookie order for last cookie in chain, which will disappear last
//                if (order.quantityLeft > 0) {
//                    order.quantityLeft --;
//                    NSInteger z = [chain count] - 1;
//                    BBQCookie *lastCookie = chain[z];
//                    lastCookie.combo.cookieOrder = order;
//                }
//            }
//        }
//    }
    
    
    //Update moves
    self.movesLeft --;
    
    return movements;
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


#pragma mark - Combos


//- (void)scoreTheCombos:(NSArray *)combos {
//    NSInteger scoreForThisRound = 0;
//    for (BBQComboAnimation *combo in combos) {
//        if (combo.score > 0) {
//            scoreForThisRound = scoreForThisRound + combo.score;
//        }
//    }
//    self.currentScore = self.currentScore + scoreForThisRound;
//}

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
