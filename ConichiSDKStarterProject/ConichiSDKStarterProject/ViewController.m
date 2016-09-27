//
//  ViewController.m
//  ConichiSDKStarterProject
//
//  Created by Anton Domashnev on 12/09/16.
//  Copyright © 2016 conichi. All rights reserved.
//

#import "ViewController.h"

@import CNISDKCoreKit;
@import Conichi_Authentication;

@interface ViewController ()

@property (nonatomic, strong) NSMutableString *logText;

@property (nonatomic, assign, getter=isAutoScrollEnabled) BOOL autoScrollEnabled;
@property (nonatomic, assign, getter=isMonitoringEnabled) BOOL monitoringEnabled;

@property (nonatomic, weak) IBOutlet UIButton *autoScrollButton;
@property (nonatomic, weak) IBOutlet UITextView *logTextView;
@property (nonatomic, weak) IBOutlet UIButton *signUpButton;
@property (nonatomic, weak) IBOutlet UIButton *signInButton;
@property (nonatomic, weak) IBOutlet UIButton *monitoringButton;
@property (nonatomic, weak) IBOutlet UIButton *actionButton;
@property (nonatomic, weak) IBOutlet UIButton *logOutButton;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateButtonsVisibility];
}

#pragma mark - Helpers

- (BOOL)isAuthorized {
    return [CNISession activeSession].isAuthorized;
}

- (void)updateButtonsVisibility {
    if ([self isAuthorized]) {
        self.signUpButton.hidden = self.signInButton.hidden = YES;
        self.actionButton.hidden = self.monitoringButton.hidden = self.logOutButton.hidden = NO;
    }
    else {
        self.signUpButton.hidden = self.signInButton.hidden = NO;
        self.actionButton.hidden = self.monitoringButton.hidden = self.logOutButton.hidden = YES;
    }
}

- (void)updateLogTextViewWithMessage:(NSString *)message {
    if (!message) {
        return;
    }
    [self.logText appendFormat:@"\n%@\n", message];
    
    ViewController __weak *wSelf = self;
    dispatch_block_t updateBlock = ^{
        ViewController __strong *sSelf = wSelf;
        sSelf.logTextView.text = sSelf.logText;
        if (sSelf.isAutoScrollEnabled) {
            [self.logTextView setContentOffset:CGPointMake(0, MAX(0, self.logTextView.contentSize.height - self.logTextView.frame.size.height))];
        }
    };
    
    
    if ([NSThread isMainThread]) {
        updateBlock();
    } else {
        dispatch_async(dispatch_get_main_queue(), updateBlock);
    }
}

- (void)updateGuestDetails {
    CNISDKUpdateGuestRequestInfo *request = [CNISDKUpdateGuestRequestInfo new];
    request.firstName = @"Bob";
    request.gender = kCNISDKGuestGenderMale;
    request.lastName = @"Parker";
    request.locale = @"en_US";
    request.nationalityISOCode = @"RU";
    
    ViewController __weak *wSelf = self;
    [[CNISDKAPIManager manager] updateCurrentGuestWithRequest:request completion:^(CNISDKGuest *guest, NSError *error) {
        ViewController __strong *sSelf = wSelf;
        [sSelf updateLogTextViewWithMessage:[NSString stringWithFormat:@"Did update guest details"]];
    }];
}

- (void)updateOptionalValue {
    CNISDKUpdateOptionalValueRequestInfo *request = [CNISDKUpdateOptionalValueRequestInfo new];
    request.optionalValue = @{ @"seat" : @"24B" };
    
    ViewController __weak *wSelf = self;
    [[CNISDKAPIManager manager] updateOptionalValuesWithRequest:request completion:^(CNISDKGuest *guest, NSError *error) {
        ViewController __strong *sSelf = wSelf;
        if (!error) {
            [sSelf updateLogTextViewWithMessage:[NSString stringWithFormat:@"Did update optional value"]];
        } else {
            [sSelf updateLogTextViewWithMessage:error.localizedDescription];
        }
    }];
}

- (void)updateTravelDocument {
    CNISDKUpdateTravelDocumentRequestInfo *request = [CNISDKUpdateTravelDocumentRequestInfo new];
    request.authority = @"RF";
    request.dateOfExpiry = [NSDate date];
    request.documentNumber = @"12321321";
    request.documentType = @"passport";
    
    ViewController __weak *wSelf = self;
    [[CNISDKAPIManager manager] updateCurrentGuestTravelDocumentWithRequest:request completion:^(CNISDKGuest *guest, NSError *error) {
        ViewController __strong *sSelf = wSelf;
        [sSelf updateLogTextViewWithMessage:[NSString stringWithFormat:@"Did update travel document"]];
    }];
}

- (void)updateAddress {
    CNISDKUpdatePersonalAddressRequestInfo *request = [CNISDKUpdatePersonalAddressRequestInfo new];
    request.street = @"Lenin street";
    request.zip = @"101010";
    request.city = @"Moscow";
    request.countryCode = @"ru";
    
    ViewController __weak *wSelf = self;
    [[CNISDKAPIManager manager] updateCurrentGuestPersonalAddressWithRequest:request completion:^(CNISDKGuest *guest, NSError *error) {
        ViewController __strong *sSelf = wSelf;
        [sSelf updateLogTextViewWithMessage:[NSString stringWithFormat:@"Did update address"]];
    }];
}


#pragma mark - Actions

- (IBAction)autoScrollButtonClicked:(id)sender {
    self.autoScrollEnabled = !self.isAutoScrollEnabled;
    [self.autoScrollButton setTitle:self.isAutoScrollEnabled ? @"Disable Autoscroll" : @"Enable Autoscroll" forState:UIControlStateNormal];
}

- (IBAction)signUpButtonClicked:(id)sender {
    UIAlertController *signUpController = [UIAlertController alertControllerWithTitle:@"Sign Up" message:@"In order to sign up please fill out information below" preferredStyle:UIAlertControllerStyleAlert];
    
    [signUpController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"Email";
        textField.keyboardType = UIKeyboardTypeEmailAddress;
    }];
    
    [signUpController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"Password: min 8";
        textField.secureTextEntry = YES;
        textField.keyboardType = UIKeyboardTypeAlphabet;
    }];
    
    [signUpController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"First name";
        textField.keyboardType = UIKeyboardTypeAlphabet;
    }];
    
    [signUpController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"Last name";
        textField.keyboardType = UIKeyboardTypeAlphabet;
    }];
    
    ViewController __weak *wSelf = self;
    UIAlertAction *signUpAction = [UIAlertAction actionWithTitle:@"Sign Up" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        ViewController __strong *sSelf = wSelf;
        CNISDKSignUpRequestInfo *requestInfo = [[CNISDKSignUpRequestInfo alloc] init];
        requestInfo.email = signUpController.textFields[0].text;
        requestInfo.password = signUpController.textFields[1].text;
        requestInfo.firstName = signUpController.textFields[2].text;
        requestInfo.lastName = signUpController.textFields[3].text;
        [[CNISDKAPIManager manager] signUpWithRequest:requestInfo completion:^(CNISDKGuest *guest, NSError *error) {
            if (error) {
                [sSelf updateLogTextViewWithMessage:[NSString stringWithFormat:@"Failed to sign up: %@", error.localizedDescription]];
            }
            else {
                [sSelf updateLogTextViewWithMessage:[NSString stringWithFormat:@"Successfully signed up with guest: %@", guest]];
            }
            [sSelf updateButtonsVisibility];
        }];
    }];
    [signUpController addAction:signUpAction];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    [signUpController addAction:cancelAction];
    
    [self presentViewController:signUpController animated:YES completion:nil];
}

- (IBAction)signInButtonClicked:(id)sender {
    UIAlertController *signInController = [UIAlertController alertControllerWithTitle:@"Sign In" message:@"In order to sign up please fill out information below" preferredStyle:UIAlertControllerStyleAlert];
    
    [signInController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"Email";
        textField.keyboardType = UIKeyboardTypeEmailAddress;
    }];
    
    [signInController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"Password: min 8";
        textField.secureTextEntry = YES;
        textField.keyboardType = UIKeyboardTypeAlphabet;
    }];
    
    ViewController __weak *wSelf = self;
    UIAlertAction *signInAction = [UIAlertAction actionWithTitle:@"Sign Up" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        ViewController __strong *sSelf = wSelf;
        NSString *email = signInController.textFields[0].text;
        NSString *password = signInController.textFields[1].text;
        [[CNISDKAPIManager manager] signInWithEmail:email password:password completion:^(CNISDKGuest *guest, NSError *error) {
            if (error) {
                [sSelf updateLogTextViewWithMessage:[NSString stringWithFormat:@"Failed to sign in: %@", error.localizedDescription]];
            }
            else {
                [sSelf updateLogTextViewWithMessage:[NSString stringWithFormat:@"Successfully signed in with guest: %@", guest]];
            }
            [sSelf updateButtonsVisibility];
        }];
    }];
    [signInController addAction:signInAction];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    [signInController addAction:cancelAction];
    
    [self presentViewController:signInController animated:YES completion:nil];
}

- (IBAction)monitoringButtonClicked:(id)sender {
    self.monitoringEnabled = !self.isMonitoringEnabled;
    [self.monitoringButton setTitle:self.isMonitoringEnabled ? @"Stop Monitoring" : @"Start Monitoring" forState:UIControlStateNormal];
    if (self.isMonitoringEnabled) {
        [[CNISDK sharedInstance] startMonitoring];
    }
    else {
        [[CNISDK sharedInstance] stopMonitoring];
    }
}

- (IBAction)actionButtonClicked:(id)sender {
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:@"What do you want to update?" message:nil preferredStyle:UIAlertControllerStyleActionSheet];

    UIAlertAction *updateGuestDetailsAction = [UIAlertAction actionWithTitle:@"Guest details" style:UIAlertActionStyleDefault handler:^(UIAlertAction *_Nonnull action) {
        [self updateGuestDetails];
    }];
    [actionSheet addAction:updateGuestDetailsAction];
    
    UIAlertAction *updateGuestOptionalValueAction = [UIAlertAction actionWithTitle:@"Guest optional value" style:UIAlertActionStyleDefault handler:^(UIAlertAction *_Nonnull action) {
        [self updateOptionalValue];
    }];
    [actionSheet addAction:updateGuestOptionalValueAction];
    
    UIAlertAction *updateAddressAction = [UIAlertAction actionWithTitle:@"Address" style:UIAlertActionStyleDefault handler:^(UIAlertAction *_Nonnull action) {
        [self updateAddress];
    }];
    [actionSheet addAction:updateAddressAction];
    
    UIAlertAction *updateTravelDocumentAction = [UIAlertAction actionWithTitle:@"Travel document" style:UIAlertActionStyleDefault handler:^(UIAlertAction *_Nonnull action) {
        [self updateTravelDocument];
    }];
    [actionSheet addAction:updateTravelDocumentAction];
    
    UIAlertAction *selectAllPreferenciesAction = [UIAlertAction actionWithTitle:@"Select all preferencies" style:UIAlertActionStyleDefault handler:^(UIAlertAction *_Nonnull action) {
        [self batchPreferencesSelection];
    }];
    [actionSheet addAction:selectAllPreferenciesAction];
    
    UIAlertAction *deselectAllPreferenciesAction = [UIAlertAction actionWithTitle:@"Deselect all preferencies" style:UIAlertActionStyleDefault handler:^(UIAlertAction *_Nonnull action) {
        [self batchPreferencesDeselection];
    }];
    [actionSheet addAction:deselectAllPreferenciesAction];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    [actionSheet addAction:cancelAction];
    
    [self presentViewController:actionSheet animated:YES completion:nil];
}

- (IBAction)logOutButtonClicked:(id)sender {
    ViewController __weak *wSelf = self;
    [[CNISDKAPIManager manager] logOutWithCompletion:^(BOOL success, NSError *error) {
        ViewController __strong *sSelf = wSelf;
        if (success) {
            [sSelf updateLogTextViewWithMessage:@"Logged out"];
        }
        else {
            [sSelf updateLogTextViewWithMessage:[NSString stringWithFormat:@"Failed to log out: %@", error.localizedDescription]];
        }
    }];
}

#pragma mark - CNISDKDelegate

- (void)conichiSDKDidFetchConfig {
    [self updateLogTextViewWithMessage:@"conichiSDKDidFetchConfig"];
}

- (void)conichiSDKDidChangeNotificationsPermission:(BOOL)isAllow {
    [self updateLogTextViewWithMessage:[NSString stringWithFormat:@"conichiSDKDidChangeNotificationsPermission %d", isAllow]];
}

- (void)conichiSDKDidChangeLocationAuthorizationStatus:(CLAuthorizationStatus)status {
    [self updateLogTextViewWithMessage:[NSString stringWithFormat:@"conichiSDKDidChangeLocationAuthorizationStatus %d", status]];
}

- (void)conichiSDKDidChangeBluetoothState:(CBCentralManagerState)state {
    [self updateLogTextViewWithMessage:[NSString stringWithFormat:@"conichiSDKDidChangeBluetoothState %ld", (long)state]];
}

- (void)conichiSDKDidDiscoverVenue:(CNISDKVenue *)venue {
    [self updateLogTextViewWithMessage:[NSString stringWithFormat:@"Guest has just discovered venue \n%@", venue]];
}

- (void)conichiSDKDidDiscoverRegion:(CNISDKRegion *)region inVenue:(CNISDKVenue *)venue {
    [self updateLogTextViewWithMessage:[NSString stringWithFormat:@"Guest has just discovered region %@\nin venue \n%@", region, venue]];
}

- (void)conichiSDKDidLeaveRegion:(CNISDKRegion *)region inVenue:(CNISDKVenue *)venue {
    [self updateLogTextViewWithMessage:[NSString stringWithFormat:@"Guest's just left the region %@\nin the venue \n%@", region, venue]];
}

- (void)conichiSDKDidLeaveVenue:(CNISDKVenue *)venue {
    [self updateLogTextViewWithMessage:[NSString stringWithFormat:@"Guest's just left the venue \n%@", venue]];
}

- (void)conichiSDKDidFailTrackingLocationWithError:(NSError *)error {
    [self updateLogTextViewWithMessage:[NSString stringWithFormat:@"Did fail tracking Guest location. \n%@", error.localizedDescription]];
}

- (void)conichiSDKDidChangeAuthorizationStatus:(BOOL)isAuthorized reason:(CNISDKAuthorizationChangeReason)reason {
    [self updateButtonsVisibility];
    if (isAuthorized) {
        [self fetchUnreadNotificationsCount];
    }
}

- (void)conichiSDKDidCloseCheckIn:(CNISDKCheckin *__nonnull)checkIn {
    [self updateLogTextViewWithMessage:[NSString stringWithFormat:@"conichiSDKDidCloseCheckIn: \n%@", checkIn]];
}

- (void)conichiSDKDidOpenCheckIn:(CNISDKCheckin *__nonnull)checkIn {
    [self updateLogTextViewWithMessage:[NSString stringWithFormat:@"conichiSDKDidOpenCheckIn: \n%@", checkIn]];
}

- (void)fetchUnreadNotificationsCount {
    [[CNISDKAPIManager manager] fetchGuestNotificationsUnreadCountWithCompletion:^(id object, NSError *error) {
        if (!error) {
            NSNumber *count = object;
            [self updateLogTextViewWithMessage:[NSString stringWithFormat:@"Guest's unread notifications count =  %@", count]];
        }
    }];
}

- (void)fetchCurrentGuest {
    [[CNISDKAPIManager manager] fetchCurrentGuestWithCompletion:^(id object, NSError *error) {
        if (error) {
            [self updateLogTextViewWithMessage:error.localizedDescription];
            return;
        }
        [self updateLogTextViewWithMessage:[NSString stringWithFormat:@"Received current guest: %@", object]];
    }];
}


- (void)batchPreferencesSelection {
    NSArray<NSString *> *preferenceConichiIDs = @[ @"256", @"255", @"254", @"253", @"252" ];
    [[CNISDKAPIManager manager] selectPreferencesWithConichiIDs:preferenceConichiIDs completion:^(id object, NSError *error) {
        if (error) {
            [self updateLogTextViewWithMessage:error.localizedDescription];
            return;
        } else {
            [self updateLogTextViewWithMessage:[NSString stringWithFormat:@"Selected preferences with results: %@", object]];
        }
    }];
}

- (void)batchPreferencesDeselection {
    NSArray *preferences = [CNISDKPreference allPreferences];
    NSArray<NSString *> *preferenceConichiIDs = [preferences valueForKey:@"conichiID"];
    [[CNISDKAPIManager manager] deselectPreferencesWithConichiIDs:preferenceConichiIDs completion:^(id object, NSError *error) {
        if (error) {
            [self updateLogTextViewWithMessage:error.localizedDescription];
            return;
        } else {
            [self updateLogTextViewWithMessage:[NSString stringWithFormat:@"Deselected preferences with results: %@", object]];
        }
    }];
}

@end
