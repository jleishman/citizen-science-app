//
//  ESSocrataAdapter.m
//  EcoSleuth
//
//  Created by Justin Leishman on 8/12/14.
//  Copyright (c) 2014 DataBay 2014. All rights reserved.
//

#import "ESSocrataAdapter.h"

@interface ESSocrataAdapter ()

@property (strong, nonatomic) NSOperationQueue *urlConnectionOperationQueue;

@end

@implementation ESSocrataAdapter

- (instancetype)initWithURL:(NSURL *)URL {
    self = [super init];
    
    if (self != nil) {
        _URL = URL.copy;
    }
    
    return self;
}

- (void)submitReport:(ESHarmfulAlgalBloomReport *)report
     completionBlock:(ESDataAdapterCompletionBlock)completionBlock {
    time_t time = [report.timestamp timeIntervalSince1970];
    
    struct tm timeStruct;
    
    localtime_r(&time, &timeStruct);
    
    char buffer[80];
    
    strftime(buffer, 80, "%m/%d/%Y %H:%M:%S %z", &timeStruct);
    
    NSString *dateString = [NSString stringWithCString:buffer encoding:NSASCIIStringEncoding];
    
    NSDictionary *dictionary = @{@"water_color": report.waterColor,
                                 @"algae_color": report.algaeColor,
                                 @"color_in_water_column": report.colorInWaterColumn,
                                 @"latitude": report.latitude,
                                 @"longitude": report.longitude,
                                 @"timestamp": dateString};
    
    NSData *imageData = UIImageJPEGRepresentation(report.image, 1.0);
    
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST"
                                                                                              URLString:self.URL.absoluteString
                                                                                             parameters:dictionary
                                                                              constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                                                                                  if (imageData != nil) {
                                                                                      [formData appendPartWithFileData:imageData
                                                                                                                  name:@"image"
                                                                                                              fileName:@"image.jpg"
                                                                                                              mimeType:@"image/jpeg"];
                                                                                  }
                                                                              }
                                                                                                  error:nil];
    
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    manager.responseSerializer = [AFHTTPResponseSerializer new];
    NSProgress *progress = nil;
    
    NSURLSessionUploadTask *uploadTask = [manager uploadTaskWithStreamedRequest:request
                                                                       progress:&progress
                                                              completionHandler:^(NSURLResponse *response,
                                                                                  id responseObject,
                                                                                  NSError *error) {
                                                                  if (completionBlock != NULL) {
                                                                      completionBlock(response, responseObject, error);
                                                                  }
                                                              }];
    
    [uploadTask resume];
}

@end
