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

typedef void (^CJDCookieCompletionBlock)(NSString *);
typedef void (^CJDPingCompletionBlock)(NSDictionary *);


@interface CJDSocketService()
@property (strong, nonatomic) GCDAsyncUdpSocket *udpSocket;
@property (strong, nonatomic) dispatch_queue_t udpQueue;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) NSString *host;
@property (nonatomic) NSUInteger port;
@end

@implementation CJDSocketService
{
    CJDCookieCompletionBlock cookieCompletionBlock;
    CJDPingCompletionBlock pingCompletionBlock;
}

- (instancetype)initWithHost:(NSString *)host port:(NSInteger)port
{
    if ((self = [super init]))
    {
        self.host = host;
        self.port = port;
        
//        static dispatch_once_t onceToken;
//        dispatch_once(&onceToken, ^{
        _udpQueue = dispatch_queue_create("me.maz.cjdns-osx.dispatch_queue", DISPATCH_QUEUE_SERIAL);
        _udpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:_udpQueue socketQueue:_udpQueue];
        [_udpSocket setIPv6Enabled:YES];

        NSError *error = nil;
        if (![_udpSocket bindToPort:0 error:&error])
        {
            NSLog(@"Error binding: %@", error);
            return nil;
        }

        [_udpSocket beginReceiving:&error];
        NSLog(@"error: %@", error);
//        });

    }
    return self;
}

- (void)fetchCookie:(void(^)(NSString *cookie))completion
{
    cookieCompletionBlock = completion;
    //    [self sendData:[]
    [self send:@{@"q":@"cookie"}];
}

- (void)ping:(void(^)(NSDictionary *response))completion
{
    pingCompletionBlock = completion;
    [self send:@{@"q":@"ping"}];
}

- (void)function:(NSString *)function arguments:(NSDictionary *)arguments
{
    [self fetchCookie:^(NSString *cookie)
     {
         if (self.password)
         {
             NSData *cookieIn = [cookie dataUsingEncoding:NSUTF8StringEncoding];
             NSData *passwordIn = [self.password dataUsingEncoding:NSUTF8StringEncoding];
             //            NSLog(@"cookieIn: %@", cookieIn);
             //            NSLog(@"passwordIn: %@", passwordIn);
             NSMutableData *passwordCookieIn = [NSMutableData data];
             [passwordCookieIn appendData:passwordIn];
             [passwordCookieIn appendData:cookieIn];
             
             NSMutableData *passwordCookieOut = [NSMutableData dataWithLength:CC_SHA256_DIGEST_LENGTH];
             CC_SHA256(passwordCookieIn.bytes, (uint32_t)passwordCookieIn.length,  passwordCookieOut.mutableBytes);
             
             //            NSLog(@"passwordCookieIn: %@", passwordCookieIn);
             //            NSLog(@"passwordCookieOut digest: %@", [passwordCookieOut hexDigest]);
             NSDictionary *request = @{@"q": function,
                                       @"hash": [passwordCookieOut hexDigest],
                                       @"cookie": cookie,
                                       @"args": @{}};
             NSMutableDictionary *mutRequest = [NSMutableDictionary dictionary];
             
             // since `password` is not nil, we fix the request to be an auth-based request by adding an `aq` key
             [mutRequest addEntriesFromDictionary:request];
             [mutRequest addEntriesFromDictionary:[self defaultParameters]];
             [mutRequest setObject:[mutRequest objectForKey:@"q"] forKey:@"aq"];
             [mutRequest setObject:@"auth" forKey:@"q"];
             //            NSLog(@"mutRequest: %@", mutRequest);
             // now sha256 the entire request
             
             NSData *bencodedRequestIn = [VOKBenkode encode:mutRequest];
             NSMutableData *bencodedRequestOut = [NSMutableData dataWithLength:CC_SHA256_DIGEST_LENGTH];
             CC_SHA256(bencodedRequestIn.bytes, (uint32_t)bencodedRequestIn.length,  bencodedRequestOut.mutableBytes);
             //            NSLog(@"bencodedRequestIn: %@", bencodedRequestIn);
             //            NSLog(@"bencodedRequestOut digest: %@", [bencodedRequestOut hexDigest]);
             [mutRequest setObject:[bencodedRequestOut hexDigest] forKey:@"hash"];
             
             //            NSLog(@"mutRequest: %@", mutRequest);
             
             [self send:mutRequest];
         }
     }];
}

- (NSDictionary *)defaultParameters
{
    return @{@"txid": CFBridgingRelease(CFUUIDCreateString(kCFAllocatorDefault, CFUUIDCreate(NULL)))};
}

- (void)send:(NSDictionary *)dictionary
{
    NSMutableDictionary *sendDict = [NSMutableDictionary dictionary];
    
    [sendDict addEntriesFromDictionary:[self defaultParameters]];
    [sendDict addEntriesFromDictionary:dictionary];
    
    // if we're about to get a cookie, send `cookie` as the txid so we
    // can identify it when its received over UDP
    if ([[sendDict allValues] containsObject:@"cookie"])
    {
        [sendDict setObject:@"cookie" forKey:@"txid"];
    }
    
    [self.udpSocket sendData:[VOKBenkode encode:sendDict] toHost:self.host port:self.port withTimeout:-1 tag:-1];
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
}

/**
 * Called if an error occurs while trying to send a datagram.
 * This could be due to a timeout, or something more serious such as the data being too large to fit in a sigle packet.
 **/
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error
{
    NSLog(@"didNotSendDataWithTag: %ld %@", tag, [error description]);
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
        if (cookieCompletionBlock != nil)
        {
            cookieCompletionBlock([dataDict objectForKey:@"cookie"]);
        }
    }
    if ([[dataDict objectForKey:@"q"] isEqualToString:@"pong"])
    {
        if (pingCompletionBlock != nil)
        {
            pingCompletionBlock(dataDict);
        }
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
