//
//  ESSocrataAdapter.m
//  EcoSleuth
//
//  Created by Justin Leishman on 8/12/14.
//  Copyright (c) 2014 DataBay 2014. All rights reserved.
//

#import "ESSocrataAdapter.h"

// Refer to https://support.socrata.com/hc/en-us/articles/202950258-What-is-a-Dataset-UID-or-a-dataset-4x4-
// for details on the domain and unique identifiers for Socrata. Note that the
// "datasets" referenced there seem to be for visualizations and web
// presentations. We're using the paths for adding data and uploading images.

static NSString * const ESSocrataBaseURLFormatString = @"https://%@";

static NSString * const ESSocrataResourcePathFormatString = @"/resource/%@.json";

static NSString * const ESSocrataFilesPathFormatString = @"/views/%@/files";

static NSString * const ESSocrataConfigurationResourceName = @"Socrata Configuration";

static NSString * const ESSocrataDomainKey = @"Domain";

static NSString * const ESSocrataDatasetUniqueIdentifierKey = @"Dataset Unique Identifier";

static NSString * const ESSocrataUsernameKey = @"Username";

static NSString * const ESSocrataPasswordKey = @"Password";

static NSString * const ESSocrataAppTokenKey = @"App Token";

static NSString * const ESSocrataFileIdentifierKey = @"file";

@interface ESSocrataAdapter ()

@property (strong, nonatomic) NSOperationQueue *urlConnectionOperationQueue;

@end

@implementation ESSocrataAdapter

+ (NSURL *)_configurationURL {
    return [[NSBundle mainBundle] URLForResource:ESSocrataConfigurationResourceName
                                   withExtension:@"plist"];
}

+ (NSDictionary *)_configuration {
    return [NSDictionary dictionaryWithContentsOfURL:[self _configurationURL]];
}

+ (NSString *)_domain {
    return [self _configuration][ESSocrataDomainKey];
}

+ (NSURL *)_baseURL {
    NSString *baseURLString = [NSString stringWithFormat:
                               ESSocrataBaseURLFormatString,
                               [self _domain]];
    
    return [NSURL URLWithString:baseURLString];
}

+ (NSString *)_datasetUniqueIdentifier {
    return [self _configuration][ESSocrataDatasetUniqueIdentifierKey];
}

+ (NSURL *)_resourceURL {
    NSString *resourcePath = [NSString stringWithFormat:
                              ESSocrataResourcePathFormatString,
                              [self _datasetUniqueIdentifier]];
    
    return [[self _baseURL] URLByAppendingPathComponent:resourcePath];
}

+ (NSURL *)_filesURL {
    NSString *filesPath = [NSString stringWithFormat:
                           ESSocrataFilesPathFormatString,
                           [self _datasetUniqueIdentifier]];
    
    return [[self _baseURL] URLByAppendingPathComponent:filesPath];
}

+ (NSString *)_username {
    return [self _configuration][ESSocrataUsernameKey];
}

+ (NSString *)_password {
    return [self _configuration][ESSocrataPasswordKey];
}

+ (NSString *)_appToken {
    return [self _configuration][ESSocrataAppTokenKey];
}

+ (NSString *)_base64EncodedAuthenticationData {
    NSString *username = [ESSocrataAdapter _username];
    
    NSString *password = [ESSocrataAdapter _password];
    
    NSString *credentialsString = [NSString stringWithFormat:@"%@:%@",
                                   username, password];
    
    NSData *authenticationData = [credentialsString dataUsingEncoding:NSASCIIStringEncoding];
    
    NSString *base64EncodedAuthenticationData = [authenticationData base64EncodedStringWithOptions:NSDataBase64Encoding76CharacterLineLength];
    
    NSString *authenticationString = [NSString stringWithFormat:@"Basic %@",
                                      base64EncodedAuthenticationData];
    
    return authenticationString;
}

+ (NSString *)_generateBoundaryString {
    return [[NSUUID UUID] UUIDString];
}

+ (void)_setAuthorizationHeaderWithRequest:(NSMutableURLRequest *)request {
    [request setValue:[ESSocrataAdapter _base64EncodedAuthenticationData]
   forHTTPHeaderField:@"Authorization"];
}

+ (void)_setAppTokenWithRequest:(NSMutableURLRequest *)request {
    [request setValue:[ESSocrataAdapter _appToken]
   forHTTPHeaderField:@"X-App-Token"];
}

+ (void)_setAppTokenAndAuthorizationWithRequest:(NSMutableURLRequest *)request {
    [self _setAppTokenWithRequest:request];
    [self _setAuthorizationHeaderWithRequest:request];
}

- (void)_uploadImage:(UIImage *)image
     completionBlock:(ESDataAdapterCompletionBlock)outerCompletionBlock {
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[ESSocrataAdapter _filesURL]];
    
    [ESSocrataAdapter _setAppTokenAndAuthorizationWithRequest:request];
    
    request.HTTPMethod = @"POST";
    
    NSData *imageData = UIImagePNGRepresentation(image);
    
    NSAssert(imageData != nil, @"Image data should not be nil.");
    
    NSString *imageType = @"image/png";
    
    NSString *boundaryString = [[NSUUID UUID] UUIDString];
    
    NSAssert(boundaryString, @"Boundary string should not be nil.");
    
    NSString *bodyPrefixString = [NSString stringWithFormat:
                                  @// empty preamble
                                  "\r\n"
                                  "--%@\r\n"
                                  "Content-Disposition: form-data; name=\"upload\"; filename=\"%@\"\r\n"
                                  "Content-Type: %@\r\n"
                                  "\r\n",
                                  boundaryString,
                                  @"image",
                                  imageType];
    
    NSData *bodyPrefixData = [bodyPrefixString dataUsingEncoding:NSASCIIStringEncoding];
    
    NSAssert(bodyPrefixData != nil, @"Body prefix data should not be nil.");
    
    NSString *bodySuffixString = [NSString stringWithFormat:
                                  @"\r\n"
                                  "--%@\r\n"
                                  "Content-Disposition: form-data; name=\"uploadButton\"\r\n"
                                  "\r\n"
                                  "Upload File\r\n"
                                  "--%@--\r\n"
                                  "\r\n",
                                  //empty epilogue
                                  boundaryString,
                                  boundaryString];
    
    NSData *bodySuffixData = [bodySuffixString dataUsingEncoding:NSASCIIStringEncoding];
    
    NSAssert(bodySuffixData != nil, @"Body suffix data should not be nil.");
    
    NSString *contentTypeString = [NSString stringWithFormat:
                                   @"multipart/form-data; boundary=\"%@\"",
                                   boundaryString];
    
    [request setValue:contentTypeString forHTTPHeaderField:@"Content-Type"];
    
    NSMutableData *bodyData = [NSMutableData dataWithData:bodyPrefixData];
    [bodyData appendData:imageData];
    [bodyData appendData:bodySuffixData];
    
    NSAssert(bodyData != nil, @"Body data should not be nil.");
    
    request.HTTPBody = bodyData;
    
    NSString *contentLengthString = [NSString stringWithFormat:@"%@",
                                     @(bodyData.length)];
    
    [request setValue:contentLengthString
   forHTTPHeaderField:@"Content-Length"];

    ESDataAdapterCompletionBlock innerCompletionBlock = ^(NSURLResponse *response,
                                                          NSData *data,
                                                          NSError *error) {
        NSAssert(error == nil, @"Error should be nil.");
        
        if (outerCompletionBlock != NULL) {
            outerCompletionBlock(response, data, error);
        }
    };
    
    [self _sendAsynchronousRequest:request
                   completionBlock:innerCompletionBlock];
}

- (void)_sendAsynchronousRequest:(NSURLRequest *)request
                 completionBlock:(ESDataAdapterCompletionBlock)completionBlock {
    self.urlConnectionOperationQueue = [NSOperationQueue new];
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:self.urlConnectionOperationQueue
                           completionHandler:completionBlock];
}

- (void)submitReport:(ESHarmfulAlgalBloomReport *)report
     completionBlock:(ESDataAdapterCompletionBlock)completionBlock {
    [self _uploadImage:report.image
       completionBlock:^(NSURLResponse *response,
                         NSData *responseData,
                         NSError *imageUploadError) {
           NSAssert(imageUploadError == nil, @"Image upload error should be nil.");
           
           NSError *jsonDeserializationError = nil;
           
           NSDictionary *imageInformation = [NSJSONSerialization JSONObjectWithData:responseData
                                                                            options:0
                                                                              error:&jsonDeserializationError];
           
           NSAssert(jsonDeserializationError == nil, @"JSON deserialization error should be nil.");
           
           NSString *fileIdentifier = imageInformation[ESSocrataFileIdentifierKey];
           
           NSDictionary *dictionary = @{@"water_color": report.waterColor,
                                        @"algae_color": report.algaeColor,
                                        @"color_in_water_column": report.colorInWaterColumn,
                                        @"latitude": report.latitude,
                                        @"longitude": report.longitude,
                                        @"image": fileIdentifier};
           
           NSError *jsonSerializationError = nil;
           
           NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary
                                                              options:0
                                                                error:&jsonSerializationError];
           
           NSAssert(jsonData != nil, @"JSON data should not be nil.");
           
           NSAssert(jsonSerializationError == nil, @"JSON error should be nil.");

           NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[ESSocrataAdapter _resourceURL]];
           request.HTTPMethod = @"POST";
           request.HTTPBody = jsonData;
           
           [request setValue:@"application/json"
          forHTTPHeaderField:@"Content-type"];
           
           [ESSocrataAdapter _setAppTokenAndAuthorizationWithRequest:request];
           
           [self _sendAsynchronousRequest:request
                          completionBlock:completionBlock];
       }];
}

@end
