//
//  HomeVC.m
//  Redshift
//
//  Created by srivatsa s pobbathi on 22/10/18.
//  Copyright © 2018 srivatsa s pobbathi. All rights reserved.
//

#import "HomeVC.h"
#import "SettingsVC.h"
#import <CoreLocation/CoreLocation.h>
#import "CLLocation+Strings.h"
#import "BLEManager.h"

@interface HomeVC ()<CLLocationManagerDelegate,CBCentralManagerDelegate>
{
    CLLocationManager * locationManager;
    double totalDistance;
    UIInterfaceOrientation lastOrients;
    CLLocation * previousLocation;
    NSTimer * timerBatteryCheck;
    NSTimer *  timertoCheckKnobStatus;
    NSString * strPrevousMainData, * strPreviousKnobData;
    NSString * strPrevConnected, * strPrevActive, * strPrevTrigger, * strPrevSystemVolt, * strPrevIgnStatus;
    int fontHght;
    UIView * mainView;
    BOOL isPortrait, isDataScanning, isViewDone;
    NSTimer * timerClock, * resentMOMTimer;
    CLLocation * savedLastLocation;
    NSString * strLastMomSent;
    CBCentralManager *centralManager;

}
@end

@implementation HomeVC

- (void)viewDidLoad
{
    mainView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [self.view addSubview:mainView];

    if (self.view.frame.size.height == 480 || self.view.frame.size.width == 480)
    {
        fontHght = 15;
    }
    else if (self.view.frame.size.height == 568 || self.view.frame.size.width == 568)
    {
        fontHght = 20;
    }
    else
    {
        fontHght = 24;
    }
    isIgnitionON = NO;
    isKnobAdvertising = NO;
    isDataScanning = NO;
    
    dictActive = [[NSMutableDictionary alloc] init];
    [self getLocationMethod];
    self.view.backgroundColor = UIColor.whiteColor;
    [self setMainViewContents];
    [super viewDidLoad];
    
    isPortrait = YES;
    if([[UIApplication sharedApplication] statusBarOrientation]==UIDeviceOrientationLandscapeLeft || [[UIApplication sharedApplication] statusBarOrientation]==UIDeviceOrientationLandscapeRight  )
    {
        isPortrait = NO;
        NSLog(@"Landscape");
        orinetationCount = [[UIDevice currentDevice]orientation];
        [self setLandscapeFrames];
    }
    NSLog(@"%ld",(long)[[UIDevice currentDevice]orientation]);
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(OrientationDidChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
    
//    [self TempMethodforStatusActive];
    // Do any additional setup after loading the view.
}
-(void)viewWillAppear:(BOOL)animated
{
    if (isCentralAssigned == NO)
    {
        centralManager = nil;
        centralManager.delegate = nil;
        centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil options:nil];
        isCentralAssigned = YES;
    }
    
    isStopUpdate = NO;
    if (@available(iOS 10.0, *)) {
        if (centralManager.state == CBCentralManagerStatePoweredOn || centralManager.state == CBManagerStateUnknown)
        {
        }
        else
        {
            [self GlobalBLuetoothCheck];
        }
    } else
    {
        if (centralManager.state == CBCentralManagerStatePoweredOff)
        {
            [self GlobalBLuetoothCheck];
        }
        // Fallback on earlier versions
    }
    
    [self InitialBLE];
    [[[BLEManager sharedManager] nonConnectArr] removeAllObjects];
    [[BLEManager sharedManager] startScan];//Scan Ble devices
    
    if([[UIApplication sharedApplication] statusBarOrientation] == UIDeviceOrientationLandscapeLeft || [[UIApplication sharedApplication] statusBarOrientation] == UIDeviceOrientationLandscapeRight)
    {
        [self setLandscapeFrames];
    }
    else if([[UIApplication sharedApplication] statusBarOrientation] == UIDeviceOrientationPortrait)
    {
        [self setUpPortraintFrames];
    }
    
    for (int i=0; i<6; i++)
    {
        NSDictionary * tmpDict = [[NSDictionary alloc]init];
        tmpDict = [[NSUserDefaults standardUserDefaults]valueForKey:[NSString stringWithFormat:@"Relay%d",i+1]];
        if (i == 0)
        {
            [btn1 setTitle:[tmpDict valueForKey:@"name"] forState:UIControlStateNormal];
        }
        else if(i == 1)
        {
            [btn2 setTitle:[tmpDict valueForKey:@"name"] forState:UIControlStateNormal];
        }
        else if(i == 2)
        {
            [btn3 setTitle:[tmpDict valueForKey:@"name"] forState:UIControlStateNormal];
        }
        else if(i == 3)
        {
            [btn4 setTitle:[tmpDict valueForKey:@"name"] forState:UIControlStateNormal];
        }
        else if(i == 4)
        {
            [btn5 setTitle:[tmpDict valueForKey:@"name"] forState:UIControlStateNormal];
        }
        else if(i == 5)
        {
            [btn6 setTitle:[tmpDict valueForKey:@"name"] forState:UIControlStateNormal];
        }
    }
    [timertoCheckKnobStatus invalidate];
    timertoCheckKnobStatus = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(CheckKnobStaus) userInfo:nil repeats:YES];
    
    [timerClock invalidate];
    timerClock = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(UpdateTime) userInfo:nil repeats:YES];

    
    if (isViewDone)
    {
        [self UpdateAllfieldsValues];
    }
    else
    {
        isViewDone = YES;
    }
}
-(void)viewDidAppear:(BOOL)animated
{
    [self performSelector:@selector(btnSettingsAction) withObject:nil afterDelay:0.5];
}
-(void)setMomentaryLabel:(UILabel *)lbls toAddLbls:(UIButton *)lblParent
{
    lbls.frame = CGRectMake(((btn1.frame.size.width-50)/2), (btn1.frame.size.height-40), 60, 30);
    lbls.font = [UIFont fontWithName:CGRegular size:17];
    lbls.backgroundColor = UIColor.clearColor;
    lbls.text = @"(MOM)";
    lbls.textColor = [UIColor blackColor];
    lbls.hidden = YES;
    [lblParent addSubview:lbls];
}
-(void)setMainButtons:(UIButton *)btns withtitle:(NSString *)strTitle
{
    btns.backgroundColor = UIColor.clearColor;
    [btns setTitle:strTitle forState:UIControlStateNormal];
    btns.layer.masksToBounds = true;
    btns.layer.borderWidth = 0.5;
    [btns setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    btns.titleLabel.font = [UIFont fontWithName:CGRegular size:txtSize+10];
    [btns setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    btns.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    btns.titleLabel.numberOfLines = 2;
    [mainView addSubview:btns];
    
}
#pragma mark - SetUp UI Frames
-(void)setMainViewContents
{
    int viewHeight = DEVICE_HEIGHT-20;
    int exYY =0;
    if (IS_IPHONE_X)
    {
        viewHeight = DEVICE_HEIGHT-84;
        exYY = 44;
    }
    
    //First Button
    btn1 = [UIButton buttonWithType:UIButtonTypeCustom];
    btn1.tag =1;
    [self setMainButtons:btn1 withtitle:@"1"];
    btn1.frame = CGRectMake(DEVICE_WIDTH-DEVICE_WIDTH/3,((DEVICE_HEIGHT)-viewHeight/5) -exYY, DEVICE_WIDTH/3, viewHeight/5);
    lblMom1= [[UILabel alloc] init];
    [self setMomentaryLabel:lblMom1 toAddLbls:btn1];
    [btn1 addTarget:self action:@selector(btn1Action) forControlEvents:UIControlEventTouchUpInside];
    
    lblLong1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, btn1.frame.size.width, btn1.frame.size.height)];
    lblLong1.userInteractionEnabled = YES;
    lblLong1.hidden = YES;
    [btn1 addSubview:lblLong1];
    
    longpress1 = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longpress1GestureMethod:)];
    longpress1.delegate = self;
    [lblLong1 addGestureRecognizer: longpress1];
    
    //Second Button
    btn2 = [UIButton buttonWithType:UIButtonTypeCustom];
    btn2.tag=2;
    [self setMainButtons:btn2 withtitle:@"2"];
    btn2.frame = CGRectMake(DEVICE_WIDTH-(DEVICE_WIDTH/3*2),((DEVICE_HEIGHT)-viewHeight/5)-exYY, DEVICE_WIDTH/3, viewHeight/5);
    lblMom2= [[UILabel alloc] init];
    [self setMomentaryLabel:lblMom2 toAddLbls:btn2];
    [btn2 addTarget:self action:@selector(btn2Action) forControlEvents:UIControlEventTouchUpInside];

    lblLong2 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, btn2.frame.size.width, btn2.frame.size.height)];
    lblLong2.userInteractionEnabled = YES;
    lblLong2.hidden = YES;
    [btn2 addSubview:lblLong2];

    longpress2 = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longpress2GestureMethod:)];
    longpress2.delegate = self;
    [lblLong2 addGestureRecognizer: longpress2];
    
    //Third Button
    btn3 = [UIButton buttonWithType:UIButtonTypeCustom];
    btn3.tag=3;
    [self setMainButtons:btn3 withtitle:@"3"];
    btn3.frame = CGRectMake(0, ((DEVICE_HEIGHT)-(viewHeight/5*2))-exYY, DEVICE_WIDTH/3, viewHeight/5);
    lblMom3= [[UILabel alloc] init];
    [self setMomentaryLabel:lblMom3 toAddLbls:btn3];
    [btn3 addTarget:self action:@selector(btn3Action) forControlEvents:UIControlEventTouchUpInside];

    lblLong3 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, btn3.frame.size.width, btn3.frame.size.height)];
    lblLong3.userInteractionEnabled = YES;
    lblLong3.hidden = YES;
    [btn3 addSubview:lblLong3];
    
    longpress3 = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longpress3GestureMethod:)];
    longpress3.delegate = self;
    [lblLong3 addGestureRecognizer: longpress3];
    
    //Fourth Button
    btn4 = [UIButton buttonWithType:UIButtonTypeCustom];
    btn4.tag=4;
    [self setMainButtons:btn4 withtitle:@"4"];
    btn4.frame = CGRectMake(0, ((DEVICE_HEIGHT)-(viewHeight/5*3))-exYY, DEVICE_WIDTH/3, viewHeight/5);
    lblMom4= [[UILabel alloc] init];
    [self setMomentaryLabel:lblMom4 toAddLbls:btn4];
    [btn4 addTarget:self action:@selector(btn4Action) forControlEvents:UIControlEventTouchUpInside];

    lblLong4 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, btn4.frame.size.width, btn4.frame.size.height)];
    lblLong4.userInteractionEnabled = YES;
    lblLong4.hidden = YES;
    [btn4 addSubview:lblLong4];
    
    longpress4 = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longpress4GestureMethod:)];
    longpress4.delegate = self;
    [lblLong4 addGestureRecognizer: longpress4];
    
    //Fifth Button
    btn5 = [UIButton buttonWithType:UIButtonTypeCustom];
    btn5.tag=5;
    [self setMainButtons:btn5 withtitle:@"5"];
    btn5.frame = CGRectMake(0, ((DEVICE_HEIGHT)-(viewHeight/5*4))-exYY, DEVICE_WIDTH/3, viewHeight/5);
    lblMom5= [[UILabel alloc] init];
    [self setMomentaryLabel:lblMom5 toAddLbls:btn5];
    [btn5 addTarget:self action:@selector(btn5Action) forControlEvents:UIControlEventTouchUpInside];

    lblLong5 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, btn5.frame.size.width, btn5.frame.size.height)];
    lblLong5.userInteractionEnabled = YES;
    lblLong5.hidden = YES;
    [btn5 addSubview:lblLong5];
    
    longpress5 = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longpress5GestureMethod:)];
    longpress5.delegate = self;
    [lblLong5 addGestureRecognizer: longpress5];
    
    //Sixth Button
    btn6 = [UIButton buttonWithType:UIButtonTypeCustom];
    btn6.tag=6;
    [self setMainButtons:btn6 withtitle:@"6"];
    btn6.frame = CGRectMake(0, ((DEVICE_HEIGHT)-(viewHeight/5*5))-exYY, DEVICE_WIDTH/3, viewHeight/5);
    lblMom6= [[UILabel alloc] init];
    [self setMomentaryLabel:lblMom6 toAddLbls:btn6];
    [btn6 addTarget:self action:@selector(btn6Action) forControlEvents:UIControlEventTouchUpInside];

    lblLong6 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, btn6.frame.size.width, btn6.frame.size.height)];
    lblLong6.userInteractionEnabled = YES;
    lblLong6.hidden = YES;
    [btn6 addSubview:lblLong6];
    
    longpress6 = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longpress6GestureMethod:)];
    longpress6.delegate = self;
    [lblLong6 addGestureRecognizer: longpress6];
    
    
    btnSettings = [UIButton buttonWithType:UIButtonTypeCustom];
    btnSettings.backgroundColor = UIColor.clearColor;
    btnSettings.frame = CGRectMake(0, ((DEVICE_HEIGHT)-viewHeight/5)-exYY, DEVICE_WIDTH/3, viewHeight/5);
    btnSettings.layer.masksToBounds = true;
    btnSettings.layer.borderWidth = 0.5;
    [btnSettings setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    //[btnSettings addTarget:self action:@selector(btnSettingsAction) forControlEvents:UIControlEventTouchUpInside];
    [mainView addSubview:btnSettings];
    
    imgSettings = [[UIImageView alloc]init];
    imgSettings.frame = CGRectMake((btnSettings.frame.size.width-40)/2,( btnSettings.frame.size.height-40)/2, 40, 40);
    imgSettings.backgroundColor = UIColor.clearColor;
    imgSettings.image = [UIImage imageNamed:@"settings.png"];
    [btnSettings addSubview:imgSettings];
    
    imgLock = [[UIImageView alloc]init];
    imgLock.frame = CGRectMake((btnSettings.frame.size.width-30)/2,(( btnSettings.frame.size.height-60)/2)+30, 30, 30);
    imgLock.backgroundColor = UIColor.clearColor;
    imgLock.image = [UIImage imageNamed:@"lock.png"];
//    [btnSettings addSubview:imgLock];
    
    yy = 20;
    if (IS_IPHONE_X)
    {
        yy = 44;
    }
    yy =yy+5;
    lblTimeView = [[UILabel alloc]initWithFrame:CGRectMake((DEVICE_WIDTH/3), yy, ((DEVICE_WIDTH/3)*2), 40)];
    lblTimeView.backgroundColor = UIColor.clearColor;
    [mainView addSubview:lblTimeView];
    
    lblTime = [[UILabel alloc]initWithFrame:CGRectMake(5, 0, lblTimeView.frame.size.width-10, 40)];
    lblTime.backgroundColor = UIColor.clearColor;
    [lblTime setFont:[UIFont fontWithName:CGRegular size:txtSize+fontHght]];
    lblTime.text = @"10:00 PM";
    [lblTimeView addSubview:lblTime];
    
    yy = yy+40+5;
    lblSpeedView = [[UILabel alloc]init];
    lblSpeedView = [[UILabel alloc]initWithFrame:CGRectMake((DEVICE_WIDTH/3), yy,((DEVICE_WIDTH/3)*2), 40)];
    lblSpeedView.backgroundColor = UIColor.clearColor;
    [mainView addSubview:lblSpeedView];
    
    lblSpeed = [[UILabel alloc]initWithFrame:CGRectMake(5, 0, lblSpeedView.frame.size.width-10, 40)];
    lblSpeed.backgroundColor = UIColor.clearColor;
    [lblSpeed setFont:[UIFont fontWithName:CGRegular size:txtSize+fontHght]];
    lblSpeed.text = @"70 mph";
    lblSpeed.textAlignment = NSTextAlignmentLeft;
    [lblSpeedView addSubview:lblSpeed];
    
    yy =  yy + 40+5;
    
    lblHeadingsView = [[UILabel alloc]init];
    lblHeadingsView = [[UILabel alloc]initWithFrame:CGRectMake((DEVICE_WIDTH/3), yy, ((DEVICE_WIDTH/3)*2), 40)];
    lblHeadingsView.backgroundColor = UIColor.clearColor;
    [mainView addSubview:lblHeadingsView];
    
    lblHeadings = [[UILabel alloc]initWithFrame:CGRectMake(5, 0, lblHeadingsView.frame.size.width-10, 40)];
    lblHeadings.backgroundColor = UIColor.clearColor;
    [lblHeadings setFont:[UIFont fontWithName:CGRegular size:txtSize+fontHght]];
    lblHeadings.text = @"278º WNV";
    [lblHeadingsView addSubview:lblHeadings];
    
    yy =  yy + 40+5;
    
    lblAltitudeView = [[UILabel alloc]init];
    lblAltitudeView = [[UILabel alloc]initWithFrame:CGRectMake(((DEVICE_WIDTH/3)), yy,((DEVICE_WIDTH/3)*2), 40)];
    lblAltitudeView.backgroundColor = UIColor.clearColor;
    [mainView addSubview:lblAltitudeView];
    
    lblAltitude = [[UILabel alloc]initWithFrame:CGRectMake(5, 0, lblAltitudeView.frame.size.width-10, 40)];
    lblAltitude.backgroundColor = UIColor.clearColor;
    [lblAltitude setFont:[UIFont fontWithName:CGRegular size:txtSize+fontHght]];
    lblAltitude.text = @"3451ª elev";
    lblAltitude.textAlignment = NSTextAlignmentLeft;
    [lblAltitudeView addSubview:lblAltitude];
    
    yy =  yy + 60+10;
    
    lblOdometersView = [[UILabel alloc]init];
    lblOdometersView = [[UILabel alloc]initWithFrame:CGRectMake((DEVICE_WIDTH/3),yy,((DEVICE_WIDTH/3)*2), 75)];
    lblOdometersView.backgroundColor = UIColor.clearColor;
    lblOdometersView.userInteractionEnabled = true;
    [mainView addSubview:lblOdometersView];
    
    lblOdometer1 = [[UILabel alloc]initWithFrame:CGRectMake(5, 5, lblOdometersView.frame.size.width-80, 25)];
    lblOdometer1.backgroundColor = UIColor.clearColor;
    [lblOdometer1 setFont:[UIFont fontWithName:CGRegular size:txtSize+fontHght]];
    lblOdometer1.text = @"555.55 mi";
    [lblOdometersView addSubview:lblOdometer1];
    
    lblOdometer2 = [[UILabel alloc]initWithFrame:CGRectMake(5, 40, lblOdometersView.frame.size.width-80, 25)];
    lblOdometer2.backgroundColor = UIColor.clearColor;
    [lblOdometer2 setFont:[UIFont fontWithName:CGRegular size:txtSize+fontHght]];
    lblOdometer2.text = @"555.55 mi";
    [lblOdometersView addSubview:lblOdometer2];
    
    btnReset1 = [[UIButton alloc]init];
    btnReset1.frame = CGRectMake((lblOdometersView.frame.size.width/2)+35, 2.5,(lblOdometersView.frame.size.width/2)-40, 30);
    [btnReset1 setTitle:@"Reset" forState:UIControlStateNormal];
    [btnReset1 setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    btnReset1.backgroundColor = UIColor.redColor;
    btnReset1.layer.masksToBounds = true;
    btnReset1.layer.cornerRadius = 10;
    btnReset1.layer.borderColor = [UIColor blackColor].CGColor;
    btnReset1.layer.borderWidth = 0.8;
    [btnReset1 addTarget:self action:@selector(btnReset1Action) forControlEvents:UIControlEventTouchUpInside];
    [lblOdometersView addSubview:btnReset1];
    
    btnReset2 = [[UIButton alloc]init];
    btnReset2.frame = CGRectMake((lblOdometersView.frame.size.width/2)+35,37.5,(lblOdometersView.frame.size.width/2)-40, 30);
    [btnReset2 setTitle:@"Reset" forState:UIControlStateNormal];
    [btnReset2 setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    btnReset2.backgroundColor = UIColor.redColor;
    btnReset2.layer.masksToBounds = true;
    btnReset2.layer.cornerRadius = 10;
    btnReset2.layer.borderColor = [UIColor blackColor].CGColor;
    btnReset2.layer.borderWidth = 0.8;
    [btnReset2 addTarget:self action:@selector(btnReset2Action) forControlEvents:UIControlEventTouchUpInside];
    [lblOdometersView addSubview:btnReset2];
    
    yy =  yy + 5 + 75 ;
    lblVoltageView = [[UILabel alloc]init];
    lblVoltageView = [[UILabel alloc]initWithFrame:CGRectMake((DEVICE_WIDTH/3), yy,((DEVICE_WIDTH/3)*2), 40)];
    lblVoltageView.backgroundColor = UIColor.clearColor;
    [mainView addSubview:lblVoltageView];
    
    lblVoltage = [[UILabel alloc]initWithFrame:CGRectMake(5, 0, lblVoltageView.frame.size.width-10, 40)];
    lblVoltage.backgroundColor = UIColor.clearColor;
    [lblVoltage setFont:[UIFont fontWithName:CGRegular size:txtSize+fontHght]];
    lblVoltage.text = @"10 V";
    [lblVoltageView addSubview:lblVoltage];
    
    yy =  yy + 5 +55 ;
    
    imgAppIcon = [[UIImageView alloc]initWithFrame:CGRectMake(((DEVICE_WIDTH/3)-200*approaxSize)/2, yy,200*approaxSize, 21*approaxSize)];
    //    imgAppIcon.autoresizingMask = UIViewAnimatingStateActive;
    imgAppIcon.image = [UIImage imageNamed:@"appIcon.png"];
    imgAppIcon.backgroundColor = UIColor.clearColor;
    imgAppIcon.layer.masksToBounds = true;
    [mainView addSubview:imgAppIcon];
    
    btn1.enabled = NO; btn2.enabled = NO; btn3.enabled = NO; btn4.enabled = NO; btn5.enabled = NO; btn6.enabled = NO;
    tapGesture1.enabled = NO; tapGesture2.enabled = NO; tapGesture3.enabled = NO; tapGesture4.enabled = NO; tapGesture5.enabled = NO;
    tapGesture6.enabled = NO;
    

    //COLOR CHANGE FOR DISABLED
    btn1.backgroundColor = [UIColor colorWithRed:239.0/255.0 green:240.0/255.0 blue:241.0/255. alpha:1];
    btn2.backgroundColor = [UIColor colorWithRed:239.0/255.0 green:240.0/255.0 blue:241.0/255. alpha:1];
    btn3.backgroundColor = [UIColor colorWithRed:239.0/255.0 green:240.0/255.0 blue:241.0/255. alpha:1];
    btn4.backgroundColor = [UIColor colorWithRed:239.0/255.0 green:240.0/255.0 blue:241.0/255. alpha:1];
    btn5.backgroundColor = [UIColor colorWithRed:239.0/255.0 green:240.0/255.0 blue:241.0/255. alpha:1];
    btn6.backgroundColor = [UIColor colorWithRed:239.0/255.0 green:240.0/255.0 blue:241.0/255. alpha:1];
}

#pragma mark - All Button Click Events
-(void)btnSettingsAction
{
    [self stopOldTimer];
     gestureRecognizer = [[UILongPressGestureRecognizer alloc] init];
    [gestureRecognizer addTarget:self action:@selector(LockUnlockLongPressed:)];
    gestureRecognizer.delegate = self;
    imgSettings.userInteractionEnabled =YES;
    [btnSettings addGestureRecognizer: gestureRecognizer];
    gestureRecognizer.enabled = YES;
}
-(void)btnReset1Action
{
    [alert removeFromSuperview];
    alert = [[FCAlertView alloc] init];
    alert.colorScheme = [UIColor blackColor];
    [alert makeAlertTypeWarning];
    [alert addButton:@"Yes" withActionBlock:^
    {
        self->lblOdometer1.text = @"0.00 mi";
        [[NSUserDefaults standardUserDefaults] setDouble:0.0 forKey:@"odo1"];
        [[NSUserDefaults standardUserDefaults] synchronize];
   
    }];
    alert.firstButtonCustomFont = [UIFont fontWithName:CGRegular size:txtSize];
    [alert showAlertInView:self
                 withTitle:@"Redshiftt"
              withSubtitle:@"Are you sure want to reset odometer 1?"
           withCustomImage:[UIImage imageNamed:@"Subsea White 180.png"]
       withDoneButtonTitle:@"No" andButtons:nil];
}
-(void)btnReset2Action
{
    [alert removeFromSuperview];
    alert = [[FCAlertView alloc] init];
    alert.colorScheme = [UIColor blackColor];
    [alert makeAlertTypeWarning];
    [alert addButton:@"Yes" withActionBlock:^
     {
         self->lblOdometer2.text = @"0.00 mi";
         [[NSUserDefaults standardUserDefaults] setDouble:0.0 forKey:@"odo2"];
         [[NSUserDefaults standardUserDefaults] synchronize];
     }];
    alert.firstButtonCustomFont = [UIFont fontWithName:CGRegular size:txtSize];
    [alert showAlertInView:self
                 withTitle:@"Redshiftt"
              withSubtitle:@"Are you sure want to reset odometer 2?"
           withCustomImage:[UIImage imageNamed:@"Subsea White 180.png"]
       withDoneButtonTitle:@"No" andButtons:nil];
}

-(void)LockUnlockLongPressed:(UILongPressGestureRecognizer*)sender
{
    if (sender.state == UIGestureRecognizerStateEnded)
    {
        if (isIgnitionON == NO)
        {
            [alert removeFromSuperview];
            alert = [[FCAlertView alloc] init];
            alert.colorScheme = [UIColor blackColor];
            [alert makeAlertTypeWarning];
            alert.firstButtonCustomFont = [UIFont fontWithName:CGRegular size:txtSize];
            [alert showAlertInView:self
                         withTitle:@"Ignition Off"
                      withSubtitle:@"Ignition is off. You cannot modify settings now."
                   withCustomImage:[UIImage imageNamed:@"Subsea White 180.png"]
               withDoneButtonTitle:@"OK" andButtons:nil];
        }
        else
        {
            if (isKnobAdvertising == NO)
            {
//                if (sender.state == UIGestureRecognizerStateBegan)
                {
                    SettingsVC *pushView = [[SettingsVC alloc]init];
                    [self.navigationController pushViewController:pushView animated:false];
                }
            }
            
        }
    }
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)OrientationDidChange:(NSNotification*)notification
{
    if (lastOrients == [[UIApplication sharedApplication] statusBarOrientation])
    {
        NSLog(@"Both are same");
    }
    else
    {
        NSLog(@"Both are  not same");
        [alert removeFromSuperview];
    }
    lastOrients = [[UIApplication sharedApplication] statusBarOrientation];

    if([[UIApplication sharedApplication] statusBarOrientation]==UIDeviceOrientationLandscapeLeft || [[UIApplication sharedApplication] statusBarOrientation]==UIDeviceOrientationLandscapeRight)
    {
        NSLog(@"Landscape");
        [self setLandscapeFrames];
    }
    else if([[UIApplication sharedApplication] statusBarOrientation]==UIDeviceOrientationPortrait)
    {
        NSLog(@"Potrait Mode");
        [self setUpPortraintFrames];
    }
}
-(void)CheckBatteryValue
{
    int btrVal = [strBatteryValue intValue];
    if(btrVal ==0)
    {
        return;
    }
    if (btrVal <= 20)
    {
        [alert removeFromSuperview];
        alert = [[FCAlertView alloc] init];
        alert.colorScheme = [UIColor blackColor];
        [alert makeAlertTypeWarning];
        alert.firstButtonCustomFont = [UIFont fontWithName:CGRegular size:txtSize];
        [alert showAlertInView:self
                     withTitle:@"Low Battery"
                  withSubtitle:@"20% of battery remaining"
               withCustomImage:[UIImage imageNamed:@"Subsea White 180.png"]
           withDoneButtonTitle:@"OK" andButtons:nil];
    }
}

-(void)setUpPortraintFrames
{
    isPortrait = YES;
    mainView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    int viewHeight = DEVICE_HEIGHT-20;
    int exYY =0;
    if (IS_IPHONE_X)
    {
        viewHeight = DEVICE_HEIGHT-84;
        exYY = 44;
    }
    //All buttons
    btn1.frame = CGRectMake(DEVICE_WIDTH-DEVICE_WIDTH/3,((DEVICE_HEIGHT)-viewHeight/5) -exYY, DEVICE_WIDTH/3, viewHeight/5);
    lblMom1.frame = CGRectMake((btn1.frame.size.width-50)/2, (btn1.frame.size.height-40), 60, 30);
    lblLong1.frame = CGRectMake(0, 0, btn1.frame.size.width, btn1.frame.size.height);

    btn2.frame = CGRectMake(DEVICE_WIDTH-(DEVICE_WIDTH/3*2),((DEVICE_HEIGHT)-viewHeight/5)-exYY, DEVICE_WIDTH/3, viewHeight/5);
    lblMom2.frame = CGRectMake((btn2.frame.size.width-50)/2, (btn2.frame.size.height-40), 60, 30);
    lblLong2.frame = CGRectMake(0, 0, btn2.frame.size.width, btn2.frame.size.height);

    btn3.frame = CGRectMake(0, ((DEVICE_HEIGHT)-(viewHeight/5*2))-exYY, DEVICE_WIDTH/3, viewHeight/5);
    lblMom3.frame = CGRectMake((btn3.frame.size.width-50)/2, (btn3.frame.size.height-40), 60, 30);
    lblLong3.frame = CGRectMake(0, 0, btn3.frame.size.width, btn3.frame.size.height);

    btn4.frame = CGRectMake(0, ((DEVICE_HEIGHT)-(viewHeight/5*3))-exYY, DEVICE_WIDTH/3, viewHeight/5);
    lblMom4.frame = CGRectMake((btn4.frame.size.width-50)/2, (btn4.frame.size.height-40), 60, 30);
    lblLong4.frame = CGRectMake(0, 0, btn4.frame.size.width, btn4.frame.size.height);

    btn5.frame = CGRectMake(0, ((DEVICE_HEIGHT)-(viewHeight/5*4))-exYY, DEVICE_WIDTH/3, viewHeight/5);
    lblMom5.frame = CGRectMake((btn5.frame.size.width-50)/2, (btn5.frame.size.height-40), 60, 30);
    lblLong5.frame = CGRectMake(0, 0, btn5.frame.size.width, btn5.frame.size.height);

    btn6.frame = CGRectMake(0, ((DEVICE_HEIGHT)-(viewHeight/5*5))-exYY, DEVICE_WIDTH/3, viewHeight/5);
    lblMom6.frame = CGRectMake((btn6.frame.size.width-50)/2, (btn6.frame.size.height-40), 60, 30);
    lblLong6.frame = CGRectMake(0, 0, btn6.frame.size.width, btn6.frame.size.height);
    
    btnSettings.frame = CGRectMake(0, ((DEVICE_HEIGHT)-viewHeight/5)-exYY, DEVICE_WIDTH/3, viewHeight/5);
    imgSettings.frame = CGRectMake((btnSettings.frame.size.width-40)/2,( btnSettings.frame.size.height-40)/2, 40, 40);
    imgLock.frame = CGRectMake((btnSettings.frame.size.width-30)/2,(( btnSettings.frame.size.height-60)/2)+30, 30, 30);
    
    
    //Other Labels
    yy = 20;
    if (IS_IPHONE_X)
    {
        yy = 44;
    }
    int Yadjust = 55;
    if (IS_IPHONE_4)
    {
        Yadjust = 40;
    }
    else if (IS_IPHONE_5)
    {
        Yadjust = 50;
    }
    else if (IS_IPHONE_6plus)
    {
        Yadjust = 60;
    }
    else if (IS_IPHONE_X)
    {
        Yadjust = 65;
    }
    yy=yy+5;
    lblTimeView.frame = CGRectMake((DEVICE_WIDTH/3), yy, ((DEVICE_WIDTH/3)*2), 40);
    lblTime.frame = CGRectMake(5, 0, lblTimeView.frame.size.width-10, 40);
    
    yy=yy+Yadjust+5;
    lblSpeedView.frame =CGRectMake((DEVICE_WIDTH/3), yy,((DEVICE_WIDTH/3)*2), 40);
    lblSpeed.frame = CGRectMake(5,0, lblSpeedView.frame.size.width-10, 40);
    lblSpeed.textAlignment = NSTextAlignmentLeft;
    
    yy = yy+Yadjust+5;
    lblHeadingsView.frame = CGRectMake((DEVICE_WIDTH/3), yy, ((DEVICE_WIDTH/3)*2), 40);
    lblHeadings.frame = CGRectMake(5, 0, lblHeadingsView.frame.size.width-10, 40);
    
    yy = yy+Yadjust+5;
    lblAltitudeView.frame = CGRectMake(((DEVICE_WIDTH/3)), yy,((DEVICE_WIDTH/3)*2), 40);
    lblAltitude.frame = CGRectMake(5, 0, lblAltitudeView.frame.size.width-10, 40);
    lblAltitude.textAlignment = NSTextAlignmentLeft;
    
    yy =  yy + Yadjust + 5;
   
    lblOdometersView.frame = CGRectMake((DEVICE_WIDTH/3),yy,((DEVICE_WIDTH/3)*2), 100);
    lblOdometer1.frame = CGRectMake(5, 0, lblOdometersView.frame.size.width-80+15, 40);
    lblOdometer2.frame = CGRectMake(5, Yadjust +5, lblOdometersView.frame.size.width-80+15, 40);
    btnReset1.frame = CGRectMake((lblOdometersView.frame.size.width/2)+48, 5,(lblOdometersView.frame.size.width/2)-50, 35);
    btnReset2.frame = CGRectMake((lblOdometersView.frame.size.width/2)+48,Yadjust + 10,(lblOdometersView.frame.size.width/2)-50, 35);
    
    btnReset1.layer.cornerRadius = (btnReset1.frame.size.width * 8)/110;
    btnReset2.layer.cornerRadius = (btnReset2.frame.size.width * 8)/110;

    yy =  yy + 13 + Yadjust * 2 ;

    lblVoltageView.frame = CGRectMake((DEVICE_WIDTH/3), yy,((DEVICE_WIDTH/3)*2), 40);
    lblVoltage.frame = CGRectMake(5,0, lblVoltageView.frame.size.width-10, 40);
    
    yy =  yy + 5 + Yadjust +10;
    
    imgAppIcon.frame = CGRectMake(((DEVICE_WIDTH)-200*approaxSize), yy,200*approaxSize, 21*approaxSize);
    
    if (relayDashedSelected > 0)
    {
        imgLock.frame = CGRectMake((btnSettings.frame.size.width-30)/2,(( btnSettings.frame.size.height-30)/2)+0, 30, 30);
        
        UIButton *btnTmp = (UIButton *)[self.view viewWithTag:relayDashedSelected];
        btnTmp.backgroundColor = [UIColor redColor];
        [btnTmp setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        btnTmp.layer.borderColor = [UIColor blackColor].CGColor;
        UIColor *borderColor;
        if ([arrStatusActive containsObject:[NSString stringWithFormat:@"%d",relayDashedSelected]])
        {
            btnTmp.backgroundColor = [UIColor redColor];
            borderColor = [UIColor blackColor];
        }
        else
        {
            btnTmp.backgroundColor = UIColor.whiteColor;
            borderColor = [UIColor blackColor];
        }
        
        yourViewBorder.lineDashPattern = @[@10, @15];
        yourViewBorder.frame = btnTmp.bounds;
        yourViewBorder.path = [UIBezierPath bezierPathWithRect:btnTmp.bounds].CGPath;
        yourViewBorder.lineWidth = 15;
        [btnTmp.layer addSublayer:yourViewBorder];
        
    }
    
}
#pragma mark - Convert Values based on Units
-(void)ConvertValuesbasedonUnits
{
    if ([[[NSUserDefaults standardUserDefaults]valueForKey:@"unitType"] isEqualToString:@"English-SAE"])
    {
        lblSpeedValue.text = @"Speed";
    }
}
-(void)GlobalBLuetoothCheck
{
    [dictActive setObject:@"off" forKey:@"1"];
    [dictActive setObject:@"off" forKey:@"2"];
    [dictActive setObject:@"off" forKey:@"3"];
    [dictActive setObject:@"off" forKey:@"4"];
    [dictActive setObject:@"off" forKey:@"5"];
    [dictActive setObject:@"off" forKey:@"6"];
    [arrStatusActive removeAllObjects];
    arrStatusActive = [[NSMutableArray alloc] init];

    
    btn1.enabled = NO; btn2.enabled = NO; btn3.enabled = NO; btn4.enabled = NO; btn5.enabled = NO; btn6.enabled = NO;
    //        longpress1.enabled = NO;
    lblLong1.hidden = YES;lblLong2.hidden = YES;lblLong3.hidden = YES;lblLong4.hidden = YES;lblLong5.hidden = YES;lblLong6.hidden = YES;
    
    //COLOR CHANGE FOR DISABLED
    btn1.backgroundColor = [UIColor colorWithRed:239.0/255.0 green:240.0/255.0 blue:241.0/255. alpha:1];
    btn2.backgroundColor = [UIColor colorWithRed:239.0/255.0 green:240.0/255.0 blue:241.0/255. alpha:1];
    btn3.backgroundColor = [UIColor colorWithRed:239.0/255.0 green:240.0/255.0 blue:241.0/255. alpha:1];
    btn4.backgroundColor = [UIColor colorWithRed:239.0/255.0 green:240.0/255.0 blue:241.0/255. alpha:1];
    btn5.backgroundColor = [UIColor colorWithRed:239.0/255.0 green:240.0/255.0 blue:241.0/255. alpha:1];
    btn6.backgroundColor = [UIColor colorWithRed:239.0/255.0 green:240.0/255.0 blue:241.0/255. alpha:1];

    [yourViewBorder removeFromSuperlayer];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Redshift" message:@"Please enable Bluetooth Connection. To enable swipe up from bottom of the display and tap on Bluetooth icon." preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {}];
    [alertController addAction:defaultAction];
    [self presentViewController:alertController animated:true completion:nil];
}
-(void)CheckKnobStaus
{
    if (isKnobAdvertising)
    {
        relayDashedSelected = 0;
        isKnobAdvertising = NO;

    }
    else
    {
        UIButton * btnSelected = (UIButton *)[self.view viewWithTag:relayDashedSelected];
        btnSelected.layer.borderColor = [UIColor blackColor].CGColor;
        [yourViewBorder removeFromSuperlayer];
        
        gestureRecognizer.enabled = YES;
        imgSettings.image = [UIImage imageNamed:@"settings.png"];
        imgLock.image = [UIImage imageNamed:@"lock.png"];
        imgSettings.hidden = NO;
        imgLock.hidden = NO;
        imgLock.frame = CGRectMake((btnSettings.frame.size.width-40)/2,(( btnSettings.frame.size.height-40)/2)+30, 40, 40);
        btnSettings.backgroundColor = [UIColor whiteColor];
        
      

    }
    
    if (isDataScanning)
    {
        isDataScanning = NO;
    }
    else
    {
        btn1.enabled = NO; btn2.enabled = NO; btn3.enabled = NO; btn4.enabled = NO; btn5.enabled = NO; btn6.enabled = NO;
        lblLong1.hidden = YES; lblLong2.hidden = YES; lblLong3.hidden = YES; lblLong4.hidden = YES; lblLong5.hidden = YES;
        lblLong6.hidden = YES;
        
        [dictActive setObject:@"off" forKey:@"1"];
        [dictActive setObject:@"off" forKey:@"2"];
        [dictActive setObject:@"off" forKey:@"3"];
        [dictActive setObject:@"off" forKey:@"4"];
        [dictActive setObject:@"off" forKey:@"5"];
        [dictActive setObject:@"off" forKey:@"6"];
        [arrStatusActive removeAllObjects];
        arrStatusActive = [[NSMutableArray alloc] init];

        //COLOR CHANGE FOR DISABLED
        btn1.backgroundColor = [UIColor colorWithRed:239.0/255.0 green:240.0/255.0 blue:241.0/255. alpha:1];
        btn2.backgroundColor = [UIColor colorWithRed:239.0/255.0 green:240.0/255.0 blue:241.0/255. alpha:1];
        btn3.backgroundColor = [UIColor colorWithRed:239.0/255.0 green:240.0/255.0 blue:241.0/255. alpha:1];
        btn4.backgroundColor = [UIColor colorWithRed:239.0/255.0 green:240.0/255.0 blue:241.0/255. alpha:1];
        btn5.backgroundColor = [UIColor colorWithRed:239.0/255.0 green:240.0/255.0 blue:241.0/255. alpha:1];
        btn6.backgroundColor = [UIColor colorWithRed:239.0/255.0 green:240.0/255.0 blue:241.0/255. alpha:1];

        isIgnitionON = NO;
        lblMom1.hidden = true;
        lblMom2.hidden = true;
        lblMom3.hidden = true;
        lblMom4.hidden = true;
        lblMom5.hidden = true;
        lblMom6.hidden = true;
    }
}
#pragma mark - set LandScape UI frames
-(void) setLandscapeFrames
{
    isPortrait = NO;
    mainView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    
    int viewHeight = DEVICE_HEIGHT - 20;
    int viewWidth = DEVICE_WIDTH;
    int yy = 20;
    
    if (self.view.frame.size.height == 375 && self.view.frame.size.width == 812)
    {
        mainView.frame = CGRectMake(44, 0, self.view.frame.size.width-44-40, self.view.frame.size.height);
        viewWidth = self.view.frame.size.width-44-40;
        viewHeight = DEVICE_HEIGHT - 40-44;
    }
    
    btnSettings.frame = CGRectMake(0,20, viewWidth/5, viewHeight/3);
    btn1.frame = CGRectMake(0, ((viewHeight/3)*2)+yy, viewWidth/5, viewHeight/3);
    lblLong1.frame = CGRectMake(0, 0, btn1.frame.size.width, btn1.frame.size.height);
    lblMom1.frame = CGRectMake((btn1.frame.size.width-50)/2, (btn1.frame.size.height-40), 60, 30);
    
    btn2.frame = CGRectMake(0,(viewHeight/3)+yy, viewWidth/5, viewHeight/3);
    lblLong2.frame = CGRectMake(0, 0, btn2.frame.size.width, btn2.frame.size.height);
    lblMom2.frame = CGRectMake((btn2.frame.size.width-50)/2, (btn2.frame.size.height-40), 60, 30);
    
    btn3.frame = CGRectMake(viewWidth/5,yy, viewWidth/5, viewHeight/3);
    lblLong3.frame = CGRectMake(0, 0, btn3.frame.size.width, btn3.frame.size.height);
    lblMom3.frame = CGRectMake((btn3.frame.size.width-50)/2, (btn3.frame.size.height-40), 60, 30);
    
    btn4.frame = CGRectMake((viewWidth/5)*2,yy, viewWidth/5, viewHeight/3);
    lblLong4.frame = CGRectMake(0, 0, btn4.frame.size.width, btn4.frame.size.height);
    lblMom4.frame = CGRectMake((btn4.frame.size.width-50)/2, (btn4.frame.size.height-40), 60, 30);
    
    btn5.frame = CGRectMake((viewWidth/5)*3,yy, viewWidth/5, viewHeight/3);
    lblLong5.frame = CGRectMake(0, 0, btn5.frame.size.width, btn5.frame.size.height);
    lblMom5.frame = CGRectMake((btn5.frame.size.width-50)/2, (btn5.frame.size.height-40), 60, 30);
    
    btn6.frame = CGRectMake((viewWidth/5)*4,yy, viewWidth/5, viewHeight/3);
    lblMom6.frame = CGRectMake((btn6.frame.size.width-50)/2, (btn6.frame.size.height-40), 60, 30);
    lblLong6.frame = CGRectMake(0, 0, btn6.frame.size.width, btn6.frame.size.height);
    
    
    lblMom1.font = [UIFont fontWithName:CGRegular size:17];
    lblMom2.font = [UIFont fontWithName:CGRegular size:17];
    lblMom3.font = [UIFont fontWithName:CGRegular size:17];
    lblMom4.font = [UIFont fontWithName:CGRegular size:17];
    lblMom5.font = [UIFont fontWithName:CGRegular size:17];
    lblMom6.font = [UIFont fontWithName:CGRegular size:17];
    yy = yy+0;
    
    int bottomViewHeight = ((DEVICE_HEIGHT-20)/3)*2;
    int boxHeight = bottomViewHeight/4;
    int bottomYindex = ((DEVICE_HEIGHT-20)/3)+20;
    
    lblTimeView.frame = CGRectMake((viewWidth)/5,bottomYindex,(viewWidth-viewWidth/5)/2,boxHeight);
    lblVoltageView.frame = CGRectMake(viewWidth - ((viewWidth-viewWidth/5)/2), bottomYindex,(viewWidth-viewWidth/5)/2,boxHeight);
    
    bottomYindex = bottomYindex+boxHeight;
    lblSpeedView.frame = CGRectMake((viewWidth/5),bottomYindex,(viewWidth-viewWidth/5)/2,boxHeight);
    lblSpeed.textAlignment = NSTextAlignmentLeft;
    lblSpeedValue.textAlignment = NSTextAlignmentLeft;
    lblOdometersView.frame = CGRectMake(viewWidth - ((viewWidth-viewWidth/5)/2), bottomYindex, (viewWidth-viewWidth/5)/2, boxHeight*2);
    
    bottomYindex = bottomYindex+boxHeight;
    lblHeadingsView.frame = CGRectMake((viewWidth/5),bottomYindex,(viewWidth-viewWidth/5)/2,boxHeight);
    bottomYindex = bottomYindex+boxHeight;
    lblAltitudeView.frame = CGRectMake((viewWidth/5),bottomYindex,(viewWidth-viewWidth/5)/2,boxHeight);
    lblAltitude.textAlignment = NSTextAlignmentLeft;
    lblAltitudeLbl.textAlignment = NSTextAlignmentLeft;
    
    imgAppIcon.frame = CGRectMake(viewWidth - 200*approaxSize -10, bottomYindex+9,200*approaxSize, 21*approaxSize);
    
    imgSettings.frame = CGRectMake((btnSettings.frame.size.width-40)/2,( btnSettings.frame.size.height-40)/2, 40, 40);
    imgLock.frame = CGRectMake((btnSettings.frame.size.width-30)/2,(( btnSettings.frame.size.height-60)/2)+30, 30, 30);
    
    lblOdometer1.frame = CGRectMake(5, 5, (lblOdometersView.frame.size.width/2)+30, 35);
    lblOdometer2.frame = CGRectMake(5, 53, (lblOdometersView.frame.size.width/2)+30, 35);
    btnReset1.frame = CGRectMake((lblOdometersView.frame.size.width/2)+35, 5,(lblOdometersView.frame.size.width/2)-40, 35);
    btnReset2.frame = CGRectMake((lblOdometersView.frame.size.width/2)+35,53,(lblOdometersView.frame.size.width/2)-40, 35);
    
    lblOdometer1.backgroundColor = [UIColor clearColor];
    if (self.view.frame.size.height == 320 )
    {
        lblOdometer1.frame = CGRectMake(5, 5, (lblOdometersView.frame.size.width/2)+30+20, 35);
        lblOdometer2.frame = CGRectMake(5, 53, (lblOdometersView.frame.size.width/2)+30+20, 35);
        btnReset1.frame = CGRectMake((lblOdometersView.frame.size.width/2)+35+20, 5,(lblOdometersView.frame.size.width/2)-60, 35);
        btnReset2.frame = CGRectMake((lblOdometersView.frame.size.width/2)+35+20,53,(lblOdometersView.frame.size.width/2)-60, 35);
    }
    if (self.view.frame.size.height == 375 && self.view.frame.size.width == 812)
    {
        lblOdometer1.frame = CGRectMake(5, 5, (lblOdometersView.frame.size.width/2)+30+50, 35);
        lblOdometer2.frame = CGRectMake(5, 53, (lblOdometersView.frame.size.width/2)+30+50, 35);

        btnReset1.frame = CGRectMake((lblOdometersView.frame.size.width/2)+35+50, 5,(lblOdometersView.frame.size.width/2)-90, 35);
        btnReset2.frame = CGRectMake((lblOdometersView.frame.size.width/2)+35+50,53,(lblOdometersView.frame.size.width/2)-90, 35);
        imgAppIcon.frame = CGRectMake(lblOdometersView.frame.origin.x, bottomYindex+9,200*approaxSize, 21*approaxSize);
    }
    if (relayDashedSelected == 0)
    {
    }
    else
    {
        imgLock.frame = CGRectMake((btnSettings.frame.size.width-30)/2,(( btnSettings.frame.size.height-30)/2)+0, 30, 30);
        
        UIButton *btnTmp = (UIButton *)[self.view viewWithTag:relayDashedSelected];
        btnTmp.backgroundColor = [UIColor redColor];
        [btnTmp setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        btnTmp.layer.borderColor = [UIColor blackColor].CGColor;
        
        UIColor *borderColor;
        if ([arrStatusActive containsObject:[NSString stringWithFormat:@"%d",relayDashedSelected]])
        {
            btnTmp.backgroundColor = [UIColor redColor];
            borderColor = [UIColor blackColor];
        }
        else
        {
            btnTmp.backgroundColor = UIColor.whiteColor;
            borderColor = [UIColor blackColor];
        }
        yourViewBorder.lineDashPattern = @[@10, @15];
        yourViewBorder.frame = btnTmp.bounds;
        yourViewBorder.path = [UIBezierPath bezierPathWithRect:btnTmp.bounds].CGPath;
        yourViewBorder.lineWidth = 15;
        [btnTmp.layer addSublayer:yourViewBorder];        
    }
    btnReset1.layer.cornerRadius = (btnReset1.frame.size.width * 8)/110;
    btnReset2.layer.cornerRadius = (btnReset2.frame.size.width * 8)/110;
    
}
-(void)getLocationMethod
{
    NSLog(@"%s",__FUNCTION__);
    /*-----------Start Location Manager----------*/
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.distanceFilter = 0; // whenever we move
    locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation; // 100 m
    if(IS_OS_8_OR_LATER) {
        [locationManager requestWhenInUseAuthorization];
    }
    [locationManager startUpdatingLocation];
    
    // Start heading updates.
    if ([CLLocationManager locationServicesEnabled]&&[CLLocationManager headingAvailable])
    {
        [locationManager startUpdatingLocation];//开启定位服务
        [locationManager startUpdatingHeading];//开始获得航向数据
    }
    /*-------------------------------------------*/
}
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    NSLog(@"Location Update>>>>>>>>>");
    CLLocation * lastLocation = locations.lastObject;
    CLLocation * startLocation = locations.firstObject;
    
    savedLastLocation = lastLocation;
    
    NSDateFormatter * dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"HH:mm:ss"];
    lblTime.text = [dateFormat stringFromDate:[NSDate date]];
    lblSpeed.text = [NSString stringWithFormat:@"%.1f MPH",lastLocation.speed * 0.00062137];
    lblAltitude.text = [NSString stringWithFormat:@"%.0f M",lastLocation.altitude];
    
    if (startLocation == nil)
    {
        startLocation = locations.firstObject;
    }
    else
    {
        lastLocation = locations.lastObject;
        double distancess = [previousLocation distanceFromLocation:lastLocation];
        startLocation = lastLocation;
        totalDistance += distancess;
        if (previousLocation == nil)
        {
            totalDistance = 0;
            distancess = 0;
        }
        previousLocation = lastLocation;
        double odo1 = [[NSUserDefaults standardUserDefaults] doubleForKey:@"odo1"];
        double odo2 = [[NSUserDefaults standardUserDefaults] doubleForKey:@"odo2"];
        
        odo1 = odo1 + distancess;
        odo2 = odo2 + distancess;
        
        BOOL isUnitODO1 = NO;
        BOOL isUnitODO2 = NO;
        
        if ([[[NSUserDefaults standardUserDefaults]valueForKey:@"odometer1"] isEqualToString:@"Unit"])
        {
            isUnitODO1 = YES;
        }
        if ([[[NSUserDefaults standardUserDefaults]valueForKey:@"odometer2"] isEqualToString:@"Unit"])
        {
            isUnitODO2 = YES;
        }
        if (distancess > 0)
        {
            if ([[[NSUserDefaults standardUserDefaults]valueForKey:@"unitType"] isEqualToString:@"English-SAE"])
            {
                if (isUnitODO1){ lblOdometer1.text = [NSString stringWithFormat:@"%.0f mi", odo1 *  0.000621371]; }
                else { lblOdometer1.text = [NSString stringWithFormat:@"%.2f mi", odo1 *  0.000621371];  }
                
                if (isUnitODO2){ lblOdometer2.text = [NSString stringWithFormat:@"%.0f mi", odo2 *  0.000621371]; }
                else { lblOdometer2.text = [NSString stringWithFormat:@"%.2f mi", odo2 *  0.000621371];  }
                
            }
            else
            {
                if (isUnitODO1) { lblOdometer1.text = [NSString stringWithFormat:@"%.0f km", odo1 * 0.001]; }
                else { lblOdometer1.text = [NSString stringWithFormat:@"%.2f km", odo1 * 0.001]; }
                
                if (isUnitODO2) { lblOdometer2.text = [NSString stringWithFormat:@"%.0f km",odo2 * 0.001];}
                else {lblOdometer2.text = [NSString stringWithFormat:@"%.2f km",odo2 * 0.001]; }
            }
            
            [[NSUserDefaults standardUserDefaults] setDouble:odo1 forKey:@"odo1"];
            [[NSUserDefaults standardUserDefaults] setDouble:odo2 forKey:@"odo2"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        else
        {
            double newOdo1 = [[NSUserDefaults standardUserDefaults] doubleForKey:@"odo1"];
            double newOdo2 = [[NSUserDefaults standardUserDefaults] doubleForKey:@"odo2"];
            
            if ([[[NSUserDefaults standardUserDefaults]valueForKey:@"unitType"] isEqualToString:@"English-SAE"])
            {
                if (isUnitODO1){ lblOdometer1.text = [NSString stringWithFormat:@"%.0f mi", newOdo1 *  0.000621371]; }
                else { lblOdometer1.text = [NSString stringWithFormat:@"%.2f mi", newOdo1 *  0.000621371];  }
                
                if (isUnitODO2){ lblOdometer2.text = [NSString stringWithFormat:@"%.0f mi", newOdo2 *  0.000621371]; }
                else { lblOdometer2.text = [NSString stringWithFormat:@"%.2f mi", newOdo2 *  0.000621371];  }
            }
            else
            {
                if (isUnitODO1) { lblOdometer1.text = [NSString stringWithFormat:@"%.0f km", newOdo1 * 0.001]; }
                else { lblOdometer1.text = [NSString stringWithFormat:@"%.2f km", newOdo1 * 0.001]; }
                
                if (isUnitODO2) { lblOdometer2.text = [NSString stringWithFormat:@"%.0f km",newOdo2 * 0.001];}
                else {lblOdometer2.text = [NSString stringWithFormat:@"%.2f km",newOdo2 * 0.001]; }
            }
            
        }
    }
    if (![[APP_DELEGATE checkforValidString:lblOdometer1.text] isEqualToString:@"NA"])
    {
        if ([lblOdometer1.text length]>8)
        {
            if (isPortrait)
            {
                [lblOdometer1 setFont:[UIFont fontWithName:CGRegular size:txtSize+fontHght-6]];
                [lblOdometer2 setFont:[UIFont fontWithName:CGRegular size:txtSize+fontHght-6]];
            }
            else
            {
                [lblOdometer1 setFont:[UIFont fontWithName:CGRegular size:txtSize+fontHght-4]];
                [lblOdometer2 setFont:[UIFont fontWithName:CGRegular size:txtSize+fontHght-4]];
            }
        }
    }
    double totalSpeed = lastLocation.speed;
    if (totalSpeed < 0)
    {
        totalSpeed = 0 ;
    }
    if ([[[NSUserDefaults standardUserDefaults]valueForKey:@"unitType"] isEqualToString:@"English-SAE"])
    {
        lblSpeed.text = [NSString stringWithFormat:@"%.2f MPH",totalSpeed];
        lblAltitude.text = [NSString stringWithFormat:@"%.0f feet",lastLocation.altitude *  3.2808399];
    }
    else
    {
        lblSpeed.text = [NSString stringWithFormat:@"%.2f KPH",totalSpeed * 3.6];
        lblAltitude.text = [NSString stringWithFormat:@"%.0f meters",lastLocation.altitude];
    }
    
}
- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading
{
    UIDevice *device =[UIDevice currentDevice];
    if (newHeading.headingAccuracy>0)
    {
        float heading =[self heading:newHeading.trueHeading fromOrirntation:device.orientation];
        NSString *geoDirectionString = [[NSString alloc] init];
        if(heading >22.5 && heading <= 67.5)
        {
            geoDirectionString = @"NE";
        } else if(heading >67.5 && heading <= 112.5)
        {
            geoDirectionString = @"E";
        } else if(heading >112.5 && heading <= 157.5)
        {
            geoDirectionString = @"SE";
        } else if(heading >157.5 && heading <= 202.5)
        {
            geoDirectionString = @"S";
        } else if(heading >202.5 && heading <= 247.5)
        {
            geoDirectionString = @"SW";
        } else if(heading >247.5 && heading <= 292.5)
        {
            geoDirectionString = @"W";
        } else if(heading >292.5 && heading <= 337.5)
        {
            geoDirectionString = @"NW";
        } else if(heading >337.5 || heading <= 22.5)
        {
            geoDirectionString = @"N";
        }
        lblHeadings.text = [NSString stringWithFormat:@"%.0f %@",heading,geoDirectionString];
    }
}
-(float)heading:(float)heading fromOrirntation:(UIDeviceOrientation)orientation{
    
    float realHeading =heading;
    switch (orientation) {
        case UIDeviceOrientationPortrait:
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            realHeading=heading-180.0f;
            break;
        case UIDeviceOrientationLandscapeLeft:
            realHeading=heading+90.0f;
            break;
        case UIDeviceOrientationLandscapeRight:
            realHeading=heading-90.0f;
            break;
        default:
            break;
    }
    if (realHeading>360.0f)
    {
        realHeading-=360.0f;
    }
    else if (realHeading<0.0f)
    {
        realHeading+=360.0f;
    }
    return  realHeading;
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"error===%@",error);
    NSLog(@"%s",__FUNCTION__);
}
#pragma mark - BLE Scanning Methods
#pragma mark - CentralManager Ble delegate Methods
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    NSLog(@"DidupdateCenterlState=%ld",(long)central.state);
    
    if (@available(iOS 10.0, *))
    {
        if (central.state == CBCentralManagerStatePoweredOff || central.state == CBManagerStateUnknown)
        {
            [self GlobalBLuetoothCheck];
            
        }
    }
    else
    {
        if (central.state == CBCentralManagerStatePoweredOff)
        {
            [self GlobalBLuetoothCheck];
        }
    }
    if (central.state == CBCentralManagerStatePoweredOn)
    {
        NSArray* connectedDevices = [centralManager retrieveConnectedPeripheralsWithServices:@[[CBUUID UUIDWithString:@"0000AD00-D102-11E1-9B23-00025B002B2B"]]];
        for (CBPeripheral *uuid in connectedDevices)
        {
            NSLog(@"Device Found. UUID = %@", uuid);
            //            [[BLEManager sharedManager] disconnectDevice:uuid];
        }
    }
}

-(void)InitialBLE
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"BLEScannedDevicelistShowhere" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(BLEScannedDevicelistShowhere:) name:@"BLEScannedDevicelistShowhere" object:nil];

    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UpdateKnobSelection" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(UpdateKnobSelection:) name:@"UpdateKnobSelection" object:nil];

}

#pragma mark - WHATEVER SCANNED FROM BLE WILL COME HERE.....
-(void)BLEScannedDevicelistShowhere:(NSNotification*)notification//Update peripheral
{
    NSDateFormatter * dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"HH:mm:ss"];
    lblTime.text = [dateFormat stringFromDate:[NSDate date]];

    isDataScanning = YES;
    [APP_DELEGATE endHudProcess];
    if ( isStopUpdate == YES)
    {
//        return;
    }
    NSString * strResult = [[BLEManager sharedManager] strMainscreenRelay];
//    if ([strPrevousMainData isEqualToString:strResult])
//    {
//    }
//    else
    {
        strPrevousMainData = strResult;
        /* 1 Start================ Which Relay Connected (Not connected in Gray)=================*/
        NSRange rangeMask = NSMakeRange(2,2);
        NSString * strConnected = [strResult substringWithRange:rangeMask];
        if (![strConnected isEqualToString:strPrevConnected])
        {
            strPrevConnected = strConnected;
            
            NSString * strBinaryConnected = [APP_DELEGATE hexToBinary:strConnected];
            btn1.enabled = NO; btn2.enabled = NO; btn3.enabled = NO; btn4.enabled = NO; btn5.enabled = NO; btn6.enabled = NO;
            lblLong1.hidden = YES; lblLong2.hidden = YES; lblLong3.hidden = YES; lblLong4.hidden = YES; lblLong5.hidden = YES;
            lblLong6.hidden = YES;
            
            //COLOR CHANGE FOR DISABLED
            btn1.backgroundColor = [UIColor colorWithRed:239.0/255.0 green:240.0/255.0 blue:241.0/255. alpha:1];
            btn2.backgroundColor = [UIColor colorWithRed:239.0/255.0 green:240.0/255.0 blue:241.0/255. alpha:1];
            btn3.backgroundColor = [UIColor colorWithRed:239.0/255.0 green:240.0/255.0 blue:241.0/255. alpha:1];
            btn4.backgroundColor = [UIColor colorWithRed:239.0/255.0 green:240.0/255.0 blue:241.0/255. alpha:1];
            btn5.backgroundColor = [UIColor colorWithRed:239.0/255.0 green:240.0/255.0 blue:241.0/255. alpha:1];
            btn6.backgroundColor = [UIColor colorWithRed:239.0/255.0 green:240.0/255.0 blue:241.0/255. alpha:1];
            
            arrConnectedRelay = [[NSMutableArray alloc] init];
            for (int i=0; i<[strBinaryConnected length]; i++)
            {
                NSRange range71 = NSMakeRange(i,1);
                NSString * strCheck = [strBinaryConnected substringWithRange:range71];
                if ([strCheck isEqualToString:@"1"])
                {
                    [arrConnectedRelay addObject:[NSString stringWithFormat:@"%d",8-i]];
                    [self MakeRelayButtonEnabledDisabledbasedOnConnected:[NSString stringWithFormat:@"%d",8-i]];
                }
            }
        }
        
        /* 2 Start=================Relay State Active/Inactive=================*/
        rangeMask = NSMakeRange(4,2);
        NSString * strActiveState = [strResult substringWithRange:rangeMask];
        NSLog(@"Active=%@",strActiveState);

        if (![strActiveState isEqualToString:strPrevActive])
        {
            strPrevActive = strActiveState;
            
            NSString * strBinaryActiveState = [APP_DELEGATE hexToBinary:strActiveState];
            arrStatusActive = [[NSMutableArray alloc] init];
            for (int i=0; i<[strBinaryActiveState length]; i++)
            {
                NSRange range71 = NSMakeRange(i,1);
                NSString * strCheck = [strBinaryActiveState substringWithRange:range71];
                [dictActive setObject:@"off" forKey:[NSString stringWithFormat:@"%d",8-i]];
                if ([strCheck isEqualToString:@"1"])
                {
                    [arrStatusActive addObject:[NSString stringWithFormat:@"%d",8-i]];
                    [self ChangeButtonStatusforActiveInactive:[NSString stringWithFormat:@"%d",8-i] withStatus:YES];
                    [dictActive setObject:@"on" forKey:[NSString stringWithFormat:@"%d",8-i]];
                }
                else
                {
                    [self ChangeButtonStatusforActiveInactive:[NSString stringWithFormat:@"%d",8-i] withStatus:NO];
                }
            }
        }
        
        /* 3 Start=================Check Trigger Switch Value (Latching/Momentary)=================*/
        rangeMask = NSMakeRange(6,2);
        NSString * strTriggerValue = [strResult substringWithRange:rangeMask];
//        if (![strTriggerValue isEqualToString:strPrevTrigger])
        {
            btn1.enabled = NO; btn2.enabled = NO; btn3.enabled = NO; btn4.enabled = NO; btn5.enabled = NO; btn6.enabled = NO;
            lblLong1.hidden = YES; lblLong2.hidden = YES; lblLong3.hidden = YES; lblLong4.hidden = YES; lblLong5.hidden = YES;
            lblLong6.hidden = YES;

            strPrevTrigger = strTriggerValue;

            NSString * strTriggerBinary = [APP_DELEGATE hexToBinary:strTriggerValue];
            lblMom1.hidden = YES; lblMom2.hidden = YES; lblMom3.hidden = YES; lblMom4.hidden = YES; lblMom5.hidden = YES; lblMom6.hidden = YES;
            
            for (int i=0; i<[strTriggerBinary length]; i++)
            {
                NSRange range71 = NSMakeRange(i,1);
                NSString * strCheck = [strTriggerBinary substringWithRange:range71];
                NSMutableDictionary * tmpDict = [[NSMutableDictionary alloc] init];
                tmpDict = [[[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"Relay%d",8-i]] mutableCopy];
                
                if ([strCheck isEqualToString:@"1"])
                {
                    [tmpDict setValue:@"Momentary"  forKey:@"switchtype"];
                    [self setRelayMomentaryStatus:[NSString stringWithFormat:@"%d",8-i]];
                }
                else
                {
                    [tmpDict setValue:@"Latch On-Off"  forKey:@"switchtype"];
                }
                [[NSUserDefaults standardUserDefaults] setValue:tmpDict forKey:[NSString stringWithFormat:@"Relay%d",8-i]];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
        }
//        if ([strTriggerValue isEqualToString:@"00"])
//        {
//            lblLong1.hidden = YES; lblLong1.hidden = YES; lblLong1.hidden = YES; lblLong1.hidden = YES; lblLong1.hidden = YES; lblLong1.hidden = YES;
//            btn1.enabled = YES; btn2.enabled = YES; btn3.enabled = YES; btn4.enabled = YES; btn5.enabled = YES; btn6.enabled = YES;
//
//        }
//
        /* 5 Start=================Fetch System Voltage=================*/
        rangeMask = NSMakeRange(8,2);
        NSString * strVoltage = [strResult substringWithRange:rangeMask];
        
        NSString * strinfromHex = [APP_DELEGATE stringFroHex:strVoltage];
        if (![[APP_DELEGATE checkforValidString:strinfromHex] isEqualToString:@"NA"])
        {
            lblVoltage.text = [NSString stringWithFormat:@"%.2f V", [strinfromHex floatValue]/10];
        }
        
        /* 6 Start=================Ignition Time Value=================*/
        rangeMask = NSMakeRange(10,2);
        NSString * strIgnitionTime = [strResult substringWithRange:rangeMask];
        NSString * strFinalTime = [APP_DELEGATE stringFroHex:strIgnitionTime];
        if (![[APP_DELEGATE checkforValidString:strFinalTime] isEqualToString:@"NA"])
        {
            [[NSUserDefaults standardUserDefaults] setValue:strFinalTime forKey:@"ignitiontime"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        
        /* 6 Start=================Ignition State(ON/OFF) Value=================*/
        rangeMask = NSMakeRange(12,2);
        NSString * strIgnState = [strResult substringWithRange:rangeMask];
//        if (![strIgnState isEqualToString:strPrevIgnStatus])
        {
            strPrevIgnStatus = strIgnState;
            NSString * strFinalIgnionState = [APP_DELEGATE stringFroHex:strIgnState];
            if (![[APP_DELEGATE checkforValidString:strFinalIgnionState] isEqualToString:@"NA"])
            {
                if ([strFinalIgnionState isEqualToString:@"1"])
                {
                    if (isIgnitionON == NO)
                    {
                        strPrevActive = @"";
                    }
                    isIgnitionON = YES;
                    [self makeAllButtonEnabled:YES];
                }
                else
                {
                    isIgnitionON = NO;
                    [self makeAllButtonEnabled:NO];
//                    imgSettings.image = [UIImage imageNamed:@"settings.png"];
//                    imgSettings.hidden = NO;
//                    btnSettings.backgroundColor = [UIColor whiteColor];

                }
                [[NSUserDefaults standardUserDefaults] setValue:strFinalIgnionState forKey:@"ignitionstate"];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
        }
        
        /* 7 Start=================Version Value=================*/
        rangeMask = NSMakeRange(14,2);
        NSString * strVersion = [strResult substringWithRange:rangeMask];
        NSString * strFinalVersion = [APP_DELEGATE stringFroHex:strVersion];
        strFirmVersion = [APP_DELEGATE checkforValidString:strFinalVersion];
    }
    

}
-(void)UpdateKnobSelection:(NSNotification*)notification//Update peripheral
{
    NSString * strResult = [[BLEManager sharedManager] strSelectedKnob];

//    if ([strPreviousKnobData isEqualToString:strResult])
//    {
//
//    }
//    else
    {
        strPreviousKnobData = strResult;
        isKnobAdvertising = YES;
        [APP_DELEGATE endHudProcess];
        if ( isStopUpdate == YES)
        {
            //        return;
        }
        /* 1 Start=================Selected Relay with Dashed Border=================*/
        
        NSRange rangeMask = NSMakeRange(2,2);
        NSString * strSelected = [strResult substringWithRange:rangeMask];
        NSLog(@"Knob Selection=%@", strSelected);

        if (![strSelected isEqualToString:@"00"])
        {
            [self ShowSelectedButtonwithDashedborder:[strSelected intValue]];
            relayDashedSelected = [strSelected intValue];
            gestureRecognizer.enabled = NO;
            
            imgLock.image = [UIImage imageNamed:@"unlock.png"];
            btnSettings.backgroundColor = [UIColor redColor];
            imgSettings.hidden = YES;
            imgLock.hidden = NO;
//            imgLock.frame = CGRectMake((btnSettings.frame.size.width-30)/2,(( btnSettings.frame.size.height-30)/2), 30, 30);

        }
        else
        {
            [yourViewBorder removeFromSuperlayer];
            relayDashedSelected = 0;

            btnSettings.backgroundColor = [UIColor whiteColor];
            gestureRecognizer.enabled = YES;
            imgSettings.image = [UIImage imageNamed:@"settings.png"];
            imgLock.image = [UIImage imageNamed:@"lock.png"];
            imgSettings.hidden = NO;
            imgLock.hidden = NO;
//            imgLock.frame = CGRectMake((btnSettings.frame.size.width-30)/2,(( btnSettings.frame.size.height-60)/2)+30, 30, 30);

        }
        if ([[strResult substringWithRange:NSMakeRange(0,2)] isEqualToString:@"01"])
        {
            return;
        }
        /* 2 Start=================Battery Value=================*/
        rangeMask = NSMakeRange(4,2);
        NSString *  strValue = [strResult substringWithRange:rangeMask];
        NSString * strFinalBattery = [APP_DELEGATE stringFroHex:strValue];
        if (![[APP_DELEGATE checkforValidString:strFinalBattery] isEqualToString:@"NA"])
        {
            strBatteryValue = [NSString stringWithFormat:@"%@",strFinalBattery];
            if(![[APP_DELEGATE checkforValidString:strBatteryValue] isEqualToString:@"NA"])
            {
                if(isLowBtryPopupShown == YES)
                {
                }
                else
                {
                    if([strBatteryValue intValue] <= 20)
                    {
                        [self CheckBatteryValue];
                        isLowBtryPopupShown = YES;
                    }
                }
            }
        }

    }
}
-(void)ChangeButtonStatusforActiveInactive:(NSString *)strRelay withStatus:(BOOL)isONN// WHOEVER ACTIVE ARE RED AND WHITE
{
//    NSLog(@"Relay=%@ ", strRelay);
    
    UIColor * giveColor = [UIColor whiteColor];
    if (isONN)
    {
        giveColor = [UIColor redColor];
    }
    if (![arrConnectedRelay containsObject:strRelay])
    {
        return;
    }
    if ([strRelay isEqualToString:@"1"])
    {
        btn1.backgroundColor = giveColor;
    }
    else if ([strRelay isEqualToString:@"2"])
    {
        btn2.backgroundColor = giveColor;
    }
    else if ([strRelay isEqualToString:@"3"])
    {
        btn3.backgroundColor = giveColor;
    }
    else if ([strRelay isEqualToString:@"4"])
    {
        btn4.backgroundColor = giveColor;
    }
    else if ([strRelay isEqualToString:@"5"])
    {
        btn5.backgroundColor = giveColor;
    }
    else if ([strRelay isEqualToString:@"6"])
    {
        btn6.backgroundColor = giveColor;
    }
    
    if ([strRelay integerValue] == relayDashedSelected)
    {
        UIButton * btnSelected = (UIButton *)[self.view viewWithTag:relayDashedSelected];
        if (giveColor == [UIColor redColor])
        {
            if (isIgnitionON)
            {
                [self setButton:btnSelected withColor:[UIColor whiteColor]];
            }
            else
            {
                [self setButton:btnSelected withColor:[UIColor redColor]];
            }
        }
        else
        {
            [self setButton:btnSelected withColor:[UIColor redColor]];
            
        }
    }
    else
    {
        if (isKnobAdvertising == NO)
        {
            [yourViewBorder removeFromSuperlayer];
        }
    }
}
-(void)MakeRelayButtonEnabledDisabledbasedOnConnected:(NSString *)strRelay // WHOEVER ENABLED ARE WHITE AND DISABLED ARE WITH GRAY BACKGROUND
{
    if ([strRelay isEqualToString:@"1"])
    {
        btn1.backgroundColor = [UIColor whiteColor];
        btn1.enabled = YES;
        tapGesture1.enabled = YES;
        [btn1 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }
    else if ([strRelay isEqualToString:@"2"])
    {
        btn2.backgroundColor = [UIColor whiteColor];
        btn2.enabled = YES;
        tapGesture2.enabled = YES;
        [btn2 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }
    else if ([strRelay isEqualToString:@"3"])
    {
        btn3.backgroundColor = [UIColor whiteColor];
        btn3.enabled = YES;
        tapGesture3.enabled = YES;
        [btn3 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }
    else if ([strRelay isEqualToString:@"4"])
    {
        btn4.backgroundColor = [UIColor whiteColor];
        btn4.enabled = YES;
        tapGesture4.enabled = YES;
        [btn4 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }
    else if ([strRelay isEqualToString:@"5"])
    {
        btn5.backgroundColor = [UIColor whiteColor];
        btn5.enabled = YES;
        tapGesture5.enabled = YES;
        [btn5 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }
    else if ([strRelay isEqualToString:@"6"])
    {
        btn6.backgroundColor = [UIColor whiteColor];
        btn6.enabled = YES;
        tapGesture6.enabled = YES;
        [btn6 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }
}

-(void)ShowSelectedButtonwithDashedborder:(int)selectTag // IT WILL MAKE SELECTED RELAY WITH DAHSED BORDER
{
    if (selectTag == 0)
    {
    }
    else
    {
        btn1.layer.borderColor = [UIColor blackColor].CGColor;
        btn2.layer.borderColor = [UIColor blackColor].CGColor;
        btn3.layer.borderColor = [UIColor blackColor].CGColor;
        btn4.layer.borderColor = [UIColor blackColor].CGColor;
        btn5.layer.borderColor = [UIColor blackColor].CGColor;
        btn6.layer.borderColor = [UIColor blackColor].CGColor;
        
        UIButton * btnSelected = (UIButton *)[self.view viewWithTag:selectTag];
        btnSelected.layer.borderColor = [UIColor blackColor].CGColor;
        btnSelected.backgroundColor = [UIColor redColor];
        [btnSelected setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        
        UIColor * borderColr;
  
        if (isIgnitionON == NO)
        {
            btnSelected.backgroundColor = [UIColor colorWithRed:239.0/255.0 green:240.0/255.0 blue:241.0/255. alpha:1];
            borderColr = [UIColor redColor];
        }
        else
        {
            if ([arrStatusActive containsObject:[NSString stringWithFormat:@"%d",selectTag]])
            {
                //            NSLog(@"=========>>>>>>>>>>Contained");
                btnSelected.backgroundColor = [UIColor redColor];
                borderColr = [UIColor whiteColor];
            }
            else
            {
                //            NSLog(@"=========>>>>>>>>>>NOT____Contained");
                
                btnSelected.backgroundColor = [UIColor whiteColor];
                borderColr = [UIColor redColor];
            }
            
        }
        [yourViewBorder removeFromSuperlayer];
        yourViewBorder = [CAShapeLayer layer];
        yourViewBorder.strokeColor = borderColr.CGColor;
        yourViewBorder.fillColor = nil;
        yourViewBorder.lineDashPattern = @[@10, @15];
        yourViewBorder.frame = btnSelected.bounds;
        yourViewBorder.path = [UIBezierPath bezierPathWithRect:btnSelected.bounds].CGPath;
        yourViewBorder.lineWidth = 15;
        [btnSelected.layer addSublayer:yourViewBorder];
        

    }
}
-(void)setRelayMomentaryStatus:(NSString *)strRelayNumber //HERE SETTING WHOEVER MOMENTARY WILL HAVE LONG PRESS AND LATCHONOFF HAVE SINGLE TAP
{
//    NSLog(@"Yes I am updating Here.........");
    if([strRelayNumber isEqualToString:@"1"])
    {
        lblMom1.hidden = NO;
        lblLong1.hidden = NO;
        btn1.enabled = YES;
    }
    else if ([strRelayNumber isEqualToString:@"2"])
    {
        lblMom2.hidden = NO;
        lblLong2.hidden = NO;
        btn2.enabled = YES;
    }
    else if ([strRelayNumber isEqualToString:@"3"])
    {
        lblMom3.hidden = NO;
        lblLong3.hidden = NO;
        btn3.enabled = YES;
    }
    else if ([strRelayNumber isEqualToString:@"4"])
    {
        lblMom4.hidden = NO;
        lblLong4.hidden = NO;
        btn4.enabled = YES;
    }
    else if ([strRelayNumber isEqualToString:@"5"])
    {
        lblMom5.hidden = NO;
        lblLong5.hidden = NO;
        btn5.enabled = YES;
    }
    else if ([strRelayNumber isEqualToString:@"6"])
    {
        lblMom6.hidden = NO;
        lblLong6.hidden = NO;
        btn5.enabled = YES;
    }
}
#pragma mark - MOMENTARY BUTTON LONG PRESS EVENTS
-(void)longpress1GestureMethod:(UILongPressGestureRecognizer*)sender
{
    strLastMomSent = @"1";
    isFromMOM = YES;
    NSLog(@"Stateatatatastatat=%ld",(long)sender.state);
    if (isIgnitionON == NO)
    {
        [self showPopupforIgnitionOff];
        return;
    }
    NSString * strOnOffStatus = [dictActive valueForKey:@"1"];
    NSString * strIntStatus;
    if (sender.state == UIGestureRecognizerStateBegan)
    {
        isStopUpdate = YES;
        if ([strOnOffStatus isEqualToString:@"on"])
        {
            strIntStatus = @"0";
            btn1.backgroundColor = [UIColor whiteColor];
            if (relayDashedSelected == 1)
            {
                btn1.backgroundColor = [UIColor redColor];
                [self setButton:btn1 withColor:[UIColor whiteColor]];
            }
        }
        else
        {
            strIntStatus = @"1";
            btn1.backgroundColor = [UIColor redColor];
            if (relayDashedSelected == 1)
            {
                btn1.backgroundColor = [UIColor whiteColor];
                [self setButton:btn1 withColor:[UIColor redColor]];
            }
        }
        [APP_DELEGATE sendSignalViaScan:@"RelayStateChange" withDeviceID:@"01" withValue:@"01" withStatus:strIntStatus];
        NSLog(@"Longpressed1 Started");
    }
    else if(sender.state == UIGestureRecognizerStateEnded)
    {
        if ([strOnOffStatus isEqualToString:@"on"])
        {
            strIntStatus = @"1";
            btn1.backgroundColor = [UIColor redColor];
            if (relayDashedSelected == 1)
            {
                btn2.backgroundColor = [UIColor whiteColor];
                [self setButton:btn1 withColor:[UIColor redColor]];
            }
        }
        else
        {
            strIntStatus = @"0";
            btn1.backgroundColor = [UIColor whiteColor];
            if (relayDashedSelected == 1)
            {
                btn1.backgroundColor = [UIColor redColor];
                [self setButton:btn1 withColor:[UIColor whiteColor]];
            }
        }
        NSLog(@"Longpressed1 Ended");
        [APP_DELEGATE sendSignalViaScan:@"RelayStateChange" withDeviceID:@"01" withValue:@"00" withStatus:strIntStatus];
        
        if ([strIntStatus isEqualToString:@"0"])
        {
            [resentMOMTimer invalidate];
            resentMOMTimer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(ResendMOM) userInfo:nil repeats:NO];
        }
    }
}
-(void)longpress2GestureMethod:(UILongPressGestureRecognizer*)sender
{
    strLastMomSent = @"2";

    isFromMOM = YES;

    NSString * strOnOffStatus = [dictActive valueForKey:@"2"];
    NSString * strIntStatus;
    if (isIgnitionON == NO)
    {
        [self showPopupforIgnitionOff];
        return;
    }
    if (sender.state == UIGestureRecognizerStateBegan)
    {
        isStopUpdate = YES;
        if ([strOnOffStatus isEqualToString:@"on"])
        {
            strIntStatus = @"0";
            btn2.backgroundColor = [UIColor whiteColor];
            if (relayDashedSelected == 2)
            {
                btn2.backgroundColor = [UIColor redColor];
                [self setButton:btn2 withColor:[UIColor whiteColor]];
            }
        }
        else
        {
            strIntStatus = @"1";
            btn2.backgroundColor = [UIColor redColor];
            if (relayDashedSelected == 2)
            {
                btn2.backgroundColor = [UIColor whiteColor];
                [self setButton:btn2 withColor:[UIColor redColor]];
            }
        }
        
        [APP_DELEGATE sendSignalViaScan:@"RelayStateChange" withDeviceID:@"02" withValue:@"01" withStatus:strIntStatus];

        NSLog(@"Longpressed2 Started");
    }
    else if(sender.state == UIGestureRecognizerStateEnded)
    {
        if ([strOnOffStatus isEqualToString:@"on"])
        {
            strIntStatus = @"1";
            btn2.backgroundColor = [UIColor redColor];
            if (relayDashedSelected == 2)
            {
                btn2.backgroundColor = [UIColor whiteColor];
                [self setButton:btn2 withColor:[UIColor redColor]];
            }
        }
        else
        {
            strIntStatus = @"0";
            btn2.backgroundColor = [UIColor whiteColor];
            if (relayDashedSelected == 2)
            {
                btn2.backgroundColor = [UIColor redColor];
                [self setButton:btn2 withColor:[UIColor whiteColor]];
            }
        }
        NSLog(@"Longpressed2 Ended");
        [APP_DELEGATE sendSignalViaScan:@"RelayStateChange" withDeviceID:@"02" withValue:@"00" withStatus:strIntStatus];
        
        if ([strIntStatus isEqualToString:@"0"])
        {
            [resentMOMTimer invalidate];
            resentMOMTimer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(ResendMOM) userInfo:nil repeats:NO];
        }
    }
}

-(void)longpress3GestureMethod:(UILongPressGestureRecognizer*)sender
{
    strLastMomSent = @"3";

    isFromMOM = YES;

    if (isIgnitionON == NO)
    {
        [self showPopupforIgnitionOff];
        return;
    }
    NSString * strOnOffStatus = [dictActive valueForKey:@"3"];
    NSString * strIntStatus;
    if (sender.state == UIGestureRecognizerStateBegan)
    {
        isStopUpdate = YES;
        if ([strOnOffStatus isEqualToString:@"on"])
        {
            strIntStatus = @"0";
            btn3.backgroundColor = [UIColor whiteColor];
            if (relayDashedSelected == 3)
            {
                btn3.backgroundColor = [UIColor redColor];
                [self setButton:btn3 withColor:[UIColor whiteColor]];
            }
        }
        else
        {
            strIntStatus = @"1";
            btn3.backgroundColor = [UIColor redColor];
            if (relayDashedSelected == 3)
            {
                btn3.backgroundColor = [UIColor whiteColor];
                [self setButton:btn3 withColor:[UIColor redColor]];
            }
        }
        [APP_DELEGATE sendSignalViaScan:@"RelayStateChange" withDeviceID:@"03" withValue:@"01" withStatus:strIntStatus];
        NSLog(@"Longpressed3 Started");
    }
    else if(sender.state == UIGestureRecognizerStateEnded)
    {
        if ([strOnOffStatus isEqualToString:@"on"])
        {
            btn3.backgroundColor = [UIColor redColor];
            strIntStatus = @"1";
            if (relayDashedSelected == 3)
            {
                btn3.backgroundColor = [UIColor whiteColor];
                [self setButton:btn3 withColor:[UIColor redColor]];
            }
        }
        else
        {
            btn3.backgroundColor = [UIColor whiteColor];
            strIntStatus = @"0";
            if (relayDashedSelected == 3)
            {
                btn3.backgroundColor = [UIColor redColor];
                [self setButton:btn3 withColor:[UIColor whiteColor]];
            }
        }
        NSLog(@"Longpressed3 Ended");
        [APP_DELEGATE sendSignalViaScan:@"RelayStateChange" withDeviceID:@"03" withValue:@"00" withStatus:strIntStatus];
        
        if ([strIntStatus isEqualToString:@"0"])
        {
            [resentMOMTimer invalidate];
            resentMOMTimer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(ResendMOM) userInfo:nil repeats:NO];
        }
    }
}
-(void)longpress4GestureMethod:(UILongPressGestureRecognizer*)sender
{
    isFromMOM = YES;
    strLastMomSent = @"4";
    if (isIgnitionON == NO)
    {
        [self showPopupforIgnitionOff];
        return;
    }
    NSString * strOnOffStatus = [dictActive valueForKey:@"4"];
    NSString * strIntStatus;
    if (sender.state == UIGestureRecognizerStateBegan)
    {
        isStopUpdate = YES;
        if ([strOnOffStatus isEqualToString:@"on"])
        {
            strIntStatus = @"0";
            btn4.backgroundColor = [UIColor whiteColor];
            if (relayDashedSelected == 4)
            {
                btn4.backgroundColor = [UIColor redColor];
                [self setButton:btn4 withColor:[UIColor whiteColor]];
            }
        }
        else
        {
            strIntStatus = @"1";
            btn4.backgroundColor = [UIColor redColor];
            if (relayDashedSelected == 4)
            {
                btn4.backgroundColor = [UIColor whiteColor];
                [self setButton:btn4 withColor:[UIColor redColor]];
            }
        }
        
        [APP_DELEGATE sendSignalViaScan:@"RelayStateChange" withDeviceID:@"04" withValue:@"01" withStatus:strIntStatus];

        NSLog(@"Longpressed4 Started");
    }
    else if(sender.state == UIGestureRecognizerStateEnded)
    {
        if ([strOnOffStatus isEqualToString:@"on"])
        {
            strIntStatus = @"1";
            btn4.backgroundColor = [UIColor redColor];
            if (relayDashedSelected == 4)
            {
                btn4.backgroundColor = [UIColor whiteColor];
                [self setButton:btn4 withColor:[UIColor redColor]];
            }
        }
        else
        {
            strIntStatus = @"0";
            btn4.backgroundColor = [UIColor whiteColor];
            if (relayDashedSelected == 4)
            {
                btn4.backgroundColor = [UIColor redColor];
                [self setButton:btn4 withColor:[UIColor whiteColor]];
            }
        }
        NSLog(@"Longpressed4 Ended");
        [APP_DELEGATE sendSignalViaScan:@"RelayStateChange" withDeviceID:@"04" withValue:@"00" withStatus:strIntStatus];
        if ([strIntStatus isEqualToString:@"0"])
        {
            [resentMOMTimer invalidate];
            resentMOMTimer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(ResendMOM) userInfo:nil repeats:NO];
        }
    }
}
-(void)longpress5GestureMethod:(UILongPressGestureRecognizer*)sender
{
    isFromMOM = YES;
    strLastMomSent = @"5";
    if (isIgnitionON == NO)
    {
        [self showPopupforIgnitionOff];
        return;
    }
    NSString * strOnOffStatus = [dictActive valueForKey:@"5"];
    NSString * strIntStatus;
    if (sender.state == UIGestureRecognizerStateBegan)
    {
        isStopUpdate = YES;
        if ([strOnOffStatus isEqualToString:@"on"])
        {
            strIntStatus = @"0";
            btn5.backgroundColor = [UIColor whiteColor];
            if (relayDashedSelected == 5)
            {
                btn5.backgroundColor = [UIColor redColor];
                [self setButton:btn5 withColor:[UIColor whiteColor]];
            }
        }
        else
        {
            strIntStatus = @"1";
            btn5.backgroundColor = [UIColor redColor];
            if (relayDashedSelected == 5)
            {
                btn5.backgroundColor = [UIColor whiteColor];
                [self setButton:btn5 withColor:[UIColor redColor]];
            }
        }
        [APP_DELEGATE sendSignalViaScan:@"RelayStateChange" withDeviceID:@"05" withValue:@"01" withStatus:strIntStatus];

        NSLog(@"Longpressed5 Started");
    }
    else if(sender.state == UIGestureRecognizerStateEnded)
    {
        if ([strOnOffStatus isEqualToString:@"on"])
        {
            strIntStatus = @"1";
            btn5.backgroundColor = [UIColor redColor];
            if (relayDashedSelected == 5)
            {
                btn5.backgroundColor = [UIColor whiteColor];
                [self setButton:btn5 withColor:[UIColor redColor]];
            }
        }
        else
        {
            strIntStatus = @"0";
            btn5.backgroundColor = [UIColor whiteColor];
            if (relayDashedSelected == 5)
            {
                btn5.backgroundColor = [UIColor redColor];
                [self setButton:btn5 withColor:[UIColor whiteColor]];
            }
        }
        NSLog(@"Longpressed5 Ended");
        [APP_DELEGATE sendSignalViaScan:@"RelayStateChange" withDeviceID:@"05" withValue:@"00" withStatus:strIntStatus];
        
        if ([strIntStatus isEqualToString:@"0"])
        {
            [resentMOMTimer invalidate];
            resentMOMTimer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(ResendMOM) userInfo:nil repeats:NO];
        }
    }
}
-(void)longpress6GestureMethod:(UILongPressGestureRecognizer*)sender
{
    isFromMOM = YES;
    strLastMomSent = @"6";
    if (isIgnitionON == NO)
    {
        [self showPopupforIgnitionOff];
        return;
    }
    NSString * strOnOffStatus = [dictActive valueForKey:@"6"];
    NSString * strIntStatus;
    if (sender.state == UIGestureRecognizerStateBegan)
    {
        isStopUpdate = YES;
        if ([strOnOffStatus isEqualToString:@"on"])
        {
            strIntStatus = @"0";
            btn6.backgroundColor = [UIColor whiteColor];
            if (relayDashedSelected == 6)
            {
                btn6.backgroundColor = [UIColor redColor];
                [self setButton:btn6 withColor:[UIColor whiteColor]];
            }
        }
        else
        {
            strIntStatus = @"1";
            btn6.backgroundColor = [UIColor redColor];
            if (relayDashedSelected == 6)
            {
                btn6.backgroundColor = [UIColor whiteColor];
                [self setButton:btn6 withColor:[UIColor redColor]];
            }
        }
        [APP_DELEGATE sendSignalViaScan:@"RelayStateChange" withDeviceID:@"06" withValue:@"01" withStatus:strIntStatus];

        NSLog(@"Longpressed6 Started");
    }
    else if(sender.state == UIGestureRecognizerStateEnded)
    {
        if ([strOnOffStatus isEqualToString:@"on"])
        {
            btn6.backgroundColor = [UIColor redColor];
            strIntStatus = @"1";
            if (relayDashedSelected == 6)
            {
                btn6.backgroundColor = [UIColor whiteColor];
                [self setButton:btn6 withColor:[UIColor redColor]];
            }
        }
        else
        {
            btn6.backgroundColor = [UIColor whiteColor];
            strIntStatus = @"0";
            if (relayDashedSelected == 6)
            {
                btn6.backgroundColor = [UIColor redColor];
                [self setButton:btn6 withColor:[UIColor whiteColor]];
            }
        }
        NSLog(@"Longpressed6 Ended");
        [APP_DELEGATE sendSignalViaScan:@"RelayStateChange" withDeviceID:@"06" withValue:@"00" withStatus:strIntStatus];
        if ([strIntStatus isEqualToString:@"0"])
        {
            [resentMOMTimer invalidate];
            resentMOMTimer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(ResendMOM) userInfo:nil repeats:NO];
        }
    }
}
-(void)setButton:(UIButton *)btns withColor:(UIColor *)rgbColor
{
    [yourViewBorder removeFromSuperlayer];
    yourViewBorder = [CAShapeLayer layer];
    yourViewBorder.strokeColor = rgbColor.CGColor;
    yourViewBorder.fillColor = nil;
    yourViewBorder.lineDashPattern = @[@10, @15];
    yourViewBorder.frame = btns.bounds;
    yourViewBorder.path = [UIBezierPath bezierPathWithRect:btns.bounds].CGPath;
    yourViewBorder.lineWidth = 15;
    [btns.layer addSublayer:yourViewBorder];

}
-(void)btn1Action
{
    if (isIgnitionON == NO)
    {
        [self showPopupforIgnitionOff];
        return;
    }
    isStopUpdate = YES;
    NSLog(@"Normal button action");
    if ([[dictActive valueForKey:@"1"] isEqualToString:@"on"])
    {
        btn1.backgroundColor = [UIColor whiteColor];
        [dictActive setObject:@"off" forKey:@"1"];
        [btn1 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        if (relayDashedSelected == 1)
        {
            btn1.backgroundColor = [UIColor whiteColor];
            [self setButton:btn1 withColor:[UIColor redColor]];
        }
        [APP_DELEGATE sendSignalViaScan:@"RelayStateChange" withDeviceID:@"01" withValue:@"01" withStatus:@"00"];
    }
    else
    {
        btn1.backgroundColor = [UIColor redColor];
        [dictActive setObject:@"on" forKey:@"1"];
        if (relayDashedSelected == 1)
        {
            btn1.backgroundColor = [UIColor redColor];
            [self setButton:btn1 withColor:[UIColor whiteColor]];
        }
        [APP_DELEGATE sendSignalViaScan:@"RelayStateChange" withDeviceID:@"01" withValue:@"01" withStatus:@"01"];
    }
}
-(void)btn2Action
{
    if (isIgnitionON == NO)
    {
        [self showPopupforIgnitionOff];
        return;
    }
    isStopUpdate = YES;
    NSString * strMsg ;
    if ([[dictActive valueForKey:@"2"] isEqualToString:@"on"])
    {
        btn2.backgroundColor = [UIColor whiteColor];
        strMsg = [NSString stringWithFormat:@"020101"];
        [dictActive setObject:@"off" forKey:@"2"];
        [btn2 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [APP_DELEGATE sendSignalViaScan:@"RelayStateChange" withDeviceID:@"02" withValue:@"01" withStatus:@"00"];
        if (relayDashedSelected == 2)
        {
            btn2.backgroundColor = [UIColor whiteColor];
            [self setButton:btn2 withColor:[UIColor redColor]];
        }
    }
    else
    {
        btn2.backgroundColor = [UIColor redColor];
        strMsg = [NSString stringWithFormat:@"020100"];
        [dictActive setObject:@"on" forKey:@"2"];
        [APP_DELEGATE sendSignalViaScan:@"RelayStateChange" withDeviceID:@"02" withValue:@"01" withStatus:@"01"];
        if (relayDashedSelected == 2)
        {
            btn2.backgroundColor = [UIColor redColor];
            [self setButton:btn2 withColor:[UIColor whiteColor]];
        }
    }
}
-(void)btn3Action
{
    if (isIgnitionON == NO)
    {
        [self showPopupforIgnitionOff];
        return;
    }
    isStopUpdate = YES;
    NSString * strMsg ;
    if ([[dictActive valueForKey:@"3"] isEqualToString:@"on"])
    {
        strMsg = [NSString stringWithFormat:@"030101"];
        [dictActive setObject:@"off" forKey:@"3"];
        [btn3 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        btn3.backgroundColor = [UIColor whiteColor];
        [APP_DELEGATE sendSignalViaScan:@"RelayStateChange" withDeviceID:@"03" withValue:@"01" withStatus:@"00"];
        if (relayDashedSelected == 3)
        {
            btn3.backgroundColor = [UIColor whiteColor];
            [self setButton:btn3 withColor:[UIColor redColor]];
        }
    }
    else
    {
        strMsg = [NSString stringWithFormat:@"030100"];
        [dictActive setObject:@"on" forKey:@"3"];
        btn3.backgroundColor = [UIColor redColor];
        [APP_DELEGATE sendSignalViaScan:@"RelayStateChange" withDeviceID:@"03" withValue:@"01" withStatus:@"01"];
        if (relayDashedSelected == 3)
        {
            btn3.backgroundColor = [UIColor redColor];
            [self setButton:btn3 withColor:[UIColor whiteColor]];
        }
    }
}
-(void)btn4Action
{
    if (isIgnitionON == NO)
    {
        [self showPopupforIgnitionOff];
        return;
    }
    isStopUpdate = YES;
    NSString * strMsg ;
    if ([[dictActive valueForKey:@"4"] isEqualToString:@"on"])
    {
        btn4.backgroundColor = [UIColor whiteColor];
        strMsg = [NSString stringWithFormat:@"040101"];
        [dictActive setObject:@"off" forKey:@"4"];
        [btn4 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [APP_DELEGATE sendSignalViaScan:@"RelayStateChange" withDeviceID:@"04" withValue:@"01" withStatus:@"00"];
        
        if (relayDashedSelected == 4)
        {
            btn4.backgroundColor = [UIColor whiteColor];
            [self setButton:btn4 withColor:[UIColor redColor]];
        }
    }
    else
    {
        btn4.backgroundColor = [UIColor redColor];
        strMsg = [NSString stringWithFormat:@"040100"];
        [dictActive setObject:@"on" forKey:@"4"];
        [APP_DELEGATE sendSignalViaScan:@"RelayStateChange" withDeviceID:@"04" withValue:@"01" withStatus:@"01"];
        if (relayDashedSelected == 4)
        {
            btn4.backgroundColor = [UIColor redColor];
            [self setButton:btn4 withColor:[UIColor whiteColor]];
        }
    }
}
-(void)btn5Action
{
    if (isIgnitionON == NO)
    {
        [self showPopupforIgnitionOff];
        return;
    }
    isStopUpdate = YES;
    NSString * strMsg ;
    if ([[dictActive valueForKey:@"5"] isEqualToString:@"on"])
    {
        strMsg = [NSString stringWithFormat:@"050101"];
        [dictActive setObject:@"off" forKey:@"5"];
        [btn5 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        btn5.backgroundColor = [UIColor whiteColor];
        [APP_DELEGATE sendSignalViaScan:@"RelayStateChange" withDeviceID:@"05" withValue:@"01" withStatus:@"00"];
        if (relayDashedSelected == 5)
        {
            btn5.backgroundColor = [UIColor whiteColor];
            [self setButton:btn5 withColor:[UIColor redColor]];
        }
    }
    else
    {
        strMsg = [NSString stringWithFormat:@"050100"];
        [dictActive setObject:@"on" forKey:@"5"];
        btn5.backgroundColor = [UIColor redColor];
        [APP_DELEGATE sendSignalViaScan:@"RelayStateChange" withDeviceID:@"05" withValue:@"01" withStatus:@"01"];
        if (relayDashedSelected == 5)
        {
            btn5.backgroundColor = [UIColor redColor];
            [self setButton:btn5 withColor:[UIColor whiteColor]];
        }
    }
}
-(void)btn6Action
{
    if (isIgnitionON == NO)
    {
        [self showPopupforIgnitionOff];
        return;
    }
    isStopUpdate = YES;
    NSString * strMsg ;
    if ([[dictActive valueForKey:@"6"] isEqualToString:@"on"])
    {
        strMsg = [NSString stringWithFormat:@"060101"];
        [dictActive setObject:@"off" forKey:@"6"];
        [btn6 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        btn6.backgroundColor = [UIColor whiteColor];
        [APP_DELEGATE sendSignalViaScan:@"RelayStateChange" withDeviceID:@"06" withValue:@"01" withStatus:@"00"];
        if (relayDashedSelected == 6)
        {
            btn6.backgroundColor = [UIColor whiteColor];
            [self setButton:btn6 withColor:[UIColor redColor]];
        }
    }
    else
    {
        strMsg = [NSString stringWithFormat:@"060100"];
        [dictActive setObject:@"on" forKey:@"6"];
        btn6.backgroundColor = [UIColor redColor];
        [APP_DELEGATE sendSignalViaScan:@"RelayStateChange" withDeviceID:@"06" withValue:@"01" withStatus:@"01"];
        if (relayDashedSelected == 6)
        {
            btn6.backgroundColor = [UIColor redColor];
            [self setButton:btn6 withColor:[UIColor whiteColor]];
        }
    }
}
-(void)stopTimerAndStartScanningMethod
{
    isStopUpdate = NO;
//    NSLog(@"Timer Stop");
}
-(void)stopOldTimer
{
    [timeOutTimer invalidate];
    timeOutTimer = nil;
}
-(void)showPopupforIgnitionOff
{
    [alert removeFromSuperview];
    alert = [[FCAlertView alloc] init];
    alert.colorScheme = [UIColor blackColor];
    [alert makeAlertTypeWarning];
    alert.firstButtonCustomFont = [UIFont fontWithName:CGRegular size:txtSize];
    [alert showAlertInView:self
                 withTitle:@"Ignition Off"
              withSubtitle:@"Ignition Off. Can't complete operation now."
           withCustomImage:[UIImage imageNamed:@"Subsea White 180.png"]
       withDoneButtonTitle:@"OK" andButtons:nil];
    
}
-(void)makeAllButtonEnabled:(BOOL)isAllEnabled
{
    if (isAllEnabled)
    {
        btn1.enabled = YES; btn2.enabled = YES; btn3.enabled =YES; btn4.enabled = YES; btn5.enabled = YES; btn6.enabled = YES;

    }
    else
    {
        btn1.enabled = NO; btn2.enabled = NO; btn3.enabled = NO; btn4.enabled = NO; btn5.enabled = NO; btn6.enabled = NO;
//        longpress1.enabled = NO;
        lblLong1.hidden = YES;lblLong2.hidden = YES;lblLong3.hidden = YES;lblLong4.hidden = YES;lblLong5.hidden = YES;lblLong6.hidden = YES;
        
        //COLOR CHANGE FOR DISABLED
        btn1.backgroundColor = [UIColor colorWithRed:239.0/255.0 green:240.0/255.0 blue:241.0/255. alpha:1];
        btn2.backgroundColor = [UIColor colorWithRed:239.0/255.0 green:240.0/255.0 blue:241.0/255. alpha:1];
        btn3.backgroundColor = [UIColor colorWithRed:239.0/255.0 green:240.0/255.0 blue:241.0/255. alpha:1];
        btn4.backgroundColor = [UIColor colorWithRed:239.0/255.0 green:240.0/255.0 blue:241.0/255. alpha:1];
        btn5.backgroundColor = [UIColor colorWithRed:239.0/255.0 green:240.0/255.0 blue:241.0/255. alpha:1];
        btn6.backgroundColor = [UIColor colorWithRed:239.0/255.0 green:240.0/255.0 blue:241.0/255. alpha:1];

    }
}
-(void)UpdateTime
{
    NSDateFormatter * dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"HH:mm:ss"];
    lblTime.text = [dateFormat stringFromDate:[NSDate date]];

}
-(void)UpdateAllfieldsValues
{
    lblSpeed.text = [NSString stringWithFormat:@"%.1f MPH",savedLastLocation.speed * 0.00062137];
    lblAltitude.text = [NSString stringWithFormat:@"%.0f M",savedLastLocation.altitude];
    
 
    {
        double distancess = [previousLocation distanceFromLocation:savedLastLocation];
        totalDistance += distancess;
        if (previousLocation == nil)
        {
            totalDistance = 0;
            distancess = 0;
        }
        previousLocation = savedLastLocation;
        double odo1 = [[NSUserDefaults standardUserDefaults] doubleForKey:@"odo1"];
        double odo2 = [[NSUserDefaults standardUserDefaults] doubleForKey:@"odo2"];
        
        odo1 = odo1 + distancess;
        odo2 = odo2 + distancess;
        
        BOOL isUnitODO1 = NO;
        BOOL isUnitODO2 = NO;
        
        if ([[[NSUserDefaults standardUserDefaults]valueForKey:@"odometer1"] isEqualToString:@"Unit"])
        {
            isUnitODO1 = YES;
        }
        if ([[[NSUserDefaults standardUserDefaults]valueForKey:@"odometer2"] isEqualToString:@"Unit"])
        {
            isUnitODO2 = YES;
        }
        if (distancess > 0)
        {
            if ([[[NSUserDefaults standardUserDefaults]valueForKey:@"unitType"] isEqualToString:@"English-SAE"])
            {
                if (isUnitODO1){ lblOdometer1.text = [NSString stringWithFormat:@"%.0f mi", odo1 *  0.000621371]; }
                else { lblOdometer1.text = [NSString stringWithFormat:@"%.2f mi", odo1 *  0.000621371];  }
                
                if (isUnitODO2){ lblOdometer2.text = [NSString stringWithFormat:@"%.0f mi", odo2 *  0.000621371]; }
                else { lblOdometer2.text = [NSString stringWithFormat:@"%.2f mi", odo2 *  0.000621371];  }
                
            }
            else
            {
                if (isUnitODO1) { lblOdometer1.text = [NSString stringWithFormat:@"%.0f km", odo1 * 0.001]; }
                else { lblOdometer1.text = [NSString stringWithFormat:@"%.2f km", odo1 * 0.001]; }
                
                if (isUnitODO2) { lblOdometer2.text = [NSString stringWithFormat:@"%.0f km",odo2 * 0.001];}
                else {lblOdometer2.text = [NSString stringWithFormat:@"%.2f km",odo2 * 0.001]; }
            }
            
            [[NSUserDefaults standardUserDefaults] setDouble:odo1 forKey:@"odo1"];
            [[NSUserDefaults standardUserDefaults] setDouble:odo2 forKey:@"odo2"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        else
        {
            double newOdo1 = [[NSUserDefaults standardUserDefaults] doubleForKey:@"odo1"];
            double newOdo2 = [[NSUserDefaults standardUserDefaults] doubleForKey:@"odo2"];
            
            if ([[[NSUserDefaults standardUserDefaults]valueForKey:@"unitType"] isEqualToString:@"English-SAE"])
            {
                if (isUnitODO1){ lblOdometer1.text = [NSString stringWithFormat:@"%.0f mi", newOdo1 *  0.000621371]; }
                else { lblOdometer1.text = [NSString stringWithFormat:@"%.2f mi", newOdo1 *  0.000621371];  }
                
                if (isUnitODO2){ lblOdometer2.text = [NSString stringWithFormat:@"%.0f mi", newOdo2 *  0.000621371]; }
                else { lblOdometer2.text = [NSString stringWithFormat:@"%.2f mi", newOdo2 *  0.000621371];  }
            }
            else
            {
                if (isUnitODO1) { lblOdometer1.text = [NSString stringWithFormat:@"%.0f km", newOdo1 * 0.001]; }
                else { lblOdometer1.text = [NSString stringWithFormat:@"%.2f km", newOdo1 * 0.001]; }
                
                if (isUnitODO2) { lblOdometer2.text = [NSString stringWithFormat:@"%.0f km",newOdo2 * 0.001];}
                else {lblOdometer2.text = [NSString stringWithFormat:@"%.2f km",newOdo2 * 0.001]; }
            }
            
        }
    }
    if (![[APP_DELEGATE checkforValidString:lblOdometer1.text] isEqualToString:@"NA"])
    {
        if ([lblOdometer1.text length]>8)
        {
            if (isPortrait)
            {
                [lblOdometer1 setFont:[UIFont fontWithName:CGRegular size:txtSize+fontHght-6]];
                [lblOdometer2 setFont:[UIFont fontWithName:CGRegular size:txtSize+fontHght-6]];
            }
            else
            {
                [lblOdometer1 setFont:[UIFont fontWithName:CGRegular size:txtSize+fontHght-4]];
                [lblOdometer2 setFont:[UIFont fontWithName:CGRegular size:txtSize+fontHght-4]];
            }
        }
    }
    double totalSpeed = savedLastLocation.speed;
    if (totalSpeed < 0)
    {
        totalSpeed = 0 ;
    }
    if ([[[NSUserDefaults standardUserDefaults]valueForKey:@"unitType"] isEqualToString:@"English-SAE"])
    {
        lblSpeed.text = [NSString stringWithFormat:@"%.2f MPH",totalSpeed];
        lblAltitude.text = [NSString stringWithFormat:@"%.0f feet",savedLastLocation.altitude *  3.2808399];
    }
    else
    {
        lblSpeed.text = [NSString stringWithFormat:@"%.2f KPH",totalSpeed * 3.6];
        lblAltitude.text = [NSString stringWithFormat:@"%.0f meters",savedLastLocation.altitude];
    }
}
-(void)ResendMOM
{
    if ([arrStatusActive containsObject:strLastMomSent])
    {
        [APP_DELEGATE sendSignalViaScan:@"RelayStateChange" withDeviceID:[NSString stringWithFormat:@"0%@",strLastMomSent] withValue:@"00" withStatus:@"0"];
    }
}
-(void)TempMethodforStatusActive
{
    NSString * strResult = @"0214070F40050F32030605040102";
    
    /* 1 Start================ Which Relay Connected =================*/
    
    NSRange rangeMask = NSMakeRange(4,2);
    NSString * strConnected = [strResult substringWithRange:rangeMask];
    NSString * strBinaryConnected = [APP_DELEGATE hexToBinary:strConnected];
    btn1.enabled = NO; btn2.enabled = NO; btn3.enabled = NO; btn4.enabled = NO; btn5.enabled = NO; btn6.enabled = NO;
    
    arrConnectedRelay = [[NSMutableArray alloc] init];
    for (int i=0; i<[strBinaryConnected length]; i++)
    {
        NSRange range71 = NSMakeRange(i,1);
        NSString * strCheck = [strBinaryConnected substringWithRange:range71];
        if ([strCheck isEqualToString:@"1"])
        {
            
            [arrConnectedRelay addObject:[NSString stringWithFormat:@"%d",8-i]];
            [self MakeRelayButtonEnabledDisabledbasedOnConnected:[NSString stringWithFormat:@"%d",8-i]];
        }
    }
    
    /* 2 Start=================Relay State Active/Inactive=================*/
    
    rangeMask = NSMakeRange(2,2);
    NSString * strActiveState = [strResult substringWithRange:rangeMask];
    NSString * strBinaryActiveState = [APP_DELEGATE hexToBinary:strActiveState];
    
    arrStatusActive = [[NSMutableArray alloc] init];
    for (int i=0; i<[strBinaryActiveState length]; i++)
    {
        NSRange range71 = NSMakeRange(i,1);
        NSString * strCheck = [strBinaryActiveState substringWithRange:range71];
        if ([strCheck isEqualToString:@"1"])
        {
            [arrStatusActive addObject:[NSString stringWithFormat:@"%d",8-i]];
            [self ChangeButtonStatusforActiveInactive:[NSString stringWithFormat:@"%d",8-i] withStatus:YES];
            [dictActive setObject:@"on" forKey:[NSString stringWithFormat:@"%d",8-i]];
        }
    }
    
    /* 3 Start=================Check Trigger Switch Value (Latching/Momentary)=================*/
    
    rangeMask = NSMakeRange(6,2);
    NSString * strTriggerValue = [strResult substringWithRange:rangeMask];
    NSString * strTriggerBinary = [APP_DELEGATE hexToBinary:strTriggerValue];
    
    for (int i=0; i<[strTriggerBinary length]; i++)
    {
        NSRange range71 = NSMakeRange(i,1);
        NSString * strCheck = [strTriggerBinary substringWithRange:range71];
        if ([strCheck isEqualToString:@"1"])
        {
            NSMutableDictionary * tmpDict = [[NSMutableDictionary alloc] init];
            tmpDict = [[[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"Relay%d",8-i]] mutableCopy];
            [tmpDict setValue:@"Momentary"  forKey:@"switchtype"];
            [[NSUserDefaults standardUserDefaults] setValue:tmpDict forKey:[NSString stringWithFormat:@"Relay%d",8-i]];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [self setRelayMomentaryStatus:[NSString stringWithFormat:@"%d",8-i]];
        }
    }
    
    
    /* 4 Start=================Fetch System Voltage=================*/
    
    rangeMask = NSMakeRange(8,2);
    NSString * strVoltage = [strResult substringWithRange:rangeMask];
    
    NSString * strinfromHex = [APP_DELEGATE stringFroHex:strVoltage];
    //    NSLog(@"String from Hex Value=%@",strinfromHex);
    if (![[APP_DELEGATE checkforValidString:strinfromHex] isEqualToString:@"NA"])
    {
        lblVoltage.text = [NSString stringWithFormat:@"%.2f V", [strinfromHex floatValue]/100];
    }
    
    /* 5 Start=================Selected Relay with Dashed Border=================*/
    
    
    rangeMask = NSMakeRange(10,2);
    NSString * strSelected = [strResult substringWithRange:rangeMask];
    [self ShowSelectedButtonwithDashedborder:[strSelected intValue]];
    relayDashedSelected = [strSelected intValue];
    
    
    /* 6 Start=================Ignition Time Value=================*/
    
    rangeMask = NSMakeRange(12,2);
    NSString * strIgnitionTime = [strResult substringWithRange:rangeMask];
    NSString * strFinalTime = [APP_DELEGATE stringFroHex:strIgnitionTime];
    if (![[APP_DELEGATE checkforValidString:strFinalTime] isEqualToString:@"NA"])
    {
        [[NSUserDefaults standardUserDefaults] setValue:strFinalTime forKey:@"ignitiontime"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    /* 7 Start=================Battery Value=================*/
    
    rangeMask = NSMakeRange(14,2);
    NSString * strBatteryValue = [strResult substringWithRange:rangeMask];
    NSString * strFinalBattery = [APP_DELEGATE stringFroHex:strBatteryValue];
    if (![[APP_DELEGATE checkforValidString:strFinalBattery] isEqualToString:@"NA"])
    {
        //Show Battery Value
    }
    
    /* 8 Start=================Assigned Relays=================*/
    
    NSMutableDictionary *dictRelayAssign = [[NSMutableDictionary alloc]init];
    
    NSArray * arrAssign = [NSArray arrayWithObjects:@"1",@"2",@"3",@"4",@"5",@"6", nil];
    for (int i=0; i<[arrAssign count]; i++)
    {
        rangeMask = NSMakeRange(16+(i*2),2);
        NSString * strM1 = [strResult substringWithRange:rangeMask];
        if (![[APP_DELEGATE checkforValidString:strM1] isEqualToString:@"NA"])
        {
            NSMutableDictionary * tmpDict = [[NSMutableDictionary alloc] init];
            tmpDict = [[[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"Relay%d",[strM1 intValue]]] mutableCopy];
            [tmpDict setObject:[arrAssign objectAtIndex:i] forKey:@"assigned"];
            [[NSUserDefaults standardUserDefaults] setValue:tmpDict forKey:[NSString stringWithFormat:@"Relay%d",[strM1 intValue]]];
            
            [dictRelayAssign setObject:[NSString stringWithFormat:@"%d",[strM1 intValue]] forKey:[arrAssign objectAtIndex:i]];
            
            [[NSUserDefaults standardUserDefaults]setValue:@"YES" forKey:@"isDefaultRelayAssigned"];
            [[NSUserDefaults standardUserDefaults]setValue:dictRelayAssign forKey:@"relayAssignedDict"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
    
   // gestureRecognizer.enabled = true;
}


/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }issue
 */

@end
