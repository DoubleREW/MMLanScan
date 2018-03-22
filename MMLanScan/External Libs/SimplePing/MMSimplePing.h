/*
    File:       SimplePing.h

    Contains:   Implements ping.

    Written by: DTS

    Copyright:  Copyright (c) 2010-2012 Apple Inc. All Rights Reserved.

    Disclaimer: IMPORTANT: This Apple software is supplied to you by Apple Inc.
                ("Apple") in consideration of your agreement to the following
                terms, and your use, installation, modification or
                redistribution of this Apple software constitutes acceptance of
                these terms.  If you do not agree with these terms, please do
                not use, install, modify or redistribute this Apple software.

                In consideration of your agreement to abide by the following
                terms, and subject to these terms, Apple grants you a personal,
                non-exclusive license, under Apple's copyrights in this
                original Apple software (the "Apple Software"), to use,
                reproduce, modify and redistribute the Apple Software, with or
                without modifications, in source and/or binary forms; provided
                that if you redistribute the Apple Software in its entirety and
                without modifications, you must retain this notice and the
                following text and disclaimers in all such redistributions of
                the Apple Software. Neither the name, trademarks, service marks
                or logos of Apple Inc. may be used to endorse or promote
                products derived from the Apple Software without specific prior
                written permission from Apple.  Except as expressly stated in
                this notice, no other rights or licenses, express or implied,
                are granted by Apple herein, including but not limited to any
                patent rights that may be infringed by your derivative works or
                by other works in which the Apple Software may be incorporated.

                The Apple Software is provided by Apple on an "AS IS" basis. 
                APPLE MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING
                WITHOUT LIMITATION THE IMPLIED WARRANTIES OF NON-INFRINGEMENT,
                MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE, REGARDING
                THE APPLE SOFTWARE OR ITS USE AND OPERATION ALONE OR IN
                COMBINATION WITH YOUR PRODUCTS.

                IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT,
                INCIDENTAL OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
                TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
                DATA, OR PROFITS; OR BUSINESS INTERRUPTION) ARISING IN ANY WAY
                OUT OF THE USE, REPRODUCTION, MODIFICATION AND/OR DISTRIBUTION
                OF THE APPLE SOFTWARE, HOWEVER CAUSED AND WHETHER UNDER THEORY
                OF CONTRACT, TORT (INCLUDING NEGLIGENCE), STRICT LIABILITY OR
                OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE POSSIBILITY OF
                SUCH DAMAGE.

*/

/*
RENAMED SYMBOLS:
SimplePing => MMSimplePing
SimplePingDelegate => MMSimplePingDelegate
ICMPHeader => MMICMPHeader
IPHeader => MMIPHeader
kICMPTypeEchoReply => kMMICMPTypeEchoReply
kICMPTypeEchoRequest => kMMICMPTypeEchoRequest
*/

#import <Foundation/Foundation.h>

#if TARGET_OS_EMBEDDED || TARGET_IPHONE_SIMULATOR
    #import <CFNetwork/CFNetwork.h>
#else
    #import <CoreServices/CoreServices.h>
#endif

#include <AssertMacros.h>

#pragma mark * SimplePing

// The SimplePing class is a very simple class that lets you send and receive pings.

@protocol MMSimplePingDelegate;

@interface MMSimplePing : NSObject

+ (MMSimplePing *)simplePingWithHostName:(NSString *)hostName;        // chooses first IPv4 address
+ (MMSimplePing *)simplePingWithHostAddress:(NSData *)hostAddress;    // contains (struct sockaddr)

@property (nonatomic, weak,   readwrite) id<MMSimplePingDelegate> delegate;

@property (nonatomic, copy,   readonly ) NSString *             hostName;
@property (nonatomic, copy,   readonly ) NSData *               hostAddress;
@property (nonatomic, assign, readonly ) uint16_t               identifier;
@property (nonatomic, assign, readonly ) uint16_t               nextSequenceNumber;

- (void)start;
    // Starts the pinger object pinging.  You should call this after 
    // you've setup the delegate and any ping parameters.

- (void)sendPingWithData:(NSData *)data;
    // Sends an actual ping.  Pass nil for data to use a standard 56 byte payload (resulting in a 
    // standard 64 byte ping).  Otherwise pass a non-nil value and it will be appended to the 
    // ICMP header.
    //
    // Do not try to send a ping before you receive the -simplePing:didStartWithAddress: delegate 
    // callback.

- (void)stop;
    // Stops the pinger object.  You should call this when you're done 
    // pinging.

+ (const struct MMICMPHeader *)icmpInPacket:(NSData *)packet;
    // Given a valid IP packet contains an ICMP , returns the address of the ICMP header that 
    // follows the IP header.  This doesn't do any significant validation of the packet.

@end

@protocol MMSimplePingDelegate <NSObject>

@optional

- (void)simplePing:(MMSimplePing *)pinger didStartWithAddress:(NSData *)address;
- (void)simplePing:(MMSimplePing *)pinger didFailWithError:(NSError *)error;
- (void)simplePing:(MMSimplePing *)pinger didSendPacket:(NSData *)packet;
- (void)simplePing:(MMSimplePing *)pinger didFailToSendPacket:(NSData *)packet error:(NSError *)error;
- (void)simplePing:(MMSimplePing *)pinger didReceivePingResponsePacket:(NSData *)packet;
 - (void)simplePing:(MMSimplePing *)pinger didReceiveUnexpectedPacket:(NSData *)packet;
    // Called whenever the SimplePing object receives an ICMP packet that does not 
    // look like a response to one of our pings.

@end

#pragma mark * IP and ICMP On-The-Wire Format

// The following declarations specify the structure of ping packets on the wire.

// IP header structure:

struct MMIPHeader {
    uint8_t     versionAndHeaderLength;
    uint8_t     differentiatedServices;
    uint16_t    totalLength;
    uint16_t    identification;
    uint16_t    flagsAndFragmentOffset;
    uint8_t     timeToLive;
    uint8_t     protocol;
    uint16_t    headerChecksum;
    uint8_t     sourceAddress[4];
    uint8_t     destinationAddress[4];
    // options...
    // data...
};
typedef struct MMIPHeader MMIPHeader;

__Check_Compile_Time(sizeof(MMIPHeader) == 20);
__Check_Compile_Time(offsetof(MMIPHeader, versionAndHeaderLength) == 0);
__Check_Compile_Time(offsetof(MMIPHeader, differentiatedServices) == 1);
__Check_Compile_Time(offsetof(MMIPHeader, totalLength) == 2);
__Check_Compile_Time(offsetof(MMIPHeader, identification) == 4);
__Check_Compile_Time(offsetof(MMIPHeader, flagsAndFragmentOffset) == 6);
__Check_Compile_Time(offsetof(MMIPHeader, timeToLive) == 8);
__Check_Compile_Time(offsetof(MMIPHeader, protocol) == 9);
__Check_Compile_Time(offsetof(MMIPHeader, headerChecksum) == 10);
__Check_Compile_Time(offsetof(MMIPHeader, sourceAddress) == 12);
__Check_Compile_Time(offsetof(MMIPHeader, destinationAddress) == 16);

// ICMP type and code combinations:

enum {
    kMMICMPTypeEchoReply   = 0,           // code is always 0
    kMMICMPTypeEchoRequest = 8            // code is always 0
};

// ICMP header structure:

struct MMICMPHeader {
    uint8_t     type;
    uint8_t     code;
    uint16_t    checksum;
    uint16_t    identifier;
    uint16_t    sequenceNumber;
    // data...
};
typedef struct MMICMPHeader MMICMPHeader;

__Check_Compile_Time(sizeof(MMICMPHeader) == 8);
__Check_Compile_Time(offsetof(MMICMPHeader, type) == 0);
__Check_Compile_Time(offsetof(MMICMPHeader, code) == 1);
__Check_Compile_Time(offsetof(MMICMPHeader, checksum) == 2);
__Check_Compile_Time(offsetof(MMICMPHeader, identifier) == 4);
__Check_Compile_Time(offsetof(MMICMPHeader, sequenceNumber) == 6);