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
    
    return spriteName;
}

- (NSString *)highlightedSpriteName {
    
    NSString *spriteName = [NSString stringWithFormat:@"%@-Highlighted", [self spriteName]];
    return spriteName;
}

- (CCColor *)lineColor {
    CCColor *color;
    
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


- (NSString *)description {
    return [NSString stringWithFormat:@"type:%ld square:(%ld, %ld)", (long)self.cookieType, (long)self.column, (long)self.row];
}



@end
