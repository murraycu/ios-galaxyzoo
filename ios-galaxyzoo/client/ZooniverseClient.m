//
//  ZooniverseClient.m
//  ios-galaxyzoo
//
//  Created by Murray Cumming on 01/05/2015.
//  Copyright (c) 2015 Murray Cumming. All rights reserved.
//

#import "ZooniverseClient.h"
#import "ZooniverseRkSubject.h"
#import <RestKit/RestKit.h>

static NSString * BASE_URL = @"https://api.zooniverse.org/projects/galaxy_zoo/";
static NSString * QUERY_PATH = @"groups/50251c3b516bcb6ecb000002/subjects";


@interface ZooniverseClient () {
    RKObjectManager * _objectManager;
}
@end

@implementation ZooniverseClient

- (ZooniverseClient *) init {

    self = [super init];

    RKLogConfigureByName("RestKit/Network*", RKLogLevelTrace);
    RKLogConfigureByName("RestKit/ObjectMapping", RKLogLevelTrace);
    
    //let AFNetworking manage the activity indicator
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    
    // Initialize HTTPClient
    NSURL *baseURL = [NSURL URLWithString:BASE_URL];
    AFHTTPClient* client = [[AFHTTPClient alloc] initWithBaseURL:baseURL];
    
    // TODO: Set User-Agent
    
    //we want to work with JSON-Data
    [client setDefaultHeader:@"Accept" value:RKMIMETypeJSON];
    
    // Initialize RestKit
    _objectManager = [[RKObjectManager alloc] initWithHTTPClient:client];
    
    return self;
}

- (void)querySubjects
{
    RKObjectMapping *subjectMapping = [RKObjectMapping mappingForClass:[ZooniverseRkSubject class]];
    [subjectMapping addAttributeMappingsFromDictionary:@{
                                                         @"id":   @"subjectId",
                                                         @"zooniverse_id":   @"zooniverseId",
                                                         @"group_id":     @"groupId",
                                                         @"location.standard":   @"locationStandard",
                                                         @"location.inverted":   @"locationInverted",
                                                         @"location.thumbnail":   @"locationThumbnail",
                                                  }];
    
    // Register our mappings with the provider using a response descriptor
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:subjectMapping
                                                                                            method:RKRequestMethodGET
                                                                                       pathPattern:QUERY_PATH
                                                                                           keyPath:nil
                                                                                       statusCodes:[NSIndexSet indexSetWithIndex:200]];
    [_objectManager addResponseDescriptor:responseDescriptor];
    
    NSDictionary *queryParams = @{@"limit" : @"5"};
    
    [_objectManager getObjectsAtPath:QUERY_PATH
                         parameters:queryParams
                            success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                NSArray* subjects = [mappingResult array];
                                NSLog(@"Loaded subjects: %@", subjects);
                                _subjects = subjects;
                                
                                for (ZooniverseRkSubject *subject in subjects) {
                                        NSLog(@"  debug: subject zooniverseId: %@", [subject zooniverseId]);
                                    }
                                /*
                                if(self.isViewLoaded)
                                    [_tableView reloadData];
                                 */
                            }
                            failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                                message:[error localizedDescription]
                                                                               delegate:nil
                                                                      cancelButtonTitle:@"OK"
                                                                      otherButtonTitles:nil];
                                [alert show];
                                NSLog(@"Hit error: %@", error);
                            }];
}

@end
