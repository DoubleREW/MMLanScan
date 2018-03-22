//
//  MainPresenter.h
//  MMLanScanDemo
//
//  Created by Michael Mavris on 04/11/2016.
//  Copyright © 2016 Miksoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MMDevice.h"

@protocol  MMLANScannerPresenterDelegate
-(void)mainPresenterIPSearchFinished;
-(void)mainPresenterIPSearchCancelled;
-(void)mainPresenterIPSearchFailed;
@end

@interface MMLANScannerPresenter : NSObject
@property(nonatomic,strong)MMDevice *localDevice;
@property(nonatomic,strong)NSArray *connectedDevices;
@property(nonatomic,assign,readonly)float progressValue;
@property(nonatomic,assign,readonly)BOOL isScanRunning;
-(instancetype)initWithDelegate:(id <MMLANScannerPresenterDelegate>)delegate;
-(void)scanButtonClicked;
-(void)startNetworkScan;
-(void)stopNetworkScan;
-(NSString*)ssidName;
@end
