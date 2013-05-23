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
    _watchUUID = [@"5dd35873-3bb6-44d6-8255-0e61bc3b97f5" dataUsingEncoding: [NSString defaultCStringEncoding]];
    // We'd like to get called when Pebbles connect and disconnect, so become the delegate of PBPebbleCentral:
    [[PBPebbleCentral defaultCentral] setDelegate:self];

    // Initialize with the last connected watch:
    [self setTargetWatch:[[PBPebbleCentral defaultCentral] lastConnectedWatch]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)clickButton:(id)sender {
    if(!_gpsRunning) {
        [self startStandardUpdates];
        [self.startButton setTitle:@"Stop" forState:UIControlStateNormal];
        [self setStatus:@"Started GPS"];
        _gpsRunning = true;
    }else {
        _gpsRunning = false;
        [self stopStandardUpdates];
        [self.startButton setTitle:@"Start" forState:UIControlStateNormal];
        [self setStatus:@"Stopped GPS"];
    }
}

- (void)setStatus:(NSString *) status {
    [self.statusView setText:[NSString stringWithFormat:@"Status: %@",status]];
}

- (void)startStandardUpdates
{
    // Create the location manager if this object does not
    // already have one.
    if (nil == locationManager)
        locationManager = [[CLLocationManager alloc] init];

    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;

    // Set a movement threshold for new events.
    //locationManager.distanceFilter = 500;

    [locationManager startUpdatingLocation];
}

-(void)stopStandardUpdates
{
    [locationManager stopUpdatingLocation];
}

- (void)setTargetWatch:(PBWatch*)watch {
    _targetWatch = watch;

    // NOTE:
    // For demonstration purposes, we start communicating with the watch immediately upon connection,
    // because we are calling -appMessagesGetIsSupported: here, which implicitely opens the communication session.
    // Real world apps should communicate only if the user is actively using the app, because there
    // is one communication session that is shared between all 3rd party iOS apps.

    // Test if the Pebble's firmware supports AppMessages / Sports:
    [watch appMessagesGetIsSupported:^(PBWatch *watch, BOOL isAppMessagesSupported) {
        if (isAppMessagesSupported) {
            // Configure our communications channel to target the sports app:
            [watch appMessagesSetUUID:_watchUUID];

            NSString *message = [NSString stringWithFormat:@"Yay! %@ supports AppMessages :D", [watch name]];
            [[[UIAlertView alloc] initWithTitle:@"Connected!" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        } else {

            NSString *message = [NSString stringWithFormat:@"Blegh... %@ does NOT support AppMessages :'(", [watch name]];
            [[[UIAlertView alloc] initWithTitle:@"Connected..." message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
    }];
}

#pragma mark -
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
        [self sendSpeedToPebble:gpsSpeed];
    }
}

- (void)sendSpeedToPebble:(double)speed {

}

#pragma mark -
#pragma mark - PBPebbleCentral delegate methods
- (void)pebbleCentral:(PBPebbleCentral*)central watchDidConnect:(PBWatch*)watch isNew:(BOOL)isNew {
    [self setTargetWatch:watch];
}

- (void)pebbleCentral:(PBPebbleCentral*)central watchDidDisconnect:(PBWatch*)watch {
    [[[UIAlertView alloc] initWithTitle:@"Disconnected!" message:[watch name] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    if (_targetWatch == watch || [watch isEqual:_targetWatch]) {
        [self setTargetWatch:nil];
    }
}

@end
