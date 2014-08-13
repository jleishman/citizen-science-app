//
//  ESSocrataAdapter.m
//  EcoSleuth
//
//  Created by Justin Leishman on 8/12/14.
//  Copyright (c) 2014 DataBay 2014. All rights reserved.
//

#import "ESSocrataAdapter.h"

static NSString * const HABHarmfulAlgalBloomSocrataData = @"Socrata Credentials";

static NSString * const HABSocrataURLKey = @"URL";

static NSString * const HABSocrataUsernameKey = @"Username";

static NSString * const HABSocrataPasswordKey = @"Password";

static NSString * const HABSocrataAppTokenKey = @"App Token";

@interface ESSocrataAdapter ()

@property (strong, nonatomic) NSOperationQueue *urlConnectionOperationQueue;

@end

@implementation ESSocrataAdapter

- (void)submitReport:(ESHarmfulAlgalBloomReport *)report
     completionBlock:(ESDataAdapterCompletionBlock)completionBlock {
    NSDictionary *dictionary = @{@"water_color" : report.waterColor,
                                 @"algae_color" : report.algaeColor,
                                 @"color_in_water_column" : report.colorInWaterColumn,
                                 @"lat" : report.latitude,
                                 @"long" : report.longitude};
    
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
                NSError *error = nil;
                
                if (httpURLResponse.statusCode != 200) {
                    error = nil;
                }
                else {
                }
                
                if (completionBlock != NULL) {
                    completionBlock(error);
                }
            }];
        }
    };
    
    self.urlConnectionOperationQueue = [NSOperationQueue new];
    
    [NSURLConnection sendAsynchronousRequest:urlRequest
                                       queue:self.urlConnectionOperationQueue
                           completionHandler:handler];
}

@end
