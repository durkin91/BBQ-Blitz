//
//  BBQTileObstacle.m
//  BbqBlitz
//
//  Created by Nikki Durkin on 4/20/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "BBQTileObstacle.h"

@implementation BBQTileObstacle

- (instancetype)initWithType:(NSString *)type column:(NSInteger)column row:(NSInteger)row {
    self = [super init];
    if (self) {
        self.type = type;
        self.column = column;
        self.row = row;
        
        [self setupProperties];
    }
    return self;
}

- (NSString *)spriteName {
    NSString *spriteName;
    if ([_type isEqualToString:GOLD_PLATED_TILE]) {
        spriteName = @"GoldPlatedTile";
    }
    
    else if ([_type isEqualToString:SILVER_PLATED_TILE]) {
        spriteName = @"SilverPlatedTile";
    }
    
    else if ([_type isEqualToString:WAD_OF_CASH_ONE]) {
        spriteName = @"WadOfCashOne";
    }
    
    else if ([_type isEqualToString:WAD_OF_CASH_TWO]) {
        spriteName = @"WadOfCashTwo";
    }
    
    else if ([_type isEqualToString:WAD_OF_CASH_THREE]) {
        spriteName = @"WadOfCashThree";
    }
    
    return spriteName;
 }

- (NSString *)spriteNameForPurposesOfCookieOrderCollection {
    NSString *spriteName;
    if ([_type isEqualToString:GOLD_PLATED_TILE] || [_type isEqualToString:SILVER_PLATED_TILE]) {
        spriteName = @"GoldPlatedTile";
    }
    else if ([_type isEqualToString:WAD_OF_CASH_ONE] || [_type isEqualToString:WAD_OF_CASH_TWO] || [_type isEqualToString:WAD_OF_CASH_THREE]) {
        spriteName = @"WadOfCashOne";
    }
    return spriteName;
}

-(void)setupProperties {
    
    if ([_type isEqualToString:GOLD_PLATED_TILE] || [_type isEqualToString:SILVER_PLATED_TILE]) {
        _isABlocker = NO;
        _requiresACookie = YES;
        _zOrder = 1;
        _detonatesWhenAdjacentToCookie = NO;
    }
    
    else if ([_type isEqualToString:WAD_OF_CASH_ONE] || [_type isEqualToString:WAD_OF_CASH_TWO] || [_type isEqualToString:WAD_OF_CASH_THREE]) {
        _isABlocker = YES;
        _requiresACookie = NO;
        _zOrder = 2;
        _detonatesWhenAdjacentToCookie = YES;
    }
}

- (void)addOrderToObstacle:(NSArray *)cookieOrders {
    //find the right order
    for (BBQCookieOrder *cookieOrder in cookieOrders) {
        NSInteger x = 0;
        if ([cookieOrder.obstacle.type isEqualToString:[self typeForPurposesOfOrderCollection]] && cookieOrder.quantityLeft > 0) {
            self.cookieOrder = cookieOrder;
            x++;
        }
        cookieOrder.quantityLeft = cookieOrder.quantityLeft - x;
        cookieOrder.quantityLeft = MAX(0, cookieOrder.quantityLeft);
    }
}

- (NSString *)typeForPurposesOfOrderCollection {
    NSString *newType;
    if ([self.type isEqualToString:GOLD_PLATED_TILE] || [self.type isEqualToString:SILVER_PLATED_TILE]) {
        newType = GOLD_PLATED_TILE;
    }
    
    else if ([_type isEqualToString:WAD_OF_CASH_ONE] || [_type isEqualToString:WAD_OF_CASH_TWO] ||[_type isEqualToString:WAD_OF_CASH_THREE]) {
        newType = WAD_OF_CASH_ONE;
    }
    return newType;
}

@end
