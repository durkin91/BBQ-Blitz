//
//  BBQCookie.m
//  BbqBlitz
//
//  Created by Nikki Durkin on 1/14/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "BBQCookie.h"

@implementation BBQCookie

- (instancetype)init {
    self = [super init];
    if (self) {
        self.isFinalCookie = NO;
    }
    return self;
}

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
            
        case 10:
            spriteName = @"SecurityGuard";
            break;
            
        case 11:
            spriteName = @"Rope";
            break;
            
        default:
            break;
    }
    
    return spriteName;
    
}

- (NSString *)description {
    return [NSString stringWithFormat:@"type:%ld square:(%ld, %ld)", (long)self.cookieType, (long)self.column, (long)self.row];
}

- (void)setCookieType:(NSUInteger)cookieType {
    _cookieType = cookieType;
    
    if (_cookieType == 10 || _cookieType == 11) {
        self.isRopeOrSecurityGuard = YES;
    }
    
    else {
        self.isRopeOrSecurityGuard = NO;
    }
}


@end
