//
//  MMDevice.m
//  MMLanScanDemo
//
//  Created by Michalis Mavris on 08/07/2017.
//  Copyright © 2017 Miksoft. All rights reserved.
//

#import "MMDevice.h"

@implementation MMDevice
-(BOOL)isEqual:(id)object {
    return ([object isKindOfClass:[MMDevice class]] && [[object ipAddress] isEqualToString:_ipAddress]);
}


- (NSUInteger)hash {
    return [self.ipAddress hash];
}

-(NSString*)macAddressLabel {
    
    if (_macAddress) {
        return _macAddress;
    }
    
    return @"N/A";
}

-(NSString*)brand {
    
    if(_brand==nil || _brand == NULL || _brand==(id)[NSNull null]){
        return @"";
    }
    
    return _brand;
}

- (NSString *)category
{
    if (!self.hostname) return nil;
    NSString *host = [self.hostname lowercaseString];
    
    if ([host rangeOfString:@"android"].location != NSNotFound) {
        return @"android";
    }else if ([host rangeOfString:@"windows"].location != NSNotFound) {
        return @"windows";
    }else if ([host rangeOfString:@"ubuntu"].location != NSNotFound ||
              [host rangeOfString:@"debian"].location != NSNotFound ||
              [host rangeOfString:@"fedora"].location != NSNotFound ||
              [host rangeOfString:@"linux"].location != NSNotFound) {
        return @"linux";
    }else if ([host rangeOfString:@"ipad"].location != NSNotFound) {
        return @"ipad";
    }else if ([host rangeOfString:@"iphone"].location != NSNotFound) {
        return @"iphone";
    }else if ([host rangeOfString:@"imac"].location != NSNotFound) {
        return @"imac";
    }else if ([host rangeOfString:@"macbook"].location != NSNotFound) {
        return @"macbook";
    }else if ([host rangeOfString:@"appletv"].location != NSNotFound ||
              [host rangeOfString:@"apple tv"].location != NSNotFound ||
              [host rangeOfString:@"apple-tv"].location != NSNotFound) {
        return @"appletv";
    }else if ([host rangeOfString:@"router"].location != NSNotFound) {
        return @"router";
    }else if ([host rangeOfString:@"modem"].location != NSNotFound) {
        return @"modem";
    }else if ([host rangeOfString:@"pc-"].location != NSNotFound ||
              [host rangeOfString:@"-pc"].location != NSNotFound) {
        return @"computer";
    }else if ([host rangeOfString:@"ap-"].location != NSNotFound ||
              [host rangeOfString:@"-ap"].location != NSNotFound ||
              [host rangeOfString:@"access-point"].location != NSNotFound ||
              [host rangeOfString:@"accesspoint"].location != NSNotFound ||
              [host rangeOfString:@"access point"].location != NSNotFound) {
        return @"router";
    }else {
        return nil;
    }
}
        
@end
