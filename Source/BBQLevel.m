//
//  BBQLevel.m
//  BbqBlitz
//
//  Created by Nikki Durkin on 1/14/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "BBQLevel.h"
#import "BBQChain.h"

@interface BBQLevel ()

@property (strong, nonatomic) NSSet *possibleChains;

@end

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
    NSAssert1(column >= 0 && column < NumColumns, @"Invalid column: %ld", (long)column);
    NSAssert1(row >= 0 && row < NumRows, @"Invalid row: %ld", (long)row);

    _cookies[column][row] = cookie;
}


- (NSSet *)shuffle {
    NSSet *set;
    do {
        set = [self createCookiesInBlankTiles];
        [self detectPossibleChains];
        NSLog(@"possible chains: %@", self.possibleChains);
        NSLog(@"Number of chains: %lu", (unsigned long)[self.possibleChains count]);
    }
    while ([self.possibleChains count] == 0);
    
    return set;
}

- (void)detectPossibleChains {
    NSMutableSet *allChains;
    
    //Vertical Chains
    for (NSInteger column = 0; column < NumColumns; column ++) {
        for (NSInteger row = NumRows - 1; row >= 0; row --) {
            NSUInteger cookieType = _cookies[column][row].cookieType;
            
            if (cookieType > 0) {
                
                //Check for chains going down
                BBQChain *vertChain;
                for (NSInteger i = row - 1; i >= 0 && _cookies[column][i].cookieType == cookieType; i--) {
                    
                    if (!allChains) {
                        allChains = [NSMutableSet set];
                    }
                    
                    if (!vertChain) {
                        vertChain = [[BBQChain alloc] initWithColumn:column row:-1];
                        vertChain.cookiesInChain = [NSMutableArray array];
                        [allChains addObject:vertChain];
                        [vertChain.cookiesInChain addObject:_cookies[column][row]];
                    }
                    
                    [vertChain.cookiesInChain addObject:_cookies[column][i]];
                    
                    //subtract a row from the loop, because otherwise vertical chains of 3 or more are recorded twice
                    row --;
                }

            }
        }
    }
    
    //Horizontal Chains
    for (NSInteger row = 0; row < NumRows; row ++) {
        for (NSInteger column = 0; column < NumColumns; column++) {
            NSUInteger cookieType = _cookies[column][row].cookieType;
            
            if (cookieType > 0) {
                //Check for chains to the left
                BBQChain *horzChain;
                for (NSInteger i = column - 1; i >= 0 && _cookies[i][row].cookieType == cookieType; i--) {
                    
                    if (!allChains) {
                        allChains = [NSMutableSet set];
                    }
                    
                    if (!horzChain) {
                        horzChain = [[BBQChain alloc] initWithColumn:-1 row:row];
                        horzChain.cookiesInChain = [NSMutableArray array];
                        [allChains addObject:horzChain];
                        [horzChain.cookiesInChain addObject:_cookies[column][row]];
                    }
                    
                    [horzChain.cookiesInChain addObject:_cookies[i][row]];
                    
                    column++;
                }
            }
        }
    }
        
    self.possibleChains = [allChains copy];
}

- (NSSet *)createCookiesInBlankTiles {
    NSMutableSet *set = [NSMutableSet set];
    
    //loop through rows and columns
    for (NSInteger row = 0; row < NumRows; row++) {
        for (NSInteger column = 0; column < NumColumns; column++) {
            BBQTile *tile = _tiles[column][row];
            if (_cookies[column][row] == nil && tile.requiresACookie == YES) {
                
                NSUInteger cookieType;
                switch (tile.tileType) {
                    case 7:
                        cookieType = 10;
                        tile.tileType = 1;
                        break;
                        
                    case 8:
                        cookieType = 11;
                        tile.tileType = 1;
                        break;
                        
                    default:
                        cookieType = arc4random_uniform(NumStartingCookies) + 1;
                        break;
                }
                
                BBQCookie *cookie = [self createCookieAtColumn:column row:row withType:cookieType];
                
                if (tile.isABlocker) {
                    cookie.isInStaticTile = YES;
                }
                else cookie.isInStaticTile = NO;
                
                //Set countdown on security guard
                if (cookie.cookieType == 10) {
                    if (!self.securityGuardCookies) {
                        self.securityGuardCookies = [@[] mutableCopy];
                    }
                    
                    cookie.countdown = self.securityGuardCountdown;
                    [self.securityGuardCookies addObject:cookie];
                }
                
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

- (NSArray *)fillHoles {
    NSMutableArray *columns = [NSMutableArray array];
    
    for (NSInteger column = 0; column < NumColumns; column ++) {
        NSMutableArray *array;
        
        for (NSInteger row = 0; row < NumRows; row++) {
            
            BBQTile *tile = _tiles[column][row];
            if (tile.tileType != 0 && _cookies[column][row] == nil) {
                for (NSInteger lookup = row + 1; lookup < NumRows; lookup ++) {
                    BBQCookie *cookie = _cookies[column][lookup];
                    
                    if (cookie != nil) {
                        _cookies[column][lookup] = nil;
                        _cookies[column][row] = cookie;
                        cookie.row = row;
                        
                        if (!array) {
                            array = [NSMutableArray array];
                            [columns addObject:array];
                        }
                        [array addObject:cookie];
                        
                        break;
                    }
                    
                }
            }
        }
    }
    return columns;
}

- (NSArray *)topUpCookies {
    NSMutableArray *columns = [NSMutableArray array];
    NSUInteger cookieType = 0;
    
    for (NSInteger column = 0; column < NumColumns; column++) {
        NSMutableArray *array;
        for (NSInteger row = NumRows - 1; row >= 0 && _cookies[column][row] == nil; row--) {
            BBQTile *tile = _tiles[column][row];
            if (tile.tileType != 0) {
                NSUInteger newCookieType;
                do {
                    newCookieType = arc4random_uniform(NumStartingCookies) + 1;
                }
                while (newCookieType == cookieType);
                cookieType = newCookieType;
                
                BBQCookie *cookie = [self createCookieAtColumn:column row:row withType:cookieType];
                
                if (!array) {
                    array = [NSMutableArray array];
                    [columns addObject:array];
                }
                [array addObject:cookie];
            }
        }
    }
    return columns;
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
                
                //create a tile object depending on the type of tile
                if ([value integerValue] == 0) {
                    _tiles[column][tileRow] = [[BBQTile alloc] initWithTileType:0 column:column row:tileRow];
                }
                
                else if ([value integerValue] == 1) {
                    _tiles[column][tileRow] = [[BBQTile alloc] initWithTileType:1 column:column row:tileRow];
                }
                
                else if ([value integerValue] == 2) {
                    _tiles[column][tileRow] = [[BBQTile alloc] initWithTileType:2 column:column row:tileRow];
                }
                
                else if ([value integerValue] == 3) {
                    _tiles[column][tileRow] = [[BBQTile alloc] initWithTileType:3 column:column row:tileRow];
                }
                
                else if ([value integerValue] == 4) {
                    _tiles[column][tileRow] = [[BBQTile alloc] initWithTileType:4 column:column row:tileRow];
                    if (!self.goldenGooseTiles) {
                        self.goldenGooseTiles = [@[] mutableCopy];
                    }
                    
                    [self.goldenGooseTiles addObject:[self tileAtColumn:column row:tileRow]];
                }
                
                else if ([value integerValue] == 5) {
                    _tiles[column][tileRow] = [[BBQTile alloc] initWithTileType:5 column:column row:tileRow];
                }
                
                else if ([value integerValue] == 6) {
                    _tiles[column][tileRow] = [[BBQTile alloc] initWithTileType:6 column:column row:tileRow];
                    if (!self.steelBlockerFactoryTiles) {
                        self.steelBlockerFactoryTiles = [@[] mutableCopy];
                    }
                    [self.steelBlockerFactoryTiles addObject:[self tileAtColumn:column row:tileRow]];
                }
                
                else if ([value integerValue] == 7) {
                    _tiles[column][tileRow] = [[BBQTile alloc] initWithTileType:7 column:column row:tileRow];
                }
                
                else if ([value integerValue] == 8) {
                    _tiles[column][tileRow] = [[BBQTile alloc] initWithTileType:8 column:column row:tileRow];
                }
                
            }];
        }];
        
        self.targetScore = [dictionary[@"targetScore"] unsignedIntegerValue];
        self.maximumMoves = [dictionary[@"moves"] unsignedIntegerValue];
        if (dictionary[@"securityGuardCountdown"]) {
            self.securityGuardCountdown = [dictionary[@"securityGuardCountdown"] unsignedIntegerValue];
        }
    }
    return self;
}

- (BBQTile *)tileAtColumn:(NSInteger)column row:(NSInteger)row {
    NSAssert1(column >= 0 && column < NumColumns, @"Invalid column: %ld", (long)column);
    NSAssert1(row >= 0 && row < NumRows, @"Invalid row: %ld", (long)row);
    
    return _tiles[column][row];
}






@end
