//
//  ViewController.h
//  PebbleCyclingComputer-iOS
//
//  Created by Nic Jackson on 23/05/2013.
//  Copyright (c) 2013 Nic Jackson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <PebbleKit/PebbleKit.h>
#import <Foundation/Foundation.h>

@interface ViewController : UIViewController <CLLocationManagerDelegate> {

    CLLocationManager * locationManager;
    bool _gpsRunning;

    CLLocation* _prevLocation;
}

@property (nonatomic,strong) PBWatch * targetWatch;

@property (nonatomic, weak) IBOutlet UIButton* startButton;
@property (nonatomic, weak) IBOutlet UILabel* statusView;

-(IBAction) clickButton:(id) sender;

- (void)sendSpeedToPebble:(double)speed;
@end
