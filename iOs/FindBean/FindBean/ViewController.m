//
//  ViewController.m
//  FindBean
//
//  Created by Cédric Toncanier on 2016-03-23.
//  Copyright © 2016 Cédric Toncanier. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"

@interface ViewController ()

@property (nonatomic,strong) BLBeanStuff *myBeanStuff;
@property (nonatomic,strong) NSString *targetBean;
@property (nonatomic,strong) NSString *targetBeanName;
@property (nonatomic,strong) PTDBean *connectedBean;
@property (nonatomic,weak) IBOutlet UILabel *temperatureLabel;
@property (nonatomic,weak) IBOutlet UILabel *batteryLabel;
@property (nonatomic,weak) IBOutlet UIProgressView *batteryProgressView;
@property (nonatomic,weak) IBOutlet UILabel *messageLabel;
@property (nonatomic,weak) IBOutlet UILabel *statusLabel;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.myBeanStuff=[BLBeanStuff sharedBeanStuff];

}


-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.myBeanStuff.delegate=self;
    [self processSettings];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



-(void) processSettings {
    
    self.myBeanStuff.delegate=self;  // Ensure that we are re-set as the BeanStuff delegate
    
    NSUserDefaults *userDefaults=[NSUserDefaults standardUserDefaults];
    
    NSString *newTargetBean=[userDefaults objectForKey:kBLTargetBeanPref];
    
    NSLog(@"Test:  %@, %@",newTargetBean, self.targetBean);

    
    if (newTargetBean == nil) {
        
         NSLog(@"Test:  Inside  newTargetBean");
        self.messageLabel.text=@"Please select a lock in settings";
        self.statusLabel.text=@"";
    }
    
    if (![newTargetBean isEqualToString:self.targetBean]) {
        
        NSLog(@"Test:  Inside  isEqualToString");
        
        self.targetBean=newTargetBean;
        self.targetBeanName=[userDefaults objectForKey:kBLTargetBeanNamePref];
        if (self.connectedBean != nil) {
            [self.myBeanStuff disconnectFromBean:self.connectedBean];
        }
        else {
            [self connect];
        }
    }
}


#pragma mark - Connection

-(void) connect {
    NSUUID *beanID=[[NSUUID alloc] initWithUUIDString:self.targetBean];
    
    self.statusLabel.text=[NSString stringWithFormat:@"Connecting to %@",self.targetBeanName];
    self.messageLabel.text=@"";
    self.temperatureLabel.text=@"-";
    self.batteryLabel.text=@"-";
    self.batteryProgressView.progress=0;
    
    if (![self.myBeanStuff connectToBeanWithIdentifier:beanID] ) {  // Connect directly if we can
        [self.myBeanStuff startScanningForBeans];                   // Otherwise scan for the bean
    }
    
}


#pragma mark - Settings View Controller

- (IBAction) settingsDone:(UIStoryboardSegue *)unwindSegue
{
    
    [self processSettings];
    
}

#pragma mark - BLBeanStuffDelegate

-(void) didConnectToBean:(PTDBean *)bean {
    // Bean may have been renamed
    if (![self.targetBeanName isEqualToString:bean.name]) {
        [[NSUserDefaults standardUserDefaults] setObject:bean.name forKey:kBLTargetBeanNamePref];
        self.targetBeanName=bean.name;
    }
    
    self.statusLabel.text=[NSString stringWithFormat:@"Connected to %@",self.targetBeanName];
    
    bean.delegate=self;
    self.connectedBean=bean;
    [self.myBeanStuff stopScanningForBeans];
    [bean readTemperature];
    if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateBackground) {
        BOOL alreadyNotified=[[NSUserDefaults standardUserDefaults] boolForKey:kBLNotificationSent];
        if (!alreadyNotified) {
            UILocalNotification* localNotification = [[UILocalNotification alloc] init];
            localNotification.fireDate = [NSDate new];
            localNotification.alertBody = @"Lock detected";
            localNotification.timeZone = [NSTimeZone defaultTimeZone];
            [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"notified"];
        }
    }
}

-(void) didDisconnectFromBean:(PTDBean *)bean {
    self.messageLabel.text=@"Disconnected";
    [self.myBeanStuff disconnectFromBean:bean];
    self.connectedBean=nil;
    if (self.targetBean != nil) {
        [self connect];
    }
}

-(void) didUpdateDiscoveredBeans:(NSArray *)discoveredBeans withBean:(PTDBean *)newBean {
    if ([self.targetBean isEqualToString:newBean.identifier.UUIDString]) {
        [self connect];
    }
}


#pragma mark - PTDBeanDelegate methods

- (void)bean:(PTDBean *)bean serialDataReceived:(NSData *)data
{
    [self.connectedBean readBatteryVoltage];
    [self.connectedBean readTemperature];
    
}

- (void)bean:(PTDBean *)bean didUpdateTemperature:(NSNumber *)degrees_celsius {
    self.temperatureLabel.text=[NSString stringWithFormat:@"%0.1fºC",[degrees_celsius floatValue]];
}

- (void)beanDidUpdateBatteryVoltage:(PTDBean *)bean error:(NSError *)error {
    float batteryVoltage = [bean.batteryVoltage floatValue];
    self.batteryLabel.text=[NSString stringWithFormat:@"%0.4fV",batteryVoltage];
    UIColor *batteryColor=[UIColor redColor];
    if (batteryVoltage > 2.5) {
        batteryColor=[UIColor greenColor];
    }
    else if (batteryVoltage >2) {
        batteryColor=[UIColor orangeColor];
    }
    self.batteryProgressView.tintColor=batteryColor;
    self.batteryProgressView.progress=[bean.batteryVoltage floatValue]/4.0;
}


@end
