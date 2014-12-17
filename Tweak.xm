#import <Foundation/Foundation.h>
#import <CoreMotion/CoreMotion.h>

#import <FlipSwitch/FlipSwitch.h>

@interface FlatVibe: NSObject

@property (retain) CMMotionManager *mm;
@property BOOL flat;

@end

@implementation FlatVibe

- (id) init {
    // TODO: check language idiom about ctor & memory mgmt
    if (self = [super init]) {
        self.flat = false;
        self.mm = [[[CMMotionManager alloc] init] autorelease];

    }
    return self;
}

- (void) run {

    NSLog(@"FlatVibe: accelerometer available: %d active: %d",
          self.mm.accelerometerAvailable, self.mm.accelerometerActive);

    if(self.mm.accelerometerAvailable) {
        if (!self.mm.accelerometerActive) {
            [self.mm startAccelerometerUpdates];
        }
        else {
            NSLog(@"FlatVibe: accelerometer was active already..");
        }
        [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(tick:) userInfo:nil repeats:YES];
    }
    else {
        NSLog(@"FlatVibe: no accelerometer available -- doing.. nothing");
        // TODO: cleanup
    }
}

- (void) tick:(NSTimer *)timer {

    if (!self.mm.accelerometerActive) { // TODO: ??
        NSLog(@"FlatVibe: accelerometer not active");
        return;
    }
    if (!self.mm.accelerometerData) { // TODO: ??
        NSLog(@"FlatVibe: no accelerometer data");
        return;
    }

    CMAcceleration a = self.mm.accelerometerData.acceleration;
    //NSLog(@"FlatVibe: acceleration: %f %f %f", a.x, a.y, a.z);
    float epsilon = 0.1;
    BOOL flat = fabs(a.x) < epsilon && fabs(a.y) < epsilon && fabs(a.z) - 1 < epsilon;

    if (flat && !self.flat) {
        NSLog(@"FlatVibe: self.flat = NO  -> YES");
        self.flat = YES;
        [self setVibration];
    }
    else if (!flat && self.flat) {
        NSLog(@"FlatVibe: self.flat = YES -> NO");
        self.flat = NO;
        [self setVibration];
    }
}

- (void) setVibration {

    NSString *switchIdentifier = @"com.a3tweaks.switch.vibration";
    FSSwitchPanel *fsp = [FSSwitchPanel sharedPanel];
    [fsp setState:(self.flat? FSSwitchStateOff: FSSwitchStateOn) forSwitchIdentifier:switchIdentifier];
    [fsp applyActionForSwitchIdentifier:switchIdentifier];
}

@end

static FlatVibe *flatvibe;

%ctor {
    flatvibe = [[[FlatVibe alloc] init] autorelease];
    [flatvibe run];
}
