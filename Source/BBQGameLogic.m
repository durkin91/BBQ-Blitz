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
            //starts checking in first column, second row from the top
            for (int row = NumRows - 2; row >= 0; row--) {
                BBQTile *tileA = [self.level tileAtColumn:column row:row];
                if (tileA != nil) {
                    BBQCookie *cookieA = [self.level cookieAtColumn:column row:row];
                    BBQTile *tileB = [self.level tileAtColumn:column row:row + 1];
                    if (tileB != nil && cookieA != nil) {
                        BBQCookie *cookieB = [self.level cookieAtColumn:column row:row + 1];
                        [self tryCombineCookieA:cookieA withCookieB:cookieB column:column row:row animations:animationsToPerform swipeDirection:@"Up"];
                        
                    }
                }
            }
        }
    }
    
    //DOWN swipe
    if ([swipeDirection isEqualToString:@"Down"]) {
        for (int column = 0; column < NumColumns ; column++) {
            for (int row = 1; row <= NumRows - 2; row++) {
                BBQTile *tileA = [self.level tileAtColumn:column row:row];
                if (tileA != nil) {
                    BBQCookie *cookieA = [self.level cookieAtColumn:column row:row];
                    BBQTile *tileB = [self.level tileAtColumn:column row:row - 1];
                    if (tileB != nil && cookieA != nil) {
                        BBQCookie *cookieB = [self.level cookieAtColumn:column row:row - 1];
                        [self tryCombineCookieA:cookieA withCookieB:cookieB column:column row:row animations:animationsToPerform swipeDirection:@"Down"];
                        
                    }
                }
            }
        }
    }
    
    //LEFT swipe
    if ([swipeDirection isEqualToString:@"Left"]) {
        for (int row = 0; row < NumRows ; row++) {
            for (int column = 1; column <= NumColumns - 2; column++) {
                BBQTile *tileA = [self.level tileAtColumn:column row:row];
                if (tileA != nil) {
                    BBQCookie *cookieA = [self.level cookieAtColumn:column row:row];
                    BBQTile *tileB = [self.level tileAtColumn:column - 1 row:row];
                    if (tileB != nil && cookieA != nil) {
                        BBQCookie *cookieB = [self.level cookieAtColumn:column - 1 row:row];
                        [self tryCombineCookieA:cookieA withCookieB:cookieB column:column row:row animations:animationsToPerform swipeDirection:@"Left"];
                        
                    }
                }
            }
        }
    }

    //RIGHT swipe
    if ([swipeDirection isEqualToString:@"Right"]) {
        for (int row = 0; row < NumRows ; row++) {
            for (int column = NumColumns - 2; column >= 0; column--) {
                BBQTile *tileA = [self.level tileAtColumn:column row:row];
                if (tileA != nil) {
                    BBQCookie *cookieA = [self.level cookieAtColumn:column row:row];
                    BBQTile *tileB = [self.level tileAtColumn:column + 1 row:row];
                    if (tileB != nil && cookieA != nil) {
                        BBQCookie *cookieB = [self.level cookieAtColumn:column + 1 row:row];
                        [self tryCombineCookieA:cookieA withCookieB:cookieB column:column row:row animations:animationsToPerform swipeDirection:@"Right"];
                        
                    }
                }
            }
        }
    }
    
    NSLog(@"Animations to perform: %@", animationsToPerform);
    return animationsToPerform;
}

- (void)tryCombineCookieA:(BBQCookie *)cookieA withCookieB:(BBQCookie *)cookieB column:(int)column row:(int)row animations:(NSDictionary *)animations swipeDirection:(NSString *)direction {
    
    if (cookieA.cookieType == cookieB.cookieType) {
        NSLog(@"combining cookie A: %@ with cookie B: %@", cookieA, cookieB);
        
        //create the combo object
        BBQCombo *combo = [[BBQCombo alloc] initWithCookieA:(BBQCookie *)cookieA cookieB:(BBQCookie *)cookieB];
        NSMutableArray *combos = animations[COMBOS];
        [combos addObject:combo];
        
        //Perform combo will return the cookie movements that resulted from the combo.
        NSMutableArray *cookieMovements = [self performCombo:combo swipeDirection:direction];
        [animations[MOVEMENTS] addObjectsFromArray:cookieMovements];
    }
}

- (NSMutableArray *)performCombo:(BBQCombo *)combo swipeDirection:(NSString *)direction {
    
    NSMutableArray *cookieMovements = [@[] mutableCopy];
    NSInteger columnA = combo.cookieA.column;
    NSInteger rowA = combo.cookieA.row;
    
    //upgrade cookie B
    combo.cookieB.cookieType = combo.cookieB.cookieType + 1;
    
    //Get cookie A's position, then set the cookie to nil
    CGPoint destination = combo.cookieA.sprite.position;
    [self.level replaceCookieAtColumn:columnA row:rowA withCookie:nil];
    
    //UP Swipe
    if ([direction isEqualToString:@"Up"]) {
        
        //Move all cookies in that column up one row
        for (int row = rowA - 1; row >= 0; row -- ) {
            BBQCookie *cookieA = [self.level cookieAtColumn:columnA row:row];
            if ([self.level tileAtColumn:columnA row:row + 1] != nil && [self.level cookieAtColumn:columnA row:row + 1] == nil) {
                NSLog(@"destination: %@", NSStringFromCGPoint(destination));
                BBQMoveCookie *moveCookie = [[BBQMoveCookie alloc] initWithCookieA:cookieA destination:destination];
                [cookieMovements addObject:moveCookie];
                
                cookieA.row = row + 1;
                [self.level replaceCookieAtColumn:columnA row:row + 1 withCookie:cookieA];
                [self.level replaceCookieAtColumn:columnA row:row withCookie:nil];
            }
            //move down one row
            destination = cookieA.sprite.position;
        }
    }
    
    //DOWN Swipe
    if ([direction isEqualToString:@"Down"]) {
        //Move all cookies in column down one row
        for (int row = rowA + 1; row < NumRows; row ++ ) {
            BBQCookie *cookieA = [self.level cookieAtColumn:columnA row:row];
            if ([self.level tileAtColumn:columnA row:row - 1] != nil && [self.level cookieAtColumn:columnA row:row - 1] == nil) {
                NSLog(@"destination: %@", NSStringFromCGPoint(destination));
                BBQMoveCookie *moveCookie = [[BBQMoveCookie alloc] initWithCookieA:cookieA destination:destination];
                [cookieMovements addObject:moveCookie];
                
                cookieA.row = row - 1;
                [self.level replaceCookieAtColumn:columnA row:row - 1 withCookie:cookieA];
                [self.level replaceCookieAtColumn:columnA row:row withCookie:nil];
            }
            //move down one row
            destination = cookieA.sprite.position;
        }
    }
    
    //LEFT Swipe
    else if ([direction isEqualToString:@"Left"]) {
        //Move all cookies in row one column to the left
        for (int column = columnA + 1; column < NumColumns; column ++ ) {
            BBQCookie *cookieA = [self.level cookieAtColumn:column row:rowA];
            if ([self.level tileAtColumn:column - 1 row:rowA] != nil && [self.level cookieAtColumn:column - 1 row:rowA] == nil) {
                NSLog(@"destination: %@", NSStringFromCGPoint(destination));
                BBQMoveCookie *moveCookie = [[BBQMoveCookie alloc] initWithCookieA:cookieA destination:destination];
                [cookieMovements addObject:moveCookie];
                
                cookieA.column = column - 1;
                [self.level replaceCookieAtColumn:column - 1 row:rowA withCookie:cookieA];
                [self.level replaceCookieAtColumn:column row:rowA withCookie:nil];
            }
            //move down one row
            destination = cookieA.sprite.position;
        }
        
    }
    
    //RIGHT Swipe
    else if ([direction isEqualToString:@"Right"]) {
        //Move all cookies in that row one column to the right
        for (int column = columnA - 1; column >= 0; column -- ) {
            BBQCookie *cookieA = [self.level cookieAtColumn:column row:rowA];
            if ([self.level tileAtColumn:column + 1 row:rowA] != nil && [self.level cookieAtColumn:column + 1 row:rowA] == nil) {
                NSLog(@"destination: %@", NSStringFromCGPoint(destination));
                BBQMoveCookie *moveCookie = [[BBQMoveCookie alloc] initWithCookieA:cookieA destination:destination];
                [cookieMovements addObject:moveCookie];
                
                cookieA.column = column + 1;
                [self.level replaceCookieAtColumn:column + 1 row:rowA withCookie:cookieA];
                [self.level replaceCookieAtColumn:column row:rowA withCookie:nil];
            }
            //move down one row
            destination = cookieA.sprite.position;
        }
        
    }
    
    return cookieMovements;
}

- (NSMutableArray *)eatCookies {
    
    NSMutableArray *eatenCookies = [@[] mutableCopy];
    
    for (NSInteger row = 0; row < NumRows; row ++) {
        for (NSInteger column = 0; column < NumColumns; column++) {
            BBQTile *tile = [self.level tileAtColumn:column row:row];
            if (tile.tileType == 2) {
                BBQCookie *cookie = [self.level cookieAtColumn:column row:row];
                cookie.status = 2;
                [eatenCookies addObject:cookie];
                [self.level replaceCookieAtColumn:column row:row withCookie:nil];
            }
        }
    }
    return eatenCookies;
}






@end
