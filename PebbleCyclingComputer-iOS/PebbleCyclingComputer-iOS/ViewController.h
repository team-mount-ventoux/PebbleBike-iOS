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

    double _speed;
    double _totalSpeed;
    int _dataPoints;
    double _distance;

    CLLocation* _prevLocation;
    NSTimer * _timer;
    double _avgspeed;
}

@property (nonatomic,strong) PBWatch * targetWatch;

@property (nonatomic, weak) IBOutlet UIButton* startButton;
@property (nonatomic, weak) IBOutlet UILabel* statusView;

-(IBAction) clickButton:(id) sender;

- (void)sendSpeedToPebble;
@end
