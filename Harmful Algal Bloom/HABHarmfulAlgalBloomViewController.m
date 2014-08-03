//
//  HABHarmfulAlgalBloomViewController.m
//  Harmful Algal Bloom
//
//  Created by Justin Leishman on 8/1/14.
//  Copyright (c) 2014 Da Bay. All rights reserved.
//

#import "HABHarmfulAlgalBloomViewController.h"

static NSString * const HABHarmfulAlgalBloomWaterColorsName = @"Water Colors";

static NSString * const HABHarmfulAlgalBloomAlgaeColorsName = @"Algae Colors";

static NSString * const HABHarmfulAlgalBloomSocrataData = @"Socrata Credentials";

static NSString * const HABSocrataURLKey = @"URL";

static NSString * const HABSocrataUsernameKey = @"Username";

static NSString * const HABSocrataPasswordKey = @"Password";

static NSString * const HABSocrataAppTokenKey = @"App Token";

@interface HABHarmfulAlgalBloomViewController ()

@property (strong, nonatomic) NSArray *waterColors;

@property (strong, nonatomic) NSArray *algaeColors;

@property (strong, nonatomic) UIPickerView *waterColorPickerView;

@property (strong, nonatomic) UIPickerView *algaeColorPickerView;

@property (strong, nonatomic) NSOperationQueue *urlConnectionOperationQueue;

@end

@interface HABHarmfulAlgalBloomViewController (UIPickerViewSupport) <UIPickerViewDataSource,
                                                                     UIPickerViewDelegate>

@end

@interface HABHarmfulAlgalBloomViewController (UIImagePickerControllerSupport) <UINavigationControllerDelegate,
                                                                                UIImagePickerControllerDelegate>

@end

@implementation HABHarmfulAlgalBloomViewController

- (void)_updateAlgaeColorTextField {
    self.algaeColorTextField.text = self.report.algaeColor;
}

- (void)_updateWaterColorTextField {
    self.waterColorTextField.text = self.report.waterColor;
}

- (void)_updateLatitudeLabel {
    self.latitudeLabel.text = [NSString stringWithFormat:@"%@",
                               self.report.latitude];
    
    [self.latitudeLabel setNeedsLayout];
}

- (void)_updateLongitudeLabel {
    self.longitudeLabel.text = [NSString stringWithFormat:@"%@",
                                self.report.longitude];
    
    [self.longitudeLabel setNeedsLayout];
}

- (void)_updateImageView {
    self.imageView.image = self.report.image;
}

- (void)_updateInterface {
    [self _updateLatitudeLabel];
    [self _updateLongitudeLabel];
}

- (void)submit {
    NSDictionary *dictionary = @{@"water_color" : self.report.waterColor,
                                 @"algae_color" : self.report.algaeColor,
                                 @"color_in_water_column" : self.report.colorInWaterColumn,
                                 @"lat" : self.report.latitude,
                                 @"long" : self.report.longitude};
    
    NSError *error = nil;
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:dictionary
                                                   options:0
                                                     error:&error];
    
    NSURL *socrataDataURL = [[NSBundle mainBundle] URLForResource:HABHarmfulAlgalBloomSocrataData
                                                    withExtension:@"plist"];
    
    NSDictionary *socrataData = [NSDictionary dictionaryWithContentsOfURL:socrataDataURL];
    
    NSURL *socrataDatasetURL = [NSURL URLWithString:socrataData[HABSocrataURLKey]];
    
    NSString *username = socrataData[HABSocrataUsernameKey];
    
    NSString *password = socrataData[HABSocrataPasswordKey];
    
    NSString *appToken = socrataData[HABSocrataAppTokenKey];
    
    NSString *credentialsString = [NSString stringWithFormat:@"%@:%@", username, password];
    
    NSData *authenticationData = [credentialsString dataUsingEncoding:NSASCIIStringEncoding];
    
    NSString *base64EncodedAuthenticationData = [authenticationData base64EncodedStringWithOptions:NSDataBase64Encoding76CharacterLineLength];
    
    NSString *authenticationString = [NSString stringWithFormat:@"Basic %@",
                                      base64EncodedAuthenticationData];
    
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:socrataDatasetURL];
    urlRequest.HTTPMethod = @"POST";
    urlRequest.HTTPBody = data;
    
    [urlRequest setValue:appToken forHTTPHeaderField:@"X-App-Token"];
    [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Content-type"];
    [urlRequest setValue:authenticationString forHTTPHeaderField:@"Authorization"];
    
    void (^handler)(NSURLResponse *,
                    NSData *,
                    NSError *) = ^(NSURLResponse *urlResponse,
                                   NSData *data,
                                   NSError *connectionError) {
        if ([urlResponse isKindOfClass:[NSHTTPURLResponse class]] == YES) {
            NSHTTPURLResponse *httpURLResponse = (NSHTTPURLResponse *)urlResponse;
            
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                if (httpURLResponse.statusCode != 200) {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error Submitting Report"
                                                                        message:@"There was a problem saving your report to Socrata."
                                                                       delegate:nil
                                                              cancelButtonTitle:@"Okay"
                                                              otherButtonTitles:nil];
                    
                    [alertView show];
                }
                else {
                    [self.navigationController popViewControllerAnimated:YES];
                }
            }];
        }
    };
    
    self.urlConnectionOperationQueue = [NSOperationQueue new];
    
    [NSURLConnection sendAsynchronousRequest:urlRequest
                                       queue:self.urlConnectionOperationQueue
                           completionHandler:handler];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.waterColors = [NSArray arrayWithContentsOfURL:[[NSBundle mainBundle] URLForResource:HABHarmfulAlgalBloomWaterColorsName
                                                                               withExtension:@"plist"]];
    
    self.algaeColors = [NSArray arrayWithContentsOfURL:[[NSBundle mainBundle] URLForResource:HABHarmfulAlgalBloomAlgaeColorsName
                                                                               withExtension:@"plist"]];
    
    self.waterColorPickerView = [[UIPickerView alloc] init];
    self.waterColorPickerView.dataSource = self;
    self.waterColorPickerView.delegate = self;
    
    self.waterColorTextField.inputView = self.waterColorPickerView;
    
    self.algaeColorPickerView = [[UIPickerView alloc] init];
    self.algaeColorPickerView.dataSource = self;
    self.algaeColorPickerView.delegate = self;
    
    self.algaeColorTextField.inputView = self.algaeColorPickerView;
    
    if (self.report.image == nil) {
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
        imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
        imagePickerController.delegate = self;
        
        [self presentViewController:imagePickerController
                           animated:YES
                         completion:NULL];
    }
    
    [self _updateAlgaeColorTextField];
    [self _updateWaterColorTextField];
    [self _updateLatitudeLabel];
    [self _updateLongitudeLabel];
}

#pragma mark UITableViewDelegate

- (BOOL)tableView:(UITableView *)tableView
shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    BOOL shouldHighlightRowAtIndexPath = YES;
    
    if ([[self.tableView indexPathForCell:self.waterColorTableViewCell] isEqual:indexPath] == YES) {
        shouldHighlightRowAtIndexPath = NO;
    }
    
    return shouldHighlightRowAtIndexPath;
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([[self.tableView indexPathForCell:self.waterColorTableViewCell] isEqual:indexPath] == YES) {
        [self.waterColorTextField becomeFirstResponder];
    }
}

@end

@implementation HABHarmfulAlgalBloomViewController (UIPickerViewSupport)

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView
numberOfRowsInComponent:(NSInteger)component {
    NSInteger numberOfRows = 0;
    
    if (pickerView == self.waterColorPickerView) {
        numberOfRows = self.waterColors.count;
    }
    else if (pickerView == self.algaeColorPickerView) {
        numberOfRows = self.algaeColors.count;
    }
    
    return numberOfRows;
}

- (NSString *)pickerView:(UIPickerView *)pickerView
             titleForRow:(NSInteger)row
            forComponent:(NSInteger)component {
    NSString *titleForRow = nil;
    
    if (pickerView == self.waterColorPickerView) {
        titleForRow = NSLocalizedStringWithDefaultValue(self.waterColors[row],
                                                        HABHarmfulAlgalBloomWaterColorsName,
                                                        [NSBundle mainBundle],
                                                        @"Unrecognized Color",
                                                        @"Localized description of water color.");
    }
    else if (pickerView == self.algaeColorPickerView) {
        titleForRow = NSLocalizedStringWithDefaultValue(self.algaeColors[row],
                                                        HABHarmfulAlgalBloomAlgaeColorsName,
                                                        [NSBundle mainBundle],
                                                        @"Unrecognized Color",
                                                        @"Localized description of algae color.");
    }
    
    return titleForRow;
}

- (void)pickerView:(UIPickerView *)pickerView
      didSelectRow:(NSInteger)row
       inComponent:(NSInteger)component {
    if (pickerView == self.waterColorPickerView) {
        self.report.waterColor = self.waterColors[row];
        
        [self _updateWaterColorTextField];
    }
    else if (pickerView == self.algaeColorPickerView) {
        self.report.algaeColor = self.algaeColors[row];
        
        [self _updateAlgaeColorTextField];
    }
}

@end

@implementation HABHarmfulAlgalBloomViewController (MKMapViewSupport)

- (void)mapView:(MKMapView *)mapView
didUpdateUserLocation:(MKUserLocation *)userLocation {
    self.report.latitude = @(userLocation.location.coordinate.latitude);
    self.report.longitude = @(userLocation.location.coordinate.longitude);
    
    [self _updateLatitudeLabel];
    [self _updateLongitudeLabel];
}

@end

@implementation HABHarmfulAlgalBloomViewController (UIImagePickerControllerSupport)

- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    
    self.report.image = image;
    
    [self _updateImageView];
    
    [self dismissViewControllerAnimated:YES
                             completion:NULL];
}

@end
