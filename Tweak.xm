#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

static NSString * const TSTelegramURLString = @"tg://resolve?domain=Turath_st";
static NSString * const TSTelegramFallbackURLString = @"https://t.me/Turath_st";
static NSString * const TSLogoURLString = @"https://iili.io/COmey0l.md.png";
static NSString * const TSPreferenceKey = @"com.turath.storeoverlay.isOn";

static UIColor *TSColorFromRGB(CGFloat red, CGFloat green, CGFloat blue) {
    return [UIColor colorWithRed:red / 255.0
                           green:green / 255.0
                            blue:blue / 255.0
                           alpha:1.0];
}

static void TSOpenTelegram(void) {
    UIApplication *application = [UIApplication sharedApplication];
    NSURL *telegramURL = [NSURL URLWithString:TSTelegramURLString];
    NSURL *fallbackURL = [NSURL URLWithString:TSTelegramFallbackURLString];

    if (@available(iOS 10.0, *)) {
        [application openURL:telegramURL
                     options:@{}
           completionHandler:^(BOOL success) {
            if (!success && fallbackURL != nil) {
                [application openURL:fallbackURL options:@{} completionHandler:nil];
            }
        }];
    } else {
        BOOL opened = [application openURL:telegramURL];
        if (!opened && fallbackURL != nil) {
            [application openURL:fallbackURL];
        }
    }
}

@interface TSTouchWindow : UIWindow
@property (nonatomic, weak) UIView *interactionPanel;
@end

@implementation TSTouchWindow

- (BOOL)canBecomeKeyWindow {
    return NO;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *panel = self.interactionPanel;
    if (self.hidden || self.alpha < 0.01 || panel == nil || panel.hidden) {
        return nil;
    }

    CGRect panelRect = [panel convertRect:panel.bounds toView:self];
    if (!CGRectContainsPoint(panelRect, point)) {
        // Let taps outside the card reach the app underneath it.
        return nil;
    }

    return [super hitTest:point withEvent:event];
}

@end

@interface TSOverlayViewController : UIViewController
@property (nonatomic, strong) UIView *panel;
@property (nonatomic, strong) NSLayoutConstraint *panelHeightConstraint;
@property (nonatomic, strong) UIImageView *logoView;
@property (nonatomic, strong) UILabel *logoFallbackLabel;
@property (nonatomic, strong) UIButton *toggleButton;
@property (nonatomic, strong) UIView *togglePill;
@property (nonatomic, strong) UIView *toggleDot;
@property (nonatomic, strong) UILabel *toggleStateLabel;
@property (nonatomic, assign) BOOL isOn;
- (void)buildOverlay;
@end

@implementation TSOverlayViewController

- (void)loadView {
    UIView *rootView = [[UIView alloc] initWithFrame:UIScreen.mainScreen.bounds];
    rootView.backgroundColor = UIColor.clearColor;
    rootView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.view = rootView;
    [self buildOverlay];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    CGFloat availableHeight = CGRectGetHeight(self.view.bounds) - 24.0;
    self.panelHeightConstraint.constant = MIN(370.0, MAX(320.0, availableHeight));
}

- (void)buildOverlay {
    self.isOn = [[NSUserDefaults standardUserDefaults] boolForKey:TSPreferenceKey];

    UIView *panel = [[UIView alloc] initWithFrame:CGRectZero];
    panel.translatesAutoresizingMaskIntoConstraints = NO;
    panel.backgroundColor = TSColorFromRGB(255, 252, 247);
    panel.layer.cornerRadius = 27.0;
    panel.layer.borderWidth = 1.0;
    panel.layer.borderColor = TSColorFromRGB(237, 227, 215).CGColor;
    panel.layer.shadowColor = UIColor.blackColor.CGColor;
    panel.layer.shadowOpacity = 0.17;
    panel.layer.shadowRadius = 27.0;
    panel.layer.shadowOffset = CGSizeMake(0.0, 13.0);
    panel.semanticContentAttribute = UISemanticContentAttributeForceRightToLeft;
    [self.view addSubview:panel];
    self.panel = panel;

    [NSLayoutConstraint activateConstraints:@[
        [panel.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [panel.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor],
        [panel.leadingAnchor constraintGreaterThanOrEqualToAnchor:self.view.leadingAnchor constant:20.0],
        [panel.trailingAnchor constraintLessThanOrEqualToAnchor:self.view.trailingAnchor constant:-20.0],
        [panel.widthAnchor constraintLessThanOrEqualToConstant:370.0]
    ]];
    self.panelHeightConstraint = [panel.heightAnchor constraintEqualToConstant:370.0];
    self.panelHeightConstraint.active = YES;

    UIView *topAccent = [[UIView alloc] initWithFrame:CGRectZero];
    topAccent.translatesAutoresizingMaskIntoConstraints = NO;
    topAccent.backgroundColor = TSColorFromRGB(177, 135, 73);
    topAccent.layer.cornerRadius = 2.0;
    [panel addSubview:topAccent];
    [NSLayoutConstraint activateConstraints:@[
        [topAccent.topAnchor constraintEqualToAnchor:panel.topAnchor],
        [topAccent.centerXAnchor constraintEqualToAnchor:panel.centerXAnchor],
        [topAccent.widthAnchor constraintEqualToConstant:76.0],
        [topAccent.heightAnchor constraintEqualToConstant:4.0]
    ]];

    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeSystem];
    closeButton.translatesAutoresizingMaskIntoConstraints = NO;
    UIImage *closeImage = [UIImage systemImageNamed:@"xmark"];
    [closeButton setImage:[closeImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]
                 forState:UIControlStateNormal];
    closeButton.tintColor = TSColorFromRGB(111, 98, 87);
    closeButton.backgroundColor = TSColorFromRGB(247, 242, 235);
    closeButton.layer.cornerRadius = 16.0;
    [closeButton addTarget:self action:@selector(closeTapped) forControlEvents:UIControlEventTouchUpInside];
    [panel addSubview:closeButton];
    [NSLayoutConstraint activateConstraints:@[
        [closeButton.topAnchor constraintEqualToAnchor:panel.topAnchor constant:10.0],
        [closeButton.trailingAnchor constraintEqualToAnchor:panel.trailingAnchor constant:-10.0],
        [closeButton.widthAnchor constraintEqualToConstant:32.0],
        [closeButton.heightAnchor constraintEqualToConstant:32.0]
    ]];

    UIView *logoHolder = [[UIView alloc] initWithFrame:CGRectZero];
    logoHolder.translatesAutoresizingMaskIntoConstraints = NO;
    logoHolder.backgroundColor = TSColorFromRGB(111, 45, 47);
    logoHolder.layer.cornerRadius = 22.0;
    logoHolder.layer.shadowColor = TSColorFromRGB(83, 35, 38).CGColor;
    logoHolder.layer.shadowOpacity = 0.18;
    logoHolder.layer.shadowRadius = 12.0;
    logoHolder.layer.shadowOffset = CGSizeMake(0.0, 5.0);
    [panel addSubview:logoHolder];
    [NSLayoutConstraint activateConstraints:@[
        [logoHolder.topAnchor constraintEqualToAnchor:panel.topAnchor constant:29.0],
        [logoHolder.centerXAnchor constraintEqualToAnchor:panel.centerXAnchor],
        [logoHolder.widthAnchor constraintEqualToConstant:72.0],
        [logoHolder.heightAnchor constraintEqualToConstant:72.0]
    ]];

    self.logoFallbackLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.logoFallbackLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.logoFallbackLabel.text = @"ت";
    self.logoFallbackLabel.textColor = TSColorFromRGB(255, 236, 201);
    self.logoFallbackLabel.font = [UIFont boldSystemFontOfSize:43.0];
    self.logoFallbackLabel.textAlignment = NSTextAlignmentCenter;
    [logoHolder addSubview:self.logoFallbackLabel];
    [NSLayoutConstraint activateConstraints:@[
        [self.logoFallbackLabel.topAnchor constraintEqualToAnchor:logoHolder.topAnchor],
        [self.logoFallbackLabel.bottomAnchor constraintEqualToAnchor:logoHolder.bottomAnchor],
        [self.logoFallbackLabel.leadingAnchor constraintEqualToAnchor:logoHolder.leadingAnchor],
        [self.logoFallbackLabel.trailingAnchor constraintEqualToAnchor:logoHolder.trailingAnchor]
    ]];

    self.logoView = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.logoView.translatesAutoresizingMaskIntoConstraints = NO;
    self.logoView.contentMode = UIViewContentModeScaleAspectFit;
    self.logoView.clipsToBounds = YES;
    self.logoView.layer.cornerRadius = 22.0;
    [logoHolder addSubview:self.logoView];
    [NSLayoutConstraint activateConstraints:@[
        [self.logoView.topAnchor constraintEqualToAnchor:logoHolder.topAnchor],
        [self.logoView.bottomAnchor constraintEqualToAnchor:logoHolder.bottomAnchor],
        [self.logoView.leadingAnchor constraintEqualToAnchor:logoHolder.leadingAnchor],
        [self.logoView.trailingAnchor constraintEqualToAnchor:logoHolder.trailingAnchor]
    ]];
    [self loadLogo];

    UILabel *welcomeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    welcomeLabel.translatesAutoresizingMaskIntoConstraints = NO;
    welcomeLabel.text = @"مرحبا بك في التراث ستور";
    welcomeLabel.textColor = TSColorFromRGB(51, 39, 34);
    welcomeLabel.font = [UIFont systemFontOfSize:22.0 weight:UIFontWeightBold];
    welcomeLabel.textAlignment = NSTextAlignmentCenter;
    welcomeLabel.numberOfLines = 2;
    welcomeLabel.adjustsFontSizeToFitWidth = YES;
    welcomeLabel.minimumScaleFactor = 0.8;
    welcomeLabel.semanticContentAttribute = UISemanticContentAttributeForceRightToLeft;
    [panel addSubview:welcomeLabel];
    [NSLayoutConstraint activateConstraints:@[
        [welcomeLabel.topAnchor constraintEqualToAnchor:logoHolder.bottomAnchor constant:11.0],
        [welcomeLabel.leadingAnchor constraintEqualToAnchor:panel.leadingAnchor constant:20.0],
        [welcomeLabel.trailingAnchor constraintEqualToAnchor:panel.trailingAnchor constant:-20.0],
        [welcomeLabel.heightAnchor constraintEqualToConstant:50.0]
    ]];

    UILabel *instructionLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    instructionLabel.translatesAutoresizingMaskIntoConstraints = NO;
    instructionLabel.text = @"لتفعيل المميزات اضغط على الزر";
    instructionLabel.textColor = TSColorFromRGB(139, 126, 113);
    instructionLabel.font = [UIFont systemFontOfSize:13.0 weight:UIFontWeightMedium];
    instructionLabel.textAlignment = NSTextAlignmentCenter;
    instructionLabel.numberOfLines = 1;
    instructionLabel.adjustsFontSizeToFitWidth = YES;
    instructionLabel.minimumScaleFactor = 0.85;
    instructionLabel.semanticContentAttribute = UISemanticContentAttributeForceRightToLeft;
    [panel addSubview:instructionLabel];
    [NSLayoutConstraint activateConstraints:@[
        [instructionLabel.topAnchor constraintEqualToAnchor:welcomeLabel.bottomAnchor constant:2.0],
        [instructionLabel.leadingAnchor constraintEqualToAnchor:panel.leadingAnchor constant:20.0],
        [instructionLabel.trailingAnchor constraintEqualToAnchor:panel.trailingAnchor constant:-20.0],
        [instructionLabel.heightAnchor constraintEqualToConstant:20.0]
    ]];

    self.toggleButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.toggleButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.toggleButton.backgroundColor = TSColorFromRGB(249, 244, 237);
    self.toggleButton.layer.cornerRadius = 17.0;
    self.toggleButton.layer.borderWidth = 1.0;
    self.toggleButton.layer.borderColor = TSColorFromRGB(235, 224, 210).CGColor;
    self.toggleButton.layer.masksToBounds = YES;
    self.toggleButton.semanticContentAttribute = UISemanticContentAttributeForceRightToLeft;
    self.toggleButton.accessibilityHint = @"تبديل حالة تفعيل المميزات";
    [self.toggleButton addTarget:self action:@selector(toggleTapped) forControlEvents:UIControlEventTouchUpInside];
    [panel addSubview:self.toggleButton];
    [NSLayoutConstraint activateConstraints:@[
        [self.toggleButton.topAnchor constraintEqualToAnchor:instructionLabel.bottomAnchor constant:14.0],
        [self.toggleButton.leadingAnchor constraintEqualToAnchor:panel.leadingAnchor constant:24.0],
        [self.toggleButton.trailingAnchor constraintEqualToAnchor:panel.trailingAnchor constant:-24.0],
        [self.toggleButton.heightAnchor constraintEqualToConstant:56.0]
    ]];

    UILabel *featureLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    featureLabel.translatesAutoresizingMaskIntoConstraints = NO;
    featureLabel.text = @"تفعيل المميزات";
    featureLabel.textColor = TSColorFromRGB(57, 45, 39);
    featureLabel.font = [UIFont systemFontOfSize:16.0 weight:UIFontWeightSemibold];
    featureLabel.textAlignment = NSTextAlignmentRight;
    featureLabel.semanticContentAttribute = UISemanticContentAttributeForceRightToLeft;
    [self.toggleButton addSubview:featureLabel];
    [NSLayoutConstraint activateConstraints:@[
        [featureLabel.trailingAnchor constraintEqualToAnchor:self.toggleButton.trailingAnchor constant:-18.0],
        [featureLabel.leadingAnchor constraintGreaterThanOrEqualToAnchor:self.toggleButton.leadingAnchor constant:100.0],
        [featureLabel.centerYAnchor constraintEqualToAnchor:self.toggleButton.centerYAnchor]
    ]];

    self.togglePill = [[UIView alloc] initWithFrame:CGRectZero];
    self.togglePill.translatesAutoresizingMaskIntoConstraints = NO;
    self.togglePill.layer.cornerRadius = 13.0;
    self.togglePill.backgroundColor = TSColorFromRGB(211, 65, 68);
    self.togglePill.userInteractionEnabled = NO;
    [self.toggleButton addSubview:self.togglePill];
    [NSLayoutConstraint activateConstraints:@[
        [self.togglePill.leadingAnchor constraintEqualToAnchor:self.toggleButton.leadingAnchor constant:14.0],
        [self.togglePill.centerYAnchor constraintEqualToAnchor:self.toggleButton.centerYAnchor],
        [self.togglePill.widthAnchor constraintEqualToConstant:66.0],
        [self.togglePill.heightAnchor constraintEqualToConstant:30.0]
    ]];

    self.toggleStateLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.toggleStateLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.toggleStateLabel.text = @"OFF";
    self.toggleStateLabel.textColor = UIColor.whiteColor;
    self.toggleStateLabel.font = [UIFont systemFontOfSize:12.0 weight:UIFontWeightBold];
    self.toggleStateLabel.textAlignment = NSTextAlignmentCenter;
    self.toggleStateLabel.semanticContentAttribute = UISemanticContentAttributeForceLeftToRight;
    [self.togglePill addSubview:self.toggleStateLabel];
    [NSLayoutConstraint activateConstraints:@[
        [self.toggleStateLabel.topAnchor constraintEqualToAnchor:self.togglePill.topAnchor],
        [self.toggleStateLabel.bottomAnchor constraintEqualToAnchor:self.togglePill.bottomAnchor],
        [self.toggleStateLabel.leadingAnchor constraintEqualToAnchor:self.togglePill.leadingAnchor],
        [self.toggleStateLabel.trailingAnchor constraintEqualToAnchor:self.togglePill.trailingAnchor]
    ]];
    [self updateToggleAppearance];

    UIButton *telegramButton = [UIButton buttonWithType:UIButtonTypeSystem];
    telegramButton.translatesAutoresizingMaskIntoConstraints = NO;
    telegramButton.backgroundColor = TSColorFromRGB(35, 152, 211);
    telegramButton.layer.cornerRadius = 16.0;
    telegramButton.layer.masksToBounds = YES;
    telegramButton.layer.borderWidth = 1.0;
    telegramButton.layer.borderColor = TSColorFromRGB(28, 137, 193).CGColor;
    telegramButton.titleLabel.font = [UIFont systemFontOfSize:16.0 weight:UIFontWeightSemibold];
    telegramButton.semanticContentAttribute = UISemanticContentAttributeForceRightToLeft;
    [telegramButton setTitle:@"قناة تليغرام" forState:UIControlStateNormal];
    [telegramButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    UIImage *telegramImage = [UIImage systemImageNamed:@"paperplane.fill"];
    [telegramButton setImage:[telegramImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]
                    forState:UIControlStateNormal];
    telegramButton.tintColor = UIColor.whiteColor;
    telegramButton.imageEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, 0.0, 9.0);
    [telegramButton addTarget:self action:@selector(telegramTapped) forControlEvents:UIControlEventTouchUpInside];
    [panel addSubview:telegramButton];
    [NSLayoutConstraint activateConstraints:@[
        [telegramButton.topAnchor constraintEqualToAnchor:self.toggleButton.bottomAnchor constant:10.0],
        [telegramButton.leadingAnchor constraintEqualToAnchor:panel.leadingAnchor constant:24.0],
        [telegramButton.trailingAnchor constraintEqualToAnchor:panel.trailingAnchor constant:-24.0],
        [telegramButton.heightAnchor constraintEqualToConstant:50.0]
    ]];
}

- (void)loadLogo {
    NSURL *url = [NSURL URLWithString:TSLogoURLString];
    if (url == nil) {
        return;
    }

    [[[NSURLSession sharedSession] dataTaskWithURL:url
                                 completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error != nil || data.length == 0) {
            return;
        }
        UIImage *image = [UIImage imageWithData:data];
        if (image == nil) {
            return;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            self.logoView.image = image;
            self.logoFallbackLabel.hidden = YES;
        });
    }] resume];
}

- (void)updateToggleAppearance {
    NSString *title = self.isOn ? @"ON" : @"OFF";
    UIColor *color = self.isOn ? TSColorFromRGB(39, 160, 101) : TSColorFromRGB(211, 65, 68);
    self.toggleStateLabel.text = title;
    self.togglePill.backgroundColor = color;
    self.toggleButton.accessibilityLabel = self.isOn ? @"إيقاف تفعيل المميزات" : @"تفعيل المميزات";
    self.toggleButton.accessibilityValue = title;
}

- (void)toggleTapped {
    self.isOn = !self.isOn;
    [[NSUserDefaults standardUserDefaults] setBool:self.isOn forKey:TSPreferenceKey];
    [self updateToggleAppearance];
    if (self.isOn) {
        TSOpenTelegram();
    }
}

- (void)telegramTapped {
    TSOpenTelegram();
}

- (void)closeTapped {
    self.panel.hidden = YES;
}

@end

@interface TSOverlayManager : NSObject
@property (nonatomic, strong) NSMutableDictionary<NSString *, TSTouchWindow *> *windowsByScene;
+ (instancetype)sharedManager;
- (void)start;
@end

@implementation TSOverlayManager

+ (instancetype)sharedManager {
    static TSOverlayManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[TSOverlayManager alloc] init];
    });
    return manager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _windowsByScene = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)start {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self
               selector:@selector(applicationBecameActive:)
                   name:UIApplicationDidBecomeActiveNotification
                 object:nil];

    if (@available(iOS 13.0, *)) {
        [center addObserver:self
                   selector:@selector(sceneBecameActive:)
                       name:UISceneDidActivateNotification
                     object:nil];
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        [self refreshOverlayWindows];
    });
}

- (void)applicationBecameActive:(NSNotification *)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self refreshOverlayWindows];
    });
}

- (void)sceneBecameActive:(NSNotification *)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self refreshOverlayWindows];
    });
}

- (void)refreshOverlayWindows {
    if (@available(iOS 13.0, *)) {
        UIApplication *application = [UIApplication sharedApplication];
        for (UIScene *scene in application.connectedScenes) {
            if (![scene isKindOfClass:[UIWindowScene class]]) {
                continue;
            }
            if (scene.activationState != UISceneActivationStateForegroundActive) {
                continue;
            }

            UIWindowScene *windowScene = (UIWindowScene *)scene;
            NSString *sceneKey = windowScene.session.persistentIdentifier;
            if (sceneKey.length == 0) {
                sceneKey = [NSString stringWithFormat:@"%p", windowScene];
            }
            if (self.windowsByScene[sceneKey] != nil) {
                continue;
            }

            TSTouchWindow *overlayWindow = [[TSTouchWindow alloc] initWithWindowScene:windowScene];
            overlayWindow.windowLevel = UIWindowLevelNormal + 1.0;
            overlayWindow.backgroundColor = UIColor.clearColor;
            TSOverlayViewController *controller = [[TSOverlayViewController alloc] init];
            overlayWindow.rootViewController = controller;
            [controller loadViewIfNeeded];
            overlayWindow.interactionPanel = controller.panel;
            overlayWindow.hidden = NO;
            self.windowsByScene[sceneKey] = overlayWindow;
        }
    }
}

@end

static BOOL TSIsEligibleApplicationProcess(void) {
    NSBundle *mainBundle = [NSBundle mainBundle];
    NSString *bundlePath = mainBundle.bundlePath;
    NSString *bundleIdentifier = mainBundle.bundleIdentifier;

    if (![bundlePath.pathExtension.lowercaseString isEqualToString:@"app"]) {
        return NO;
    }
    if (bundleIdentifier.length == 0 ||
        [bundleIdentifier isEqualToString:@"com.apple.springboard"]) {
        return NO;
    }
    if (NSClassFromString(@"UIApplication") == Nil) {
        return NO;
    }
    return YES;
}

%ctor {
    @autoreleasepool {
        if (!TSIsEligibleApplicationProcess()) {
            return;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [[TSOverlayManager sharedManager] start];
        });
    }
}
