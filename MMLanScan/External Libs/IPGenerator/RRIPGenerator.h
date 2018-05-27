//
//  RRIPGenerator.h
//  MacApp
//
//  Created by Fausto Ristagno on 21/04/18.
//  Copyright © 2018 Fausto Ristagno. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RRIPGenerator : NSObject

@property (nonatomic, readonly) NSString *ip;
@property (nonatomic, readonly) NSString *netmask;
@property (nonatomic, readonly) NSUInteger bunchSize;
@property (nonatomic, readonly) NSUInteger currentBunch;
@property (nonatomic, readonly) NSUInteger ipsCount;
@property (nonatomic, readonly) BOOL hasMore;
@property (nonatomic, readonly) BOOL skipIdAndBroadcastIPs;

- (instancetype)initWithIP:(NSString *)ip subnetMask:(NSString *)netmask bunchSize:(NSUInteger)bunchSize;
- (instancetype)initWithIP:(NSString *)ip subnetMask:(NSString *)netmask;
- (NSArray<NSString *> *)nextBunch;
- (void)rewind;
- (NSString *)minIp;
- (NSString *)maxIp;

@end
