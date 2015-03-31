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


- (NSString *)description {
    return [NSString stringWithFormat:@"type:%ld square:(%ld, %ld)", (long)self.cookieType, (long)self.column, (long)self.row];
}



@end
