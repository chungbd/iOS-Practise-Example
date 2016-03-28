//
//  ViewController.m
//  AVFoundation
//
//  Created by Chung Bui Duc on 3/27/16.
//  Copyright © 2016 Chung Bui Duc. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <MobileCoreServices/MobileCoreServices.h>
#define kPlayerRate               @"rate"

@interface ViewController ()<AVAssetResourceLoaderDelegate,NSURLConnectionDataDelegate>
@property (nonatomic, strong) NSMutableData *songData;
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerLayer *playerLayer;
@property (nonatomic, strong) NSURLConnection *connection;
@property (nonatomic, strong) NSURLSession *connectionNew;
@property (nonatomic, strong) NSHTTPURLResponse *response;
@property (nonatomic, strong) NSMutableArray *pendingRequests;
@property (weak, nonatomic) IBOutlet UIView *viewContent;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
//    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:[self songURLWithCustomScheme:@"streaming"] options:nil];
//    [asset.resourceLoader setDelegate:self queue:dispatch_get_main_queue()];
//    
//    self.pendingRequests = [NSMutableArray array];
//    
//    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:asset];
//    self.player = [[AVPlayer alloc] initWithPlayerItem:playerItem];
//    [playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:NULL];

    self.player = [[AVPlayer alloc] init];
    self.player.actionAtItemEnd = AVPlayerActionAtItemEndNone;
    self.player.volume = 1.0;
    
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    self.playerLayer.frame = CGRectMake(0, 0, 1024, 768);
//    self.playerLayer.backgroundColor = [UIColor clearColor].CGColor;
    [self.viewContent.layer addSublayer:self.playerLayer];
//    self.playerLayer.hidden = true;
    
    
//    [self.player addObserver:self
//                  forKeyPath:kPlayerRate
//                     options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
//                     context:nil];
//    
//    typeof(self) __self = self;
//    self.timerPlayer = [self.player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(1, 1)
//                                                                 queue:dispatch_get_main_queue()
//                                                            usingBlock:^(CMTime time) {
//                                                                if (__self && __self.delegate && [self.delegate respondsToSelector:@selector(videoPlayer:playingAt:)]) {
//                                                                    [__self.delegate videoPlayer:__self playingAt:CMTimeGetSeconds(time)];
//                                                                    if(CMTimeGetSeconds(time) > 0) {
//                                                                        [__self.spin stopAnimating];
//                                                                    }
//                                                                }
//                                                            }];

}
- (IBAction)btnt:(id)sender {
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:[self songURLWithCustomScheme:@"streaming"] options:nil];
    [asset.resourceLoader setDelegate:self queue:dispatch_get_main_queue()];
    
    self.pendingRequests = [NSMutableArray array];
    
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:asset];
   [self.player replaceCurrentItemWithPlayerItem:playerItem];
//    self.player = [[AVPlayer alloc] initWithPlayerItem:playerItem];
    [playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:NULL];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private Methods
- (NSURL *)songURL
{
    return [NSURL URLWithString:@"http://cdn.showroomapp.tv/videos/video_600_82f8bafabce1e42086a53ec61029c813.mp4"];
}

- (NSURL *)songURLWithCustomScheme:(NSString *)scheme
{
    NSURLComponents *components = [[NSURLComponents alloc] initWithURL:[self songURL] resolvingAgainstBaseURL:NO];
    components.scheme = scheme;
    
    return [self songURL];
}

#pragma mark - NSURLConnection delegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    self.songData = [NSMutableData data];
    self.response = (NSHTTPURLResponse *)response;
    
    [self processPendingRequests];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.songData appendData:data];
    
    [self processPendingRequests];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [self processPendingRequests];
    
    NSString *cachedFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"cached.mp4"];
    
    [self.songData writeToFile:cachedFilePath atomically:YES];
}

#pragma mark - AVURLAsset resource loading

- (void)processPendingRequests
{
    NSMutableArray *requestsCompleted = [NSMutableArray array];
    
    for (AVAssetResourceLoadingRequest *loadingRequest in self.pendingRequests)
    {
        [self fillInContentInformation:loadingRequest.contentInformationRequest];
        
        BOOL didRespondCompletely = [self respondWithDataForRequest:loadingRequest.dataRequest];
        
        if (didRespondCompletely)
        {
            [requestsCompleted addObject:loadingRequest];
            
            [loadingRequest finishLoading];
        }
    }
    
    [self.pendingRequests removeObjectsInArray:requestsCompleted];
}

- (void)fillInContentInformation:(AVAssetResourceLoadingContentInformationRequest *)contentInformationRequest
{
    if (contentInformationRequest == nil || self.response == nil)
    {
        return;
    }
    
    NSString *mimeType = [self.response MIMEType];
    CFStringRef contentType = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, (__bridge CFStringRef)(mimeType), NULL);
    
    contentInformationRequest.byteRangeAccessSupported = YES;
    contentInformationRequest.contentType = CFBridgingRelease(contentType);
    contentInformationRequest.contentLength = [self.response expectedContentLength];
}

- (BOOL)respondWithDataForRequest:(AVAssetResourceLoadingDataRequest *)dataRequest
{
    long long startOffset = dataRequest.requestedOffset;
    if (dataRequest.currentOffset != 0)
    {
        startOffset = dataRequest.currentOffset;
    }
    
    // Don't have any data at all for this request
    if (self.songData.length < startOffset)
    {
        return NO;
    }
    
    // This is the total data we have from startOffset to whatever has been downloaded so far
    NSUInteger unreadBytes = self.songData.length - (NSUInteger)startOffset;
    
    // Respond with whatever is available if we can't satisfy the request fully yet
    NSUInteger numberOfBytesToRespondWith = MIN((NSUInteger)dataRequest.requestedLength, unreadBytes);
    
    [dataRequest respondWithData:[self.songData subdataWithRange:NSMakeRange((NSUInteger)startOffset, numberOfBytesToRespondWith)]];
    
    long long endOffset = startOffset + dataRequest.requestedLength;
    BOOL didRespondFully = self.songData.length >= endOffset;
    
    return didRespondFully;
}


- (BOOL)resourceLoader:(AVAssetResourceLoader *)resourceLoader shouldWaitForLoadingOfRequestedResource:(AVAssetResourceLoadingRequest *)loadingRequest
{
    if (self.connection == nil)
    {
        NSURL *interceptedURL = [loadingRequest.request URL];
        NSURLComponents *actualURLComponents = [[NSURLComponents alloc] initWithURL:interceptedURL resolvingAgainstBaseURL:NO];
        actualURLComponents.scheme = @"http";
        
        NSURLRequest *request = [NSURLRequest requestWithURL:[actualURLComponents URL]];
        self.connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
        [self.connection setDelegateQueue:[NSOperationQueue mainQueue]];
        
        [self.connection start];
    }
    
    [self.pendingRequests addObject:loadingRequest];
    
    return YES;
}

- (void)resourceLoader:(AVAssetResourceLoader *)resourceLoader didCancelLoadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest
{
    [self.pendingRequests removeObject:loadingRequest];
}


#pragma KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (self.player.currentItem.status == AVPlayerItemStatusReadyToPlay) {
        dispatch_async(dispatch_get_main_queue(), ^{
            //_log(@"playbackBufferFull -- Play video");
            [self.player play];
            self.playerLayer.hidden = false;
            //[self.spin stopAnimating];
        });
    }
}
@end
