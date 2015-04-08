//
//  BBQCookie.m
//  BbqBlitz
//
//  Created by Nikki Durkin on 1/14/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "BBQCookie.h"

@implementation BBQCookie

- (NSString *)spriteNameBase {
    NSString *spriteName;
    
    switch (self.cookieType) {
        case 1:
            spriteName = @"Croissant";
            break;
            
        case 2:
            spriteName = @"Cupcake";
            break;
            
        case 3:
            spriteName = @"Danish";
            break;
            
        case 4:
            spriteName = @"Donut";
            break;
            
        case 5:
            spriteName = @"Macaroon";
            break;
            
        case 6:
            spriteName = @"SugarCookie";
            break;
            
        default:
            break;
    }
    
    return spriteName;
    
}

- (NSString *)spriteName {
    NSString *spriteName;
    
    if (self.powerup == nil) {
        spriteName = [self spriteNameBase];
    }
    
    else if (self.powerup && self.powerup.type == 6) {
        spriteName = [NSString stringWithFormat:@"%@%@", [self spriteNameBase], self.powerup.direction];
    }
    
    else if (self.powerup && self.powerup.type == 9) {
        spriteName = @"PivotPad";
    }
    
    else if (self.powerup && self.powerup.type == 12) {
        spriteName = @"MultiCookie";
    }
    
    else if (self.powerup && self.powerup.type == 15) {
        spriteName = @"RobbersSack";
    }
    
    else if (self.powerup && self.powerup.type == 20) {
        spriteName = [NSString stringWithFormat:@"%@CrissCross", [self spriteNameBase]];
    }
    
    return spriteName;
}

- (NSString *)highlightedSpriteName {
    
    NSString *spriteName = [NSString stringWithFormat:@"%@-Highlighted", [self spriteName]];
    return spriteName;
}

- (CCColor *)lineColor {
    CCColor *color;
    
    //Take care of pivot pad color
    if (self.powerup.type == 9) {
        color = [CCColor blackColor];
        return color;
    }
    
    switch (_cookieType) {
        case 1:
            color = [CCColor colorWithRed:255.0/255.0 green:166.0/255.0 blue:0];
            break;
            
        case 2:
            color = [CCColor colorWithRed:217/255.0 green:55/255.0 blue:63/255.0];
            break;
            
        case 3:
            color = [CCColor colorWithRed:41/255.0 green:186/255.0 blue:248/255.0];
            break;
            
        case 4:
            color = [CCColor colorWithRed:248/255.0 green:97/255.0 blue:193/255.0];
            break;
            
        case 5:
            color = [CCColor colorWithRed:50/255.0 green:150/255.0 blue:77/255.0];
            break;
            
        case 6:
            color = [CCColor colorWithRed:226/255.0 green:217/255.0 blue:93/255.0];
            break;
            
        default:
            break;
    }
    
    return color;
}

- (BOOL)canBeChainedToCookie:(BBQCookie *)potentialCookie {
    if ([self.powerup canOnlyJoinWithCookieNextToIt] &&
        self.powerup.isCurrentlyTemporary == NO &&
        (potentialCookie.column == self.column + 1 || potentialCookie.column == self.column - 1 || potentialCookie.row == self.row + 1 || potentialCookie.row == self.row - 1)) {
        return YES;
    }
    else if ([potentialCookie.powerup isAPivotPad] && potentialCookie.powerup.isCurrentlyTemporary == NO) {
        return YES;
    }
    else if (self.cookieType == potentialCookie.cookieType) {
        return YES;
    }
    else {
        return NO;
    }
}


- (NSString *)description {
    return [NSString stringWithFormat:@"type:%ld square:(%ld, %ld)", (long)self.cookieType, (long)self.column, (long)self.row];
}



@end
