//
//  DPNetworkService.m
//  DasPrototyp
//
//  Created by HongliYu on 16/5/1.
//  Copyright © 2016年 HongliYu. All rights reserved.
//

#import "DPNetworkService.h"
#import "DPUserModel.h"
#import "AFNetworking.h"

static NSString *const kRequestBaseURLHTTP = @"http://dasprototyp.com/api/";
static NSString *const kRequestBaseURLHTTPS = @"https://dasprototyp.com/api/";
static NSString *const kREQEST_REQUEST_ERROR_DOMAIN = @"DPREQEEST_ERROR_DOMAIN";

typedef NS_ENUM(NSUInteger, DPRequestErrorCode) {
  DPREQUEST_NOERROR = 0
};

@interface DPNetworkService()

@property (strong, nonatomic) AFHTTPSessionManager *sessionManager;
@property (strong, nonatomic) dispatch_queue_t netWorkQueue;

@end

@implementation DPNetworkService

- (instancetype)init {
  self = [super init];
  if (self) {
    _netWorkQueue = dispatch_queue_create("com.hongliyu.dasprototyp.networkservice", DISPATCH_QUEUE_CONCURRENT);
    NSURL *baseURL = [NSURL URLWithString:kRequestBaseURLHTTP];
    _sessionManager = [[AFHTTPSessionManager alloc]
                       initWithBaseURL:baseURL];
    _sessionManager.requestSerializer.timeoutInterval = 10.f;
    _sessionManager.requestSerializer.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
    [_sessionManager.requestSerializer setValue:@"application/json"
                             forHTTPHeaderField:@"Accept"];
    [_sessionManager.requestSerializer setValue:baseURL.absoluteString
                             forHTTPHeaderField:@"Referer"];
    _sessionManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",
                                                                 @"text/plain", @"text/javascript", @"text/json", @"text/html", nil];
    _sessionManager.securityPolicy.allowInvalidCertificates = YES;
  }
  return self;
}

- (NSInteger)loginWithUserModel:(DPUserModel *)userModel
                     completion:(resultCompletionHandler)completion {
  NSDictionary *params = @{userModel.name : @"name",
                           userModel.password : @"password"};
  NSURLSessionDataTask *sessionTask = [self.sessionManager POST:@"login/"
                                                     parameters:params
                                                       progress:^(NSProgress * _Nonnull uploadProgress) {
                                                         ;
                                                       }
                                                        success:^(NSURLSessionDataTask * _Nonnull task, id _Nullable responseObject) {
                                                          if (completion) {
                                                            completion(responseObject, nil);
                                                          }
                                                        }
                                                        failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                                                          if (completion) {
                                                            completion(nil, error);
                                                          }
                                                        }];
  return sessionTask.taskIdentifier;
}

- (void)requestAphorismsCompletion:(resultCompletionHandler)completion {
  NSURL *aphorismsURL = [NSURL URLWithString:@"http://quotesondesign.com"];
  AFHTTPSessionManager *sessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:aphorismsURL];
  [sessionManager GET:@"wp-json/posts"
           parameters:@{@"filter[orderby]": @"rand", @"filter[posts_per_page]": @"1" }
             progress:^(NSProgress * _Nonnull uploadProgress) {
               ;
             }
              success:^(NSURLSessionDataTask * _Nonnull task, id _Nullable responseObject) {
                if (completion) {
                  completion(responseObject, nil);
                }
              }
              failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                if (completion) {
                  completion(nil, error);
                }
              }];
}

@end
