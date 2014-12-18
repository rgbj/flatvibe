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
    if (self = [super init]) {
        _vibrate = FSSwitchStateIndeterminate;
        _fsp = [FSSwitchPanel sharedPanel];
        _mm = [[CMMotionManager alloc] init];
    }
    return self;
}

- (void) dealloc {
    NSLog(@"FlatVibe:dealloc");
    [self.mm release];
    [super dealloc];
}

- (void) loadPreferences {

    NSLog(@"FlatVibe: loadPreferences");

    NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.lazypulse.flatvibeprefs.plist"];

    if (!prefs) {
        NSLog(@"FlatVibe: no prefs??");
        return;
    }

    id o = [prefs objectForKey:@"enabled"];
    if (nil == o) {
        NSLog(@"FlatVibe: nil == o");
    }
    BOOL enable = [o boolValue];
    NSLog(@"FlatVibe: enable = %d", enable);

    if (enable) {
        if (!self.timer) {
            NSLog(@"FlatVibe: enabling");
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
    }
    else {
        if (self.timer) {
            NSLog(@"FlatVibe: disabling");
            [self.timer invalidate];
            [self.timer release];
            self.timer = nil;
            [self.mm stopAccelerometerUpdates];
        }
    }

    [prefs release];
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

static FlatVibe *flatvibe;

static void loadPrefs() {
    [flatvibe loadPreferences];
}


%ctor {
    flatvibe = [[[FlatVibe alloc] init] autorelease];

    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
                                    NULL,
                                    (CFNotificationCallback)loadPrefs,
                                    CFSTR("com.lazypulse.flatvibeprefs/changed"),
                                    NULL,
                                    CFNotificationSuspensionBehaviorCoalesce);
    [flatvibe loadPreferences];
}
