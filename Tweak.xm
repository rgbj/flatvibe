#import <Foundation/Foundation.h>
#import <CoreMotion/CoreMotion.h>

#import <FlipSwitch/FlipSwitch.h>

@interface FlatVibe: NSObject

@property (retain) CMMotionManager *mm;
@property (retain) FSSwitchPanel *fsp;
@property (retain) NSTimer *timer;

@property FSSwitchState vibrate;

@end

@implementation FlatVibe

- (id) init {
    // TODO: check language idiom about alloc/init & errs
    if (self = [super init]) {

        self.vibrate = FSSwitchStateIndeterminate;
        self.fsp = [FSSwitchPanel sharedPanel];
        self.mm = [[[CMMotionManager alloc] init] autorelease];

        if(self.mm.accelerometerAvailable) {
            if (!self.mm.accelerometerActive) {
                [self.mm startAccelerometerUpdates];
            }
            else {
                NSLog(@"FlatVibe: accelerometer was active already..");
            }
            self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(tick:) userInfo:nil repeats:YES];
        }
        else {
            NSLog(@"FlatVibe: no accelerometer available -- doing.. nothing");
        }
    }
    return self;
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
    float epsilon = 0.1;

    FSSwitchState vibrate =
        fabs(a.x) < epsilon && fabs(a.y) < epsilon && fabs(a.z) - 1 < epsilon?
        FSSwitchStateOff:
        FSSwitchStateOn;

    if (self.vibrate != vibrate) {
        NSLog(@"FlatVibe: vibrate: %d -> %d", self.vibrate, vibrate);
        self.vibrate = vibrate;
        [self setVibration];
    }
}

static NSString *switchIdentifier = @"com.a3tweaks.switch.vibration";

- (void) setVibration {
    [self.fsp setState:self.vibrate forSwitchIdentifier:switchIdentifier];
    [self.fsp applyActionForSwitchIdentifier:switchIdentifier];
}

@end

%ctor {
    [[[FlatVibe alloc] init] autorelease];
}
