//
//  BBQCookie.m
//  BbqBlitz
//
//  Created by Nikki Durkin on 1/14/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "BBQCookie.h"

@implementation BBQCookie

- (NSString *)spriteName {
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

- (NSString *)highlightedSpriteName {
    NSString *spriteName;
    
    switch (self.cookieType) {
        case 1:
            spriteName = @"Croissant-Highlighted";
            break;
            
        case 2:
            spriteName = @"Cupcake-Highlighted";
            break;
            
        case 3:
            spriteName = @"Danish-Highlighted";
            break;
            
        case 4:
            spriteName = @"Donut-Highlighted";
            break;
            
        case 5:
            spriteName = @"Macaroon-Highlighted";
            break;
            
        case 6:
            spriteName = @"SugarCookie-Highlighted";
            break;
            
        default:
            break;
    }
    
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
