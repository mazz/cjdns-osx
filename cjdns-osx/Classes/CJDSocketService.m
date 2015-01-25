//
//  CJDApiService.m
//  cjdns-osx
//
//  Created by maz on 2015-01-17.
//  Copyright (c) 2015 maz. All rights reserved.
//

#import "CJDSocketService.h"
#import "GCDAsyncUdpSocket.h"
#import "VOKBenkode.h"
#import <CommonCrypto/CommonDigest.h>
#import "NSData+Digest.h"
#import "DKQueue.h"

typedef NS_ENUM(NSInteger, CJDSocketServiceSendTag) {
    CJDSocketServiceSendTagConnectPing = -9999
};

typedef void (^CJDCookieCompletionBlock)(NSString *);
typedef void (^CJDPingCompletionBlock)(NSDictionary *);
typedef void(^CJDSocketServiceCompletionBlock)(NSDictionary *completion);

@interface CJDSocketService()
@property (strong, nonatomic) GCDAsyncUdpSocket *udpSocket;
@property (strong, nonatomic) dispatch_queue_t udpQueue;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) NSString *host;
@property (nonatomic) NSUInteger port;
@property (nonatomic, strong) NSOperationQueue *socketQueue;
@property (nonatomic, strong) DKQueue *cookieBlockQueue;
@property (nonatomic, strong) NSMutableArray *pagedResponseCache;
@end

@implementation CJDSocketService
{
    CJDPingCompletionBlock pingCompletionBlock;
    CJDSocketServiceCompletionBlock _adminFunctionsCompletionBlock;
    long _page;
}
- (instancetype)initWithHost:(NSString *)host port:(NSInteger)port password:(NSString *)password delegate:(id<CJDSocketServiceDelegate>)delegate
{
    if ((self = [super init]))
    {
        self.host = host;
        self.port = port;
        self.password = password;
        self.delegate = delegate;
        _udpQueue = dispatch_queue_create("me.maz.cjdns-osx.dispatch_queue", DISPATCH_QUEUE_SERIAL);
        _udpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:_udpQueue socketQueue:_udpQueue];
        [_udpSocket setIPv6Enabled:YES];

        NSError *err = nil;
        if (![_udpSocket bindToPort:0 error:&err])
        {
            NSLog(@"Error binding: %@", err);
            return nil;
        }

        [_udpSocket beginReceiving:&err];
        NSLog(@"error: %@", err);
//        *error = err;
        
        self.socketQueue = [NSOperationQueue new];
        self.socketQueue.maxConcurrentOperationCount = 1;
        
        self.cookieBlockQueue = [DKQueue new];
        
        _page = 0;
        self.pagedResponseCache = [NSMutableArray array];
//        [self sendConnectPing];
    }
    return self;
}

- (void)fetchCookie:(void(^)(NSString *cookie))completion
{
    [self.cookieBlockQueue enqueue:completion];
    [self send:@{@"q":@"cookie"}];
}

- (void)function:(NSString *)function arguments:(NSDictionary *)arguments
{
    [self fetchCookie:^(NSString *cookie)
     {
         if (self.password)
         {
             NSData *cookieIn = [cookie dataUsingEncoding:NSUTF8StringEncoding];
             NSData *passwordIn = [self.password dataUsingEncoding:NSUTF8StringEncoding];
             NSMutableData *passwordCookieIn = [NSMutableData data];
             [passwordCookieIn appendData:passwordIn];
             [passwordCookieIn appendData:cookieIn];

             NSMutableData *passwordCookieOut = [NSMutableData dataWithLength:CC_SHA256_DIGEST_LENGTH];
             CC_SHA256(passwordCookieIn.bytes, (uint32_t)passwordCookieIn.length,  passwordCookieOut.mutableBytes);
             
             NSDictionary *request = @{@"q": function,
                                       @"hash": [passwordCookieOut hexDigest],
                                       @"cookie": cookie,
                                       @"args": arguments};
             NSMutableDictionary *mutRequest = [NSMutableDictionary dictionary];

             // since `password` is not nil, we fix the request to be an auth-based request by adding an `aq` key
             [mutRequest addEntriesFromDictionary:request];
             [mutRequest addEntriesFromDictionary:[self defaultParameters]];
             [mutRequest setObject:[mutRequest objectForKey:@"q"] forKey:@"aq"];
             [mutRequest setObject:@"auth" forKey:@"q"];

             // now sha256 the entire request
             NSData *bencodedRequestIn = [VOKBenkode encode:mutRequest];
             NSMutableData *bencodedRequestOut = [NSMutableData dataWithLength:CC_SHA256_DIGEST_LENGTH];
             CC_SHA256(bencodedRequestIn.bytes, (uint32_t)bencodedRequestIn.length,  bencodedRequestOut.mutableBytes);
             [mutRequest setObject:[bencodedRequestOut hexDigest] forKey:@"hash"];
             
             [self send:mutRequest];
         }
     }];
}

- (NSDictionary *)defaultParameters
{
    return @{@"txid": CFBridgingRelease(CFUUIDCreateString(kCFAllocatorDefault, CFUUIDCreate(NULL)))};
}

- (void)fetchAdminFunctions:(void(^)(NSDictionary *response))completion
{
    _adminFunctionsCompletionBlock = completion;
    [self function:@"Admin_availableFunctions" arguments:@{@"page": @1}];
}

- (void)sendConnectPing
{
    [self.udpSocket sendData:[VOKBenkode encode:@{@"q":@"ping"}] toHost:self.host port:self.port withTimeout:-1 tag:CJDSocketServiceSendTagConnectPing];
}

- (void)send:(NSDictionary *)dictionary
{
    [self.socketQueue addOperation:[NSBlockOperation blockOperationWithBlock:^{
        NSMutableDictionary *sendDict = [NSMutableDictionary dictionary];
        
        //        [sendDict addEntriesFromDictionary:[self defaultParameters]];
        [sendDict addEntriesFromDictionary:dictionary];
        
        // if we're about to get a cookie, send `cookie` as the txid so we
        // can identify it when its received over UDP
        if ([[sendDict allValues] containsObject:@"cookie"])
        {
            [sendDict setObject:@"cookie" forKey:@"txid"];
        }
        //        NSLog(@"sendDict: %@", sendDict);
        [self.udpSocket sendData:[VOKBenkode encode:sendDict] toHost:self.host port:self.port withTimeout:-1 tag:-1];
    }]];
}

#pragma mark - GCDAsyncUdpSocketDelegate

/**
 * By design, UDP is a connectionless protocol, and connecting is not needed.
 * However, you may optionally choose to connect to a particular host for reasons
 * outlined in the documentation for the various connect methods listed above.
 *
 * This method is called if one of the connect methods are invoked, and the connection is successful.
 **/
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didConnectToAddress:(NSData *)address
{
    NSLog(@"didConnectToAddress: %@", [[NSString alloc] initWithData:address encoding:NSUTF8StringEncoding]);
}

/**
 * By design, UDP is a connectionless protocol, and connecting is not needed.
 * However, you may optionally choose to connect to a particular host for reasons
 * outlined in the documentation for the various connect methods listed above.
 *
 * This method is called if one of the connect methods are invoked, and the connection fails.
 * This may happen, for example, if a domain name is given for the host and the domain name is unable to be resolved.
 **/
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotConnect:(NSError *)error
{
    NSLog(@"didNotConnect: %@", [error description]);
}

/**
 * Called when the datagram with the given tag has been sent.
 **/
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(long)tag
{
    NSLog(@"didSendDataWithTag: %ld", tag);
    if (tag == CJDSocketServiceSendTagConnectPing)
    {
        if (self.delegate && [self.delegate respondsToSelector:@selector(connectionPingDidSucceed)])
        {
            [self.delegate connectionPingDidSucceed];
        }
    }
}

/**
 * Called if an error occurs while trying to send a datagram.
 * This could be due to a timeout, or something more serious such as the data being too large to fit in a sigle packet.
 **/
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error
{
    NSLog(@"didNotSendDataWithTag: %ld %@", tag, [error description]);
    if (tag == CJDSocketServiceSendTagConnectPing)
    {
        if (self.delegate && [self.delegate respondsToSelector:@selector(connectionPingDidFailWithError:)])
        {
            [self.delegate connectionPingDidFailWithError:error];
        }
    }
}

/**
 * Called when the socket has received the requested datagram.
 **/
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data
      fromAddress:(NSData *)address
withFilterContext:(id)filterContext
{
    //    NSLog(@"didReceiveData: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    NSDictionary *dataDict = [VOKBenkode decode:data options:0 error:nil];
    NSLog(@"dataDict: %@", dataDict);
    if ([[dataDict objectForKey:@"txid"] isEqualToString:@"cookie"])
    {
        if (!self.cookieBlockQueue.isEmpty)
        {
            void(^CJDCookieCompletionBlock)(NSString *) = [self.cookieBlockQueue dequeue];
            CJDCookieCompletionBlock([dataDict objectForKey:@"cookie"]);
        }
    }
    if ([[dataDict objectForKey:@"q"] isEqualToString:@"pong"])
    {
        if (pingCompletionBlock != nil)
        {
            pingCompletionBlock(dataDict);
        }
    }
    if ([dataDict objectForKey:@"availableFunctions"] && [dataDict objectForKey:@"more"])
    {
//        _adminFunctionsCompletionBlock(dataDict);
        [self.pagedResponseCache addObject:[dataDict objectForKey:@"availableFunctions"]];
        _page++;
        [self function:@"Admin_availableFunctions" arguments:@{@"page": [NSNumber numberWithLong:_page]}];
    }
    else if ([dataDict objectForKey:@"availableFunctions"] && ![dataDict objectForKey:@"more"])
    {
        // no more admin functions
        NSMutableDictionary *adminFunctions = [NSMutableDictionary dictionary];
        for (NSDictionary *page in self.pagedResponseCache)
        {
            [adminFunctions addEntriesFromDictionary:page];
        }
        _adminFunctionsCompletionBlock(adminFunctions);
        _page = 0;
        self.pagedResponseCache = [NSMutableArray array];
    }
}

/**
 * Called when the socket is closed.
 **/
- (void)udpSocketDidClose:(GCDAsyncUdpSocket *)sock withError:(NSError *)error
{
    NSLog(@"udpSocketDidClose: %@", [error description]);
}

@end
