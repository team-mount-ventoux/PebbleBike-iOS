//
//  ViewController.m
//  PebbleCyclingComputer-iOS
//
//  Created by Nic Jackson on 23/05/2013.
//  Copyright (c) 2013 Nic Jackson. All rights reserved.
//
#import "ViewController.h"

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)clickButton:(id)sender {
    if(!_gpsRunning) {
        [self.targetWatch appMessagesLaunch:^(PBWatch *watch, NSError *error) {
           if(error)
               NSLog(@"Unable to start watch face %@",[error localizedDescription]);
        }];
        [self startStandardUpdates];
        [self.startButton setTitle:@"Stop" forState:UIControlStateNormal];
        [self setStatus:@"GPS Started"];
        _gpsRunning = true;
    }else {
        [self.targetWatch appMessagesKill:^(PBWatch *watch, NSError *error) {
            if(error)
                NSLog(@"Unable to stop watch face %@", error);
        }];
        _gpsRunning = false;
        [self stopStandardUpdates];
        [self.startButton setTitle:@"Start" forState:UIControlStateNormal];
        [self setStatus:@"GPS Stopped"];
    }
}

- (void)setStatus:(NSString *) status {
    [self.statusView setText:[NSString stringWithFormat:@"%@",status]];
}

- (void)startStandardUpdates
{
    // Create the location manager if this object does not
    // already have one.
    if (nil == locationManager)
        locationManager = [[CLLocationManager alloc] init];

    _dataPoints = 0;
    _totalSpeed = 0.0;
    _distance = 0.0;
    _speed = 0;
    [self sendSpeedToPebble];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;

    // Set a movement threshold for new events.
    //locationManager.distanceFilter = 500;

    [locationManager startUpdatingLocation];
}

-(void)stopStandardUpdates
{
    [locationManager stopUpdatingLocation];
    [_timer invalidate];
}

#pragma mark - Delegate method from the CLLocationManagerDelegate protocol
- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations {
    // If it's a relatively recent event, turn off updates to save power
    CLLocation* location = [locations lastObject];
    NSDate* eventDate = location.timestamp;
    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
    if (abs(howRecent) < 15.0) {
        // If the event is recent, do something with it.
        NSLog(@"latitude %+.6f, longitude %+.6f\n",
                location.coordinate.latitude,
                location.coordinate.longitude);
        double gpsSpeed = (location.speed * 2.23693629); // speed in m/s convert to miles per hour use 3.6 for kph


        int distance = 0;

        if(_prevLocation != nil) {
            double distance = [location distanceFromLocation:_prevLocation] * 0.000621371192;
            if(distance > 0)
                distance += _distance;
            else
                distance = _distance;
            
            NSLog(@"Got Prevlocaiton with distance: %f",distance);
            
        }

        if(gpsSpeed > 0) {
            _totalSpeed += gpsSpeed;
            _dataPoints ++;
        }

        if(gpsSpeed < 1)
            gpsSpeed = 0.0;

        double avgspeed = 0;
        if(_totalSpeed/_dataPoints > 0)
            avgspeed = _totalSpeed/_dataPoints;

        if((gpsSpeed != _speed) || (avgspeed != _avgspeed) || (distance != _distance)) {
            _speed = gpsSpeed;
            _avgspeed = avgspeed;
            _distance = distance;
            [self sendSpeedToPebble];
        }
        
        _prevLocation = location;
        
    }
}

- (void)sendSpeedToPebble {

	NSNumber * SPEED_TEXT = @(1);
	NSNumber * DISTANCE_TEXT = @(2);
	NSNumber * AVGSPEED_TEXT = @(3);

    NSNumberFormatter *fmt = [[NSNumberFormatter alloc] init];
    [fmt setPositiveFormat:@"0.0"];

    // set the speed with 1dp accuracy
    NSDictionary *updateDict = @{
            SPEED_TEXT: [fmt stringFromNumber:[NSNumber numberWithDouble:_speed]],
            DISTANCE_TEXT: [fmt stringFromNumber:[NSNumber numberWithDouble:_distance]],
            AVGSPEED_TEXT: [fmt stringFromNumber:[NSNumber numberWithDouble:_avgspeed]]
    };

    [_targetWatch sportsAppUpdate:updateDict onSent:^(PBWatch *watch, NSError *error) {
        if (error) {
            NSLog(@"Failed sending update: %@\n", error);
        } else {
            NSLog(@"Updated Pebble");
        }
    }];

}
@end
