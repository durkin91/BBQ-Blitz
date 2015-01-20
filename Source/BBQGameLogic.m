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

- (NSSet *)setupGame {
    self.level = [[BBQLevel alloc] initWithFile:@"Level_1"];
    return [self.level createCookiesInBlankTiles];
}

#pragma mark - Swipe Logic

- (NSDictionary *)swipe:(NSString *)swipeDirection {
    
    NSDictionary *animationsToPerform = @{
                                          COMBOS : [@[] mutableCopy],
                                          MOVEMENTS : [@[] mutableCopy],
                                          };
    
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
                        [self tryCombineCookieA:cookieA withCookieB:cookieB animations:animationsToPerform swipeDirection:@"Up"];
                        
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
    
    NSLog(@"Animations to perform: %@", animationsToPerform);
    return animationsToPerform;
}

                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
//                BBQTile *tileA = [self.level tileAtColumn:column row:row];
//                if (tileA != nil) {
//                    BBQCookie *cookieA = [self.level cookieAtColumn:column row:row];
//                    BBQTile *tileB = [self.level tileAtColumn:column row:row + 1];
//                    
//                    //need to account for the shark tiles, which will have nil cookies
//                    int x = 1;
//                    BBQCookie *cookieB = [self.level cookieAtColumn:column row:row + x];
//                    while (tileB != nil && tileB.tileType == 2) {
//                        tileB = [self.level tileAtColumn:column row:row + x];
//                        cookieB = [self.level cookieAtColumn:column row:row + x];
//                        x ++;
//                    }
//                    if (tileB != nil && cookieA != nil) {
//                        [self tryCombineCookieA:cookieA withCookieB:cookieB animations:animationsToPerform swipeDirection:@"Up"];
//                        
//                    }
//                }
//            
//                //move all cookies in that column into appropriate space
//                for (int rowX = row; rowX >= 1; rowX --) {
//                    BBQCookie *topCookie = [self.level cookieAtColumn:column row:rowX];
//                    BBQCookie *bottomCookie = [self.level cookieAtColumn:column row:rowX - 1];
//                    BBQTile *bottomTile = [self.level tileAtColumn:column row:rowX - 1];
//                    if (bottomTile != nil && bottomCookie == nil) {
//                        BBQMoveCookie *cookieMovement = [self moveASingleCookie:topCookie direction:swipeDirection];
//                        [animationsToPerform[MOVEMENTS] addObject:cookieMovement];
//                    }
//                }
//            }
//        }
//    }
    
//    //DOWN swipe
//    if ([swipeDirection isEqualToString:@"Down"]) {
//        for (int column = 0; column < NumColumns ; column++) {
//            for (int row = 1; row <= NumRows - 2; row++) {
//                BBQTile *tileA = [self.level tileAtColumn:column row:row];
//                if (tileA != nil) {
//                    BBQCookie *cookieA = [self.level cookieAtColumn:column row:row];
//                    BBQTile *tileB = [self.level tileAtColumn:column row:row - 1];
//                    if (tileB != nil && cookieA != nil) {
//                        BBQCookie *cookieB = [self.level cookieAtColumn:column row:row - 1];
//                        [self tryCombineCookieA:cookieA withCookieB:cookieB animations:animationsToPerform swipeDirection:@"Down"];
//                        
//                    }
//                }
//            }
//        }
//    }
//    
//    //LEFT swipe
//    if ([swipeDirection isEqualToString:@"Left"]) {
//        for (int row = 0; row < NumRows ; row++) {
//            for (int column = 1; column <= NumColumns - 2; column++) {
//                BBQTile *tileA = [self.level tileAtColumn:column row:row];
//                if (tileA != nil) {
//                    BBQCookie *cookieA = [self.level cookieAtColumn:column row:row];
//                    BBQTile *tileB = [self.level tileAtColumn:column - 1 row:row];
//                    if (tileB != nil && cookieA != nil) {
//                        BBQCookie *cookieB = [self.level cookieAtColumn:column - 1 row:row];
//                        [self tryCombineCookieA:cookieA withCookieB:cookieB animations:animationsToPerform swipeDirection:@"Left"];
//                        
//                    }
//                }
//            }
//        }
//    }
//
//    //RIGHT swipe
//    if ([swipeDirection isEqualToString:@"Right"]) {
//        for (int row = 0; row < NumRows ; row++) {
//            for (int column = NumColumns - 2; column >= 0; column--) {
//                BBQTile *tileA = [self.level tileAtColumn:column row:row];
//                if (tileA != nil) {
//                    BBQCookie *cookieA = [self.level cookieAtColumn:column row:row];
//                    BBQTile *tileB = [self.level tileAtColumn:column + 1 row:row];
//                    if (tileB != nil && cookieA != nil) {
//                        BBQCookie *cookieB = [self.level cookieAtColumn:column + 1 row:row];
//                        [self tryCombineCookieA:cookieA withCookieB:cookieB animations:animationsToPerform swipeDirection:@"Right"];
//                        
//                    }
//                }
//            }
//        }
//    }
    

- (void)tryCombineCookieA:(BBQCookie *)cookieA withCookieB:(BBQCookie *)cookieB animations:(NSDictionary *)animations swipeDirection:(NSString *)direction {
    
    if (cookieA.cookieType == cookieB.cookieType) {
        NSLog(@"combining cookie A: %@ with cookie B: %@", cookieA, cookieB);
        
        //create the combo object
        BBQCombo *combo = [[BBQCombo alloc] initWithCookieA:(BBQCookie *)cookieA cookieB:(BBQCookie *)cookieB];
        NSMutableArray *combos = animations[COMBOS];
        [combos addObject:combo];
        
        //Perform the combo model logic
        NSInteger columnA = combo.cookieA.column;
        NSInteger rowA = combo.cookieA.row;
        
        combo.cookieB.cookieType = combo.cookieB.cookieType + 1;
        
        [self.level replaceCookieAtColumn:columnA row:rowA withCookie:nil];
    }
}

//- (NSMutableArray *)performCombo:(BBQCombo *)combo swipeDirection:(NSString *)direction {
//    
//    NSMutableArray *cookieMovements = [@[] mutableCopy];
//    NSInteger columnA = combo.cookieA.column;
//    NSInteger rowA = combo.cookieA.row;
//    
//    //upgrade cookie B
//    combo.cookieB.cookieType = combo.cookieB.cookieType + 1;
//    
//    //Get cookie A's position, then set the cookie to nil
//    CGPoint destination = combo.cookieA.sprite.position;
//    [self.level replaceCookieAtColumn:columnA row:rowA withCookie:nil];
//    
//    //Move the rest of the cookies
//    for (int row = combo.cookieB.row; row >= 0; row --) {
//        BBQCookie *topCookie = [self.level cookieAtColumn:combo.cookieB.column row:row];
//        BBQCookie *bottomCookie = [self.level cookieAtColumn:combo.cookieB.column row:row - 1];
//        BBQTile *bottomTile = [self.level tileAtColumn:combo.cookieB.column row:row - 1];
//        if (bottomCookie == nil && bottomTile != nil) {
//            BBQMoveCookie *cookieMovement = [self moveASingleCookie:topCookie direction:direction];
//            [cookieMovements addObject:cookieMovement];
//        }
//    }
//    
//    
//    BBQMoveCookie *cookieMovement = [self moveASingleCookie:combo.cookieB direction:direction];
//    [cookieMovements addObject:cookieMovement];
//    
//    
//    //UP Swipe
//    if ([direction isEqualToString:@"Up"]) {
//        
//        //Move all cookies in that column up one row
//        for (int row = rowA - 1; row >= 0; row -- ) {
//            BBQCookie *cookieA = [self.level cookieAtColumn:columnA row:row];
//            if ([self.level tileAtColumn:columnA row:row + 1] != nil && [self.level cookieAtColumn:columnA row:row + 1] == nil) {
//                NSLog(@"destination: %@", NSStringFromCGPoint(destination));
//                BBQMoveCookie *moveCookie = [[BBQMoveCookie alloc] initWithCookieA:cookieA destination:destination];
//                [cookieMovements addObject:moveCookie];
//                
//                cookieA.row = row + 1;
//                [self.level replaceCookieAtColumn:columnA row:row + 1 withCookie:cookieA];
//                [self.level replaceCookieAtColumn:columnA row:row withCookie:nil];
//            }
//            //move down one row
//            destination = cookieA.sprite.position;
//        }
//    }
//    
//    //DOWN Swipe
//    if ([direction isEqualToString:@"Down"]) {
//        //Move all cookies in column down one row
//        for (int row = rowA + 1; row < NumRows; row ++ ) {
//            BBQCookie *cookieA = [self.level cookieAtColumn:columnA row:row];
//            if ([self.level tileAtColumn:columnA row:row - 1] != nil && [self.level cookieAtColumn:columnA row:row - 1] == nil) {
//                NSLog(@"destination: %@", NSStringFromCGPoint(destination));
//                BBQMoveCookie *moveCookie = [[BBQMoveCookie alloc] initWithCookieA:cookieA destination:destination];
//                [cookieMovements addObject:moveCookie];
//                
//                cookieA.row = row - 1;
//                [self.level replaceCookieAtColumn:columnA row:row - 1 withCookie:cookieA];
//                [self.level replaceCookieAtColumn:columnA row:row withCookie:nil];
//            }
//            //move down one row
//            destination = cookieA.sprite.position;
//        }
//    }
//    
//    //LEFT Swipe
//    else if ([direction isEqualToString:@"Left"]) {
//        //Move all cookies in row one column to the left
//        for (int column = columnA + 1; column < NumColumns; column ++ ) {
//            BBQCookie *cookieA = [self.level cookieAtColumn:column row:rowA];
//            if ([self.level tileAtColumn:column - 1 row:rowA] != nil && [self.level cookieAtColumn:column - 1 row:rowA] == nil) {
//                NSLog(@"destination: %@", NSStringFromCGPoint(destination));
//                BBQMoveCookie *moveCookie = [[BBQMoveCookie alloc] initWithCookieA:cookieA destination:destination];
//                [cookieMovements addObject:moveCookie];
//                
//                cookieA.column = column - 1;
//                [self.level replaceCookieAtColumn:column - 1 row:rowA withCookie:cookieA];
//                [self.level replaceCookieAtColumn:column row:rowA withCookie:nil];
//            }
//            //move down one row
//            destination = cookieA.sprite.position;
//        }
//        
//    }
//    
//    //RIGHT Swipe
//    else if ([direction isEqualToString:@"Right"]) {
//        //Move all cookies in that row one column to the right
//        for (int column = columnA - 1; column >= 0; column -- ) {
//            BBQCookie *cookieA = [self.level cookieAtColumn:column row:rowA];
//            if ([self.level tileAtColumn:column + 1 row:rowA] != nil && [self.level cookieAtColumn:column + 1 row:rowA] == nil) {
//                NSLog(@"destination: %@", NSStringFromCGPoint(destination));
//                BBQMoveCookie *moveCookie = [[BBQMoveCookie alloc] initWithCookieA:cookieA destination:destination];
//                [cookieMovements addObject:moveCookie];
//                
//                cookieA.column = column + 1;
//                [self.level replaceCookieAtColumn:column + 1 row:rowA withCookie:cookieA];
//                [self.level replaceCookieAtColumn:column row:rowA withCookie:nil];
//            }
//            //move down one row
//            destination = cookieA.sprite.position;
//        }
//        
//    }
//    
//    return cookieMovements;
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
            NSLog(@"Cookie at rowB - x + 1: %@", [self.level cookieAtColumn:columnB row:rowB - x + 1]);
        }
    }
    
    return moveCookie;

}

- (NSMutableArray *)eatCookies {
    
    NSMutableArray *eatenCookies = [@[] mutableCopy];
    
    for (NSInteger row = 0; row < NumRows; row ++) {
        for (NSInteger column = 0; column < NumColumns; column++) {
            BBQTile *tile = [self.level tileAtColumn:column row:row];
            BBQCookie *cookie = [self.level cookieAtColumn:column row:row];
            if (tile.tileType == 2 && cookie != nil) {
                cookie.status = 2;
                [eatenCookies addObject:cookie];
                [self.level replaceCookieAtColumn:column row:row withCookie:nil];
            }
        }
    }
    return eatenCookies;
}






@end
