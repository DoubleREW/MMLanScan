//
//  MMLANScannerPresenter.m
//  MMLanScan
//
//  Created by Michael Mavris on 04/11/2016.
//  Copyright © 2016 Miksoft. All rights reserved.
//

#import "MMLANScannerPresenter.h"
#import "LANProperties.h"
#import "MMLANScanner.h"

@interface MMLANScannerPresenter()<MMLANScannerDelegate>

@property (nonatomic,weak)id <MMLANScannerPresenterDelegate> delegate;
@property(nonatomic,strong) MMLANScanner *lanScanner;
@property(nonatomic,assign,readwrite)BOOL isScanRunning;
@property(nonatomic,assign,readwrite)float progressValue;
@end

@implementation MMLANScannerPresenter {
    NSMutableArray *connectedDevicesMutable;
}

#pragma mark - Init method
//Initialization with delegate
-(instancetype)initWithDelegate:(id <MMLANScannerPresenterDelegate>)delegate {

    self = [super init];
    
    if (self) {
        
        self.isScanRunning=NO;
       
        self.delegate=delegate;
        
        self.lanScanner = [[MMLANScanner alloc] initWithDelegate:self];
    }
    
    return self;
}

#pragma mark - Button Actions
//This method is responsible for handling the tap button action on MainVC. In case the scan is running and the button is tapped it will stop the scan
-(void)scanButtonClicked {
    
    //Checks if is already scanning
    if (self.isScanRunning) {
        
        [self stopNetworkScan];
    }
    else {
        
        [self startNetworkScan];
    }
    
}
-(void)startNetworkScan {
    
    self.isScanRunning=YES;
    
    connectedDevicesMutable = [[NSMutableArray alloc] init];
    self.connectedDevices = (NSArray *)connectedDevicesMutable;
    
    if (!self.localDevice) self.localDevice = [LANProperties localIPAddress];
    [self.lanScanner startWithLocalDevice:self.localDevice];
};

-(void)stopNetworkScan {
    
    [self.lanScanner stop];
    
    self.isScanRunning=NO;
}

#pragma mark - SSID
//Getting the SSID string using LANProperties
-(NSString*)ssidName {

    return [NSString stringWithFormat:@"%@",[LANProperties fetchSSIDInfo]];
};

#pragma mark - MMLANScannerDelegate methods
//The delegate methods of MMLANScanner
-(void)lanScanDidFindNewDevice:(MMDevice*)device{
    // Removing duplicated device by mac address
    NSArray *duplicates = [connectedDevicesMutable filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"macAddress == %@", device.macAddress]];
    BOOL deviceUpdated = false;
    
    if ([duplicates count]) {
        if ([device.hostname length]) {
            MMDevice *duplicated;
            for (MMDevice *d in duplicates) {
                if (![d.hostname length] && ![d.hostname isEqualToString:device.hostname]) {
                    duplicated = d;
                }
            }
            
            if (duplicated) {
                NSUInteger index = [connectedDevicesMutable indexOfObject:duplicated];
                if (index != NSNotFound && index < [connectedDevicesMutable count]) {
                    [connectedDevicesMutable replaceObjectAtIndex:index
                                                   withObject:device];
                    deviceUpdated = true;
                }
            }
        }
    }
    
    if (![connectedDevicesMutable containsObject:device] && !deviceUpdated) {
        //Check if the Device is already added
        [connectedDevicesMutable addObject:device];
    }
    
    // NSSortDescriptor *valueDescriptor = [[NSSortDescriptor alloc] initWithKey:@"ipAddress" ascending:YES];
    NSSortDescriptor *valueDescriptor = [[NSSortDescriptor alloc] initWithKey:@"ipAddress" ascending:YES comparator:^NSComparisonResult(NSString *a, NSString *b) {
        return [a compare:b options:NSNumericSearch];
    }];
    
    //Updating the array that holds the data. MainVC will be notified by KVO
    self.connectedDevices = [connectedDevicesMutable sortedArrayUsingDescriptors:@[valueDescriptor]];
}

-(void)lanScanDidFinishScanningWithStatus:(MMLanScannerStatus)status{
   
    self.isScanRunning=NO;
    
    //Checks the status of finished. Then call the appropriate method
    if (status == MMLanScannerStatusFinished) {
        
        [self.delegate mainPresenterIPSearchFinished];
    }
    else if (status==MMLanScannerStatusCancelled) {
       
        [self.delegate mainPresenterIPSearchCancelled];
    }
}

-(void)lanScanProgressPinged:(float)pingedHosts from:(NSInteger)overallHosts {
    
    //Updating the progress value. MainVC will be notified by KVO
    self.progressValue=pingedHosts/overallHosts;
}

-(void)lanScanDidFailedToScan {
   
    self.isScanRunning=NO;

    [self.delegate mainPresenterIPSearchFailed];
}

@end
