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
        self.isCurrentlyTemporary = YES;
        self.isReadyToDetonate = NO;
        self.scorePerCookie = 10;
        
        if ([direction isEqualToString:RIGHT] || [direction isEqualToString:LEFT]) {
            self.direction = HORIZONTAL;
        }
        else if ([direction isEqualToString:UP] || [direction isEqualToString:DOWN]) {
            self.direction = VERTICAL;
        }
        
    }
    
    return self;
}

- (void)performPowerupWithLevel:(BBQLevel *)level cookie:(BBQCookie *)rootCookie cookieTypeToCollect:(BBQCookie *)cookieTypeToCollect {
    
    _level = level;
    self.arraysOfDisappearingCookies = [NSMutableArray array];
    
    switch (self.type) {
        case 6:
            if ([self.direction isEqualToString:HORIZONTAL]) {
                [self destroyEntireRowOfCookies:rootCookie];
            }
            else if ([self.direction isEqualToString:VERTICAL]) {
                [self destroyEntireColumnOfCookies:rootCookie];
            }
            break;
            
        case 9:
            break;
            
        case 12:
            [self removeAllCookiesOfCookieType:cookieTypeToCollect rootCookie:rootCookie];
            break;
            
        case 15:
            [self removeAllCookiesInLayersAroundBlast:rootCookie numberOfLayers:20];
            break;
        
        //Criss Cross
        case 20:
            [self destroyCrissCrossCookies:rootCookie];
            break;
        
        //Box powerup
        case 30:
            [self removeAllCookiesInLayersAroundBlast:rootCookie numberOfLayers:1];
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
    if (self.type == 9 || self.type == 12 || self.type == 15) {
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

- (BOOL)isARobbersSack {
    if (self.type == 15) return YES;
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
        self.totalScore = self.totalScore + ([array count] * self.scorePerCookie);
    }
}

- (void)removeDuplicateCookiesFromChainsCookies:(NSArray *)cookiesInChain {
    for (BBQCookie *cookie in cookiesInChain) {
        for (NSMutableArray *array in self.arraysOfDisappearingCookies) {
            if ([array containsObject:cookie]) {
                [array removeObject:cookie];
                break;
            }
        }
    }
}

- (void)addCookieOrders:(NSArray *)cookieOrders {
    
    //find the right order
    for (BBQCookieOrder *cookieOrder in cookieOrders) {
        NSInteger x = 0;
        for (NSArray *array in self.arraysOfDisappearingCookies) {
            for (BBQCookie *cookie in array) {
                if (cookieOrder.cookie.cookieType == cookie.cookieType && cookieOrder.quantityLeft > 0 && !cookie.powerup) {
                    cookie.cookieOrder = cookieOrder;
                    x++;
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
        
        if (cookie.powerup) {
            cookie.powerup.isReadyToDetonate = YES;
        }
    }
}

//- (void)destroyOneCookieVertically:(BBQCookie *)rootCookie {
//    NSInteger rootRow = rootCookie.row;
//    if (rootRow < NumRows - 1) {
//        [self destroyCookieAtColumn:rootCookie.column row:rootRow + 1];
//    }
//    if (rootRow >= 1) {
//        [self destroyCookieAtColumn:rootCookie.column row:rootRow - 1];
//    }
//}
//
//- (void)destroyOneCookieHorizontally:(BBQCookie *)rootCookie {
//    NSInteger rootColumn = rootCookie.column;
//    if (rootColumn < NumColumns - 1) {
//        [self destroyCookieAtColumn:rootColumn + 1 row:rootCookie.row];
//    }
//    if (rootColumn >= 1) {
//        [self destroyCookieAtColumn:rootColumn - 1 row:rootCookie.row];
//    }
//}

- (void)destroyEntireColumnOfCookies:(BBQCookie *)rootCookie {
    
    //ABOVE
    NSMutableArray *above = [NSMutableArray array];
    [self.arraysOfDisappearingCookies addObject:above];
    for (NSInteger i = rootCookie.row + 1; i < NumRows; i ++) {
        [self destroyCookieAtColumn:rootCookie.column row:i array:above];
    }
    
    //BELOW
    NSMutableArray *below = [NSMutableArray array];
    [self.arraysOfDisappearingCookies addObject:below];
    for (NSInteger i = rootCookie.row - 1; i >= 0; i--) {
        [self destroyCookieAtColumn:rootCookie.column row:i array:below];
    }
}

- (void)destroyEntireRowOfCookies:(BBQCookie *)rootCookie {
    
    //RIGHT
    NSMutableArray *right = [NSMutableArray array];
    [self.arraysOfDisappearingCookies addObject:right];
    for (NSInteger i = rootCookie.column + 1; i < NumColumns; i ++) {
        [self destroyCookieAtColumn:i row:rootCookie.row array:right];
    }
    
    //LEFT
    NSMutableArray *left = [NSMutableArray array];
    [self.arraysOfDisappearingCookies addObject:left];
    for (NSInteger i = rootCookie.column - 1; i >= 0; i--) {
        [self destroyCookieAtColumn:i row:rootCookie.row array:left];
    }
}


- (void)removeAllCookiesOfCookieType:(BBQCookie *)cookieType rootCookie:(BBQCookie *)rootCookie {
    
    //If the cookieType has no powerup upgrade required, then all cookies are in a seperate array so they are collected at the same time.
    if ([cookieType.powerup isATypeSixPowerup] || [cookieType.powerup isACrissCross] || [cookieType.powerup isABox]) {
        NSMutableArray *array = [NSMutableArray array];
        [self.arraysOfDisappearingCookies addObject:array];
        
        for (NSInteger column = 0; column < NumColumns; column ++) {
            for (NSInteger row = 0; row < NumRows; row++) {
                BBQCookie *cookie = [_level cookieAtColumn:column row:row];
                if (cookie.cookieType == cookieType.cookieType) {
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

- (void)destroyAllCookies:(BBQCookie *)rootCookie {
    for (NSInteger column = 0; column < NumColumns; column ++) {
        for (NSInteger row = 0; row < NumRows; row++) {
            BBQCookie *cookie = [_level cookieAtColumn:column row:row];
            if (cookie) {
                NSMutableArray *array = [NSMutableArray array];
                [self.arraysOfDisappearingCookies addObject:array];
                [self destroyCookieAtColumn:column row:row array:array];
            }
        }
    }
}

- (void)destroyCrissCrossCookies:(BBQCookie *)rootCookie {
    NSInteger rootColumn = rootCookie.column;
    NSInteger rootRow = rootCookie.row;
    NSInteger x = 1;
    
    //Top Left
    NSMutableArray *topLeft = [NSMutableArray array];
    [self.arraysOfDisappearingCookies addObject:topLeft];
    while (rootColumn - x >= 0 && rootRow + x < NumRows) {
        [self destroyCookieAtColumn:rootColumn - x row:rootRow + x array:topLeft];
        x++;
    }
    
    // Top Right
    x = 1;
    NSMutableArray *topRight = [NSMutableArray array];
    [self.arraysOfDisappearingCookies addObject:topRight];
    while (rootColumn + x < NumColumns && rootRow + x < NumRows) {
        [self destroyCookieAtColumn:rootColumn + x row:rootRow + x array:topRight];
        x++;
    }
    
    //Bottom Left
    x = 1;
    NSMutableArray *bottomLeft = [NSMutableArray array];
    [self.arraysOfDisappearingCookies addObject:bottomLeft];
    while (rootColumn - x >= 0 && rootRow - x >= 0) {
        [self destroyCookieAtColumn:rootColumn - x row:rootRow - x array:bottomLeft];
        x++;
    }
    
    //Bottom Right
    x = 1;
    NSMutableArray *bottomRight = [NSMutableArray array];
    [self.arraysOfDisappearingCookies addObject:bottomRight];
    while (rootColumn + x < NumColumns && rootRow - x >= 0) {
        [self destroyCookieAtColumn:rootColumn + x row:rootRow - x array:bottomRight];
        x++;
    }
}

- (void)removeAllCookiesInLayersAroundBlast:(BBQCookie *)rootCookie numberOfLayers:(NSInteger)numberOfLayers {
    BOOL isFinished = NO;
    NSInteger x = 1;
    NSInteger startRowOffset = 0;
    NSInteger startColumnOffset = 1;
    while (!isFinished) {
        NSMutableArray *array = [NSMutableArray array];
        
        //Above
        if (rootCookie.row + x < NumRows) {
            for (NSInteger column = rootCookie.column - startColumnOffset; column <= rootCookie.column + startColumnOffset; column++) {
                if (column >= 0 && column < NumColumns) {
                    BBQCookie *cookie = [_level cookieAtColumn:column row:rootCookie.row + x];
                    if (cookie) {
                        [self destroyCookieAtColumn:column row:rootCookie.row + x array:array];
                    }
                }
            }
        }
        
        //Below
        if (rootCookie.row - x >= 0) {
            for (NSInteger column = rootCookie.column - startColumnOffset; column <= rootCookie.column + startColumnOffset; column++) {
                if (column >= 0 && column < NumColumns) {
                    BBQCookie *cookie = [_level cookieAtColumn:column row:rootCookie.row - x];
                    if (cookie) {
                        [self destroyCookieAtColumn:column row:rootCookie.row - x array:array];
                    }
                }
            }
        }
        
        startColumnOffset ++;
        
        //Left
        if (rootCookie.column + x < NumColumns) {
            for (NSInteger row = rootCookie.row - startRowOffset; row <= rootCookie.row + startRowOffset; row ++) {
                if (row >= 0 && row < NumRows) {
                    BBQCookie *cookie = [_level cookieAtColumn:rootCookie.column + x row:row];
                    if (cookie) {
                        [self destroyCookieAtColumn:rootCookie.column + x row:row array:array];
                    }
                }
            }
        }
        
        //Right
        if (rootCookie.column - x >= 0) {
            for (NSInteger row = rootCookie.row - startRowOffset; row <= rootCookie.row + startRowOffset; row ++) {
                if (row >= 0 && row < NumRows) {
                    BBQCookie *cookie = [_level cookieAtColumn:rootCookie.column - x row:row];
                    if (cookie) {
                        [self destroyCookieAtColumn:rootCookie.column - x row:row array:array];
                    }
                }
            }
        }
        
        startRowOffset++;
        x++;
        numberOfLayers --;
        
        if ([array count] > 0) {
            [self.arraysOfDisappearingCookies addObject:array];
        }
        if ([array count] == 0 || numberOfLayers <= 0){
            isFinished = YES;
        }
    }
}

- (void)upgradeMultiCookiePowerupCookiesToCookieType:(BBQCookie *)cookieType {
    NSMutableArray *oldArray = [self.arraysOfDisappearingCookies firstObject];
    
    if ([cookieType.powerup isATypeSixPowerup] || [cookieType.powerup isABox] || [cookieType.powerup isACrissCross]) {
        
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
            cookie.powerup = [[BBQPowerup alloc] initWithType:cookieType.powerup.type direction:direction];
            cookie.powerup.isCurrentlyTemporary = NO;
            cookie.powerup.isCurrentlyTemporary = YES;
        }
        
        //seperate the cookies into arrays of 3 to detonate at a time
        NSMutableArray *allArrays = [NSMutableArray array];
        while ([oldArray count] > 0) {
            NSMutableArray *newArray = [NSMutableArray array];
            while ([newArray count] <= 3 && [oldArray count] > 0) {
                NSInteger randomIndex = arc4random_uniform([oldArray count]);
                BBQCookie *cookie = oldArray[randomIndex];
                [newArray addObject:cookie];
                [oldArray removeObject:cookie];
            }
            if ([newArray count] > 0) {
                [allArrays addObject:newArray];
            }
        }
        self.arraysOfDisappearingCookies = allArrays;
    }

}



#pragma mark - combined powerups

//When a type 6 is combined with a type 6
- (void)destroyTwoTypeSixCombo:(BBQCookie *)rootCookie {
    [self destroyEntireRowOfCookies:rootCookie];
    [self destroyEntireColumnOfCookies:rootCookie];
}

//When 2 boxes are combined
- (void)destroyTwoBoxCombo:(BBQCookie *)rootCookie {
    [self removeAllCookiesInLayersAroundBlast:rootCookie numberOfLayers:3];
}

//when a type six is combined with a box
- (void)destroyType6WithBoxCombo:(BBQCookie *)rootCookie {
    [self destroyEntireColumnOfCookies:rootCookie];
    [self destroyEntireRowOfCookies:rootCookie];
    [self removeAllCookiesInLayersAroundBlast:rootCookie numberOfLayers:2];
}

//When a type 6 and a criss cross are combined, or two criss crosses
- (void)destroyTypeSixAndCrissCrossCombo:(BBQCookie *)rootCookie {
    [self destroyCrissCrossCookies:rootCookie];
    [self destroyEntireColumnOfCookies:rootCookie];
    [self destroyEntireRowOfCookies:rootCookie];
}

//When a criss cross and a box are combined
- (void)destroyCrissCrossWithBoxCombo:(BBQCookie *)rootCookie {
    [self destroyCrissCrossCookies:rootCookie];
    [self removeAllCookiesInLayersAroundBlast:rootCookie numberOfLayers:2];
}

//- (void)destroyRowAndColumnAndAroundRootCookie:(BBQCookie *)rootCookie {
//    
//    
//    [self destroyEntireRowOfCookies:rootCookie];
//    [self destroyEntireColumnOfCookies:rootCookie];
//    
//    //Left side
//    NSInteger x = 1;
//    NSInteger leftColumn = rootCookie.column - x;
//    while (leftColumn >= 0 && x <= 2) {
//        NSInteger row = rootCookie.row + 2;
//        for (int i = 0; i <= 4; i ++) {
//            if (row < NumRows && row > 0) {
//                [self destroyCookieAtColumn:leftColumn row:row - i];
//                
//            }
//            i++;
//        }
//    }
//    
//    //Right side
//    x = 1;
//    NSInteger rightColumn = rootCookie.column + x;
//    while (rightColumn < NumColumns && x <= 2) {
//        NSInteger row = rootCookie.row + 2;
//        for (int i = 0; i <= 4; i ++) {
//            if (row < NumRows && row > 0) {
//                [self destroyCookieAtColumn:rightColumn row:row - i];
//            }
//            i++;
//        }
//    }
//    
//}
//
//- (void)destroyThreeByThree:(BBQCookie *)rootCookie {
//    [self destroyEntireColumnOfCookies:rootCookie];
//    [self destroyEntireRowOfCookies:rootCookie];
//    
//    for (int i = 0; i < NumColumns; i ++) {
//        [self destroyCookieAtColumn:i row:rootCookie.row + 1];
//    }
//    
//    for (int i = 0; i < NumColumns; i ++) {
//        [self destroyCookieAtColumn:i row:rootCookie.row - 1];
//    }
//    
//    for (int i = 0; i < NumRows; i ++) {
//        [self destroyCookieAtColumn:rootCookie.column + 1 row:i];
//    }
//    
//    for (int i = 0; i < NumRows; i ++) {
//        [self destroyCookieAtColumn:rootCookie.column - 1 row:i];
//    }
// 
//}

@end
