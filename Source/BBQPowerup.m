//
//  BBQPowerup.m
//  BbqBlitz
//
//  Created by Nikki Durkin on 3/13/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "BBQPowerup.h"
#import "BBQLevel.h"
#import "BBQGameLogic.h"

@implementation BBQPowerup {
    BBQLevel *_level;
}

- (instancetype)initWithType:(NSInteger)type direction:(NSString *)direction {
    self = [super init];
    if (self) {
        self.type = type;
        
        if ([direction isEqualToString:RIGHT] || [direction isEqualToString:LEFT]) {
            self.direction = HORIZONTAL;
        }
        else if ([direction isEqualToString:UP] || [direction isEqualToString:DOWN]) {
            self.direction = VERTICAL;
        }
        
    }
    
    return self;
}

- (NSString *)powerupName {
    NSString *powerupName;
    
    switch (self.type) {
        case 6:
            powerupName = self.direction;
            break;
            
        case 9:
            powerupName = @"PivotPad";
            break;
            
        case 12:
            powerupName = @"MultiCookie";
            break;
            
        case 20:
            powerupName = @"CrissCross";
            break;
            
        case 30:
            powerupName = @"Box";
            break;
            
        default:
            break;
    }
    
    return powerupName;
}

- (void)performPowerupWithLevel:(BBQLevel *)level cookie:(BBQCookie *)rootCookie cookieTypeToCollect:(BBQCookie *)cookieTypeToCollect {
    
    _level = level;
    self.arraysOfDisappearingCookies = [NSMutableArray array];
    
    switch (self.type) {
        case 6:
            if ([self.direction isEqualToString:HORIZONTAL]) {
                [self destroyEntireRowOfCookies:rootCookie numberOfLayers:100];
            }
            else if ([self.direction isEqualToString:VERTICAL]) {
                [self destroyEntireColumnOfCookies:rootCookie numberOfLayers:100];
            }
            break;
            
        case 9:
            break;
            
        case 12:
            [self removeAllCookiesOfCookieType:cookieTypeToCollect rootCookie:rootCookie];
            break;
        
        //Criss Cross
        case 20:
            [self destroyCrissCrossCookies:rootCookie numberOfLayers:100];
            break;
        
        //Box powerup
        case 30:
            [self destroyAllCookiesAroundBlast:rootCookie numberOfLayers:1];
            break;
            
        //Combine 2 type six powerups
        case 100:
            [self destroyTwoTypeSixCombo:rootCookie];
            break;
        
        //Combine 2 box powerups
        case 150:
            [self destroyTwoBoxCombo:rootCookie];
            break;
        
        //Combine 2 criss cross powerups
        case 200:
            [self destroyTypeSixAndCrissCrossCombo:rootCookie];
            break;
            
        //Combine type 6 with criss cross
        case 250:
            [self destroyTypeSixAndCrissCrossCombo:rootCookie];
            break;
            
        //Combine type 6 and box
        case 300:
            [self destroyType6WithBoxCombo:rootCookie];
            break;
            
        //combine box and criss cross
        case 350:
            [self destroyCrissCrossWithBoxCombo:rootCookie];
            break;
            
        default:
            break;
    }
    
}

- (BOOL)canOnlyJoinWithCookieNextToIt {
    if (self.type == 9 || self.type == 12 ) {
        return YES;
    }
    else return NO;
}

//Box, type 6 or criss cross
- (BOOL)canBeDetonatedWithoutAChain {
    if (self.type == 6 || self.type == 20 || self.type == 30) {
        return YES;
    }
    else return NO;
}

- (BOOL)isAPivotPad {
    if (self.type == 9) return YES;
    else return NO;
}

- (BOOL)isAMultiCookie {
    if (self.type == 12) return YES;
    else return NO;
}

- (BOOL)isATypeSixPowerup {
    if (self.type == 6) {
        return YES;
    }
    else return NO;
}

- (BOOL)isACrissCross {
    if (self.type == 20) {
        return YES;
    }
    else return NO;
}

- (BOOL)isABox {
    if (self.type == 30) return YES;
    else return NO;
}

- (BOOL)isATwoSixesCombo {
    if (self.type == 100) return YES;
    else return NO;
}

- (BOOL)isATwoBoxCombo {
    if (self.type == 150) return YES;
    else return NO;
}

- (BOOL)isATwoCrissCrossCombo {
    if (self.type == 200) return YES;
    else return NO;
}

- (BOOL)isATypeSixWithCrissCrossCombo {
    if (self.type == 250) return YES;
    else return NO;
}

- (BOOL)isaTypeSixWithBoxCombo {
    if (self.type == 300) return YES;
    else return NO;
}

- (BOOL)isABoxAndCrissCrossCombo {
    if (self.type == 350) return YES;
    else return NO;
}

- (void)scorePowerup {
    
    for (NSArray *array in self.arraysOfDisappearingCookies) {
        for (id object in array) {
            if ([object isKindOfClass:[BBQCookie class]]) {
                BBQCookie *cookie = object;
            
                if ([cookie.activePowerup canBeDetonatedWithoutAChain]) {
                    cookie.score = 150;
                }
                else if ([cookie.activePowerup isAPivotPad]) {
                    cookie.score = 250;
                }
                else if ([cookie.activePowerup isAMultiCookie]) {
                    cookie.score = 300;
                }

                else {
                    cookie.score = 30;
                }
                
                self.totalScore = self.totalScore + cookie.score;

            }
        }
    }
}

- (void)addCookieOrders:(NSArray *)cookieOrders {
    
    //find the right order
    for (BBQCookieOrder *cookieOrder in cookieOrders) {
        NSInteger x = 0;
        for (NSArray *array in self.arraysOfDisappearingCookies) {
            for (id object in array) {
                if ([object isKindOfClass:[BBQCookie class]]) {
                    BBQCookie *cookie = object;
                    if (cookieOrder.cookie.cookieType == cookie.cookieType && cookieOrder.quantityLeft > 0 && !cookie.activePowerup) {
                        cookie.cookieOrder = cookieOrder;
                        x++;
                    }
                }
            }
        }
        cookieOrder.quantityLeft = cookieOrder.quantityLeft - x;
        cookieOrder.quantityLeft = MAX(0, cookieOrder.quantityLeft);
    }
}

- (void)destroyCookieAtColumn:(NSInteger)column row:(NSInteger)row array:(NSMutableArray *)array {
    BBQCookie *cookie = [_level cookieAtColumn:column row:row];
    if (cookie != nil) {
        [_level replaceCookieAtColumn:column row:row withCookie:nil];
        [array addObject:cookie];
    }
    else {
        BBQTile *tile = [_level tileAtColumn:column row:row];
        [array addObject:tile];
    }
}

- (void)destroyEntireColumnOfCookies:(BBQCookie *)rootCookie numberOfLayers:(NSInteger)numberOfLayers {
    
    //ABOVE
    NSInteger x = numberOfLayers;
    NSMutableArray *above = [NSMutableArray array];
    [self.arraysOfDisappearingCookies addObject:above];
    for (NSInteger i = rootCookie.row + 1; i < NumRows && x > 0; i ++) {
        [self destroyCookieAtColumn:rootCookie.column row:i array:above];
        x--;
    }
    
    //BELOW
    x = numberOfLayers;
    NSMutableArray *below = [NSMutableArray array];
    [self.arraysOfDisappearingCookies addObject:below];
    for (NSInteger i = rootCookie.row - 1; i >= 0 && x > 0; i--) {
        [self destroyCookieAtColumn:rootCookie.column row:i array:below];
        x--;
    }
}

- (void)destroyEntireRowOfCookies:(BBQCookie *)rootCookie numberOfLayers:(NSInteger)numberOfLayers {
    
    //RIGHT
    NSInteger x = numberOfLayers;
    NSMutableArray *right = [NSMutableArray array];
    [self.arraysOfDisappearingCookies addObject:right];
    for (NSInteger i = rootCookie.column + 1; i < NumColumns && x > 0; i ++) {
        [self destroyCookieAtColumn:i row:rootCookie.row array:right];
        x--;
    }
    
    //LEFT
    x = numberOfLayers;
    NSMutableArray *left = [NSMutableArray array];
    [self.arraysOfDisappearingCookies addObject:left];
    for (NSInteger i = rootCookie.column - 1; i >= 0 && x > 0; i--) {
        [self destroyCookieAtColumn:i row:rootCookie.row array:left];
        x--;
    }
}


- (void)removeAllCookiesOfCookieType:(BBQCookie *)cookieType rootCookie:(BBQCookie *)rootCookie {
    
    //If the cookieType has no powerup upgrade required, then all cookies are in a seperate array so they are collected at the same time.
    if ([cookieType.activePowerup isATypeSixPowerup] || [cookieType.activePowerup isACrissCross] || [cookieType.activePowerup isABox]) {
        NSMutableArray *array = [NSMutableArray array];
        [self.arraysOfDisappearingCookies addObject:array];
        
        for (NSInteger column = 0; column < NumColumns; column ++) {
            for (NSInteger row = 0; row < NumRows; row++) {
                BBQCookie *cookie = [_level cookieAtColumn:column row:row];
                if (cookie.cookieType == cookieType.cookieType && [cookie isEqual:cookieType] == NO) {
                    [array addObject:cookie];
                }
            }
        }
        
        [self upgradeMultiCookiePowerupCookiesToCookieType:cookieType];
    }
            
    else {
        for (NSInteger column = 0; column < NumColumns; column ++) {
            for (NSInteger row = 0; row < NumRows; row++) {
                BBQCookie *cookie = [_level cookieAtColumn:column row:row];
                if (cookie.cookieType == cookieType.cookieType) {
                    NSMutableArray *array = [NSMutableArray array];
                    [self.arraysOfDisappearingCookies addObject:array];
                    [self destroyCookieAtColumn:column row:row array:array];
                }
            }
        }
    }
}

- (void)destroyCrissCrossCookies:(BBQCookie *)rootCookie numberOfLayers:(NSInteger)numberOfLayers {
    NSInteger rootColumn = rootCookie.column;
    NSInteger rootRow = rootCookie.row;
    NSInteger x = 1;
    
    //Top Left
    NSMutableArray *topLeft = [NSMutableArray array];
    [self.arraysOfDisappearingCookies addObject:topLeft];
    while (rootColumn - x >= 0 && rootRow + x < NumRows && x <= numberOfLayers) {
        [self destroyCookieAtColumn:rootColumn - x row:rootRow + x array:topLeft];
        x++;
    }
    
    // Top Right
    x = 1;
    NSMutableArray *topRight = [NSMutableArray array];
    [self.arraysOfDisappearingCookies addObject:topRight];
    while (rootColumn + x < NumColumns && rootRow + x < NumRows && x <= numberOfLayers) {
        [self destroyCookieAtColumn:rootColumn + x row:rootRow + x array:topRight];
        x++;
    }
    
    //Bottom Left
    x = 1;
    NSMutableArray *bottomLeft = [NSMutableArray array];
    [self.arraysOfDisappearingCookies addObject:bottomLeft];
    while (rootColumn - x >= 0 && rootRow - x >= 0 && x <= numberOfLayers) {
        [self destroyCookieAtColumn:rootColumn - x row:rootRow - x array:bottomLeft];
        x++;
    }
    
    //Bottom Right
    x = 1;
    NSMutableArray *bottomRight = [NSMutableArray array];
    [self.arraysOfDisappearingCookies addObject:bottomRight];
    while (rootColumn + x < NumColumns && rootRow - x >= 0 && x <= numberOfLayers) {
        [self destroyCookieAtColumn:rootColumn + x row:rootRow - x array:bottomRight];
        x++;
    }
}

- (void)destroyAllCookiesAroundBlast:(BBQCookie *)rootCookie numberOfLayers:(NSInteger)numberOfLayers {
    
    //ABOVE LEFT UPPER
    NSInteger x = 2;
    for (NSInteger column = rootCookie.column - 1; column >= 0 && x <= numberOfLayers; column --) {
        NSMutableArray *array = [NSMutableArray array];
        [self.arraysOfDisappearingCookies addObject:array];
        for (NSInteger i = x - 1; i > 0; i--) {
            [array addObject:[NSNull null]];
        }
        for (NSInteger row = rootCookie.row + x; row < NumRows && [array count] < numberOfLayers; row++) {
            [self destroyCookieAtColumn:column row:row array:array];
        }
        x++;
    }
    
    //ABOVE RIGHT UPPER
    x = 2;
    for (NSInteger column = rootCookie.column + 1; column < NumColumns && x <= numberOfLayers; column ++) {
        NSMutableArray *array = [NSMutableArray array];
        [self.arraysOfDisappearingCookies addObject:array];
        for (NSInteger i = x - 1; i > 0; i--) {
            [array addObject:[NSNull null]];
        }
        for (NSInteger row = rootCookie.row + x; row < NumRows && [array count] < numberOfLayers; row++) {
            [self destroyCookieAtColumn:column row:row array:array];
        }
        x++;
    }
    
    //BELOW LEFT
    x = 2;
    for (NSInteger column = rootCookie.column - 1; column >= 0 && x <= numberOfLayers; column --) {
        NSMutableArray *array = [NSMutableArray array];
        [self.arraysOfDisappearingCookies addObject:array];
        for (NSInteger i = x - 1; i > 0; i--) {
            [array addObject:[NSNull null]];
        }
        for (NSInteger row = rootCookie.row - x; row >= 0 && [array count] < numberOfLayers; row--) {
            [self destroyCookieAtColumn:column row:row array:array];
        }
        x++;
    }
    
    //BELOW RIGHT
    x = 2;
    for (NSInteger column = rootCookie.column + 1; column < NumColumns && x <= numberOfLayers; column ++) {
        NSMutableArray *array = [NSMutableArray array];
        [self.arraysOfDisappearingCookies addObject:array];
        for (NSInteger i = x - 1; i > 0; i--) {
            [array addObject:[NSNull null]];
        }
        for (NSInteger row = rootCookie.row - x; row >= 0 && [array count] < numberOfLayers; row--) {
            [self destroyCookieAtColumn:column row:row array:array];
        }
        x++;
    }
    
    
    //REVERSE OF THE ABOVE
    
    //ABOVE LEFT UPPER
    x = 2;
    for (NSInteger row = rootCookie.row - 1; row >= 0 && x <= numberOfLayers; row --) {
        NSMutableArray *array = [NSMutableArray array];
        [self.arraysOfDisappearingCookies addObject:array];
        for (NSInteger i = x - 1; i > 0; i--) {
            [array addObject:[NSNull null]];
        }
        for (NSInteger column = rootCookie.column + x; column < NumColumns && [array count] < numberOfLayers; column++) {
            [self destroyCookieAtColumn:column row:row array:array];
        }
        x++;
    }
    
    //ABOVE RIGHT UPPER
    x = 2;
    for (NSInteger row = rootCookie.row + 1; row < NumRows && x <= numberOfLayers; row ++) {
        NSMutableArray *array = [NSMutableArray array];
        [self.arraysOfDisappearingCookies addObject:array];
        for (NSInteger i = x - 1; i > 0; i--) {
            [array addObject:[NSNull null]];
        }
        for (NSInteger column = rootCookie.column + x; column < NumColumns && [array count] < numberOfLayers; column++) {
            [self destroyCookieAtColumn:column row:row array:array];
        }
        x++;
    }
    
    //BELOW LEFT
    x = 2;
    for (NSInteger row = rootCookie.row - 1; row >= 0 && x <= numberOfLayers; row --) {
        NSMutableArray *array = [NSMutableArray array];
        [self.arraysOfDisappearingCookies addObject:array];
        for (NSInteger i = x - 1; i > 0; i--) {
            [array addObject:[NSNull null]];
        }
        for (NSInteger column = rootCookie.column - x; column >= 0 && [array count] < numberOfLayers; column--) {
            [self destroyCookieAtColumn:column row:row array:array];
        }
        x++;
    }
    
    //BELOW RIGHT
    x = 2;
    for (NSInteger row = rootCookie.row + 1; row < NumRows && x <= numberOfLayers; row ++) {
        NSMutableArray *array = [NSMutableArray array];
        [self.arraysOfDisappearingCookies addObject:array];
        for (NSInteger i = x - 1; i > 0; i--) {
            [array addObject:[NSNull null]];
        }
        for (NSInteger column = rootCookie.column - x; column >= 0 && [array count] < numberOfLayers; column--) {
            [self destroyCookieAtColumn:column row:row array:array];
        }
        x++;
    }

    
    
    //OTHER
    [self destroyCrissCrossCookies:rootCookie numberOfLayers:numberOfLayers];
    [self destroyEntireColumnOfCookies:rootCookie numberOfLayers:numberOfLayers];
    [self destroyEntireRowOfCookies:rootCookie numberOfLayers:numberOfLayers];

}

//- (void)removeAllCookiesInLayersAroundBlast:(BBQCookie *)rootCookie numberOfLayers:(NSInteger)numberOfLayers {
//    BOOL isFinished = NO;
//    NSInteger x = 1;
//    NSInteger startRowOffset = 0;
//    NSInteger startColumnOffset = 1;
//    while (!isFinished) {
//        NSMutableArray *array = [NSMutableArray array];
//        
//        //Above
//        if (rootCookie.row + x < NumRows) {
//            for (NSInteger column = rootCookie.column - startColumnOffset; column <= rootCookie.column + startColumnOffset; column++) {
//                if (column >= 0 && column < NumColumns) {
//                    BBQCookie *cookie = [_level cookieAtColumn:column row:rootCookie.row + x];
//                    if (cookie) {
//                        [self destroyCookieAtColumn:column row:rootCookie.row + x array:array];
//                    }
//                }
//            }
//        }
//        
//        //Below
//        if (rootCookie.row - x >= 0) {
//            for (NSInteger column = rootCookie.column - startColumnOffset; column <= rootCookie.column + startColumnOffset; column++) {
//                if (column >= 0 && column < NumColumns) {
//                    BBQCookie *cookie = [_level cookieAtColumn:column row:rootCookie.row - x];
//                    if (cookie) {
//                        [self destroyCookieAtColumn:column row:rootCookie.row - x array:array];
//                    }
//                }
//            }
//        }
//        
//        startColumnOffset ++;
//        
//        //Left
//        if (rootCookie.column + x < NumColumns) {
//            for (NSInteger row = rootCookie.row - startRowOffset; row <= rootCookie.row + startRowOffset; row ++) {
//                if (row >= 0 && row < NumRows) {
//                    BBQCookie *cookie = [_level cookieAtColumn:rootCookie.column + x row:row];
//                    if (cookie) {
//                        [self destroyCookieAtColumn:rootCookie.column + x row:row array:array];
//                    }
//                }
//            }
//        }
//        
//        //Right
//        if (rootCookie.column - x >= 0) {
//            for (NSInteger row = rootCookie.row - startRowOffset; row <= rootCookie.row + startRowOffset; row ++) {
//                if (row >= 0 && row < NumRows) {
//                    BBQCookie *cookie = [_level cookieAtColumn:rootCookie.column - x row:row];
//                    if (cookie) {
//                        [self destroyCookieAtColumn:rootCookie.column - x row:row array:array];
//                    }
//                }
//            }
//        }
//        
//        startRowOffset++;
//        x++;
//        numberOfLayers --;
//        
//        if ([array count] > 0) {
//            [self.arraysOfDisappearingCookies addObject:array];
//        }
//        if ([array count] == 0 || numberOfLayers <= 0){
//            isFinished = YES;
//        }
//    }
//}

- (void)upgradeMultiCookiePowerupCookiesToCookieType:(BBQCookie *)cookieType {
    NSMutableArray *oldArray = [self.arraysOfDisappearingCookies firstObject];
    
    if ([cookieType.activePowerup isATypeSixPowerup] || [cookieType.activePowerup isABox] || [cookieType.activePowerup isACrissCross]) {
        
        //upgrade the cookie type
        for (BBQCookie *cookie in oldArray) {
            NSInteger random = arc4random_uniform(2) + 1;
            NSString *direction;
            if (random == 1) {
                direction = RIGHT;
            }
            else {
                direction = UP;
            }
            cookie.activePowerup = [[BBQPowerup alloc] initWithType:cookieType.activePowerup.type direction:direction];
        }
        
        self.arraysOfDisappearingCookies = [self returnArrayOfCookiesRandomlyAssignedToArrays:oldArray];
        [self.arraysOfDisappearingCookies[0] addObject:cookieType];
    }

}

- (NSMutableArray *)returnArrayOfCookiesRandomlyAssignedToArrays:(NSMutableArray *)oldArray {
    NSMutableArray *allArrays = [NSMutableArray array];
    while ([oldArray count] > 0) {
        NSMutableArray *newArray = [NSMutableArray array];
        while ([newArray count] < 3 && [oldArray count] > 0) {
            NSInteger randomIndex = arc4random_uniform([oldArray count]);
            BBQCookie *cookie = oldArray[randomIndex];
            [newArray addObject:cookie];
            [oldArray removeObject:cookie];
        }
        if ([newArray count] > 0) {
            [allArrays addObject:newArray];
        }
    }
    return allArrays;
}

- (void)removeUndetonatedPowerupFromArraysOfPowerupsToDetonate:(BBQCookie *)cookie {
    
    for (NSInteger index = 0; index < [self.arraysOfDisappearingCookies count]; index ++) {
        [self.arraysOfDisappearingCookies[index] removeObject:cookie];
    }
    
    //Now redistribute the other cookies evenly in the leftover arrays
    NSMutableArray *allCookies = [self singleArrayContainingAllCookiesToRemove];
    
    NSMutableArray *finalArrays = [self returnArrayOfCookiesRandomlyAssignedToArrays:allCookies];
    [finalArrays insertObject:[self.arraysOfDisappearingCookies firstObject] atIndex:0];
    
    self.arraysOfDisappearingCookies = finalArrays;
    
    if (!self.upgradedMuliticookiePowerupCookiesThatNeedreplacing) {
        self.upgradedMuliticookiePowerupCookiesThatNeedreplacing = [NSMutableArray array];
    }
    [self.upgradedMuliticookiePowerupCookiesThatNeedreplacing addObject:cookie];
}

- (void)addNewlyCreatedPowerupToArraysOfPowerupsToDetonate:(BBQCookie *)cookie {
    NSMutableArray *lastArray = [self.arraysOfDisappearingCookies lastObject];
    if ([lastArray count] < 3) {
        [lastArray addObject:cookie];
    }
    else {
        NSMutableArray *newArray = [NSMutableArray array];
        [newArray addObject:cookie];
        [self.arraysOfDisappearingCookies addObject:newArray];
    }
}

#pragma mark - Helper methods

- (NSMutableArray *)singleArrayContainingAllCookiesToRemove {
    NSMutableArray *allCookies = [NSMutableArray array];
    for (NSInteger i = 1; i < [self.arraysOfDisappearingCookies count]; i++) {
        NSMutableArray *array = self.arraysOfDisappearingCookies[i];
        for (BBQCookie *cookie in array) {
            [allCookies addObject:cookie];
        }
    }
    return allCookies;
}


#pragma mark - combined powerups

//When a type 6 is combined with a type 6
- (void)destroyTwoTypeSixCombo:(BBQCookie *)rootCookie {
    [self destroyEntireRowOfCookies:rootCookie numberOfLayers:100];
    [self destroyEntireColumnOfCookies:rootCookie numberOfLayers:100];
}

//When 2 boxes are combined
- (void)destroyTwoBoxCombo:(BBQCookie *)rootCookie {
    [self destroyAllCookiesAroundBlast:rootCookie numberOfLayers:3];
}

//when a type six is combined with a box
- (void)destroyType6WithBoxCombo:(BBQCookie *)rootCookie {
    [self destroyEntireColumnOfCookies:rootCookie numberOfLayers:100];
    [self destroyEntireRowOfCookies:rootCookie numberOfLayers:100];
    [self destroyAllCookiesAroundBlast:rootCookie numberOfLayers:2];
}

//When a type 6 and a criss cross are combined, or two criss crosses
- (void)destroyTypeSixAndCrissCrossCombo:(BBQCookie *)rootCookie {
    [self destroyCrissCrossCookies:rootCookie numberOfLayers:100];
    [self destroyEntireColumnOfCookies:rootCookie numberOfLayers:100];
    [self destroyEntireRowOfCookies:rootCookie numberOfLayers:100];
}

//When a criss cross and a box are combined
- (void)destroyCrissCrossWithBoxCombo:(BBQCookie *)rootCookie {
    [self destroyCrissCrossCookies:rootCookie numberOfLayers:100];
    [self destroyAllCookiesAroundBlast:rootCookie numberOfLayers:2];
}



@end
