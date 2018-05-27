//
//  MMIPGenerator.m
//  MacApp
//
//  Created by Fausto Ristagno on 21/04/18.
//  Copyright © 2018 Fausto Ristagno. All rights reserved.
//

#import "RRIPGenerator.h"
#include <arpa/inet.h>

@interface RRIPGenerator ()
{
    in_addr_t _ip_bin;
    in_addr_t _nm_bin;
    in_addr_t _min_ip;
    in_addr_t _max_ip;
}

@property (nonatomic, strong) NSString *ip;
@property (nonatomic, strong) NSString *netmask;
@property (nonatomic, assign) NSUInteger bunchSize;
@property (nonatomic, assign) NSUInteger currentBunch;
@property (nonatomic, assign) BOOL skipIdAndBroadcastIPs;

@property (nonatomic, strong) NSMutableArray *ips;

@end

@implementation RRIPGenerator

- (instancetype)initWithIP:(NSString *)ip subnetMask:(NSString *)netmask
{
    return [self initWithIP:ip subnetMask:netmask bunchSize: 256];
}

- (instancetype)initWithIP:(NSString *)ip subnetMask:(NSString *)netmask bunchSize:(NSUInteger)bunchSize
{
    if (self = [super init]) {
        self.ip = ip;
        self.netmask = netmask;
        self.bunchSize = bunchSize;
        self.currentBunch = 0;
        self.ips = [NSMutableArray arrayWithCapacity:self.bunchSize];
        self.skipIdAndBroadcastIPs = YES;
        
        // IP Binary
        struct in_addr ip_sa;
        int res = inet_pton(AF_INET, [self.ip cStringUsingEncoding:NSASCIIStringEncoding], &(ip_sa));
        if (res != 1) {
            return nil;
        }
        _ip_bin = ntohl(ip_sa.s_addr);
        
        // Netmask binary
        struct in_addr nm_sa;
        res = inet_pton(AF_INET, [self.netmask cStringUsingEncoding:NSASCIIStringEncoding], &(nm_sa));
        if (res != 1) {
            return nil;
        }
        _nm_bin = ntohl(nm_sa.s_addr);
        
        // Min IP
        _min_ip = (_ip_bin & _nm_bin);
        
        // Max IP
        _max_ip = _min_ip + (0xFFFFFFFF - _nm_bin); // Base IP + Max Offset
    }
    return self;
}

- (NSArray<NSString *> *)nextBunch
{
    if (![self hasMore]) {
        return nil;
    }
    
    [self.ips removeAllObjects];
    
    struct in_addr ip_sa;
    in_addr_t offset;
    in_addr_t next_ip;
    char addr[INET_ADDRSTRLEN];
    
    for (NSUInteger i = 0; i < self.bunchSize; ++i) {
        offset = (in_addr_t)((self.currentBunch * self.bunchSize) + i);
        if (((uint64_t)_nm_bin + (uint64_t)offset) <= 0xFFFFFFFF) {
            next_ip = _min_ip + offset;
            
            if (self.skipIdAndBroadcastIPs && (next_ip == _min_ip || next_ip == _max_ip)) {
                // Salto IP xxx.xxx.xxx.0 e xxx.xxx.xxx.255
                continue;
            }
            
            ip_sa.s_addr = htonl(next_ip);
            
            inet_ntop(AF_INET, &ip_sa, addr, INET_ADDRSTRLEN);
            
            [self.ips addObject:[NSString stringWithFormat:@"%s", addr]];
        }
    }
    
    self.currentBunch++;
    
    return self.ips;
}

- (void)rewind
{
    self.currentBunch = 0;
}

- (BOOL)hasMore
{
    uint64_t offset = self.currentBunch * self.bunchSize;
    return (((uint64_t)_nm_bin + offset) <= 0xFFFFFFFF);
}

- (NSUInteger)ipsCount
{
    uint32_t allIPs = (0xFFFFFFFF - _nm_bin) + 1;
    if (self.skipIdAndBroadcastIPs) {
        return allIPs - 2;
    }else {
        return allIPs;
    }
}

- (NSString *)convertBinIpToString:(in_addr_t)ip
{
    char addr[INET_ADDRSTRLEN];
    struct in_addr ip_sa;
    
    ip_sa.s_addr = htonl(ip);
    inet_ntop(AF_INET, &ip_sa, addr, INET_ADDRSTRLEN);
    
    return [NSString stringWithFormat:@"%s", addr];
}

- (NSString *)minIp
{
    return [self convertBinIpToString: _min_ip + (self.skipIdAndBroadcastIPs ? 1 : 0)];
}

- (NSString *)maxIp
{
    return [self convertBinIpToString: _max_ip - (self.skipIdAndBroadcastIPs ? 1 : 0)];
}

@end
