//
//  SettingsVC.m
//  Redshift
//
//  Created by srivatsa s pobbathi on 23/10/18.
//  Copyright © 2018 srivatsa s pobbathi. All rights reserved.
//

#import "SettingsVC.h"

@interface SettingsVC ()
{
    UIInterfaceOrientation lastOrients;
    int cnttt ;
    int fntSize;

    UIButton * btnOTA;
    UILabel * lblVersion;
}

@end

@implementation SettingsVC
@synthesize unitRadioBtn,odo1RadioBtn,odo2RadioBtn;
-(void)TimerClick
{
    cnttt = cnttt + 1;
    if (cnttt >=7)
    {
        return;
    }
    [APP_DELEGATE sendSignalViaScan:@"GearKnobAssignment" withDeviceID:[NSString stringWithFormat:@"%d",cnttt] withValue:[NSString stringWithFormat:@"%d",cnttt] withStatus:@"0"];

}
- (void)viewDidLoad
{
    fntSize = 7;
    if (self.view.frame.size.height == 320 || self.view.frame.size.width == 320)
    {
        fntSize = 6;
    }

    if (![[APP_DELEGATE checkforValidString:[[NSUserDefaults standardUserDefaults] valueForKey:@"ignitiontime"]] isEqualToString:@"NA"])
    {
        strTimeValue = [[NSUserDefaults standardUserDefaults] valueForKey:@"ignitiontime"];
    }
    selectedRelayBtn = 0;

    NSLog(@"%ld",(long)[[UIDevice currentDevice]orientation]);
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(OrientationDidChange:) name:UIDeviceOrientationDidChangeNotification object:nil];

    self.view.backgroundColor = UIColor.whiteColor;
    [self setUpFrames];
    
    [super viewDidLoad];
    [self setValueForMainSettingScreen];
    
    if ([[[NSUserDefaults standardUserDefaults]valueForKey:@"isDefaultRelayAssigned"] isEqualToString:@"YES"])
    {
        dictRelayAssign = [[NSMutableDictionary alloc]init];
        dictRelayAssign = [[[NSUserDefaults standardUserDefaults]valueForKey:@"relayAssignedDict"] mutableCopy];
    }
    else
    {
        dictRelayAssign = [[NSMutableDictionary alloc]init];
        [dictRelayAssign setObject:@"1" forKey:@"1"];
        [dictRelayAssign setObject:@"2" forKey:@"2"];
        [dictRelayAssign setObject:@"3" forKey:@"3"];
        [dictRelayAssign setObject:@"4" forKey:@"4"];
        [dictRelayAssign setObject:@"5" forKey:@"5"];
        [dictRelayAssign setObject:@"6" forKey:@"6"];
        [[NSUserDefaults standardUserDefaults]setValue:@"YES" forKey:@"isDefaultRelayAssigned"];
        [[NSUserDefaults standardUserDefaults]setValue:dictRelayAssign forKey:@"relayAssignedDict"];
        [[NSUserDefaults standardUserDefaults]synchronize];
    }
    // Do any additional setup after loading the view.
}
-(void)viewWillAppear:(BOOL)animated
{
    lastOrients = [[UIApplication sharedApplication] statusBarOrientation];

    if([[UIApplication sharedApplication] statusBarOrientation] == UIDeviceOrientationLandscapeLeft || [[UIApplication sharedApplication] statusBarOrientation] == UIDeviceOrientationLandscapeRight)
    {
        [self setLandscapeFrames];
    }
    else if([[UIApplication sharedApplication] statusBarOrientation] == UIDeviceOrientationPortrait)
    {
        [self setUpPortraitFrames];
    }
}
#pragma mark - SetUp UI Frames
-(void) setUpFrames
{
    [self setMainSettingsView];
    [self setRelayView];
    
    int viewHeight = DEVICE_HEIGHT-20;
    int exYY =0;
    if (IS_IPHONE_X)
    {
        viewHeight = DEVICE_HEIGHT-84;
        exYY = 44;
    }
    
    btn1 = [UIButton buttonWithType:UIButtonTypeCustom];
    btn1.backgroundColor = UIColor.whiteColor;
    btn1.frame = CGRectMake(DEVICE_WIDTH-DEVICE_WIDTH/3,((DEVICE_HEIGHT)-viewHeight/5) -exYY, DEVICE_WIDTH/3, viewHeight/5);
    [btn1 setTitle:@"1" forState:UIControlStateNormal];
    btn1.layer.masksToBounds = true;
    btn1.layer.borderWidth = 1;
    [btn1 setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    [btn1 addTarget:self action:@selector(btn1Action) forControlEvents:UIControlEventTouchUpInside];
    btn1.titleLabel.font = [UIFont fontWithName:CGRegular size:txtSize+10];
    [btn1 setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    btn1.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    btn1.titleLabel.numberOfLines = 2;
    [self.view addSubview:btn1];
    
    btn2 = [UIButton buttonWithType:UIButtonTypeCustom];
    btn2.backgroundColor = UIColor.whiteColor;
    btn2.frame = CGRectMake(DEVICE_WIDTH-(DEVICE_WIDTH/3*2),((DEVICE_HEIGHT)-viewHeight/5)-exYY, DEVICE_WIDTH/3, viewHeight/5);
    [btn2 setTitle:@"2" forState:UIControlStateNormal];
    btn2.layer.masksToBounds = true;
    btn2.layer.borderWidth = 1;
    [btn2 setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    [btn2 addTarget:self action:@selector(btn2Action) forControlEvents:UIControlEventTouchUpInside];
    btn2.titleLabel.font = [UIFont fontWithName:CGRegular size:txtSize+10];
    [btn2 setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    btn2.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    btn2.titleLabel.numberOfLines = 2;
    [self.view addSubview:btn2];
    
    btnSettings = [UIButton buttonWithType:UIButtonTypeCustom];
    btnSettings.backgroundColor = UIColor.whiteColor;
    btnSettings.frame = CGRectMake(0, ((DEVICE_HEIGHT)-viewHeight/5)-exYY, DEVICE_WIDTH/3, viewHeight/5);
    btnSettings.layer.masksToBounds = true;
    btnSettings.layer.borderWidth = 1;
    [btnSettings setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    [btnSettings setTitle:@"OK" forState:UIControlStateNormal];
    [btnSettings addTarget:self action:@selector(btnSettingsAction) forControlEvents:UIControlEventTouchUpInside];
    btnSettings.titleLabel.font = [UIFont fontWithName:CGRegular size:txtSize+10];
    [self.view addSubview:btnSettings];
    
    btn3 = [UIButton buttonWithType:UIButtonTypeCustom];
    btn3.backgroundColor = UIColor.whiteColor;
    btn3.frame = CGRectMake(0, ((DEVICE_HEIGHT)-(viewHeight/5*2))-exYY, DEVICE_WIDTH/3, viewHeight/5);
    [btn3 setTitle:@"3" forState:UIControlStateNormal];
    btn3.layer.masksToBounds = true;
    btn3.layer.borderWidth = 1;
    [btn3 addTarget:self action:@selector(btn3Action) forControlEvents:UIControlEventTouchUpInside];
    [btn3 setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    [btn3 setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    btn3.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    btn3.titleLabel.font = [UIFont fontWithName:CGRegular size:txtSize+10];
    btn3.titleLabel.numberOfLines = 2;
    [self.view addSubview:btn3];
    
    btn4 = [UIButton buttonWithType:UIButtonTypeCustom];
    btn4.backgroundColor = UIColor.whiteColor;
    btn4.frame = CGRectMake(0, ((DEVICE_HEIGHT)-(viewHeight/5*3))-exYY, DEVICE_WIDTH/3, viewHeight/5);
    [btn4 setTitle:@"4" forState:UIControlStateNormal];
    btn4.layer.masksToBounds = true;
    btn4.layer.borderWidth = 1;
    [btn4 addTarget:self action:@selector(btn4Action) forControlEvents:UIControlEventTouchUpInside];
    [btn4 setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    [btn4 setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    btn4.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    btn4.titleLabel.font = [UIFont fontWithName:CGRegular size:txtSize+5];
    btn4.titleLabel.numberOfLines = 2;
    [self.view addSubview:btn4];
    
    btn5 = [UIButton buttonWithType:UIButtonTypeCustom];
    btn5.backgroundColor = UIColor.whiteColor;
    btn5.frame = CGRectMake(0, ((DEVICE_HEIGHT)-(viewHeight/5*4))-exYY, DEVICE_WIDTH/3, viewHeight/5);
    [btn5 setTitle:@"5" forState:UIControlStateNormal];
    btn5.layer.masksToBounds = true;
    btn5.layer.borderWidth = 1;
    [btn5 addTarget:self action:@selector(btn5Action) forControlEvents:UIControlEventTouchUpInside];
    [btn5 setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    [btn5 setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    btn5.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    btn5.titleLabel.font = [UIFont fontWithName:CGRegular size:txtSize+10];
    btn5.titleLabel.numberOfLines = 2;
    [self.view addSubview:btn5];
    
    btn6 = [UIButton buttonWithType:UIButtonTypeCustom];
    btn6.backgroundColor = UIColor.whiteColor;
    btn6.frame = CGRectMake(0, ((DEVICE_HEIGHT)-(viewHeight/5*5))-exYY, DEVICE_WIDTH/3, viewHeight/5);
    [btn6 setTitle:@"6" forState:UIControlStateNormal];
    btn6.layer.masksToBounds = true;
    btn6.layer.borderWidth = 1;
    [btn6 addTarget:self action:@selector(btn6Action) forControlEvents:UIControlEventTouchUpInside];
    [btn6 setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    [btn6 setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    btn6.titleLabel.font = [UIFont fontWithName:CGRegular size:txtSize+10];
    btn6.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    btn6.titleLabel.numberOfLines = 2;
    [self.view addSubview:btn6];
    NSLog(@"%ld",(long)[[UIDevice currentDevice]  orientation]);

//    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
//
//    if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationFaceDown || [[UIDevice currentDevice] orientation] == UIDeviceOrientationUnknown || [[UIDevice currentDevice] orientation] == UIDeviceOrientationFaceUp)
//    {
//        orientation = (UIDeviceOrientation)orinetationCount;
//    }
    if ([[UIApplication sharedApplication] statusBarOrientation] == UIDeviceOrientationLandscapeLeft || [[UIApplication sharedApplication] statusBarOrientation] == UIDeviceOrientationLandscapeRight )
    {
        [self setLandscapeFrames];
    }
    
    
    
    for (int i=0; i<6; i++)
    {
        NSMutableDictionary * tmpDict = [[NSMutableDictionary alloc] init];
        tmpDict = [[NSUserDefaults standardUserDefaults] valueForKey:[NSString stringWithFormat:@"Relay%d",i+1]];
        [self setMainRelayBtnName:[tmpDict valueForKey:@"name"] forRelayNumber:[NSString stringWithFormat:@"%d",i+1]];
        
    }
    
}

#pragma mark - SET ALL VALUES
-(void)setAllValues
{
    
}

#pragma mark - ORBSwitchDelegate

- (void)orbSwitchToggled:(ORBSwitch *)switchObj withNewValue:(BOOL)newValue
{
    isSwitchOn = newValue;

    if (newValue == NO)
    {
        NSLog(@"switch is off");
        
        [btnName setHidden:true];
        [lblTfieldNameLine setHidden:true];
        
        viewBelowSwitch.frame = CGRectMake((DEVICE_WIDTH/3)+5, switchEditButton.frame.origin.y + switchEditButton.frame.size.height+3, (DEVICE_WIDTH-(DEVICE_WIDTH/3))-5, 420);
        
        if ([[UIApplication sharedApplication] statusBarOrientation] == UIDeviceOrientationLandscapeLeft || [[UIApplication sharedApplication] statusBarOrientation] == UIDeviceOrientationLandscapeRight)
        {
            viewBelowSwitch.frame = CGRectMake((DEVICE_WIDTH/5)+5, lblEditlbl.frame.origin.y+lblEditlbl.frame.size.height+5, (DEVICE_WIDTH-DEVICE_WIDTH/5)-10, 420);
        }
        else if ([[UIApplication sharedApplication] statusBarOrientation] == UIDeviceOrientationPortrait)
        {
             viewBelowSwitch.frame = CGRectMake((DEVICE_WIDTH/3)+5, switchEditButton.frame.origin.y + switchEditButton.frame.size.height+3, (DEVICE_WIDTH-(DEVICE_WIDTH/3))-5, 420);
        }
        btnOTA.frame = CGRectMake((DEVICE_WIDTH/3)+10, switchEditButton.frame.size.height + switchEditButton.frame.origin.y + 30, (DEVICE_WIDTH/2)-20, 44);
        lblVersion.frame = CGRectMake((DEVICE_WIDTH/3)+10, btnOTA.frame.size.height + btnOTA.frame.origin.y + 30, (DEVICE_WIDTH/2)- 20, 44);

    }
    else if(newValue == YES)
    {
        NSLog(@"switch is on");
        
        btnName = [[UIButton alloc]initWithFrame:CGRectMake((DEVICE_WIDTH/3)+5, (switchEditButton.frame.origin.y + switchEditButton.frame.size.height+5), (DEVICE_WIDTH-(DEVICE_WIDTH/3)), 30)];
        [btnName setTitle:@"Enter Name" forState:UIControlStateNormal];
        [btnName setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
        [btnName addTarget:self action:@selector(btnNameAction) forControlEvents:UIControlEventTouchUpInside];
        btnName.backgroundColor = UIColor.clearColor;
        btnName.titleLabel.font = [UIFont fontWithName:CGRegular size:txtSize+3];
        btnName.titleLabel.textAlignment = NSTextAlignmentLeft;
        btnName.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [viewRelay addSubview:btnName];
        
        lblTfieldNameLine = [[UILabel alloc]initWithFrame:CGRectMake(0, btnName.frame.size.height-1,btnName.frame.size.width, 1)];
        [lblTfieldNameLine setBackgroundColor:[UIColor lightGrayColor]];
        [btnName addSubview:lblTfieldNameLine];
        
        [btnName setTitle:[dictSelected valueForKey:@"name"] forState:UIControlStateNormal];

        CGRect switchViewFrame = viewBelowSwitch.frame;
        switchViewFrame.origin.y = switchEditButton.frame.origin.y + switchEditButton.frame.size.height+40;
        
        viewBelowSwitch.frame = switchViewFrame;
        if ([[UIApplication sharedApplication] statusBarOrientation] == UIDeviceOrientationLandscapeLeft || [[UIApplication sharedApplication] statusBarOrientation] == UIDeviceOrientationLandscapeRight)
        {
            viewBelowSwitch.frame = CGRectMake((DEVICE_WIDTH/5)+5, switchEditButton.frame.origin.y + switchEditButton.frame.size.height+40, (DEVICE_WIDTH-(DEVICE_WIDTH/3))-5, 420);
            btnName.frame = CGRectMake((DEVICE_WIDTH/5)+5, (switchEditButton.frame.origin.y + switchEditButton.frame.size.height+5),  (DEVICE_WIDTH-DEVICE_WIDTH/5)-10, 30);
            lblTfieldNameLine.frame = CGRectMake(0, btnName.frame.size.height-6,btnName.frame.size.width, 1);
            
            if (self.view.frame.size.width == 480)
            {
                viewRelay.scrollEnabled = YES;
                viewRelay.contentSize = CGSizeMake(viewRelay.frame.size.width,viewRelay.frame.size.height+200);
            }
        }
        else if ([[UIApplication sharedApplication] statusBarOrientation] == UIDeviceOrientationPortrait)
        {
            viewBelowSwitch.frame = CGRectMake((DEVICE_WIDTH/3)+5, switchEditButton.frame.origin.y + switchEditButton.frame.size.height+40, (DEVICE_WIDTH-(DEVICE_WIDTH/3))-5, 420);
            btnName.frame = CGRectMake((DEVICE_WIDTH/3)+5, (switchEditButton.frame.origin.y + switchEditButton.frame.size.height+5),  (DEVICE_WIDTH-DEVICE_WIDTH/3)-10, 30);
            lblTfieldNameLine.frame = CGRectMake(0, btnName.frame.size.height-6,btnName.frame.size.width, 1);
            
            if (self.view.frame.size.height == 480)
            {
                viewRelay.scrollEnabled = YES;
                viewRelay.contentSize = CGSizeMake(viewRelay.frame.size.width, viewRelay.frame.size.height+130);
            }
        }
        
        btnOTA.frame = CGRectMake((DEVICE_WIDTH/3)+10, btnName.frame.size.height + btnName.frame.origin.y + 30, (DEVICE_WIDTH/2)- 20, 44);
        lblVersion.frame = CGRectMake((DEVICE_WIDTH/3)+10, btnOTA.frame.size.height + btnOTA.frame.origin.y + 30, (DEVICE_WIDTH/2)- 20, 44);


    }
}

-(void)orbSwitchToggleAnimationFinished:(ORBSwitch *)switchObj
{
    [switchObj setCustomKnobImage:[UIImage imageNamed:(switchObj.isOn) ? @"on_icon" : @"off_icon"]
          inactiveBackgroundImage:[UIImage imageNamed:@"switch_track_icon"]
            activeBackgroundImage:[UIImage imageNamed:@"switch_track_icon"]];
}
#pragma mark - MAIN SETTING VIEW Button Click Events
-(void)btnUnitClick:(id)sender
{
    if ([sender tag] ==1)
    {
        [btnEnglish setImage:[UIImage imageNamed:@"radioSelected"]  forState:UIControlStateNormal];
        [btnMetric setImage:[UIImage imageNamed:@"radioUnselected"]  forState:UIControlStateNormal];
        
        [[NSUserDefaults standardUserDefaults] setValue:@"English-SAE" forKey:@"unitType"];
        
    }
    else
    {
        [btnMetric setImage:[UIImage imageNamed:@"radioSelected"]  forState:UIControlStateNormal];
        [btnEnglish setImage:[UIImage imageNamed:@"radioUnselected"]  forState:UIControlStateNormal];
        
        [[NSUserDefaults standardUserDefaults] setValue:@"Metric-ISO" forKey:@"unitType"];
        
    }
    [[NSUserDefaults standardUserDefaults]synchronize];
}
-(void)btnOdo1Click:(id)sender
{
    if ([sender tag] ==1)
    {
        [btnUnitOdo1 setImage:[UIImage imageNamed:@"radioSelected"]  forState:UIControlStateNormal];
        [btnTenthsOd1 setImage:[UIImage imageNamed:@"radioUnselected"]  forState:UIControlStateNormal];
        
        [[NSUserDefaults standardUserDefaults] setValue:@"Unit" forKey:@"odometer1"];
        
    }
    else
    {
        [btnTenthsOd1 setImage:[UIImage imageNamed:@"radioSelected"]  forState:UIControlStateNormal];
        [btnUnitOdo1 setImage:[UIImage imageNamed:@"radioUnselected"]  forState:UIControlStateNormal];
        
        [[NSUserDefaults standardUserDefaults] setValue:@"Tenths" forKey:@"odometer1"];
    }
    [[NSUserDefaults standardUserDefaults]synchronize];
}
-(void)btnOdo2Click:(id)sender
{
    if ([sender tag] ==1)
    {
        [btnUnitOdo2 setImage:[UIImage imageNamed:@"radioSelected"]  forState:UIControlStateNormal];
        [btnTenthsOd2 setImage:[UIImage imageNamed:@"radioUnselected"]  forState:UIControlStateNormal];
        
        [[NSUserDefaults standardUserDefaults] setValue:@"Unit" forKey:@"odometer2"];
    }
    else
    {
        [btnTenthsOd2 setImage:[UIImage imageNamed:@"radioSelected"]  forState:UIControlStateNormal];
        [btnUnitOdo2 setImage:[UIImage imageNamed:@"radioUnselected"]  forState:UIControlStateNormal];
        
        [[NSUserDefaults standardUserDefaults] setValue:@"Tenths" forKey:@"odometer2"];
    }
    [[NSUserDefaults standardUserDefaults]synchronize];
}

-(void)btnSettingsAction
{
    [yourViewBorder removeFromSuperlayer];
    btn1.layer.borderColor = [UIColor blackColor].CGColor;
    btn2.layer.borderColor = [UIColor blackColor].CGColor;
    btn3.layer.borderColor = [UIColor blackColor].CGColor;
    btn4.layer.borderColor = [UIColor blackColor].CGColor;
    btn5.layer.borderColor = [UIColor blackColor].CGColor;
    btn6.layer.borderColor = [UIColor blackColor].CGColor;

    if (viewRelay.hidden == false)
    {
        viewRelay.hidden = true;
        viewSettings.hidden = false;
    }
    else if(viewSettings.hidden == false)
    {
        [self.navigationController popViewControllerAnimated:false];
    }
}
-(void) btnIgnitionTimePickerClick
{
    [self OpenTimePicker];
    [self ShowPicker:YES andView:ViewPicker];
}
-(void) btnCancelAction
{
    [self ShowPicker:NO andView:ViewPicker];
}
-(void) btnDoneAction
{
    if (btnDone.tag == 1)
    {
        if ([[APP_DELEGATE checkforValidString:strTimeValue] isEqualToString:@"NA"])
        {
            lblPicker.text = [NSString stringWithFormat:@"5 Mins"];
        }
        else
        {
            lblPicker.text = [NSString stringWithFormat:@"%@ Mins",strTimeValue];
            [[NSUserDefaults standardUserDefaults] setValue:strTimeValue forKey:@"ignitiontime"];
            [[NSUserDefaults standardUserDefaults]synchronize];
            
            [APP_DELEGATE sendSignalViaScan:@"ignitionOffTime" withDeviceID:strTimeValue withValue:@"0" withStatus:@"0"];

        }
        [self ShowPicker:NO andView:ViewPicker];
    }
   else if(btnDone.tag == 2)
   {
       if ([[APP_DELEGATE checkforValidString:strElapsedTimeValueHH] isEqualToString:@"NA"])
       {
           strElapsedTimeValueHH = @"00";
       }
       
       if ([[APP_DELEGATE checkforValidString:strElapsedTimeValueMM] isEqualToString:@"NA"])
       {
           strElapsedTimeValueMM = @"00";
       }
       
       if ([[APP_DELEGATE checkforValidString:strElapsedTimeValueSS] isEqualToString:@"NA"])
       {
           strElapsedTimeValueSS = @"00";
       }
       strElapsedTimeValue = [NSString stringWithFormat:@"%@ : %@ : %@",strElapsedTimeValueHH,strElapsedTimeValueMM,strElapsedTimeValueSS];
       
       if ([[APP_DELEGATE checkforValidString:strElapsedTimeValue] isEqualToString:@"NA"])
       {
           [btnTimeValue setTitle:@"00:00:00" forState:UIControlStateNormal];
       }
       else
       {
           [btnTimeValue setTitle:[NSString stringWithFormat:@"%@",strElapsedTimeValue] forState:UIControlStateNormal];
       }
       [self ShowPicker:NO andView:ViewPicker];
       [dictSelected setObject:strElapsedTimeValue forKey:@"elapsedtime"];
       [[NSUserDefaults standardUserDefaults]setObject:dictSelected forKey:[NSString stringWithFormat:@"Relay%ld",(long)selectedRelayBtn] ];
       [[NSUserDefaults standardUserDefaults]synchronize ];
   }
    else if (btnDone.tag == 3)
    {
        
        if ([[APP_DELEGATE checkforValidString:strRelayAssigned] isEqualToString:@"NA"])
        {
            strRelayAssigned = @"1";
            [btnRelayAssign setTitle:strRelayAssigned forState:UIControlStateNormal];

        }
        else
        {
            [btnRelayAssign setTitle:strRelayAssigned forState:UIControlStateNormal];
        }
        [self ShowPicker:NO andView:ViewPicker];
        
         strPrevAss = [dictRelayAssign valueForKey:strRelayAssigned];
        [dictRelayAssign setValue:[NSString stringWithFormat:@"%ld",(long)selectedRelayBtn] forKey:strRelayAssigned];
        [dictRelayAssign setValue:strPrevAss forKey:strDefaltAssigned];
        [[NSUserDefaults standardUserDefaults]setValue:dictRelayAssign forKey:@"relayAssignedDict"];
        [[NSUserDefaults standardUserDefaults]synchronize];
        
        NSMutableDictionary * tmpDict1 = [[NSMutableDictionary alloc] init];
        tmpDict1 = [[[NSUserDefaults standardUserDefaults] valueForKey:[NSString stringWithFormat:@"Relay%ld",(long)selectedRelayBtn]] mutableCopy];
        [tmpDict1 setValue:strRelayAssigned forKey:@"assigned"];
        [[NSUserDefaults standardUserDefaults] setObject:tmpDict1 forKey:[NSString stringWithFormat:@"Relay%ld",(long)selectedRelayBtn]];
        
        [self SendRelayAssignedValuetoBLE:strRelayAssigned withRelayNumber:[NSString stringWithFormat:@"%ld",(long)selectedRelayBtn]];
        
//        [self performSelector:@selector(stopAdvertiseiBacons) withObject:nil afterDelay:4];

    }
}
-(void)stopAdvertiseiBacons
{
    NSMutableDictionary * tmpDict2 = [[NSMutableDictionary alloc] init];
    tmpDict2 = [[[NSUserDefaults standardUserDefaults] valueForKey:[NSString stringWithFormat:@"Relay%@",strPrevAss]] mutableCopy];
    [tmpDict2 setValue:strDefaltAssigned forKey:@"assigned"];
    [[NSUserDefaults standardUserDefaults] setObject:tmpDict2 forKey:[NSString stringWithFormat:@"Relay%@",strPrevAss]];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self SendRelayAssignedValuetoBLE:strDefaltAssigned withRelayNumber:[NSString stringWithFormat:@"%@",strPrevAss]];

}
-(void)SendRelayAssignedValuetoBLE:(NSString *)strRelayAssigned withRelayNumber:(NSString *)strRelayNumber
{
//    NSString * strMsg = [NSString stringWithFormat:strRelayAssigned];
    NSLog(@"RELAY NO=%@    &&&&& ASSIGNED =%@", strRelayNumber, strRelayAssigned);
    
    [APP_DELEGATE sendSignalViaScan:@"GearKnobAssignment" withDeviceID:0 withValue:0 withStatus:@"0"];
}

#pragma mark - RELAY BUTTON CLICK EVENTS
-(void) btn1Action
{
    selectedRelayBtn = 1;

    int viewHeight = DEVICE_HEIGHT-20;
    int exYY =0;
    int xx = 20;
    if (IS_IPHONE_X)
    {
        xx = 44;
        viewHeight = DEVICE_HEIGHT-84;
        exYY = 44;
    }
    btn1.layer.borderColor = [UIColor whiteColor].CGColor;
    btn2.layer.borderColor = [UIColor blackColor].CGColor;
    btn3.layer.borderColor = [UIColor blackColor].CGColor;
    btn4.layer.borderColor = [UIColor blackColor].CGColor;
    btn5.layer.borderColor = [UIColor blackColor].CGColor;
    btn6.layer.borderColor = [UIColor blackColor].CGColor;
    
    viewRelay.hidden = NO;
    lblChannelNumber.text = @"Channel 1 Settings";
    viewSettings.hidden = YES;
    [btnRelayAssign setTitle:@"1" forState:UIControlStateNormal];
    [self ShowPicker:NO andView:ViewPicker];

    [self setSettingsValue];
    
    [yourViewBorder removeFromSuperlayer];
    yourViewBorder = [CAShapeLayer layer];
    yourViewBorder.strokeColor = [UIColor whiteColor].CGColor;
    yourViewBorder.fillColor = nil;
    yourViewBorder.lineDashPattern = @[@20, @20];
    yourViewBorder.frame = btn3.bounds;
    yourViewBorder.path = [UIBezierPath bezierPathWithRect:btn1.bounds].CGPath;
    yourViewBorder.lineWidth = 15;
    [btn1.layer addSublayer:yourViewBorder];

    strAlertViewText =@"";
}
-(void) btn2Action
{
    selectedRelayBtn = 2;
    int viewHeight = DEVICE_HEIGHT-20;
    int exYY =0;
    int xx = 20;

    if (IS_IPHONE_X)
    {
        xx=44;
        viewHeight = DEVICE_HEIGHT-84;
        exYY = 44;
    }
    lblChannelNumber.text = @"Channel 2 Settings";
    viewSettings.hidden = YES;
    viewRelay.hidden = NO;
    [btnRelayAssign setTitle:@"2" forState:UIControlStateNormal];
    [self ShowPicker:NO andView:ViewPicker];
    [self setSettingsValue];
    
    btn1.layer.borderColor = [UIColor blackColor].CGColor;
    btn2.layer.borderColor = [UIColor whiteColor].CGColor;
    btn3.layer.borderColor = [UIColor blackColor].CGColor;
    btn4.layer.borderColor = [UIColor blackColor].CGColor;
    btn5.layer.borderColor = [UIColor blackColor].CGColor;
    btn6.layer.borderColor = [UIColor blackColor].CGColor;

    [yourViewBorder removeFromSuperlayer];
    yourViewBorder = [CAShapeLayer layer];
    yourViewBorder.strokeColor = [UIColor whiteColor].CGColor;
    yourViewBorder.fillColor = nil;
    yourViewBorder.lineDashPattern = @[@20, @20];
    yourViewBorder.frame = btn3.bounds;
    yourViewBorder.path = [UIBezierPath bezierPathWithRect:btn1.bounds].CGPath;
    yourViewBorder.lineWidth = 15;
    [btn2.layer addSublayer:yourViewBorder];
    strAlertViewText =@"";
}
-(void) btn3Action
{
    selectedRelayBtn = 3;

    int viewHeight = DEVICE_HEIGHT-20;
    int exYY =0;
    int xx = 20;
    if (IS_IPHONE_X)
    {
        xx = 44;
        viewHeight = DEVICE_HEIGHT-84;
        exYY = 44;
    }
    btn1.layer.borderColor = [UIColor blackColor].CGColor;
    btn2.layer.borderColor = [UIColor blackColor].CGColor;
    btn3.layer.borderColor = [UIColor whiteColor].CGColor;
    btn4.layer.borderColor = [UIColor blackColor].CGColor;
    btn5.layer.borderColor = [UIColor blackColor].CGColor;
    btn6.layer.borderColor = [UIColor blackColor].CGColor;
    
    
    lblChannelNumber.text = @"Channel 3 Settings";
    viewRelay.hidden = NO;
    viewSettings.hidden = YES;
    [btnRelayAssign setTitle:@"3" forState:UIControlStateNormal];
    [self setSettingsValue];

    [yourViewBorder removeFromSuperlayer];
    yourViewBorder = [CAShapeLayer layer];
    yourViewBorder.strokeColor = [UIColor whiteColor].CGColor;
    yourViewBorder.fillColor = nil;
    yourViewBorder.lineDashPattern = @[@20, @20];
    yourViewBorder.frame = btn3.bounds;
    yourViewBorder.path = [UIBezierPath bezierPathWithRect:btn1.bounds].CGPath;
    yourViewBorder.lineWidth = 15;
    [btn3.layer addSublayer:yourViewBorder];
    strAlertViewText =@"";
    


}
-(void) btn4Action
{
    selectedRelayBtn = 4;

    int viewHeight = DEVICE_HEIGHT-20;
    int exYY =0;
    int xx = 20;
    if (IS_IPHONE_X)
    {
        xx = 44;
        viewHeight = DEVICE_HEIGHT-84;
        exYY = 44;
    }

    btn1.layer.borderColor = [UIColor blackColor].CGColor;
    btn2.layer.borderColor = [UIColor blackColor].CGColor;
    btn3.layer.borderColor = [UIColor blackColor].CGColor;
    btn4.layer.borderColor = [UIColor whiteColor].CGColor;
    btn5.layer.borderColor = [UIColor blackColor].CGColor;
    btn6.layer.borderColor = [UIColor blackColor].CGColor;
    
    lblChannelNumber.text = @"Channel 4 Settings";
    viewRelay.hidden = NO;
    viewSettings.hidden = YES;
    [btnRelayAssign setTitle:@"4" forState:UIControlStateNormal];
    [self ShowPicker:NO andView:ViewPicker];
    [self setSettingsValue];

    [yourViewBorder removeFromSuperlayer];
    yourViewBorder = [CAShapeLayer layer];
    yourViewBorder.strokeColor = [UIColor whiteColor].CGColor;
    yourViewBorder.fillColor = nil;
    yourViewBorder.lineDashPattern = @[@20, @20];
    yourViewBorder.frame = btn3.bounds;
    yourViewBorder.path = [UIBezierPath bezierPathWithRect:btn1.bounds].CGPath;
    yourViewBorder.lineWidth = 15;
    [btn4.layer addSublayer:yourViewBorder];
    strAlertViewText =@"";

}
-(void) btn5Action
{
    selectedRelayBtn = 5;

    int viewHeight = DEVICE_HEIGHT-20;
    int exYY =0;
    int xx = 20;
    if (IS_IPHONE_X)
    {
        xx= 44;
        viewHeight = DEVICE_HEIGHT-84;
        exYY = 44;
    }
    btn1.layer.borderColor = [UIColor blackColor].CGColor;
    btn2.layer.borderColor = [UIColor blackColor].CGColor;
    btn3.layer.borderColor = [UIColor blackColor].CGColor;
    btn4.layer.borderColor = [UIColor blackColor].CGColor;
    btn5.layer.borderColor = [UIColor whiteColor].CGColor;
    btn6.layer.borderColor = [UIColor blackColor].CGColor;

   
    lblChannelNumber.text = @"Channel 5 Settings";
    viewRelay.hidden = NO;
    viewSettings.hidden = YES;
    [btnRelayAssign setTitle:@"5" forState:UIControlStateNormal];
    [self ShowPicker:NO andView:ViewPicker];
    [self setSettingsValue];
    
    [yourViewBorder removeFromSuperlayer];
    yourViewBorder = [CAShapeLayer layer];
    yourViewBorder.strokeColor = [UIColor whiteColor].CGColor;
    yourViewBorder.fillColor = nil;
    yourViewBorder.lineDashPattern = @[@20, @20];
    yourViewBorder.frame = btn3.bounds;
    yourViewBorder.path = [UIBezierPath bezierPathWithRect:btn1.bounds].CGPath;
    yourViewBorder.lineWidth = 15;
    [btn5.layer addSublayer:yourViewBorder];
    strAlertViewText =@"";

}
-(void) btn6Action
{
    selectedRelayBtn = 6;

    int viewHeight = DEVICE_HEIGHT-20;
    int exYY =0;
    int xx = 20;
    if (IS_IPHONE_X)
    {
        xx = 44;
        viewHeight = DEVICE_HEIGHT-84;
        exYY = 44;
    }
    btn1.layer.borderColor = [UIColor blackColor].CGColor;
    btn2.layer.borderColor = [UIColor blackColor].CGColor;
    btn3.layer.borderColor = [UIColor blackColor].CGColor;
    btn4.layer.borderColor = [UIColor blackColor].CGColor;
    btn5.layer.borderColor = [UIColor blackColor].CGColor;
    btn6.layer.borderColor = [UIColor whiteColor].CGColor;
    
    lblChannelNumber.text = @"Channel 6 Settings";
    viewRelay.hidden = NO;
    viewSettings.hidden = YES;
    [btnRelayAssign setTitle:@"6" forState:UIControlStateNormal];
    [self ShowPicker:NO andView:ViewPicker];
    [self setSettingsValue];

    [yourViewBorder removeFromSuperlayer];
    yourViewBorder = [CAShapeLayer layer];
    yourViewBorder.strokeColor = [UIColor whiteColor].CGColor;
    yourViewBorder.fillColor = nil;
    yourViewBorder.lineDashPattern = @[@20, @20];
    yourViewBorder.frame = btn3.bounds;
    yourViewBorder.path = [UIBezierPath bezierPathWithRect:btn1.bounds].CGPath;
    yourViewBorder.lineWidth = 15;
    [btn6.layer addSublayer:yourViewBorder];
    strAlertViewText =@"";

}
-(void)btnSwitchTypeClick:(id)sender
{
    if ([sender tag] ==1)
    {
        [APP_DELEGATE startHudProcessForSettingScreen:@""];

        [btnLatch setImage:[UIImage imageNamed:@"radioSelected"]  forState:UIControlStateNormal];
        [btnMom setImage:[UIImage imageNamed:@"radioUnselected"]  forState:UIControlStateNormal];
        [dictSelected setValue:@"Latch On-Off"  forKey:@"switchtype"];
        [[NSUserDefaults standardUserDefaults]setObject:dictSelected forKey:[NSString stringWithFormat:@"Relay%ld",(long)selectedRelayBtn]];
        [[NSUserDefaults standardUserDefaults]synchronize];
        [APP_DELEGATE sendSignalViaScan:@"RelayTypeConfig" withDeviceID:[NSString stringWithFormat:@"%ld",(long)selectedRelayBtn] withValue:@"00" withStatus:@"0"];

        
        [self setOperationMethodForLatch];
    }
    else if([sender tag] ==2)
    {
        [APP_DELEGATE startHudProcessForSettingScreen:@""];

        [APP_DELEGATE sendSignalViaScan:@"RelayTypeConfig" withDeviceID:[NSString stringWithFormat:@"%ld",(long)selectedRelayBtn] withValue:@"01" withStatus:@"0"];
        
        [btnMom setImage:[UIImage imageNamed:@"radioSelected"]  forState:UIControlStateNormal];
        [btnLatch setImage:[UIImage imageNamed:@"radioUnselected"]  forState:UIControlStateNormal];
        
        [dictSelected setValue:@"Momentary"  forKey:@"switchtype"];
        [[NSUserDefaults standardUserDefaults]setObject:dictSelected forKey:[NSString stringWithFormat:@"Relay%ld",(long)selectedRelayBtn]];
        [[NSUserDefaults standardUserDefaults]synchronize];
        
        lblOperation.hidden = true;
        btnNone.hidden = true;
        btnElapsedTime.hidden = true;
        btnSpeed.hidden = true;
        btnDistance.hidden = true;
        
        lblMoreSpeed.hidden = true;
        lblLessSpeed.hidden = true;
        btnLessSpeedValue.hidden = true;
        btnMoreSpeedValue.hidden = true;
        lblDistStaticlbl.hidden = true;
        btnValueDistance.hidden = true;
        lblTimelbl.hidden = true;
        btnTimeValue.hidden = true;
    }
    
    NSLog(@"--------------------------------------------------->startttt");
    timerSettings = nil;
    [timerSettings invalidate];
    timerSettings = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(stopTimer) userInfo:nil repeats:NO];
}
-(void)stopTimer
{
    NSLog(@"---------------------------------------------------->end");
    [APP_DELEGATE endHudProcessForSettingScreen];
}
/*
-(void)btnConditionalOp:(id)sender
{
    if ([sender tag] ==1)
    {
        intSelectedIndex = 0;
        strSelectedOperation = @"None";
        [btnNone setImage:[UIImage imageNamed:@"radioSelected"]  forState:UIControlStateNormal];
        [btnElapsedTime setImage:[UIImage imageNamed:@"radioUnselected"]  forState:UIControlStateNormal];
        [btnSpeed setImage:[UIImage imageNamed:@"radioUnselected"]  forState:UIControlStateNormal];
        [btnDistance setImage:[UIImage imageNamed:@"radioUnselected"]  forState:UIControlStateNormal];
        
        lblMoreSpeed.hidden = true;
        lblLessSpeed.hidden = true;
        btnLessSpeedValue.hidden = true;
        lblDistStaticlbl.hidden = true;
        btnTimeValue.hidden = true;
        btnValueDistance.hidden = true;
        btnMoreSpeedValue.hidden = true;
        lblTimelbl.hidden = true;


        
    }
    else if([sender tag] ==2)
    {
        intSelectedIndex = 1;
        strSelectedOperation = @"Elapsed Time";
        [btnElapsedTime setImage:[UIImage imageNamed:@"radioSelected"]  forState:UIControlStateNormal];
        [btnNone setImage:[UIImage imageNamed:@"radioUnselected"]  forState:UIControlStateNormal];
        [btnSpeed setImage:[UIImage imageNamed:@"radioUnselected"]  forState:UIControlStateNormal];
        [btnDistance setImage:[UIImage imageNamed:@"radioUnselected"]  forState:UIControlStateNormal];
      
        lblMoreSpeed.hidden = true;
        lblLessSpeed.hidden = true;
        btnLessSpeedValue.hidden = true;
        lblDistStaticlbl.hidden = true;
        lblTimelbl.hidden = false;
        btnTimeValue.hidden = false;
        btnValueDistance.hidden = true;
        btnMoreSpeedValue.hidden = true;

    }
    else if([sender tag] ==3)
    {
        intSelectedIndex = 2;
        strSelectedOperation = @"Speed";
        [btnSpeed setImage:[UIImage imageNamed:@"radioSelected"]  forState:UIControlStateNormal];
        [btnElapsedTime setImage:[UIImage imageNamed:@"radioUnselected"]  forState:UIControlStateNormal];
        [btnNone setImage:[UIImage imageNamed:@"radioUnselected"]  forState:UIControlStateNormal];
        [btnDistance setImage:[UIImage imageNamed:@"radioUnselected"]  forState:UIControlStateNormal];
        
        lblMoreSpeed.hidden = false;
        lblLessSpeed.hidden = false;
        btnLessSpeedValue.hidden = false;
        btnTimeValue.hidden = true;
        lblDistStaticlbl.hidden = true;
        lblTimelbl.hidden = true;
        btnValueDistance.hidden = true;
        btnMoreSpeedValue.hidden = false;
        
     
    }
    
    else if([sender tag] ==4)
    {
        intSelectedIndex = 3;
        strSelectedOperation = @"Distance";
        [btnDistance setImage:[UIImage imageNamed:@"radioSelected"]  forState:UIControlStateNormal];
        [btnElapsedTime setImage:[UIImage imageNamed:@"radioUnselected"]  forState:UIControlStateNormal];
        [btnSpeed setImage:[UIImage imageNamed:@"radioUnselected"]  forState:UIControlStateNormal];
        [btnNone setImage:[UIImage imageNamed:@"radioUnselected"]  forState:UIControlStateNormal];
        
        lblMoreSpeed.hidden = true;
        lblLessSpeed.hidden = true;
        btnLessSpeedValue.hidden = true;
        btnTimeValue.hidden = true;
        lblTimelbl.hidden = true;
        lblDistStaticlbl.hidden = NO;
        btnValueDistance.hidden = false;
        btnMoreSpeedValue.hidden = true;
    }
    [[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithFormat:@"%d",intSelectedIndex] forKey:@"prevSelectedIndex"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}
 */
-(void)btnTimeValueAction
{
    strElapsedTimeValueHH = @"00";
    strElapsedTimeValueMM = @"00";
    strElapsedTimeValueSS = @"00";
    
    [self openElapsedTimePicker];
    [self ShowPicker:YES andView:ViewPicker];

}
-(void)btnNameAction
{
    [alert removeFromSuperview];
    alert = [[FCAlertView alloc] init];
    alert.delegate = self;
    alert.tag = 100;
    alert.colorScheme = global_color;
    
    UITextField *customField = [[UITextField alloc] init];
    customField.placeholder = @"Enter Name";
    customField.keyboardType = UIKeyboardTypeDefault;
    customField.autocorrectionType = UITextAutocorrectionTypeNo;
    
    strAlertViewText = [dictSelected valueForKey:@"name"];
    if (![[APP_DELEGATE checkforValidString:strAlertViewText] isEqualToString:@"NA"])
    {
        customField.text = strAlertViewText;
    }
    
    [alert addTextFieldWithCustomTextField:customField andPlaceholder:nil andTextReturnBlock:^(NSString *text) {
        NSLog(@"Custom TextField Returns: %@", text); // Do what you'd like with the text returned from the field
        
        if (![[APP_DELEGATE checkforValidString:text] isEqualToString:@"NA"])
        {
            self->strAlertViewText = text;
        }
        
        
    }];
    [alert addButton:@"Cancel" withActionBlock:^{
        NSLog(@"Custom Font Button Pressed");
        // Put your action here
    }];
    
    [alert showAlertInView:self
                 withTitle:@"Redshift"
              withSubtitle:@"Enter Name"
           withCustomImage:nil
       withDoneButtonTitle:nil
                andButtons:nil];
}
-(void)btnValueDistanceAction
{
    [alert removeFromSuperview];
    alert = [[FCAlertView alloc] init];
    alert.delegate = self;
    alert.tag = 103;
    alert.colorScheme = global_color;
    
    UITextField *customField = [[UITextField alloc] init];
    customField.placeholder = @"Enter Distance";
    customField.keyboardType = UIKeyboardTypeNumberPad;
    customField.autocorrectionType = UITextAutocorrectionTypeNo;
    
    strAlertViewText = [dictSelected valueForKey:@"distance"];
    if (![[APP_DELEGATE checkforValidString:strAlertViewText] isEqualToString:@"NA"])
    {
        customField.text = strAlertViewText;
    }
    [alert addTextFieldWithCustomTextField:customField andPlaceholder:nil andTextReturnBlock:^(NSString *text) {
        NSLog(@"Custom TextField Returns: %@", text); // Do what you'd like with the text returned from the field
        
        if (![[APP_DELEGATE checkforValidString:text] isEqualToString:@"NA"])
        {
            self->strAlertViewText = text;
        }
       
    }];
    [alert addButton:@"Cancel" withActionBlock:^{
        NSLog(@"Custom Font Button Pressed");
        // Put your action here
    }];
    
    NSString * strHintTxt;
    if ([[[NSUserDefaults standardUserDefaults]valueForKey:@"unitType"] isEqualToString:@"English-SAE"])
    {
        strHintTxt = @"Enter Distance (Miles)";
    }
    else
    {
        strHintTxt = @"Enter Distance (KM)";
    }
    [alert showAlertInView:self
                 withTitle:@"Redshift"
              withSubtitle:strHintTxt
           withCustomImage:nil
       withDoneButtonTitle:nil
                andButtons:nil];
}
-(void)btnMoreSpeedValueAction
{
    [alert removeFromSuperview];
    alert = [[FCAlertView alloc] init];
    alert.delegate = self;
    alert.tag = 101;
    alert.colorScheme = global_color;
    
    UITextField *customField = [[UITextField alloc] init];
    customField.placeholder = @"Enter More Than Speed";
    customField.keyboardType = UIKeyboardTypeNumberPad;
    customField.autocorrectionType = UITextAutocorrectionTypeNo;
    
    strAlertViewText = [dictSelected valueForKey:@"morespeed"];
    if (![[APP_DELEGATE checkforValidString:strAlertViewText] isEqualToString:@"NA"])
    {
        customField.text = strAlertViewText;
    }
    
    [alert addTextFieldWithCustomTextField:customField andPlaceholder:nil andTextReturnBlock:^(NSString *text)
    {
        NSLog(@"Custom TextField Returns: %@", text); // Do what you'd like with the text returned from the field
       // self->strAlertViewText = [text stringByAppendingString:@ "KPH"];
        
        if (![[APP_DELEGATE checkforValidString:text] isEqualToString:@"NA"])
        {
            self->strAlertViewText = text;
            
           
        }
        
    }];
    [alert addButton:@"Cancel" withActionBlock:^{
        NSLog(@"Custom Font Button Pressed");
        // Put your action here
    }];
    
    NSString * strHintTxt;
    if ([[[NSUserDefaults standardUserDefaults]valueForKey:@"unitType"] isEqualToString:@"English-SAE"])
    {
        strHintTxt = @"More than Speed (MPH)";
    }
    else
    {
        strHintTxt = @"More than Speed (KPH)";
    }
    [alert showAlertInView:self
                 withTitle:@"Redshift"
              withSubtitle:strHintTxt
           withCustomImage:nil
       withDoneButtonTitle:nil
                andButtons:nil];
}
-(void)btnLessSpeedValueAction
{
    [alert removeFromSuperview];
    alert = [[FCAlertView alloc] init];
    alert.delegate = self;
    alert.tag = 102;
    alert.colorScheme = global_color;
    
    UITextField *customField = [[UITextField alloc] init];
    customField.placeholder = @"Enter Less Than Speed";
    customField.keyboardType = UIKeyboardTypeNumberPad;
    customField.autocorrectionType = UITextAutocorrectionTypeNo;
    
    strAlertViewText = [dictSelected valueForKey:@"lessspeed"];
    if (![[APP_DELEGATE checkforValidString:strAlertViewText] isEqualToString:@"NA"])
    {
        customField.text = strAlertViewText;
    }
    
    [alert addTextFieldWithCustomTextField:customField andPlaceholder:nil andTextReturnBlock:^(NSString *text) {
        NSLog(@"Custom TextField Returns: %@", text); // Do what you'd like with the text returned from the field
        //self->strAlertViewText = [text stringByAppendingString:@"KPH"];
        if (![[APP_DELEGATE checkforValidString:text] isEqualToString:@"NA"])
        {
            self->strAlertViewText = text;
        }
        
    }];
    [alert addButton:@"Cancel" withActionBlock:^{
        NSLog(@"Custom Font Button Pressed");
        // Put your action here
    }];
    
    NSString * strHintTxt;
    if ([[[NSUserDefaults standardUserDefaults]valueForKey:@"unitType"] isEqualToString:@"English-SAE"])
    {
        strHintTxt = @"Less than Speed (MPH)";
    }
    else
    {
        strHintTxt = @"Less than Speed (KPH)";
    }
    [alert showAlertInView:self
                 withTitle:@"Redshift"
              withSubtitle:strHintTxt
           withCustomImage:nil
       withDoneButtonTitle:nil
                andButtons:nil];
}
-(void)btnRelayAssignAction
{
    strRelayAssigned = @"";
    [self openRelayAssignPicker];
    [self ShowPicker:YES andView:ViewPicker];
}
-(void)btnOTAClick
{
    [APP_DELEGATE sendSignalViaScan:@"GearKnobAssignment" withDeviceID:0 withValue:0 withStatus:@"0"];
}
#pragma mark - Helper Methods

- (void)FCAlertView:(FCAlertView *)alertView clickedButtonIndex:(NSInteger)index buttonTitle:(NSString *)title
{
    NSLog(@"Button Cancel Clicked: %ld Title:%@", (long)index, title);
  
}

- (void)FCAlertDoneButtonClicked:(FCAlertView *)alertView
{
    NSLog(@"Done Button Clicked");
    
    NSString * strLocalDistanceUnit, * strLocalSpeedUnits;
    if ([[[NSUserDefaults standardUserDefaults]valueForKey:@"unitType"] isEqualToString:@"English-SAE"])
    {
        strLocalDistanceUnit = @"Miles";
        strLocalSpeedUnits = @"MPH";
    }
    else
    {
        strLocalDistanceUnit = @"KM";
        strLocalSpeedUnits = @"KPH";
    }
     if(alertView.tag == 100)
    {
        [btnName setTitle:strAlertViewText forState:UIControlStateNormal];
        [dictSelected setObject:strAlertViewText forKey:@"name"];
        [[NSUserDefaults standardUserDefaults]setObject:dictSelected forKey:[NSString stringWithFormat:@"Relay%ld",(long)selectedRelayBtn] ];
        [[NSUserDefaults standardUserDefaults]synchronize ];
        [self setMainRelayBtnName:strAlertViewText forRelayNumber:[NSString stringWithFormat:@"%ld",(long)selectedRelayBtn]];

    }
     else if (alertView.tag == 101)
     {
         if (![[APP_DELEGATE checkforValidString:strAlertViewText] isEqualToString:@"NA"])
         {
             int speedLimit = [strAlertViewText intValue];
             if (speedLimit > 400)
             {
                 [alert removeFromSuperview];
                 alert = [[FCAlertView alloc] init];
                 alert.colorScheme = [UIColor blackColor];
                 [alert makeAlertTypeCaution];
                 {
                 };
                 alert.firstButtonCustomFont = [UIFont fontWithName:CGRegular size:txtSize];
                 [alert showAlertInView:self
                              withTitle:@"Redshiftt"
                           withSubtitle:@"Invalid speed value"
                        withCustomImage:[UIImage imageNamed:@"Subsea White 180.png"]
                    withDoneButtonTitle:@"OK" andButtons:nil];
             }
             else
             {
                 [btnMoreSpeedValue setTitle:[NSString stringWithFormat:@"%@ %@",strAlertViewText,strLocalSpeedUnits]   forState:UIControlStateNormal];
                 [dictSelected setObject:strAlertViewText forKey:@"morespeed"];
                 [[NSUserDefaults standardUserDefaults]setObject:dictSelected forKey:[NSString stringWithFormat:@"Relay%ld",(long)selectedRelayBtn] ];
                 [[NSUserDefaults standardUserDefaults]synchronize ];
             }
         }
     }
    else if (alertView.tag ==  102)
    {
        if (![[APP_DELEGATE checkforValidString:strAlertViewText] isEqualToString:@"NA"])
        {
            int speedLimit = [strAlertViewText intValue];
            if (speedLimit > 400)
            {
                [alert removeFromSuperview];
                alert = [[FCAlertView alloc] init];
                alert.colorScheme = [UIColor blackColor];
                [alert makeAlertTypeCaution];
                {
                };
                alert.firstButtonCustomFont = [UIFont fontWithName:CGRegular size:txtSize];
                [alert showAlertInView:self
                             withTitle:@"Redshiftt"
                          withSubtitle:@"Invalid speed value"
                       withCustomImage:[UIImage imageNamed:@"Subsea White 180.png"]
                   withDoneButtonTitle:@"OK" andButtons:nil];
            }
          else
            {
                [btnLessSpeedValue setTitle:[NSString stringWithFormat:@"%@ %@",strAlertViewText,strLocalSpeedUnits]  forState:UIControlStateNormal];
                [dictSelected setObject:strAlertViewText forKey:@"lessspeed"];
                [[NSUserDefaults standardUserDefaults]setObject:dictSelected forKey:[NSString stringWithFormat:@"Relay%ld",(long)selectedRelayBtn] ];
                [[NSUserDefaults standardUserDefaults]synchronize ];
            }
        }
    }
    else if (alertView.tag == 103)
    {
        if (![[APP_DELEGATE checkforValidString:strAlertViewText] isEqualToString:@"NA"])
        {
            [btnValueDistance setTitle:[NSString stringWithFormat:@"%@ %@",strAlertViewText,strLocalDistanceUnit]  forState:UIControlStateNormal];
            [dictSelected setObject:strAlertViewText forKey:@"distance"];
            [[NSUserDefaults standardUserDefaults]setObject:dictSelected forKey:[NSString stringWithFormat:@"Relay%ld",(long)selectedRelayBtn] ];
            [[NSUserDefaults standardUserDefaults]synchronize ];
        }
    }
}

- (void)FCAlertViewDismissed:(FCAlertView *)alertView
{
    NSLog(@"Alert Dismissed");
}

- (void)FCAlertViewWillAppear:(FCAlertView *)alertView
{
    NSLog(@"Alert Will Appear");
}
#pragma mark - PickerView Frames
/* PickerView for Main Settings*/
-(void)OpenTimePicker
{
    [backShadowView removeFromSuperview];
    backShadowView = [[UIView alloc] init];
    backShadowView.backgroundColor = [UIColor blackColor];
    backShadowView.alpha = 0.8;
    backShadowView.frame = CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT);
    [self.view addSubview:backShadowView];

    int widthView = (DEVICE_WIDTH-self->btnSettings.frame.size.width)-20;
    if ([[UIApplication sharedApplication] statusBarOrientation] == UIDeviceOrientationPortrait || [[UIApplication sharedApplication] statusBarOrientation] == UIDeviceOrientationPortraitUpsideDown)
    {
        widthView = (DEVICE_WIDTH-self->btnSettings.frame.size.width)+20;
    }
    
    [ViewPicker removeFromSuperview];
    ViewPicker = [[UIView alloc]initWithFrame:CGRectMake((DEVICE_WIDTH-widthView)/2, DEVICE_HEIGHT,widthView, DEVICE_HEIGHT-315)];
    ViewPicker.backgroundColor = UIColor.whiteColor;
    ViewPicker.layer.cornerRadius = 12;
    ViewPicker.layer.masksToBounds = YES;
    [self.view addSubview:ViewPicker];
    
    if ([[UIApplication sharedApplication] statusBarOrientation] == UIDeviceOrientationPortrait || [[UIApplication sharedApplication] statusBarOrientation] == UIDeviceOrientationPortraitUpsideDown)
    {
        if (self.view.frame.size.height == 480)
        {
            ViewPicker.frame = CGRectMake((DEVICE_WIDTH-widthView)/2, DEVICE_HEIGHT,widthView, 315);
        }
    }
    else
    {
        if (self.view.frame.size.width == 480)
        {
            ViewPicker.frame = CGRectMake((DEVICE_WIDTH-widthView)/2, DEVICE_HEIGHT,widthView, 315);
        }
    }
    
    UIButton *btnCancel = [[UIButton alloc]initWithFrame:CGRectMake(0,0,70,44)];
    [btnCancel setTitleColor:UIColor.redColor forState:UIControlStateNormal];
    [btnCancel setTitle:@"Cancel" forState:UIControlStateNormal];
    btnCancel.backgroundColor = UIColor.clearColor;
    [btnCancel addTarget:self action:@selector(btnCancelAction) forControlEvents:UIControlEventTouchUpInside];
    [ViewPicker addSubview:btnCancel];
    
    btnDone = [[UIButton alloc]initWithFrame:CGRectMake(widthView-70,0,70,44)];
    [btnDone setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    [btnDone setTitle:@"Done" forState:UIControlStateNormal];
    btnDone.backgroundColor = UIColor.clearColor;
    btnDone.tag = 1;
    [btnDone addTarget:self action:@selector(btnDoneAction) forControlEvents:UIControlEventTouchUpInside];
    [ViewPicker addSubview:btnDone];
    
    UILabel * lblLine = [[UILabel alloc] init];
    lblLine.frame = CGRectMake(0, btnDone.frame.origin.y + btnDone.frame.size.height, widthView, 0.5);
    lblLine.backgroundColor = [UIColor lightGrayColor];
    [ViewPicker addSubview:lblLine];
    
    pickerMainSettings = [[UIPickerView alloc]init];
    pickerMainSettings.frame = CGRectMake(0,44,ViewPicker.frame.size.width, ViewPicker.frame.size.height-44);
    pickerMainSettings.delegate = self;
    pickerMainSettings.dataSource = self;
    [ViewPicker addSubview:pickerMainSettings];
    
    if (IS_IPHONE_X)
    {
        if ([[UIApplication sharedApplication] statusBarOrientation] == UIDeviceOrientationLandscapeLeft || [[UIApplication sharedApplication] statusBarOrientation] == UIDeviceOrientationLandscapeRight)
        {
        }
        else
        {
            ViewPicker.frame = CGRectMake((DEVICE_WIDTH-widthView)/2, DEVICE_HEIGHT,DEVICE_WIDTH-self->btnSettings.frame.size.width-10, DEVICE_HEIGHT-315-44);
            pickerMainSettings.frame = CGRectMake(0,44,ViewPicker.frame.size.width, ViewPicker.frame.size.height-44);
        }
    }
}
/*Pickerview for Relay View*/
-(void)openElapsedTimePicker
{
    [backShadowView removeFromSuperview];
    backShadowView = [[UIView alloc] init];
    backShadowView.backgroundColor = [UIColor blackColor];
    backShadowView.alpha = 0.8;
    backShadowView.frame = CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT);
    [self.view addSubview:backShadowView];
    
    int widthView = (DEVICE_WIDTH-self->btnSettings.frame.size.width)-20;
    if ([[UIApplication sharedApplication] statusBarOrientation] == UIDeviceOrientationPortrait || [[UIApplication sharedApplication] statusBarOrientation] == UIDeviceOrientationPortraitUpsideDown)
    {
        widthView = (DEVICE_WIDTH-self->btnSettings.frame.size.width)+20;
    }
    
    [ViewPicker removeFromSuperview];
    ViewPicker = [[UIView alloc]initWithFrame:CGRectMake((DEVICE_WIDTH-widthView)/2, DEVICE_HEIGHT,widthView, DEVICE_HEIGHT-315)];
    ViewPicker.backgroundColor = UIColor.whiteColor;
    ViewPicker.layer.cornerRadius = 12;
    ViewPicker.layer.masksToBounds = YES;
    [self.view addSubview:ViewPicker];
    
    if ([[UIApplication sharedApplication] statusBarOrientation] == UIDeviceOrientationPortrait || [[UIApplication sharedApplication] statusBarOrientation] == UIDeviceOrientationPortraitUpsideDown)
    {
        if (self.view.frame.size.height == 480)
        {
            ViewPicker.frame = CGRectMake((DEVICE_WIDTH-widthView)/2, DEVICE_HEIGHT,widthView, 315);
        }
    }
    else
    {
        if (self.view.frame.size.width == 480)
        {
            ViewPicker.frame = CGRectMake((DEVICE_WIDTH-widthView)/2, DEVICE_HEIGHT,widthView, 315);
        }
    }
    
    UIButton *btnCancel = [[UIButton alloc]initWithFrame:CGRectMake(0,0,70,44)];
    [btnCancel setTitleColor:UIColor.redColor forState:UIControlStateNormal];
    [btnCancel setTitle:@"Cancel" forState:UIControlStateNormal];
    btnCancel.backgroundColor = UIColor.clearColor;
    [btnCancel addTarget:self action:@selector(btnCancelAction) forControlEvents:UIControlEventTouchUpInside];
    [ViewPicker addSubview:btnCancel];
    
    btnDone = [[UIButton alloc]initWithFrame:CGRectMake(widthView-70,0,70,44)];
    [btnDone setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    [btnDone setTitle:@"Done" forState:UIControlStateNormal];
    btnDone.backgroundColor = UIColor.clearColor;
    btnDone.tag = 2;
    [btnDone addTarget:self action:@selector(btnDoneAction) forControlEvents:UIControlEventTouchUpInside];
    [ViewPicker addSubview:btnDone];
    
    UILabel * lblLine = [[UILabel alloc] init];
    lblLine.frame = CGRectMake(0, btnDone.frame.origin.y + btnDone.frame.size.height, widthView, 0.5);
    lblLine.backgroundColor = [UIColor lightGrayColor];
    [ViewPicker addSubview:lblLine];
    
    UILabel* lblHH = [[UILabel alloc]initWithFrame:CGRectMake(5, 49,ViewPicker.frame.size.width/3, 20)];
    lblHH.backgroundColor = UIColor.clearColor;
    lblHH.textColor = UIColor.redColor;
    lblHH.font = [UIFont fontWithName:CGRegular size:txtSize-1];
    lblHH.text = @"Hour";
    lblHH.textAlignment = NSTextAlignmentCenter;
    [ViewPicker addSubview:lblHH];
    
    UILabel* lblMM = [[UILabel alloc]initWithFrame:CGRectMake(ViewPicker.frame.size.width/3+5, 49, ViewPicker.frame.size.width/3, 20)];
    lblMM.backgroundColor = UIColor.clearColor;
    lblMM.textAlignment = NSTextAlignmentCenter;
    lblMM.textColor = UIColor.grayColor;
    lblMM.font = [UIFont fontWithName:CGRegular size:txtSize-1];
    lblMM.text = @"Min";
    [ViewPicker addSubview:lblMM];
    
    UILabel * lblSS = [[UILabel alloc]initWithFrame:CGRectMake(((ViewPicker.frame.size.width/3)*2), 49, ViewPicker.frame.size.width/3, 20)];
    lblSS.backgroundColor = UIColor.clearColor;
    lblSS.textColor = UIColor.grayColor;
    lblSS.textAlignment = NSTextAlignmentCenter;
    lblSS.font = [UIFont fontWithName:CGRegular size:txtSize-1];
    lblSS.text = @"Sec";
    [ViewPicker addSubview:lblSS];
    
   
    datePicker = [[UIPickerView alloc]init];
    datePicker.frame = CGRectMake(0,64,ViewPicker.frame.size.width, ViewPicker.frame.size.height-44);
    datePicker.delegate = self;
    datePicker.dataSource = self;
    [ViewPicker addSubview:datePicker];

    
    if (IS_IPHONE_X)
    {
        if ([[UIApplication sharedApplication] statusBarOrientation] == UIDeviceOrientationLandscapeLeft || [[UIApplication sharedApplication] statusBarOrientation] == UIDeviceOrientationLandscapeRight)
        {
        }
        else
        {
            ViewPicker.frame = CGRectMake((DEVICE_WIDTH-widthView)/2, DEVICE_HEIGHT,DEVICE_WIDTH-self->btnSettings.frame.size.width-10, DEVICE_HEIGHT-315-44);
            datePicker.frame = CGRectMake(0,44,ViewPicker.frame.size.width, ViewPicker.frame.size.height-44);
        }
    }
}
-(void)openRelayAssignPicker
{
    [backShadowView removeFromSuperview];
    backShadowView = [[UIView alloc] init];
    backShadowView.backgroundColor = [UIColor blackColor];
    backShadowView.alpha = 0.8;
    backShadowView.frame = CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT);
    [self.view addSubview:backShadowView];
    
    int widthView = (DEVICE_WIDTH-self->btnSettings.frame.size.width)-20;
    if ([[UIApplication sharedApplication] statusBarOrientation] == UIDeviceOrientationPortrait || [[UIApplication sharedApplication] statusBarOrientation] == UIDeviceOrientationPortraitUpsideDown)
    {
        widthView = (DEVICE_WIDTH-self->btnSettings.frame.size.width)+20;
    }
    
    [ViewPicker removeFromSuperview];
    ViewPicker = [[UIView alloc]initWithFrame:CGRectMake((DEVICE_WIDTH-widthView)/2, DEVICE_HEIGHT,widthView, DEVICE_HEIGHT-315)];
    ViewPicker.backgroundColor = UIColor.whiteColor;
    ViewPicker.layer.cornerRadius = 12;
    ViewPicker.layer.masksToBounds = YES;
    [self.view addSubview:ViewPicker];
    
    if ([[UIApplication sharedApplication] statusBarOrientation] == UIDeviceOrientationPortrait || [[UIApplication sharedApplication] statusBarOrientation] == UIDeviceOrientationPortraitUpsideDown)
    {
        if (self.view.frame.size.height == 480)
        {
            ViewPicker.frame = CGRectMake((DEVICE_WIDTH-widthView)/2, DEVICE_HEIGHT,widthView, 315);
        }
    }
    else
    {
        if (self.view.frame.size.width == 480)
        {
            ViewPicker.frame = CGRectMake((DEVICE_WIDTH-widthView)/2, DEVICE_HEIGHT,widthView, 315);
        }
    }
    
    UIButton *btnCancel = [[UIButton alloc]initWithFrame:CGRectMake(0,0,70,44)];
    [btnCancel setTitleColor:UIColor.redColor forState:UIControlStateNormal];
    [btnCancel setTitle:@"Cancel" forState:UIControlStateNormal];
    btnCancel.backgroundColor = UIColor.clearColor;
    [btnCancel addTarget:self action:@selector(btnCancelAction) forControlEvents:UIControlEventTouchUpInside];
    [ViewPicker addSubview:btnCancel];
    
    btnDone = [[UIButton alloc]initWithFrame:CGRectMake(widthView-70,0,70,44)];
    [btnDone setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    [btnDone setTitle:@"Done" forState:UIControlStateNormal];
    btnDone.backgroundColor = UIColor.clearColor;
    btnDone.tag = 3;
    [btnDone addTarget:self action:@selector(btnDoneAction) forControlEvents:UIControlEventTouchUpInside];
    [ViewPicker addSubview:btnDone];
    
    UILabel * lblLine = [[UILabel alloc] init];
    lblLine.frame = CGRectMake(0, btnDone.frame.origin.y + btnDone.frame.size.height, widthView, 0.5);
    lblLine.backgroundColor = [UIColor lightGrayColor];
    [ViewPicker addSubview:lblLine];
    
    relayPicker = [[UIPickerView alloc]init];
    relayPicker.frame = CGRectMake(0,44,ViewPicker.frame.size.width, ViewPicker.frame.size.height-44);
    relayPicker.delegate = self;
    relayPicker.dataSource = self;
    [ViewPicker addSubview:relayPicker];
    
    if (IS_IPHONE_X)
    {
        if ([[UIApplication sharedApplication] statusBarOrientation] == UIDeviceOrientationLandscapeLeft || [[UIApplication sharedApplication] statusBarOrientation] == UIDeviceOrientationLandscapeRight)
        {
        }
        else
        {
            ViewPicker.frame = CGRectMake((DEVICE_WIDTH-widthView)/2, DEVICE_HEIGHT,DEVICE_WIDTH-self->btnSettings.frame.size.width-10, DEVICE_HEIGHT-315-44);
            relayPicker.frame = CGRectMake(0,44,ViewPicker.frame.size.width, ViewPicker.frame.size.height-44);
        }
    }
}
#pragma mark - PickerView Delegates
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView;
{
    if (pickerView == pickerMainSettings)
    {
        return 1;
    }
    else if(pickerView == datePicker)
    {
    return 3;
    }
    else if (pickerView == relayPicker)
    {
        return 1;
    }
    return true;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component;
{
    if (pickerView == pickerMainSettings)
    {
        return dataArray.count;
    }
    else if(pickerView == datePicker)
    {
        if (component == 0)
        {
            return arrDatePickerHH.count;
        }
        else if(component == 1)
        {
            return arrDatePickerMM.count;
        }
        else if (component == 2)
        {
            return arrDatePickerSS.count;
        }
    }
    else if(pickerView == relayPicker)
    {
        return arrRelayAssign.count;
    }
    return true;
}

- (nullable NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component __TVOS_PROHIBITED;
{
    if (pickerView == pickerMainSettings)
    {
        return [NSString stringWithFormat:@"%@ Mins",dataArray[row]];
    }
    else if(pickerView == datePicker)
    {
        if (component == 0)
        {
            return arrDatePickerHH[row];
        }
        else if(component == 1)
        {
            return arrDatePickerMM[row];
        }
        else if (component == 2)
        {
            return arrDatePickerSS[row];
        }
    }
    else if (pickerView == relayPicker)
    {
        return arrRelayAssign[row];
    }
    return nil;
}
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component __TVOS_PROHIBITED;
{
    if (pickerView == pickerMainSettings)
    {
        strTimeValue = dataArray[row];
    }
    else if(pickerView == datePicker)
    {
        if (component == 0)
        {
            strElapsedTimeValueHH = arrDatePickerHH[row];
        }
        else if(component == 1)
        {
            strElapsedTimeValueMM = arrDatePickerMM[row];
        }
        else if (component == 2)
        {
            strElapsedTimeValueSS = arrDatePickerSS[row];
        }
        
        if ([[APP_DELEGATE checkforValidString:strElapsedTimeValueHH] isEqualToString:@"NA"])
        {
            strElapsedTimeValueHH = @"00";
        }

        if ([[APP_DELEGATE checkforValidString:strElapsedTimeValueMM] isEqualToString:@"NA"])
        {
            strElapsedTimeValueMM = @"00";
        }
       
        if ([[APP_DELEGATE checkforValidString:strElapsedTimeValueSS] isEqualToString:@"NA"])
        {
            strElapsedTimeValueSS = @"00";
        }
      
        strElapsedTimeValue = [NSString stringWithFormat:@"%@ : %@ : %@",strElapsedTimeValueHH,strElapsedTimeValueMM,strElapsedTimeValueSS];
        
    }
    else if (pickerView == relayPicker)
    {
        strRelayAssigned = arrRelayAssign[row];
    }
}
#pragma mark - Animations
-(void)ShowPicker:(BOOL)isShow andView:(UIView *)myView
{
    int xx = 315;
    int exHeight = 0;
    if (IS_IPHONE_5 || IS_IPHONE_4)
    {
        xx = 345;
    }
    else if (IS_IPHONE_X)
    {
        xx = 420;
        exHeight = 44;
    }
    else
    {
        xx = DEVICE_HEIGHT - 315;
    }
    int widthView = (DEVICE_WIDTH-self->btnSettings.frame.size.width)-20;
    int heightView = DEVICE_HEIGHT-xx-20;
    if ([[UIApplication sharedApplication] statusBarOrientation] == UIDeviceOrientationPortrait || [[UIApplication sharedApplication] statusBarOrientation] == UIDeviceOrientationPortraitUpsideDown)
    {
        widthView = (DEVICE_WIDTH-self->btnSettings.frame.size.width)+20;
        heightView = DEVICE_HEIGHT-xx+40;
        if (self.view.frame.size.height == 480)
        {
            widthView = (DEVICE_WIDTH-self->btnSettings.frame.size.width)+20;
            heightView = 320;
        }
    }
    else
    {
        if (self.view.frame.size.width == 480)
        {
            widthView = (DEVICE_WIDTH-self->btnSettings.frame.size.width)+20;
            heightView = DEVICE_HEIGHT-40;

        }
    }
    if (isShow == YES)
    {
        [UIView transitionWithView:myView duration:0.1
                           options:UIViewAnimationOptionCurveEaseIn
                        animations:^{
                            [myView setFrame:CGRectMake((DEVICE_WIDTH-widthView)/2,(DEVICE_HEIGHT-heightView)/2,widthView, heightView)];
                            self->pickerMainSettings.frame = CGRectMake(0,44,myView.frame.size.width, myView.frame.size.height-44);
                            self->datePicker.frame = CGRectMake(0,64,self->ViewPicker.frame.size.width, self->ViewPicker.frame.size.height-44);
                            self->relayPicker.frame = CGRectMake(0,44,myView.frame.size.width, myView.frame.size.height-44);

                        }
                        completion:^(BOOL finished)
         {
         }];
    }
    else
    {
        [UIView transitionWithView:myView duration:0.1
                           options:UIViewAnimationOptionCurveEaseOut
                        animations:^{
                            [self->backShadowView removeFromSuperview];
                            [myView setFrame:CGRectMake((DEVICE_WIDTH-widthView)/2,DEVICE_HEIGHT,widthView, DEVICE_HEIGHT-xx-20)];

                        }
                        completion:^(BOOL finished)
         {
         }];
    }
}

#pragma mark - TextField Delegates
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == tfieldLandscapeDisplay)
    {
             [tfieldLandscapeDisplay resignFirstResponder] ;
    }
    return true;
}
- (void)textFieldDidBeginEditing:(UITextField *)textField
{

    if ([[UIApplication sharedApplication] statusBarOrientation] == UIDeviceOrientationLandscapeLeft || [[UIApplication sharedApplication] statusBarOrientation] == UIDeviceOrientationLandscapeRight)
    {
        /*view Relay textfieldSetup*/
        int viewHeight = DEVICE_HEIGHT - 20;
        int YYindex = 20;
        if (IS_IPHONE_X)
        {
            YYindex = 44;
        }
        if (textField == tfieldLandscapeDisplay)
        {
            
        }
       else
       {
           tfieldLandscapeDisplay = [[UITextField alloc]initWithFrame:CGRectMake(0, YYindex, DEVICE_WIDTH, (viewHeight/3)+50)];
           tfieldLandscapeDisplay.placeholder = @"Enter your text";
           tfieldLandscapeDisplay.backgroundColor = UIColor.whiteColor;
           tfieldLandscapeDisplay.returnKeyType = UIReturnKeyDone;
           tfieldLandscapeDisplay.autocorrectionType = UITextAutocorrectionTypeNo;
           [self.view addSubview:tfieldLandscapeDisplay];
           intSelectedTfield=0;
           tfieldLandscapeDisplay.delegate = self;
//           [textField resignFirstResponder];
           [tfieldLandscapeDisplay becomeFirstResponder];
           //  if (textField == tfieldName || textField == tfieldLessSpeed || textField == tfieldMoreSpeed)
           //  {
            
       }
   
    }
}
//-(void)textFieldDidEndEditing:(UITextField *)textField

//    if (textField == tfieldName)
//    {
//        lblTfieldNameLine.frame = CGRectMake(0, tfieldName.frame.size.height-6,tfieldName.frame.size.width, 1);
//        [lblTfieldNameLine setBackgroundColor:[UIColor lightGrayColor]];
//    }
//    else if (textField == tfieldLessSpeed)
//    {
//        lblBtnLessSpeedLine.frame = CGRectMake(0, tfieldLessSpeed.frame.size.height-6,tfieldLessSpeed.frame.size.width,1);
//        [lblBtnLessSpeedLine setBackgroundColor:[UIColor lightGrayColor]];
//    }
//    else if (textField == tfieldMoreSpeed)
//    {
//        lbltnMoreSpeedLine.frame = CGRectMake(0, tfieldMoreSpeed.frame.size.height-6,tfieldMoreSpeed.frame.size.width, 1);
//        lbltnMoreSpeedLine.backgroundColor = UIColor.lightGrayColor;
//    }
    
//}
//-(void)btnDoneKeypadAction
//{
//
//    if ([[UIDevice currentDevice]orientation] == UIDeviceOrientationLandscapeLeft || [[UIDevice currentDevice]orientation] == UIDeviceOrientationLandscapeRight)
//    {
//        if (intSelectedTfield == 1)
//        {
//            tfieldName.text = tfieldLandscapeDisplay.text;
//        }
//        else if (intSelectedTfield == 2)
//        {
//
//        }
//        else if (intSelectedTfield == 3)
//        {
//            tfieldLessSpeed.text = tfieldLandscapeDisplay.text;
//        }
//        [tfieldLandscapeDisplay removeFromSuperview];
//    }
//
//
//    [tfieldLessSpeed resignFirstResponder];
//}

- (void)didReceiveMemoryWarning
    {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - orientation method
-(void)OrientationDidChange:(NSNotification*)notification
{
    if (lastOrients == [[UIApplication sharedApplication] statusBarOrientation])
    {
        NSLog(@"Both are same");
    }
    else
    {
        NSLog(@"Both are  not same");
        [self ShowPicker:NO andView:ViewPicker];
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
          [self setUpPortraitFrames];
    }
}
#pragma mark - Main Settings View Methods
-(void) setMainSettingsView
{
    //    int viewHeight = DEVICE_HEIGHT-20;
    int yIndex = 0;
    if (IS_IPHONE_X)
    {
        yIndex = 44;
    }
    
    viewSettings = [[UIScrollView alloc]init];
    viewSettings.frame = CGRectMake(0, yIndex, self.view.frame.size.width, self.view.frame.size.height);
    viewSettings.backgroundColor = UIColor.clearColor;
    [self.view addSubview:viewSettings];
    
    lblSettingsHeader = [[UILabel alloc]initWithFrame:CGRectMake((DEVICE_WIDTH/3), 0, (DEVICE_WIDTH-(DEVICE_WIDTH/3)), 20)];
    lblSettingsHeader.backgroundColor = UIColor.clearColor;
    lblSettingsHeader.text = @"Settings";
    lblSettingsHeader.textAlignment = NSTextAlignmentCenter;
    lblSettingsHeader.textColor = UIColor.blackColor;
    lblSettingsHeader.font = [UIFont fontWithName:CGBold size:txtSize+3];
    [viewSettings addSubview:lblSettingsHeader];
    
  
    yIndex = yIndex + 30;
    [self SetUnitRadioButtons:yIndex];
    
    yIndex = yIndex + 60 + 5;
    [self SetOdometersRadio:yIndex];
    
    yIndex = yIndex + 110 + 5;
    
 
    lblInfo = [[UILabel alloc]initWithFrame:CGRectMake((DEVICE_WIDTH/3)+5, yIndex, (DEVICE_WIDTH-(DEVICE_WIDTH/3))-5, 80)];
    lblInfo.textAlignment = NSTextAlignmentLeft;
    lblInfo.text = @"When ignition turned off maintain state of all closed relays for min.";
    lblInfo.numberOfLines = 3;
    lblInfo.font = [UIFont fontWithName:CGRegular size:txtSize+3];
    lblInfo.backgroundColor = UIColor.clearColor;
    [viewSettings addSubview:lblInfo];
    
    yIndex = yIndex + 80 + 5;
    
    imgArrow = [[UIImageView alloc]initWithFrame:CGRectMake(DEVICE_WIDTH-22, yIndex+20, 12, 7)];
    imgArrow.image = [UIImage imageNamed:@"right_black_arrow.png"];
    imgArrow.backgroundColor = UIColor.clearColor;
    [viewSettings addSubview:imgArrow];
    
    btnPickerView = [[UIButton alloc]initWithFrame:CGRectMake((DEVICE_WIDTH/3)+5, yIndex, (DEVICE_WIDTH-(DEVICE_WIDTH/3))-10, 55)];
    btnPickerView.backgroundColor = UIColor.clearColor;
    [btnPickerView setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    [btnPickerView addTarget:self action:@selector(btnIgnitionTimePickerClick) forControlEvents:UIControlEventTouchUpInside];
    [viewSettings addSubview:btnPickerView];
    
    /*PickerView data*/
    dataArray = [[NSMutableArray alloc]initWithObjects:@"0",@"5",@"10",@"15",@"20",@"25",@"30",@"35",@"40",@"45",@"50",@"55",@"60", nil];
    
    arrDatePickerHH = [[NSMutableArray alloc]init];
    for (int i=0; i<13;i++)
    {
        [arrDatePickerHH addObject:[NSString stringWithFormat:@"%d",i]];
    }
    arrDatePickerMM = [[NSMutableArray alloc]init];
    arrDatePickerSS = [[NSMutableArray alloc]init];
    for (int i=0; i<61;i++)
    {
        [arrDatePickerMM addObject:[NSString stringWithFormat:@"%d",i]];
        [arrDatePickerSS addObject:[NSString stringWithFormat:@"%d",i]];
        
    }
    arrRelayAssign = [[NSMutableArray alloc]initWithObjects:@"1",@"2",@"3",@"4",@"5",@"6", nil];
    
    lblPicker = [[UILabel alloc]initWithFrame:CGRectMake((DEVICE_WIDTH/3)+5, yIndex+5, (DEVICE_WIDTH-(DEVICE_WIDTH/3))-10, 35)];
    lblPicker.backgroundColor = UIColor.clearColor;
    lblPicker.textAlignment = NSTextAlignmentCenter;
    lblPicker.layer.masksToBounds = true;
    lblPicker.layer.borderWidth = 0.5;
    lblPicker.layer.borderColor = [UIColor lightGrayColor].CGColor;
    lblPicker.layer.cornerRadius = 3;
    lblPicker.font = [UIFont fontWithName:CGRegular size:txtSize+5];
    [viewSettings addSubview:lblPicker];
    
    lblPicker.text = [NSString stringWithFormat:@"%@ Mins",[[NSUserDefaults standardUserDefaults]valueForKey:@"ignitiontime"]];
}
-(void)SetUnitRadioButtons:(int)yIndex
{
    viewUnit = [[UIView alloc] init];
    
    viewUnit.frame = CGRectMake((DEVICE_WIDTH/3)+5, yIndex-5, (DEVICE_WIDTH-(DEVICE_WIDTH/3))-5, 55);
    viewUnit.backgroundColor = [UIColor clearColor];
    [viewSettings addSubview:viewUnit];
    
    lblUnitlbl = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, (DEVICE_WIDTH-(DEVICE_WIDTH/3))-5, 20)];
    lblUnitlbl.textAlignment = NSTextAlignmentLeft;
    lblUnitlbl.text = @"Unit";
    lblUnitlbl.font = [UIFont fontWithName:CGRegular size:txtSize+3];
    lblUnitlbl.textColor = [UIColor grayColor];
    [viewUnit addSubview:lblUnitlbl];
    
    btnEnglish = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnEnglish setImage:[UIImage imageNamed:@"radioSelected"]  forState:UIControlStateNormal];
    [btnEnglish setTitle:@" English-SAE" forState:UIControlStateNormal];
    [btnEnglish setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    btnEnglish.titleLabel.font = [UIFont fontWithName:CGRegular size:txtSize+fntSize];
    btnEnglish.frame = CGRectMake(0,10, viewUnit.frame.size.width/2, 55);
    btnEnglish.tag = 1;
    [btnEnglish addTarget:self action:@selector(btnUnitClick:) forControlEvents:UIControlEventTouchUpInside];
    [viewUnit addSubview:btnEnglish];
    btnEnglish.backgroundColor = [UIColor clearColor];
    
    btnMetric = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnMetric setImage:[UIImage imageNamed:@"radioUnselected"]  forState:UIControlStateNormal];
    [btnMetric setTitle:@" Metric-ISO" forState:UIControlStateNormal];
    [btnMetric setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    btnMetric.titleLabel.font = [UIFont fontWithName:CGRegular size:txtSize+fntSize];
    btnMetric.tag = 2;
    btnMetric.frame = CGRectMake(viewUnit.frame.size.width/2,10, viewUnit.frame.size.width/2, 55);
    [btnMetric addTarget:self action:@selector(btnUnitClick:) forControlEvents:UIControlEventTouchUpInside];
    btnMetric.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [viewUnit addSubview:btnMetric];
}

-(void)SetOdometersRadio:(int)yIndex
{
    viewOdometer = [[UIView alloc] init];
    viewOdometer.frame = CGRectMake((DEVICE_WIDTH/3)-10, yIndex-5, (DEVICE_WIDTH-(DEVICE_WIDTH/3)), 110);
    viewOdometer.backgroundColor = [UIColor clearColor];
    [viewSettings addSubview:viewOdometer];
    
    lblOdo1 = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, (DEVICE_WIDTH-(DEVICE_WIDTH/3))-5, 20)];
    lblOdo1.textAlignment = NSTextAlignmentLeft;
    lblOdo1.text = @"Odometer 1";
    lblOdo1.font = [UIFont fontWithName:CGRegular size:txtSize+3];
    lblOdo1.textColor = [UIColor grayColor];
    [viewOdometer addSubview:lblOdo1];
    
    btnUnitOdo1 = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnUnitOdo1 setImage:[UIImage imageNamed:@"radioSelected"]  forState:UIControlStateNormal];
    [btnUnitOdo1 setTitle:@"Unit" forState:UIControlStateNormal];
    [btnUnitOdo1 setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    btnUnitOdo1.titleLabel.font = [UIFont fontWithName:CGRegular size:txtSize+fntSize];
    btnUnitOdo1.frame = CGRectMake(0,10, viewUnit.frame.size.width/2-30, 50);
    btnUnitOdo1.tag = 1;
    [btnUnitOdo1 addTarget:self action:@selector(btnOdo1Click:) forControlEvents:UIControlEventTouchUpInside];
    [viewOdometer addSubview:btnUnitOdo1];
    btnUnitOdo1.backgroundColor = [UIColor clearColor];
    
    btnTenthsOd1 = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnTenthsOd1 setImage:[UIImage imageNamed:@"radioUnselected"]  forState:UIControlStateNormal];
    [btnTenthsOd1 setTitle:@"hundredths" forState:UIControlStateNormal];
    [btnTenthsOd1 setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    btnTenthsOd1.titleLabel.font = [UIFont fontWithName:CGRegular size:txtSize+fntSize];
    btnTenthsOd1.frame = CGRectMake(viewUnit.frame.size.width/2,10, viewUnit.frame.size.width/2, 50);
    btnTenthsOd1.tag = 2;
    btnTenthsOd1.backgroundColor = UIColor.clearColor;
    [btnTenthsOd1 addTarget:self action:@selector(btnOdo1Click:) forControlEvents:UIControlEventTouchUpInside];
    [viewOdometer addSubview:btnTenthsOd1];
    btnTenthsOd1.backgroundColor = [UIColor clearColor];

    lblOdo2 = [[UILabel alloc]initWithFrame:CGRectMake(0, 55, (DEVICE_WIDTH-(DEVICE_WIDTH/3))-5, 20)];
    lblOdo2.textAlignment = NSTextAlignmentLeft;
    lblOdo2.text = @"Odometer 2";
    lblOdo2.font = [UIFont fontWithName:CGRegular size:txtSize+1];
    lblOdo2.textColor = [UIColor grayColor];
    [viewOdometer addSubview:lblOdo2];
    
    btnUnitOdo2 = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnUnitOdo2 setImage:[UIImage imageNamed:@"radioSelected"]  forState:UIControlStateNormal];
    [btnUnitOdo2 setTitle:@"Unit" forState:UIControlStateNormal];
    [btnUnitOdo2 setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    btnUnitOdo2.titleLabel.font = [UIFont fontWithName:CGRegular size:txtSize+fntSize];
    btnUnitOdo2.frame = CGRectMake(0,65, (viewUnit.frame.size.width/2)-40, 55);
    btnUnitOdo2.tag = 1;
    [btnUnitOdo2 addTarget:self action:@selector(btnOdo2Click:) forControlEvents:UIControlEventTouchUpInside];
    [viewOdometer addSubview:btnUnitOdo2];
    
    btnTenthsOd2 = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnTenthsOd2 setImage:[UIImage imageNamed:@"radioUnselected"]  forState:UIControlStateNormal];
    [btnTenthsOd2 setTitle:@"hundredths" forState:UIControlStateNormal];
    [btnTenthsOd2 setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    btnTenthsOd2.titleLabel.font = [UIFont fontWithName:CGRegular size:txtSize+fntSize];
    btnTenthsOd2.frame = CGRectMake((viewUnit.frame.size.width/2)-30,65, (viewUnit.frame.size.width/2)+40, 55);
    btnTenthsOd2.tag= 2;
    [btnTenthsOd2 addTarget:self action:@selector(btnOdo2Click:) forControlEvents:UIControlEventTouchUpInside];
    [viewOdometer addSubview:btnTenthsOd2];

}
#pragma mark - Relay View Frames
-(void)setRelayView
{
    int exYY = 0;
    int zz = 20;
    if (IS_IPHONE_X)
    {
        exYY = 54;
        zz = 44;
    }
    
    viewRelay = [[UIScrollView alloc]initWithFrame:CGRectMake(0, zz, self.view.frame.size.width,((DEVICE_HEIGHT-((DEVICE_HEIGHT-20)/5))-25)-exYY)];
    viewRelay.backgroundColor = UIColor.whiteColor;
    viewRelay.contentSize = CGSizeMake(viewRelay.frame.size.width, (DEVICE_HEIGHT-((DEVICE_HEIGHT-20)/5))-exYY+50);
    viewRelay.scrollEnabled = true;
    [self.view addSubview:viewRelay];
    viewRelay.hidden = YES;

    if ([[UIApplication sharedApplication] statusBarOrientation] == UIDeviceOrientationLandscapeLeft || [[UIApplication sharedApplication] statusBarOrientation] == UIDeviceOrientationLandscapeRight )
    {
        if (self.view.frame.size.width == 480)
        {
            viewRelay.scrollEnabled = YES;
            viewRelay.contentSize = CGSizeMake(viewRelay.frame.size.width, (DEVICE_HEIGHT-((DEVICE_HEIGHT-20)/5))-exYY+80);
        }
    }
    else
    {
        if (self.view.frame.size.height == 480)
        {
            viewRelay.scrollEnabled = YES;
            viewRelay.contentSize = CGSizeMake(viewRelay.frame.size.width, (DEVICE_HEIGHT-((DEVICE_HEIGHT-20)/5))-exYY+80);
        }
    }
    
    yy = 0;
    lblChannelNumber = [[UILabel alloc]initWithFrame:CGRectMake(DEVICE_WIDTH/3, yy, (DEVICE_WIDTH-(DEVICE_WIDTH/3)), 25)];
    lblChannelNumber.backgroundColor = UIColor.clearColor;
    lblChannelNumber.textAlignment = NSTextAlignmentCenter;
    lblChannelNumber.textColor = UIColor.blackColor;
    lblChannelNumber.font = [UIFont fontWithName:CGBold size:txtSize +3];
    [viewRelay addSubview:lblChannelNumber];
    
    yy = yy + 35;
    
    lblSwitchTypeLbl = [[UILabel alloc]initWithFrame:CGRectMake((DEVICE_WIDTH/3)+5, yy, (DEVICE_WIDTH-(DEVICE_WIDTH/3))-5, 25)];
    lblSwitchTypeLbl.textAlignment = NSTextAlignmentLeft;
    lblSwitchTypeLbl.text = @"Switch Type";
    lblSwitchTypeLbl.font = [UIFont fontWithName:CGBold size:txtSize+3];
    lblSwitchTypeLbl.backgroundColor = UIColor.clearColor;
    [viewRelay addSubview:lblSwitchTypeLbl];
    

    btnLatch = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnLatch setImage:[UIImage imageNamed:@"radioSelected"]  forState:UIControlStateNormal];
    [btnLatch setTitle:@" Latch On-Off" forState:UIControlStateNormal];
    [btnLatch setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    btnLatch.titleLabel.font = [UIFont fontWithName:CGRegular size:txtSize+fntSize];
    btnLatch.frame = CGRectMake((DEVICE_WIDTH/3)+5,yy+20,(DEVICE_WIDTH-(DEVICE_WIDTH/3))-5-70, 45);
    btnLatch.tag = 1;
    [btnLatch addTarget:self action:@selector(btnSwitchTypeClick:) forControlEvents:UIControlEventTouchUpInside];
    [viewRelay addSubview:btnLatch];
    btnLatch.backgroundColor = [UIColor clearColor];
    btnLatch.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    
    
    btnMom = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnMom setImage:[UIImage imageNamed:@"radioUnselected"]  forState:UIControlStateNormal];
    [btnMom setTitle:@" Momentary   " forState:UIControlStateNormal];
    [btnMom setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    btnMom.titleLabel.font = [UIFont fontWithName:CGRegular size:txtSize+fntSize];
    btnMom.tag = 2;
    btnMom.frame = CGRectMake((DEVICE_WIDTH/3)+5,yy+55+5, (DEVICE_WIDTH-(DEVICE_WIDTH/3))-5-70, 45);
    [btnMom addTarget:self action:@selector(btnSwitchTypeClick:) forControlEvents:UIControlEventTouchUpInside];
    btnMom.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [viewRelay addSubview:btnMom];
    btnMom.backgroundColor = [UIColor clearColor];
    
    yy = yy + 120 ;

    lblEditlbl = [[UILabel alloc]initWithFrame:CGRectMake((DEVICE_WIDTH/3)+5, yy, (DEVICE_WIDTH-(DEVICE_WIDTH/3))-5-70, 25)];
    lblEditlbl.textAlignment = NSTextAlignmentLeft;
    lblEditlbl.text = @"Edit button label";
    lblEditlbl.backgroundColor = UIColor.clearColor;
    if (IS_IPHONE_5 )
    {
        lblEditlbl.font = [UIFont fontWithName:CGBold size:17] ;

    }
    else if (IS_IPHONE_4)
    {
        lblEditlbl.font = [UIFont fontWithName:CGBold size:txtSize] ;

    }
    else
    {
        lblEditlbl.font = [UIFont fontWithName:CGBold size:18] ;
    }
    [viewRelay addSubview:lblEditlbl];
    
    switchEditButton = [[ORBSwitch alloc] initWithCustomKnobImage:[UIImage imageNamed:@"off_icon"] inactiveBackgroundImage:[UIImage imageNamed:@"switch_track_icon"] activeBackgroundImage:[UIImage imageNamed:@"switch_track_icon"] frame:CGRectMake(DEVICE_WIDTH-60, yy-7, 44, 30)];
    //switchEditButton.isOn = NO;
    switchEditButton.knobRelativeHeight = 0.8f;
    switchEditButton.backgroundColor = [UIColor clearColor];
    switchEditButton.delegate = self;
    [viewRelay addSubview:switchEditButton];
    
    viewRelay.backgroundColor = [UIColor clearColor];
    
    btnOTA = [UIButton buttonWithType:UIButtonTypeCustom];
    btnOTA.frame = CGRectMake((DEVICE_WIDTH/3)+10, yy + 30, (DEVICE_WIDTH/2)-20, 44);
    [btnOTA setTitle:@"Enable OTA" forState:UIControlStateNormal];
    [btnOTA addTarget:self action:@selector(btnOTAClick) forControlEvents:UIControlEventTouchUpInside];
    btnOTA.titleLabel.font = [UIFont fontWithName:CGRegular size:txtSize + 2];
    [btnOTA setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    btnOTA.layer.borderWidth = 1.0;
    btnOTA.layer.borderColor = [UIColor blackColor].CGColor;
    [btnOTA setShowsTouchWhenHighlighted:YES];
//    [viewRelay addSubview:btnOTA];
    
    lblVersion = [[UILabel alloc]initWithFrame:CGRectMake((DEVICE_WIDTH/3)+10, yy + 30 + 44, (DEVICE_WIDTH/2)-20, 20)];
    lblVersion.textAlignment = NSTextAlignmentCenter;
    lblVersion.font = [UIFont fontWithName:CGRegular size:txtSize+1];
    lblVersion.textColor = [UIColor blackColor];
    lblVersion.layer.borderColor = [UIColor blackColor].CGColor;
    lblVersion.layer.borderWidth = 1.0;
    lblVersion.text = @"Version 1.0";
//    [viewRelay addSubview:lblVersion];
    
    btnOTA.frame = CGRectMake((DEVICE_WIDTH/3)+10, switchEditButton.frame.size.height + switchEditButton.frame.origin.y + 30, (DEVICE_WIDTH/2)-20, 44);
    lblVersion.frame = CGRectMake((DEVICE_WIDTH/3)+10, btnOTA.frame.size.height + btnOTA.frame.origin.y + 30, (DEVICE_WIDTH/2)- 20, 44);
    
    if (![[APP_DELEGATE checkforValidString:strFirmVersion] isEqualToString:@"NA"])
    {
        lblVersion.text = [NSString stringWithFormat:@"Version %@",strFirmVersion];
    }

}
#pragma mark - SetUp Portrait Framees
-(void)setUpPortraitFrames
{

    int viewHeight = DEVICE_HEIGHT-20;
    int exYY =0;
    if (IS_IPHONE_X)
    {
        viewHeight = DEVICE_HEIGHT-84;
        exYY = 44;
    }
    btn1.frame = CGRectMake(DEVICE_WIDTH-DEVICE_WIDTH/3,((DEVICE_HEIGHT)-viewHeight/5) -exYY, DEVICE_WIDTH/3, viewHeight/5);
    btn2.frame = CGRectMake(DEVICE_WIDTH-(DEVICE_WIDTH/3*2),((DEVICE_HEIGHT)-viewHeight/5)-exYY, DEVICE_WIDTH/3, viewHeight/5);
    btnSettings.frame = CGRectMake(0, ((DEVICE_HEIGHT)-viewHeight/5)-exYY, DEVICE_WIDTH/3, viewHeight/5);
    btn3.frame = CGRectMake(0, ((DEVICE_HEIGHT)-(viewHeight/5*2))-exYY, DEVICE_WIDTH/3, viewHeight/5);
    btn4.frame = CGRectMake(0, ((DEVICE_HEIGHT)-(viewHeight/5*3))-exYY, DEVICE_WIDTH/3, viewHeight/5);
    btn5.frame = CGRectMake(0, ((DEVICE_HEIGHT)-(viewHeight/5*4))-exYY, DEVICE_WIDTH/3, viewHeight/5);
    btn6.frame = CGRectMake(0, ((DEVICE_HEIGHT)-(viewHeight/5*5))-exYY, DEVICE_WIDTH/3, viewHeight/5);
    
    int yIndex = 0;
    if (IS_IPHONE_X)
    {
        yIndex = 44;
    }
  
    viewSettings.frame = CGRectMake(0, yIndex, self.view.frame.size.width, self.view.frame.size.height);
    viewSettings.contentSize = CGSizeMake(viewSettings.frame.size.width, viewSettings.frame.size.height+230);
    viewSettings.scrollEnabled = false;
    
    lblSettingsHeader.frame = CGRectMake((DEVICE_WIDTH/3), 0, (DEVICE_WIDTH-(DEVICE_WIDTH/3)), 20);
    yIndex = yIndex + 30;
    viewUnit.frame = CGRectMake((DEVICE_WIDTH/3)+5, yIndex-10, (DEVICE_WIDTH-(DEVICE_WIDTH/3))-5, 110);
    lblUnitlbl.frame = CGRectMake(0, 0, (DEVICE_WIDTH-(DEVICE_WIDTH/3))-5, 20);
    btnEnglish.frame = CGRectMake(0,13, viewUnit.frame.size.width, 45);

    btnMetric.frame = CGRectMake(0,55, viewUnit.frame.size.width, 40);
    btnMetric.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    btnEnglish.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;

    yIndex = yIndex + 95 + 5;
    viewOdometer.frame = CGRectMake((DEVICE_WIDTH/3), yIndex-5, (DEVICE_WIDTH-(DEVICE_WIDTH/3)), 130);
    lblOdo1.frame = CGRectMake(5, 0, (DEVICE_WIDTH-(DEVICE_WIDTH/3))-5, 20);
    btnUnitOdo1.frame = CGRectMake(0,5, (viewUnit.frame.size.width/2)-40, 55);
    btnTenthsOd1.frame = CGRectMake((viewUnit.frame.size.width/2)-30,5, (viewUnit.frame.size.width/2)+40, 55);
    lblOdo2.frame = CGRectMake(5, 60, (DEVICE_WIDTH-(DEVICE_WIDTH/3))-5, 20);
    btnUnitOdo2.frame = CGRectMake(0,65, (viewUnit.frame.size.width/2)-40, 55);
    btnTenthsOd2.frame = CGRectMake((viewUnit.frame.size.width/2)-30,65, (viewUnit.frame.size.width/2)+40, 55);
    
    yIndex = yIndex + 110 + 5;
    lblInfo.frame = CGRectMake((DEVICE_WIDTH/3)+5, yIndex, (DEVICE_WIDTH-(DEVICE_WIDTH/3))-5, 80);
    yIndex = yIndex + 75 + 5;
    imgArrow.frame = CGRectMake(DEVICE_WIDTH-22, yIndex+20, 12, 7);
    btnPickerView.frame = CGRectMake((DEVICE_WIDTH/3)+5, yIndex, (DEVICE_WIDTH-(DEVICE_WIDTH/3))-10, 55);
    lblPicker.frame = CGRectMake((DEVICE_WIDTH/3)+5, yIndex+5, (DEVICE_WIDTH-(DEVICE_WIDTH/3))-10, 35);
    
 
    
    /*Relay View Frames*/
    int zz = 20;
    if (IS_IPHONE_X)
    {
        zz = 44;
    }
    viewRelay.frame = CGRectMake(0, zz, self.view.frame.size.width,((DEVICE_HEIGHT-((DEVICE_HEIGHT-20)/5))-25)-exYY);
    viewRelay.contentSize = CGSizeMake(viewRelay.frame.size.width, (DEVICE_HEIGHT-((DEVICE_HEIGHT-20)/5))-exYY+50);

    if ([[UIApplication sharedApplication] statusBarOrientation] == UIDeviceOrientationLandscapeLeft || [[UIApplication sharedApplication] statusBarOrientation] == UIDeviceOrientationLandscapeRight )
    {
        if (self.view.frame.size.width == 480)
        {
            viewRelay.scrollEnabled = YES;
            viewRelay.contentSize = CGSizeMake(viewRelay.frame.size.width, viewRelay.frame.size.height+200);
        }
    }
    else
    {
        if (self.view.frame.size.height == 480)
        {
            viewRelay.scrollEnabled = YES;
            viewRelay.contentSize = CGSizeMake(viewRelay.frame.size.width, viewRelay.frame.size.height+130);
        }
    }
    yy = 0;
    lblChannelNumber.frame = CGRectMake(DEVICE_WIDTH/3, yy, (DEVICE_WIDTH-(DEVICE_WIDTH/3)), 25);
    yy = yy + 25+0;
    lblSwitchTypeLbl.frame = CGRectMake((DEVICE_WIDTH/3)+5, yy, (DEVICE_WIDTH-(DEVICE_WIDTH/3))-5, 25);
    btnLatch.frame = CGRectMake((DEVICE_WIDTH/3)+5,yy+20+5,(DEVICE_WIDTH-(DEVICE_WIDTH/3)), 45);
    btnMom.frame = CGRectMake((DEVICE_WIDTH/3)+5,yy+55+5, (DEVICE_WIDTH-(DEVICE_WIDTH/3)), 45);
    
    
    yy = yy + 105 ;
    lblEditlbl.frame = CGRectMake((DEVICE_WIDTH/3)+5, yy, (DEVICE_WIDTH-(DEVICE_WIDTH/3))-5-70, 25);
    if (IS_IPHONE_5)
    {
        lblEditlbl.font = [UIFont fontWithName:CGBold size:17] ;

    }
    else if(IS_IPHONE_4)
    {
        lblEditlbl.font = [UIFont fontWithName:CGBold size:txtSize] ;

    }
    else
    {
        lblEditlbl.font = [UIFont fontWithName:CGBold size:18] ;

    }
    switchEditButton.frame = CGRectMake(DEVICE_WIDTH-60, yy-7, 60, 44);
    switchEditButton.backgroundColor=UIColor.clearColor;
    yy = yy + 25+10;
    if (isSwitchOn == true)
    {
        viewBelowSwitch.frame = CGRectMake((DEVICE_WIDTH/3)+5, switchEditButton.frame.origin.y + switchEditButton.frame.size.height+40, (DEVICE_WIDTH-(DEVICE_WIDTH/3))-5, 420);
        btnName.frame = CGRectMake((DEVICE_WIDTH/3)+5, (switchEditButton.frame.origin.y + switchEditButton.frame.size.height+5),  (DEVICE_WIDTH-DEVICE_WIDTH/3)-10, 30);
        lblTfieldNameLine.frame = CGRectMake(0, btnName.frame.size.height-6,btnName.frame.size.width, 1);
        
//        viewSettings.contentSize = CGSizeMake(viewSettings.frame.size.width, viewSettings.frame.size.height-330);

    }
    else
    {
        viewBelowSwitch.frame = CGRectMake((DEVICE_WIDTH/3)+5, switchEditButton.frame.origin.y + switchEditButton.frame.size.height+5, (DEVICE_WIDTH-(DEVICE_WIDTH/3))-5, 420);
    }
    
    lblAssigned.frame = CGRectMake(0, 0, 140, 45);
    lblAssigned.numberOfLines = 2;
    btnRelayAssign.frame = CGRectMake((DEVICE_WIDTH-(DEVICE_WIDTH/3))/2+25,-3,50 *(approaxSize), 44);
    
    lblAssignBtnLine.frame = CGRectMake(0, btnRelayAssign.frame.size.height-1,btnRelayAssign.frame.size.width, 1);
    yy = 45+20;
    lblOperation.frame = CGRectMake(0,yy,viewBelowSwitch.frame.size.width,45);
    yy=yy+45;
    btnNone.frame = CGRectMake(0,yy,80 *(approaxSize), 40);
    btnElapsedTime.frame = CGRectMake(80*(approaxSize),yy,130*(approaxSize), 40);
    yy = yy+40;
    btnSpeed.frame = CGRectMake(0,yy,80*(approaxSize), 40);
    btnDistance.frame = CGRectMake(80*(approaxSize),yy,130*(approaxSize), 40);
    yy = yy+40;
    lblMoreSpeed.frame = CGRectMake(0, yy, (DEVICE_WIDTH-(DEVICE_WIDTH/3))-5-0, 20);
    lblDistStaticlbl.frame = CGRectMake(0, yy, (DEVICE_WIDTH-(DEVICE_WIDTH/3))-5-0, 20);
    lblTimelbl.frame = CGRectMake(0, yy, (DEVICE_WIDTH-(DEVICE_WIDTH/3))-5-0, 20);
    yy = yy+15;
    btnTimeValue.frame = CGRectMake(0, yy, viewBelowSwitch.frame.size.width-5, 30);
    lblTimeValueLine.frame = CGRectMake(0, btnTimeValue.frame.size.height-1,btnTimeValue.frame.size.width, 1);
    btnMoreSpeedValue.frame = CGRectMake(0, yy, viewBelowSwitch.frame.size.width, 30);
    lbltnMoreSpeedLine.frame = CGRectMake(0, btnMoreSpeedValue.frame.size.height-1,btnMoreSpeedValue.frame.size.width, 1);
    btnValueDistance.frame = CGRectMake(0, yy, viewBelowSwitch.frame.size.width, 30);
    lblBtnDistLine.frame = CGRectMake(0, btnValueDistance.frame.size.height-1,btnValueDistance.frame.size.width, 1);
    yy = yy + 30+5;
    lblLessSpeed.frame = CGRectMake(0, yy, (DEVICE_WIDTH-(DEVICE_WIDTH/3))-5-0, 20);
    yy = yy+15;
    btnLessSpeedValue.frame = CGRectMake(0, yy, viewBelowSwitch.frame.size.width, 30);
    yy = yy + 35;
    lblBtnLessSpeedLine.frame = CGRectMake(0, btnLessSpeedValue.frame.size.height-1,btnLessSpeedValue.frame.size.width, 1);
    
    if (selectedRelayBtn == 0)
    {
        
    }
    else
    {
//        UIButton *btnTmp = (UIButton *)[self.view viewWithTag:selectedRelayBtn];
//        [yourViewBorder removeFromSuperlayer];
//        yourViewBorder = [CAShapeLayer layer];
//        yourViewBorder.strokeColor = [UIColor whiteColor].CGColor;
//        yourViewBorder.fillColor = nil;
//        yourViewBorder.lineDashPattern = @[@20, @20];
//        yourViewBorder.frame = btnTmp.bounds;
//        yourViewBorder.path = [UIBezierPath bezierPathWithRect:btnTmp.bounds].CGPath;
//        yourViewBorder.lineWidth = 15;
//        [btnTmp.layer addSublayer:yourViewBorder];
    }
    if (![[APP_DELEGATE checkforValidString:strFirmVersion] isEqualToString:@"NA"])
    {
        lblVersion.text = [NSString stringWithFormat:@"Version %@",strFirmVersion];
    }
}
#pragma mark - set LandScape UI frames
-(void) setLandscapeFrames
{

    int viewHeight = DEVICE_HEIGHT - 20;
    int yy = 20;
    
    btnSettings.frame = CGRectMake(0,20, DEVICE_WIDTH/5, viewHeight/3);
    btn1.frame = CGRectMake(0, ((viewHeight/3)*2)+yy, DEVICE_WIDTH/5, viewHeight/3);
    btn2.frame = CGRectMake(0,(viewHeight/3)+yy, DEVICE_WIDTH/5, viewHeight/3);
    btn3.frame = CGRectMake(DEVICE_WIDTH/5,yy, DEVICE_WIDTH/5, viewHeight/3);
    btn4.frame = CGRectMake((DEVICE_WIDTH/5)*2,yy, DEVICE_WIDTH/5, viewHeight/3);
    btn5.frame = CGRectMake((DEVICE_WIDTH/5)*3,yy, DEVICE_WIDTH/5, viewHeight/3);
    btn6.frame = CGRectMake((DEVICE_WIDTH/5)*4,yy, DEVICE_WIDTH/5, viewHeight/3);
    
    /* View Settings*/
    viewSettings.frame = CGRectMake(0, (viewHeight/3)+yy, self.view.frame.size.width, (viewHeight/3)*2);
    viewSettings.contentSize = CGSizeMake(viewSettings.frame.size.width, viewSettings.frame.size.height+230);
    viewSettings.scrollEnabled = true;
    yy=5;
    lblSettingsHeader.frame = CGRectMake((DEVICE_WIDTH/5)+5,yy, (DEVICE_WIDTH-DEVICE_WIDTH/5)-10, 25);
    yy = yy+25+5;
    
    viewUnit.frame =CGRectMake((DEVICE_WIDTH/5)+5, yy, (DEVICE_WIDTH-DEVICE_WIDTH/5)-10, 55);
    lblUnitlbl.frame =  CGRectMake(0, 0,  (DEVICE_WIDTH-DEVICE_WIDTH/5)-10-300, 25);
    btnEnglish.frame = CGRectMake(0,25,((DEVICE_WIDTH-DEVICE_WIDTH/5)/2)-80 , 30);
    btnEnglish.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    btnMetric.frame = CGRectMake(btnEnglish.frame.size.width+30,25,((DEVICE_WIDTH-DEVICE_WIDTH/5)/2)-80 , 30);
    btnMetric.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    
    yy = yy+55+5;
    viewOdometer.frame = CGRectMake((DEVICE_WIDTH/5)+5, yy, (DEVICE_WIDTH-DEVICE_WIDTH/5)-10, 110);
    lblOdo1.frame = CGRectMake(0, 0,((DEVICE_WIDTH-DEVICE_WIDTH/5)/2)-80, 20);
    
    btnUnitOdo1.frame = CGRectMake(0,20,((DEVICE_WIDTH-DEVICE_WIDTH/5)/2)-80 , 30);
    btnUnitOdo1.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    
    btnTenthsOd1.frame = CGRectMake(btnUnitOdo1.frame.size.width+30,20,((DEVICE_WIDTH-DEVICE_WIDTH/5)/2)-40 , 30);
    btnTenthsOd1.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    
    lblOdo2.frame = CGRectMake(0, 55, ((DEVICE_WIDTH-DEVICE_WIDTH/5)/2)-80, 20);
    btnUnitOdo2.frame = CGRectMake(0,75,((DEVICE_WIDTH-DEVICE_WIDTH/5)/2)-80 , 30);
    btnUnitOdo2.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    
    btnTenthsOd2.frame = CGRectMake(btnUnitOdo2.frame.size.width+30,75,((DEVICE_WIDTH-DEVICE_WIDTH/5)/2)-40 , 30);
    btnTenthsOd2.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    
    yy = yy+110+5;
    lblInfo.frame =CGRectMake((DEVICE_WIDTH/5)+5, yy, (DEVICE_WIDTH-DEVICE_WIDTH/5)-10, 65);
    yy = yy+60+5;
    imgArrow.frame = CGRectMake(DEVICE_WIDTH-22, yy+20, 12, 7);
    btnPickerView.frame = CGRectMake((DEVICE_WIDTH/5)+5, yy, (DEVICE_WIDTH-DEVICE_WIDTH/5)-10, 55);
    lblPicker.frame = CGRectMake((DEVICE_WIDTH/5)+5, yy+5, (DEVICE_WIDTH-DEVICE_WIDTH/5)-10, 35);
    
    /* View Relay*/
    
    yy = 20;
    viewRelay.frame = CGRectMake(0, (viewHeight/3)+yy, self.view.frame.size.width, (viewHeight/3)*2);
    viewRelay.contentSize = CGSizeMake(viewRelay.frame.size.width, ((viewHeight/3)*2)+200);
    viewRelay.scrollEnabled = true;
    
    yy=5;
    lblChannelNumber.frame = CGRectMake((DEVICE_WIDTH/5)+5, yy,  (DEVICE_WIDTH-DEVICE_WIDTH/5)-10, 25);
    yy = yy+25;
    lblSwitchTypeLbl.frame = CGRectMake((DEVICE_WIDTH/5)+5, yy,  (DEVICE_WIDTH-DEVICE_WIDTH/5)-10-250, 25);
    yy = yy+25;
    btnLatch.frame = CGRectMake((DEVICE_WIDTH/5)+5, yy, ((DEVICE_WIDTH-DEVICE_WIDTH/5)/2)-40, 40);
    btnMom.frame = CGRectMake(btnLatch.frame.origin.x+btnLatch.frame.size.width+60, yy,((DEVICE_WIDTH-DEVICE_WIDTH/5)/2)-80, 40);
    yy = yy+45+5;
    lblEditlbl.frame = CGRectMake((DEVICE_WIDTH/5)+5, yy, (DEVICE_WIDTH/2), 25);
    
    switchEditButton.frame = CGRectMake(lblEditlbl.frame.origin.x+122+30, yy-7,60, 44);
    yy = yy+25+10;
    
    if (isSwitchOn == true)
    {
        viewBelowSwitch.frame = CGRectMake((DEVICE_WIDTH/5)+5, switchEditButton.frame.origin.y + switchEditButton.frame.size.height+40, (DEVICE_WIDTH-(DEVICE_WIDTH/3))-5, 420);

        btnName.frame = CGRectMake((DEVICE_WIDTH/5)+5, (switchEditButton.frame.origin.y + switchEditButton.frame.size.height+5),  (DEVICE_WIDTH-DEVICE_WIDTH/5)-10, 30);
        lblTfieldNameLine.frame = CGRectMake(0, btnName.frame.size.height-6,btnName.frame.size.width, 1);
    }
    else if (isSwitchOn == false)
    {
        viewBelowSwitch.frame = CGRectMake((DEVICE_WIDTH/5)+5, switchEditButton.frame.origin.y + switchEditButton.frame.size.height+5, (DEVICE_WIDTH-(DEVICE_WIDTH/3))-5, 420);
    }
    
    lblAssigned.frame = CGRectMake(0,5,270, 25);
//    lblAssigned.backgroundColor = UIColor.redColor;
    lblAssigned.numberOfLines = 1;
    btnRelayAssign.frame = CGRectMake(lblAssigned.frame.origin.x+lblAssigned.frame.size.width+5 ,-5, 50*approaxSize, 44);
    lblAssignBtnLine.frame = CGRectMake(0, btnRelayAssign.frame.size.height-1,btnRelayAssign.frame.size.width, 1);
    
    
    yy=25+10;
    lblOperation.frame = CGRectMake(0,yy,viewBelowSwitch.frame.size.width,45);
    yy = yy+40;
    int xx = 80;
    btnNone.frame = CGRectMake(0,yy,xx*(approaxSize), 40);
    xx = xx+10;
    
    btnElapsedTime.frame = CGRectMake(xx*(approaxSize),yy,130*(approaxSize), 40);
    xx = xx+130+10;
    btnSpeed.frame = CGRectMake(xx*(approaxSize),yy,80*(approaxSize), 40);
    xx = xx+80+10;
    btnDistance.frame = CGRectMake(xx*(approaxSize),yy,120*(approaxSize), 40);
    
    if (self.view.frame.size.height == 320 && self.view.frame.size.width == 480)
    {
        xx = 80;
        btnNone.frame = CGRectMake(0,yy,xx*(approaxSize), 30);
        // btnNone.backgroundColor = UIColor.yellowColor;
        xx = xx;
        btnElapsedTime.frame = CGRectMake(xx*(approaxSize),yy,130*(approaxSize), 30);
        //  btnElapsedTime.backgroundColor = UIColor.grayColor;
        xx = xx+130;
        btnSpeed.frame = CGRectMake(xx*(approaxSize),yy,80*(approaxSize), 30);
        //   btnSpeed.backgroundColor = UIColor.yellowColor;
        xx = xx+80;
        btnDistance.frame = CGRectMake(xx*(approaxSize),yy,120*(approaxSize), 30);
        //    btnDistance.backgroundColor = UIColor.grayColor;
        
    }
    yy = yy+40+5;
    lblTimelbl.frame = CGRectMake(5,yy, viewBelowSwitch.frame.size.width-10, 20);
    lblMoreSpeed.frame = CGRectMake(5,yy, viewBelowSwitch.frame.size.width, 20);
    lblDistStaticlbl.frame = CGRectMake(5,yy,viewBelowSwitch.frame.size.width, 20);
    
    yy = yy+15;
    btnTimeValue.frame = CGRectMake(5, yy,viewBelowSwitch.frame.size.width , 30);
    lblTimeValueLine.frame = CGRectMake(0, btnTimeValue.frame.size.height-1,btnTimeValue.frame.size.width, 1);
    
    btnMoreSpeedValue.frame = CGRectMake(5, yy,viewBelowSwitch.frame.size.width , 30);
    lbltnMoreSpeedLine.frame=CGRectMake(0, btnMoreSpeedValue.frame.size.height-1,btnMoreSpeedValue.frame.size.width, 1);
    
    btnValueDistance.frame = CGRectMake(5, yy,viewBelowSwitch.frame.size.width , 30);
    lblBtnDistLine.frame = CGRectMake(0, btnValueDistance.frame.size.height-1,btnValueDistance.frame.size.width, 1);
    
    yy = yy +30+5;
    lblLessSpeed.frame = CGRectMake(5,yy,viewBelowSwitch.frame.size.width, 20);
    
    yy = yy+15;
    btnLessSpeedValue.frame = CGRectMake(5, yy,viewBelowSwitch.frame.size.width , 30);
    lblBtnLessSpeedLine.frame=CGRectMake(0, btnLessSpeedValue.frame.size.height-1,btnLessSpeedValue.frame.size.width, 1);
    
    
    /*pickerView frames*/
    datePicker.frame = CGRectMake(0,64,ViewPicker.frame.size.width, ViewPicker.frame.size.height-44);
    relayPicker.frame = CGRectMake(0,44,ViewPicker.frame.size.width, ViewPicker.frame.size.height-44);
    
    if (selectedRelayBtn == 0)
    {
        
    }
    else
    {
//        UIButton *btnTmp = (UIButton *)[self.view viewWithTag:selectedRelayBtn];
//        [yourViewBorder removeFromSuperlayer];
//        yourViewBorder = [CAShapeLayer layer];
//        yourViewBorder.strokeColor = [UIColor whiteColor].CGColor;
//        yourViewBorder.fillColor = nil;
//        yourViewBorder.lineDashPattern = @[@20, @20];
//        yourViewBorder.frame = btnTmp.bounds;
//        yourViewBorder.path = [UIBezierPath bezierPathWithRect:btnTmp.bounds].CGPath;
//        yourViewBorder.lineWidth = 15;
//        [btnTmp.layer addSublayer:yourViewBorder];
    }
    
    if (![[APP_DELEGATE checkforValidString:strFirmVersion] isEqualToString:@"NA"])
    {
        lblVersion.text = [NSString stringWithFormat:@"Version : %@",strFirmVersion];
    }
}
#pragma mark - set Channel's Values

//Main Settings View
-(void)setValueForMainSettingScreen
{
    //Unit Type
    if ([[[NSUserDefaults standardUserDefaults]valueForKey:@"unitType"] isEqualToString:@"English-SAE"])
    {
        [btnEnglish setImage:[UIImage imageNamed:@"radioSelected"]  forState:UIControlStateNormal];
        [btnMetric setImage:[UIImage imageNamed:@"radioUnselected"]  forState:UIControlStateNormal];
    }
    else
    {
        [btnMetric setImage:[UIImage imageNamed:@"radioSelected"]  forState:UIControlStateNormal];
        [btnEnglish setImage:[UIImage imageNamed:@"radioUnselected"]  forState:UIControlStateNormal];
    }
    
    
    //Odometer 1 Type
    if ([[[NSUserDefaults standardUserDefaults]valueForKey:@"odometer1"] isEqualToString:@"Unit"])
    {
        [btnUnitOdo1 setImage:[UIImage imageNamed:@"radioSelected"]  forState:UIControlStateNormal];
        [btnTenthsOd1 setImage:[UIImage imageNamed:@"radioUnselected"]  forState:UIControlStateNormal];
    }
    else
    {
        [btnTenthsOd1 setImage:[UIImage imageNamed:@"radioSelected"]  forState:UIControlStateNormal];
        [btnUnitOdo1 setImage:[UIImage imageNamed:@"radioUnselected"]  forState:UIControlStateNormal];
    }
    
    //Odometer 2 Type
    if ([[[NSUserDefaults standardUserDefaults]valueForKey:@"odometer2"] isEqualToString:@"Unit"])
    {
        [btnUnitOdo2 setImage:[UIImage imageNamed:@"radioSelected"]  forState:UIControlStateNormal];
        [btnTenthsOd2 setImage:[UIImage imageNamed:@"radioUnselected"]  forState:UIControlStateNormal];
    }
    else
    {
        [btnTenthsOd2 setImage:[UIImage imageNamed:@"radioSelected"]  forState:UIControlStateNormal];
        [btnUnitOdo2 setImage:[UIImage imageNamed:@"radioUnselected"]  forState:UIControlStateNormal];
    }
    
    //PickerView
    lblPicker.text = [NSString stringWithFormat:@"%@ Mins",[[NSUserDefaults standardUserDefaults]valueForKey:@"ignitiontime"]];


}
//Relay View
-(void)setSettingsValue
{
    NSMutableDictionary * tmpDict = [[NSMutableDictionary alloc] init];
    tmpDict = [[NSUserDefaults standardUserDefaults] valueForKey:[NSString stringWithFormat:@"Relay%ld",(long)selectedRelayBtn]];
    dictSelected = [[NSMutableDictionary alloc] init];
    dictSelected = [tmpDict mutableCopy];
    
    //Switch Type
    if ([[tmpDict valueForKey:@"switchtype"] isEqualToString:@"Latch On-Off"])
    {
        [btnLatch setImage:[UIImage imageNamed:@"radioSelected"]  forState:UIControlStateNormal];
        [btnMom setImage:[UIImage imageNamed:@"radioUnselected"]  forState:UIControlStateNormal];
        [self setOperationMethodForLatch];
    }
    else
    {
        [btnMom setImage:[UIImage imageNamed:@"radioSelected"]  forState:UIControlStateNormal];
        [btnLatch setImage:[UIImage imageNamed:@"radioUnselected"]  forState:UIControlStateNormal];
        
        lblOperation.hidden = true;
        btnNone.hidden = true;
        btnElapsedTime.hidden = true;
        btnSpeed.hidden = true;
        btnDistance.hidden = true;
        
        lblMoreSpeed.hidden = true;
        lblLessSpeed.hidden = true;
        btnLessSpeedValue.hidden = true;
        btnMoreSpeedValue.hidden = true;
        lblDistStaticlbl.hidden = true;
        btnValueDistance.hidden = true;
        lblTimelbl.hidden = true;
        btnTimeValue.hidden = true;
    }
    NSString * strLocalSpeedUnits, * strLocalDistanceUnits;
    if ([[[NSUserDefaults standardUserDefaults]valueForKey:@"unitType"] isEqualToString:@"English-SAE"])
    {
        lblMoreSpeed.text = @"More than speed (MPH)";
        lblDistStaticlbl.text = @"Enter Distance (M)";
        lblLessSpeed.text = @"Less than speed (MPH)";
        strLocalSpeedUnits = @"MPH";
        strLocalDistanceUnits = @"M";
    }
    else
    {
        lblMoreSpeed.text = @"More than speed (KPH)";
        lblDistStaticlbl.text = @"Enter Distance (KM)";
        lblLessSpeed.text = @"Less than speed (KPH)";
        strLocalSpeedUnits = @"KPH";
        strLocalDistanceUnits = @"KM";

    }
    //Set Name
    [btnName setTitle:[tmpDict valueForKey:@"name"] forState:UIControlStateNormal];
    
    // Assigned Label
    [btnRelayAssign setTitle:[tmpDict valueForKey:@"assigned"] forState:UIControlStateNormal];
    strDefaltAssigned = [tmpDict valueForKey:@"assigned"];

    // More than Speed
    if ([[tmpDict valueForKey:@"morespeed"] isEqualToString:@"NA"])
    {
        [btnMoreSpeedValue setTitle:@"Enter speed here" forState:UIControlStateNormal];
    }
    else
    {
        [btnMoreSpeedValue setTitle:[NSString stringWithFormat:@"%@ %@",[tmpDict valueForKey:@"morespeed"],strLocalSpeedUnits] forState:UIControlStateNormal];
    }
    
    // Less than Speed
    if ([[tmpDict valueForKey:@"lessspeed"] isEqualToString:@"NA"])
    {
        [btnLessSpeedValue setTitle:@"Enter speed here" forState:UIControlStateNormal];
    }
    else
    {
        [btnLessSpeedValue setTitle:[NSString stringWithFormat:@"%@ %@",[tmpDict valueForKey:@"lessspeed"],strLocalSpeedUnits] forState:UIControlStateNormal];
    }
    
    // Elapsed time
    if ([[tmpDict valueForKey:@"elapsedtime"] isEqualToString:@"NA"])
    {
        [btnTimeValue setTitle:@"Select Time here" forState:UIControlStateNormal];
    }
    else
    {
        [btnTimeValue setTitle:[tmpDict valueForKey:@"elapsedtime"] forState:UIControlStateNormal];
    }
    
    // Distance
    if ([[tmpDict valueForKey:@"distance"] isEqualToString:@"NA"])
    {
        [btnValueDistance setTitle:@"Enter Distance here" forState:UIControlStateNormal];
    }
    else
    {
        
        [btnValueDistance setTitle:[NSString stringWithFormat:@"%@ %@",[tmpDict valueForKey:@"distance"], strLocalDistanceUnits] forState:UIControlStateNormal];
    }
    
    //
    //btnLessSpeedValue
}
-(void)setMainRelayBtnName:(NSString *)strName forRelayNumber:(NSString *)strNumber
{
    if ([strNumber isEqualToString:@"1"])
    {
        [btn1 setTitle:strName forState:UIControlStateNormal];
    }
    else if([strNumber isEqualToString:@"2"])
    {
        [btn2 setTitle:strName forState:UIControlStateNormal];
    }
    else if([strNumber isEqualToString:@"3"])
    {
        [btn3 setTitle:strName forState:UIControlStateNormal];
    }
    else if([strNumber isEqualToString:@"4"])
    {
        [btn4 setTitle:strName forState:UIControlStateNormal];
    }
    else if([strNumber isEqualToString:@"5"])
    {
        [btn5 setTitle:strName forState:UIControlStateNormal];
    }
    else if([strNumber isEqualToString:@"6"])
    {
        [btn6 setTitle:strName forState:UIControlStateNormal];
    }
}
-(void)setOperationMethodForLatch
{
    lblOperation.hidden = false;
    btnNone.hidden = false;
    btnElapsedTime.hidden = false;
    btnSpeed.hidden = false;
    btnDistance.hidden = false;
    
    if ([strSelectedOperation isEqualToString:@"None"])
    {
        lblMoreSpeed.hidden = true;
        lblLessSpeed.hidden = true;
        btnLessSpeedValue.hidden = true;
        lblDistStaticlbl.hidden = true;
        btnTimeValue.hidden = true;
        btnValueDistance.hidden = true;
        btnMoreSpeedValue.hidden = true;
        lblTimelbl.hidden = true;
    }
    else if ([strSelectedOperation isEqualToString:@"Elapsed Time"])
    {
        lblMoreSpeed.hidden = true;
        lblLessSpeed.hidden = true;
        btnLessSpeedValue.hidden = true;
        lblDistStaticlbl.hidden = true;
        lblTimelbl.hidden = false;
        btnTimeValue.hidden = false;
        btnValueDistance.hidden = true;
        btnMoreSpeedValue.hidden = true;
    }
    else if ([strSelectedOperation isEqualToString:@"Speed"])
    {
        lblMoreSpeed.hidden = false;
        lblLessSpeed.hidden = false;
        btnLessSpeedValue.hidden = false;
        btnTimeValue.hidden = true;
        lblDistStaticlbl.hidden = true;
        lblTimelbl.hidden = true;
        btnValueDistance.hidden = true;
        btnMoreSpeedValue.hidden = false;
    }
    else if ([strSelectedOperation isEqualToString:@"Distance"])
    {
        lblMoreSpeed.hidden = true;
        lblLessSpeed.hidden = true;
        btnLessSpeedValue.hidden = true;
        btnTimeValue.hidden = true;
        lblTimelbl.hidden = true;
        lblDistStaticlbl.hidden = NO;
        btnValueDistance.hidden = false;
        btnMoreSpeedValue.hidden = true;
    }
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
