//
//  BBQLevel.m
//  BbqBlitz
//
//  Created by Nikki Durkin on 1/14/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "BBQLevel.h"


@implementation BBQLevel {
    BBQCookie *_cookies[NumColumns][NumRows];
    BBQTile *_tiles[NumColumns][NumRows];
}

- (BBQCookie *)cookieAtColumn:(NSInteger)column row:(NSInteger)row {
    NSAssert1(column >= 0 && column < NumColumns, @"Invalid column: %ld", (long)column);
    NSAssert1(row >= 0 && row < NumRows, @"Invalid row: %ld", (long)row);
    
    return _cookies[column][row];
}

- (void)replaceCookieAtColumn:(int)column row:(int)row withCookie:(BBQCookie *)cookie {
    _cookies[column][row] = cookie;
}

- (NSMutableArray *)performCombo:(BBQCombo *)combo swipeDirection:(NSString *)direction {
    
    NSMutableArray *cookieMovements = [@[] mutableCopy];
    NSInteger columnA = combo.cookieA.column;
    NSInteger rowA = combo.cookieA.row;
    
    //upgrade cookie B
    combo.cookieB.cookieType = combo.cookieB.cookieType + 1;
    
    //Get cookie A's position, then set the cookie to nil
    CGPoint destination = combo.cookieA.sprite.position;
    _cookies[columnA][rowA] = nil;
    
    //UP Swipe
    if ([direction isEqualToString:@"Up"]) {
        
        //Move all cookies in that column up one row
        for (int row = rowA - 1; row >= 0; row -- ) {
            BBQCookie *cookieA = _cookies[columnA][row];
            if ([self tileAtColumn:columnA row:row + 1] != nil && [self cookieAtColumn:columnA row:row + 1] == nil) {
                NSLog(@"destination: %@", NSStringFromCGPoint(destination));
                BBQMoveCookie *moveCookie = [[BBQMoveCookie alloc] initWithCookieA:cookieA destination:destination];
                [cookieMovements addObject:moveCookie];
                
                cookieA.row = row + 1;
                _cookies[columnA][row + 1] = cookieA;
                _cookies[columnA][row] = nil;
            }
            //move down one row
            destination = cookieA.sprite.position;
        }
    }
    
    //DOWN Swipe
    if ([direction isEqualToString:@"Down"]) {
        //Move all cookies in column down one row
        for (int row = rowA + 1; row < NumRows; row ++ ) {
            BBQCookie *cookieA = _cookies[columnA][row];
            if ([self tileAtColumn:columnA row:row - 1] != nil && [self cookieAtColumn:columnA row:row - 1] == nil) {
                NSLog(@"destination: %@", NSStringFromCGPoint(destination));
                BBQMoveCookie *moveCookie = [[BBQMoveCookie alloc] initWithCookieA:cookieA destination:destination];
                [cookieMovements addObject:moveCookie];
                
                cookieA.row = row - 1;
                _cookies[columnA][row - 1] = cookieA;
                _cookies[columnA][row] = nil;
            }
            //move down one row
            destination = cookieA.sprite.position;
        }
    }
    
    //LEFT Swipe
    else if ([direction isEqualToString:@"Left"]) {
        //Move all cookies in row one column to the left
        for (int column = columnA + 1; column < NumColumns; column ++ ) {
            BBQCookie *cookieA = _cookies[column][rowA];
            if ([self tileAtColumn:column - 1 row:rowA] != nil && [self cookieAtColumn:column - 1 row:rowA] == nil) {
                NSLog(@"destination: %@", NSStringFromCGPoint(destination));
                BBQMoveCookie *moveCookie = [[BBQMoveCookie alloc] initWithCookieA:cookieA destination:destination];
                [cookieMovements addObject:moveCookie];
                
                cookieA.column = column - 1;
                _cookies[column - 1][rowA] = cookieA;
                _cookies[column][rowA] = nil;
            }
            //move down one row
            destination = cookieA.sprite.position;
        }

    }
    
    //RIGHT Swipe
    else if ([direction isEqualToString:@"Right"]) {
        //Move all cookies in that row one column to the right
        for (int column = columnA - 1; column >= 0; column -- ) {
            BBQCookie *cookieA = _cookies[column][rowA];
            if ([self tileAtColumn:column + 1 row:rowA] != nil && [self cookieAtColumn:column + 1 row:rowA] == nil) {
                NSLog(@"destination: %@", NSStringFromCGPoint(destination));
                BBQMoveCookie *moveCookie = [[BBQMoveCookie alloc] initWithCookieA:cookieA destination:destination];
                [cookieMovements addObject:moveCookie];
                
                cookieA.column = column + 1;
                _cookies[column + 1][rowA] = cookieA;
                _cookies[column][rowA] = nil;
            }
            //move down one row
            destination = cookieA.sprite.position;
        }

    }
    
    return cookieMovements;
}

- (NSSet *)shuffle {
    return [self createInitialCookies];
}

- (NSSet *)createInitialCookies {
    NSMutableSet *set = [NSMutableSet set];
    
    //loop through rows and columns
    for (NSInteger row = 0; row < NumRows; row++) {
        for (NSInteger column = 0; column < NumColumns; column++) {
            
            if (_tiles[column][row] != nil) {
            
            //choose a random cookie number
            NSUInteger cookieType = arc4random_uniform(NumStartingCookies) + 1;
            
            BBQCookie *cookie = [self createCookieAtColumn:column row:row withType:cookieType];
            
            [set addObject:cookie];
            }
            
        }
    }
    
    return set;
}

- (BBQCookie *)createCookieAtColumn:(NSInteger)column row:(NSInteger)row withType:(NSUInteger)cookieType {
    BBQCookie *cookie = [[BBQCookie alloc] init];
    cookie.cookieType = cookieType;
    cookie.column = column;
    cookie.row = row;
    _cookies[column][row] = cookie;
    return cookie;
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
        
        //Loop through the rows
        [dictionary[@"tiles"] enumerateObjectsUsingBlock:^(NSArray *array, NSUInteger row, BOOL *stop) {
            
            //Loop through the columns in the current row
            [array enumerateObjectsUsingBlock:^(NSNumber *value, NSUInteger column, BOOL *stop) {
                
                //Note that in cocos (0,0) is at the bottom of the screen so we need to read this file upside down
                NSInteger tileRow = NumRows - row - 1;
                
                //if the value is 1, create a tile object
                if ([value integerValue] == 1) {
                    _tiles[column][tileRow] = [[BBQTile alloc] init];
                }
            }];
        }];
    }
    return self;
}

- (BBQTile *)tileAtColumn:(NSInteger)column row:(NSInteger)row {
    NSAssert1(column >= 0 && column < NumColumns, @"Invalid column: %ld", (long)column);
    NSAssert1(row >= 0 && row < NumRows, @"Invalid row: %ld", (long)row);
    
    return _tiles[column][row];
}





@end
