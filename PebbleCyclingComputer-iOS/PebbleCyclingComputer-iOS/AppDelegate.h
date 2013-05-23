//
//  AppDelegate.h
//  PebbleCyclingComputer-iOS
//
//  Created by Nic Jackson on 23/05/2013.
//  Copyright (c) 2013 Nic Jackson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <PebbleKit/PebbleKit.h>

@class ViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate,PBPebbleCentralDelegate> {
    
    PBWatch *_targetWatch;
    NSData * _watchUUID;
    
}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) ViewController *viewController;

@end
