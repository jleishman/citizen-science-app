//
//  ESHarmfulAlgalBloomViewController.m
//  EcoSleuth
//
//  Created by Justin Leishman on 8/1/14.
//  Copyright (c) 2014 DataBay 2014. All rights reserved.
//

#import "ESHarmfulAlgalBloomViewController.h"

static NSString * const HABHarmfulAlgalBloomWaterColorsName = @"Water Colors";

static NSString * const HABHarmfulAlgalBloomAlgaeColorsName = @"Algae Colors";

@interface ESHarmfulAlgalBloomViewController ()

@property (strong, nonatomic) NSArray *waterColors;

@property (strong, nonatomic) NSArray *algaeColors;

@property (strong, nonatomic) UIPickerView *waterColorPickerView;

@property (strong, nonatomic) UIPickerView *algaeColorPickerView;

@property (strong, nonatomic) NSArray *availableSourceTypes;

@end

@interface ESHarmfulAlgalBloomViewController (UIPickerViewSupport) <UIPickerViewDataSource,
                                                                     UIPickerViewDelegate>

@end

@interface ESHarmfulAlgalBloomViewController (UIImagePickerControllerSupport) <UINavigationControllerDelegate,
                                                                               UIImagePickerControllerDelegate,
                                                                               UIActionSheetDelegate>

@end

@implementation ESHarmfulAlgalBloomViewController

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
    [self.dataReporter submitReport:self.report
                    completionBlock:^(NSURLResponse *response,
                                      NSData *data,
                                      NSError *error) {
        if (error != nil) {
            // TODO: Show alert view.
        }
        else {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [self.navigationController popViewControllerAnimated:YES];
            }];
        }
    }];
}

- (void)captureImage {
    NSMutableArray *availableSourceTypes = [NSMutableArray new];
    NSMutableArray *sourceTypeButtonTitles = [NSMutableArray new];
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] == YES) {
        [availableSourceTypes addObject:@(UIImagePickerControllerSourceTypeCamera)];
        
        NSString *buttonTitle = NSLocalizedStringWithDefaultValue(@"Source Type Camera Button Title",
                                                                  NSStringFromClass([self class]),
                                                                  [NSBundle mainBundle],
                                                                  @"Camera",
                                                                  nil);
        
        [sourceTypeButtonTitles addObject:buttonTitle];
    }
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary] == YES) {
        [availableSourceTypes addObject:@(UIImagePickerControllerSourceTypePhotoLibrary)];
        
        NSString *buttonTitle = NSLocalizedStringWithDefaultValue(@"Source Type Photo Library Button Title",
                                                                  NSStringFromClass([self class]),
                                                                  [NSBundle mainBundle],
                                                                  @"Photo Library",
                                                                  nil);
        
        [sourceTypeButtonTitles addObject:buttonTitle];
    }

    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum] == YES) {
        [availableSourceTypes addObject:@(UIImagePickerControllerSourceTypeSavedPhotosAlbum)];
        
        NSString *buttonTitle = NSLocalizedStringWithDefaultValue(@"Source Type Camera Roll Button Title",
                                                                  NSStringFromClass([self class]),
                                                                  [NSBundle mainBundle],
                                                                  @"Camera Roll",
                                                                  nil);
        
        [sourceTypeButtonTitles addObject:buttonTitle];
    }
    
    if (availableSourceTypes.count == 1) {
        [self _captureImageWithSourceType:[availableSourceTypes.firstObject integerValue]];
    }
    else {
        self.availableSourceTypes = availableSourceTypes.copy;
        
        NSString *cancelButtonTitle = NSLocalizedStringWithDefaultValue(@"Source Type Cancel Button Title",
                                                                        NSStringFromClass([self class]),
                                                                        [NSBundle mainBundle],
                                                                        @"Cancel",
                                                                        nil);
        
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                 delegate:self
                                                        cancelButtonTitle:nil
                                                   destructiveButtonTitle:nil
                                                        otherButtonTitles:nil];
        
        for (NSString *buttonTitle in sourceTypeButtonTitles) {
            [actionSheet addButtonWithTitle:buttonTitle];
        }
        
        [actionSheet addButtonWithTitle:cancelButtonTitle];
        actionSheet.cancelButtonIndex = [sourceTypeButtonTitles count];
        
        [actionSheet showInView:self.view];
    }
}

- (void)_captureImageWithSourceType:(UIImagePickerControllerSourceType)sourceType {
    NSAssert([UIImagePickerController isSourceTypeAvailable:sourceType] == YES,
             @"Source type is unavailable.");
    
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.sourceType = sourceType;
    
    if (sourceType == UIImagePickerControllerSourceTypeCamera) {
        imagePickerController.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
    }
    
    imagePickerController.delegate = self;
    
    [self presentViewController:imagePickerController
                       animated:YES
                     completion:NULL];
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
    
    [self _updateAlgaeColorTextField];
    [self _updateWaterColorTextField];
    [self _updateLatitudeLabel];
    [self _updateLongitudeLabel];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (self.report.image == nil) {
        [self captureImage];
    }
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

@implementation ESHarmfulAlgalBloomViewController (UIPickerViewSupport)

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

@implementation ESHarmfulAlgalBloomViewController (MKMapViewSupport)

- (void)mapView:(MKMapView *)mapView
didUpdateUserLocation:(MKUserLocation *)userLocation {
    self.report.latitude = @(userLocation.location.coordinate.latitude);
    self.report.longitude = @(userLocation.location.coordinate.longitude);
    
    [self _updateLatitudeLabel];
    [self _updateLongitudeLabel];
}

@end

@implementation ESHarmfulAlgalBloomViewController (UIImagePickerControllerSupport)

#pragma mark UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    
    self.report.image = image;
    
    [self _updateImageView];
    
    [self dismissViewControllerAnimated:YES
                             completion:NULL];
}

#pragma mark UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet
clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex != self.availableSourceTypes.count) {
        NSNumber *sourceType = self.availableSourceTypes[buttonIndex];
        
        [self _captureImageWithSourceType:sourceType.integerValue];
        
        self.availableSourceTypes = nil;
    }
}

@end
