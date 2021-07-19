//
//  SGFManager.m
//  SGFindSDK
//
//  Created by Kalpesh Panchasara on 7/11/14.
//  Copyright (c) 2014 Kalpesh Panchasara, Ind. All rights reserved.
//


#import "BLEManager.h"
#import "Constant.h"
#import "Header.h"

static BLEManager    *sharedManager    = nil;
//BLEManager    *sharedManager    = nil;

@interface BLEManager()
{
    NSMutableArray *disconnectedPeripherals;
    NSMutableArray *connectedPeripherals;
    NSMutableArray *peripheralsServices;
    CBCentralManager    *centralManager;
    BLEService * blutoothService;
    
    int timeOutCount;
}
@end

@implementation BLEManager
@synthesize delegate,foundDevices,connectedServices,centralManager,nonConnectArr, strMainscreenRelay, strSelectedKnob;

#pragma mark- Self Class Methods
-(id)init
{
    timeOutCount = -1;
    if(self = [super init])
    {
        [self initialize];
    }
    return self;
}

#pragma mark --> Initilazie
-(void)initialize
{
    //  NSLog(@"bleManager initialized");
    centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil options:@{ CBCentralManagerOptionRestoreIdentifierKey:  @"CentralManagerIdentifier" }];
    centralManager.delegate = self;
    blutoothService.delegate = self;
    [foundDevices removeAllObjects];
    [nonConnectArr removeAllObjects];
    if(!foundDevices)foundDevices = [[NSMutableArray alloc] init];
    if(!nonConnectArr)nonConnectArr = [[NSMutableArray alloc] init];
    if(!connectedServices)connectedServices = [[NSMutableArray alloc] init];
    if(!disconnectedPeripherals)disconnectedPeripherals = [NSMutableArray new];
}

+ (BLEManager*)sharedManager
{
    if (!sharedManager)
    {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            sharedManager = [[BLEManager alloc] init];
        });
    }
    return sharedManager;
}
-(NSArray *)getLastConnected
{
    return [centralManager retrieveConnectedPeripheralsWithServices:@[[CBUUID UUIDWithString:@"0000D100-AB00-11E1-9B23-00025B00A5A5"]]];//000D100-AB00-11E1-9B23-00025B00A5A5[CBUUID UUIDWithString:@"xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"]
}
#pragma mark- Scanning Method
-(void)startScan
{
    //    CBPeripheralManager *pm = [[CBPeripheralManager alloc] initWithDelegate:nil queue:nil];
    //  NSLog(@"pm===%@",pm);
    NSDictionary * options = [NSDictionary dictionaryWithObjectsAndKeys: [NSNumber numberWithBool:NO], CBCentralManagerScanOptionAllowDuplicatesKey,nil];
    [centralManager scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:@"0000D100-AB00-11E1-9B23-00025B00A5A5"]] options:options];
}
#pragma mark - > Rescan Method
-(void) rescan
{
    centralManager.delegate = self;
    blutoothService.delegate = self;
    self.serviceDelegate = self;
    
    NSDictionary * options = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSNumber numberWithBool:NO], CBCentralManagerScanOptionAllowDuplicatesKey,
                              nil];
    [centralManager scanForPeripheralsWithServices:nil options:options];
}

#pragma mark - Stop Method
-(void)stopScan
{
    self.delegate = nil;
    self.serviceDelegate = nil;
    blutoothService.delegate = nil;
    blutoothService = nil;
    centralManager.delegate = nil;
    [foundDevices removeAllObjects];
    [centralManager stopScan];
    [blutoothSearchTimer invalidate];
    
}

#pragma mark - Central manager delegate method stop
-(void)centralmanagerScanStop
{
    [centralManager stopScan];
}
#pragma mark - Connect Ble device
- (void) connectDevice:(CBPeripheral*)device{
    
    if (device == nil)
    {
        return;
    }
    else
    {//3.13.1 is live or testlgijt ?
        if ([disconnectedPeripherals containsObject:device])
        {
            [disconnectedPeripherals removeObject:device];
        }
        [self connectPeripheral:device];
    }
}

#pragma mark - Disconenct Device
- (void)disconnectDevice:(CBPeripheral*)device
{
    if (device == nil) {
        return;
    }else{
        [self disconnectPeripheral:device];
    }
}

-(void)connectPeripheral:(CBPeripheral*)peripheral
{
    NSError *error;
    if (peripheral)
    {
        if (peripheral.state != CBPeripheralStateConnected)
        {
            [centralManager connectPeripheral:peripheral options:nil];
        }
        else
        {
            if(delegate)
            {
                [delegate didFailToConnectDevice:peripheral error:error];
            }
        }
    }
    else
    {
        if(delegate)
        {
            [delegate didFailToConnectDevice:peripheral error:error];
        }
    }
}

-(void) disconnectPeripheral:(CBPeripheral*)peripheral
{
    [self.delegate didDisconnectDevice:peripheral];
    if (peripheral)
    {
        if (peripheral.state == CBPeripheralStateConnected)
        {
            [centralManager cancelPeripheralConnection:peripheral];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"deviceDidDisConnectNotification" object:peripheral];
        }
    }
}
-(void) updateBluetoothState
{
    [self centralManagerDidUpdateState:centralManager];
}
-(void) updateBleImageWithStatus:(BOOL)isConnected andPeripheral:(CBPeripheral*)peripheral
{
}
#pragma mark -  Search Timer Auto Connect
-(void)searchConnectedBluetooth:(NSTimer*)timer
{
    //    NSLog(@"its scanning");
    [self rescan];
}
#pragma mark Scan Sync Timer
-(void)scanDeviceSync:(NSTimer*)timer
{
}
#pragma mark - CBCentralManagerDelegate
- (void) centralManagerDidUpdateState:(CBCentralManager *)central
{
    [self startScan];
    /*----Here we can come to know bluethooth state----*/
    [blutoothSearchTimer invalidate];
    blutoothSearchTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(searchConnectedBluetooth:) userInfo:nil repeats:YES];
    
    switch (central.state)
    {
        case CBPeripheralManagerStateUnknown:
            //The current state of the peripheral manager is unknown; an update is imminent.
            if(delegate)[delegate bluetoothPowerState:@"The current state of the peripheral manager is unknown; an update is imminent."];
            
            break;
        case CBPeripheralManagerStateUnauthorized:
            //The app is not authorized to use the Bluetooth low energy peripheral/server role.
            if(delegate)[delegate bluetoothPowerState:@"The app is not authorized to use the Bluetooth low energy peripheral/server role."];
            
            break;
        case CBPeripheralManagerStateResetting:
            //The connection with the system service was momentarily lost; an update is imminent.
            if(delegate)[delegate bluetoothPowerState:@"The connection with the system service was momentarily lost; an update is imminent."];
            
            break;
        case CBPeripheralManagerStatePoweredOff:
            //Bluetooth is currently powered off"
            if(delegate)[delegate bluetoothPowerState:@"Bluetooth is currently powered off."];
            
            break;
        case CBPeripheralManagerStateUnsupported:
            //The platform doesn't support the Bluetooth low energy peripheral/server role.
            if(delegate)[delegate bluetoothPowerState:@"The platform doesn't support the Bluetooth low energy peripheral/server role."];
            
            break;
        case CBPeripheralManagerStatePoweredOn:
            //Bluetooth is currently powered on and is available to use.
            if(delegate)[delegate bluetoothPowerState:@"Bluetooth is currently powered on and is available to use."];
            break;
    }
}

#pragma mark - Finding Device with in Range
-(void)centralManager:(CBCentralManager *)central didRetrievePeripherals:(NSArray *)peripherals
{
    //  NSLog(@"peripherals==%@",peripherals);
}

#pragma mark - Discover all devices here
/*-----------if device is in range we can find in this method--------*/
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    NSData * manufcData = [advertisementData valueForKey:@"kCBAdvDataManufacturerData"];
    NSString * strAdvData = [NSString stringWithFormat:@"%@",manufcData];
    strAdvData = [strAdvData stringByReplacingOccurrencesOfString:@" " withString:@""];
    strAdvData = [strAdvData stringByReplacingOccurrencesOfString:@">" withString:@""];
    strAdvData = [strAdvData stringByReplacingOccurrencesOfString:@"<" withString:@""];
    
    if (![[APP_DELEGATE checkforValidString:strAdvData] isEqualToString:@"NA"])
    {
        if ([strAdvData length]>=36)
        {
            NSRange rangeFirst = NSMakeRange(0, 4);
            NSString * strIdentifyCheck = [strAdvData substringWithRange:rangeFirst];
            if ([strIdentifyCheck isEqualToString:@"5900"])
            {
                if ([strAdvData length]>=36)
                {
                    
                }
                NSString * strFinalData = [self getStringConvertedinUnsigned:[strAdvData substringWithRange:NSMakeRange(4, 32)]];

                NSData * updatedMFData = [self GetDecrypedDataKeyforData:strFinalData withKey:strFinalData withLength:[strAdvData length]/2];
                NSString * strDecrypted = [NSString stringWithFormat:@"%@",updatedMFData];
                strDecrypted = [strDecrypted stringByReplacingOccurrencesOfString:@" " withString:@""];
                strDecrypted = [strDecrypted stringByReplacingOccurrencesOfString:@">" withString:@""];
                strDecrypted = [strDecrypted stringByReplacingOccurrencesOfString:@"<" withString:@""];
//                NSLog(@"After Data=%@",strDecrypted);
//                if (timeOutCount == -1 || timeOutCount == 2)
                {
                    if ([strDecrypted length]>=16)
                    {
                        rangeFirst = NSMakeRange(8, 2);
                        if ([[strDecrypted substringWithRange:rangeFirst] isEqualToString:@"02"])
                        {
                            [APP_DELEGATE endHudProcess];
                            if ([strDecrypted length]>=16)
                            {
                                rangeFirst = NSMakeRange(8, 16);
                                NSString * strFinalResult = [strDecrypted substringWithRange:rangeFirst];
                                {
                                    strMainscreenRelay = strFinalResult;
                                    [[NSNotificationCenter defaultCenter] postNotificationName:@"BLEScannedDevicelistShowhere" object:nil];
                                }

                            }
                        }
                        else if ([[strDecrypted substringWithRange:rangeFirst] isEqualToString:@"07"] || [[strDecrypted substringWithRange:rangeFirst] isEqualToString:@"01"])
                        {
                            [APP_DELEGATE endHudProcess];
                            rangeFirst = NSMakeRange(8, 6);
                            NSString * strFinalResult = [strDecrypted substringWithRange:rangeFirst];
//                            NSLog(@"===>%@",strFinalResult);

//                            if (![strFinalResult isEqualToString:strSelectedKnob])
                            {
                                strSelectedKnob = strFinalResult;
                                [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateKnobSelection" object:nil];
                            }
                        }
                    }
                    timeOutCount = 0;
                }
//                else
//                {
//
//                    timeOutCount = timeOutCount + 1;
//                }
                
                //Here send notification to View of updated data
            }
            
        }
    }
}

#pragma mark - > Resttore state of devices
- (void)centralManager:(CBCentralManager *)central willRestoreState:(NSDictionary *)dict
{
    NSArray *peripherals =dict[CBCentralManagerRestoredStatePeripheralsKey];
    
    if (peripherals.count>0)
    {
        for (CBPeripheral *p in peripherals)
        {
            if (p.state != CBPeripheralStateConnected)
            {
                //[self connectPeripheral:p];
            }
        }
    }
}

#pragma mark - Fail to connect device
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    /*---This method will call if failed to connect device-----*/
    if(delegate)[delegate didFailToConnectDevice:peripheral error:error];
}

- (void)discoverIncludedServices:(nullable NSArray<CBUUID *> *)includedServiceUUIDs forService:(CBService *)service;
{
    
}
- (void)discoverCharacteristics:(nullable NSArray<CBUUID *> *)characteristicUUIDs forService:(CBService *)service;
{
    
}
- (void)readValueForCharacteristic:(CBCharacteristic *)characteristic;
{
    
}


#pragma mark - Connect Delegate method
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    //    [[BLEManager sharedManager] stopScan];
    
    NSLog(@"COnnected Device");
    
    /*-------This method will call after succesfully device Ble device connect-----*/
    peripheral.delegate = self;
    if (peripheral.services)
    {
        [self peripheral:peripheral didDiscoverServices:nil];
    }
    else
    {
        [peripheral discoverServices:@[[CBUUID UUIDWithString:@"0000D100-AB00-11E1-9B23-00025B00A5A5"]]];
    }
}
-(void) peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    BOOL gotService = NO;
    for(CBService* svc in peripheral.services)
    {
        gotService = YES;
        NSLog(@"service=%@",svc);
        if(svc.characteristics)
            [self peripheral:peripheral didDiscoverCharacteristicsForService:svc error:nil]; //already discovered characteristic before, DO NOT do it again
        else
            [peripheral discoverCharacteristics:nil
                                     forService:svc]; //need to discover characteristics
    }
    if (gotService == NO)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"hideHud" object:nil];
        [self disconnectDevice:peripheral];
    }
}

-(void) peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    for(CBCharacteristic* c in service.characteristics)
    {
        NSLog(@"characteristics=%@",c);
        
        //Do some work with the characteristic...
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"deviceDidConnectNotification" object:peripheral];

        [[BLEService sharedInstance] sendNotifications:peripheral withType:NO withUUID:@"0001D100-AB00-11E1-9B23-00025B00A5A5"];
        [[BLEService sharedInstance] readAuthValuefromManager:peripheral];
    
}


#pragma mark - Disconnect Ble Device
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(nullable NSError *)error;
{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"deviceDidDisConnectNotification" object:peripheral];
}
-(void)timeOutConnection
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"BLEConnectionErrorPopup" object:nil];
}
-(NSData *)GetDecrypedDataKeyforData:(NSString *)strData withKey:(NSString *)strKey withLength:(long)dataLength
{
    strKey = [NSString stringWithFormat:@"0x52 0x65 0x64 0x72 0x16 0x39 0x22 0x67 0x53 0x68 0x69 0x66 0x74 0x74 0x66 0x23"];
    
    //RAW Data of 16 bytes
    NSScanner *scanner = [NSScanner scannerWithString: strData];
    unsigned char strrRawData[16];
    unsigned index = 0;
    while (![scanner isAtEnd])
    {
        unsigned value = 0;
        if (![scanner scanHexInt: &value])
        {
            // invalid value
            break;
        }
        strrRawData[index++] = value;
    }
    
    //Password encrypted Key 16 bytes
    NSScanner *scannerKey = [NSScanner scannerWithString: strKey];
    unsigned char strrDataKey[16];
    unsigned indexKey = 0;
    while (![scannerKey isAtEnd])
    {
        unsigned value = 0;
        if (![scannerKey scanHexInt: &value])
        {
            // invalid value
            break;
        }
        strrDataKey[indexKey++] = value;
    }
    unsigned char  tempResultOp[16];
    Header_h AES_ECB(strrRawData, strrDataKey, tempResultOp, 0);
    
    NSUInteger size = dataLength;
    NSData* data = [NSData dataWithBytes:(const void *)tempResultOp length:sizeof(unsigned char)*size];
    //    NSLog(@"Data=%@",data);
    return data;
}
-(NSString *)getStringConvertedinUnsigned:(NSString *)strNormal
{
    NSString * strKey = strNormal;
    long ketLength = [strKey length]/2;
    NSString * strVal;
    for (int i=0; i<ketLength; i++)
    {
        NSRange range73 = NSMakeRange(i*2, 2);
        NSString * str3 = [strKey substringWithRange:range73];
        if ([strVal length]==0)
        {
            strVal = [NSString stringWithFormat:@" 0x%@",str3];
        }
        else
        {
            strVal = [strVal stringByAppendingString:[NSString stringWithFormat:@" 0x%@",str3]];
        }
    }
    return strVal;
}
@end
//    kCBAdvDataManufacturerData = <0a00640b 00009059 22590161 00007f0c 09fb0069 00>;
//0a00 0002 32ac 6057 26

