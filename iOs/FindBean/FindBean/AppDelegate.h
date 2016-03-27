//
//  AppDelegate.h
//  FindBean
//
//  Created by Cédric Toncanier on 2016-03-23.
//  Copyright © 2016 Cédric Toncanier. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kBLTargetBeanPref @"targetBean"
#define kBLTargetBeanNamePref @"targetBeanName"
#define kBLPasswordPref @"password"
#define kBLAutoUnlockPref @"autoUnlock"
#define kBLUnlockNotification @"kBLUnlockNotification"
#define kBLNotificationSent @"notified"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;


@end

