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
@property (strong, nonatomic) NSString *cachedFilePath;
@property (weak, nonatomic) IBOutlet UIView *viewContent;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.cachedFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"cached.mp3"];
}

- (void)viewDidAppear:(BOOL)animated {
    self.player = [[AVPlayer alloc] init];
    self.player.actionAtItemEnd = AVPlayerActionAtItemEndNone;
    self.player.volume = 1.0;
    
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    self.playerLayer.frame = CGRectMake(0, 0, 1024, 768);
    //    self.playerLayer.backgroundColor = [UIColor clearColor].CGColor;
    [self.viewContent.layer addSublayer:self.playerLayer];
    
    
    [self touchUpInside_btn:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IB Outlet Action 
- (IBAction)touchUpInside_btn:(id)sender {
    NSURL *url = [NSURL fileURLWithPath:self.cachedFilePath];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    // If the expected store doesn't exist, copy the default store.
    if (![fileManager fileExistsAtPath:[url path]]) {
        AVURLAsset *asset = [AVURLAsset URLAssetWithURL:[self songURLWithCustomScheme:@"streaming"] options:nil];
        [asset.resourceLoader setDelegate:self queue:dispatch_get_main_queue()];
        
        self.pendingRequests = [NSMutableArray array];
        
        AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:asset];
        [self.player replaceCurrentItemWithPlayerItem:playerItem];
        //    self.player = [[AVPlayer alloc] initWithPlayerItem:playerItem];
        [playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:NULL];
    } else {
        //        AVURLAsset *asset = [AVURLAsset URLAssetWithURL:url options:nil];
        //        AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:asset];
        AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:url];
        [self.player replaceCurrentItemWithPlayerItem:playerItem];
        [playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:NULL];
    }
}


#pragma mark - Private Methods
- (NSURL *)songURL {
//    return [NSURL URLWithString:@"http://cdn.showroomapp.tv/videos/video_400_82f8bafabce1e42086a53ec61029c813.mp4"];
    return [NSURL URLWithString:@"http://mp3.zing.vn/download/song/Toi-La-Ai-Trong-Em-Doi-Thong-ERIK-ST-319/ZHJnyZmNWSaWLFByZDxyDGZm"];
}

- (NSURL *)songURLWithCustomScheme:(NSString *)scheme {
    NSURLComponents *components = [[NSURLComponents alloc] initWithURL:[self songURL] resolvingAgainstBaseURL:NO];
    components.scheme = scheme;
    
    return [components URL];
}

- (void) doSaveFileAndChangPlayLocalFile {
    NSString *cachedFilePath = self.cachedFilePath;
    
    [self.songData writeToFile:cachedFilePath atomically:YES];
    
    NSURL *filepath = [NSURL fileURLWithPath:cachedFilePath];
//    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:[NSURL URLWithString:cachedFilePath] options:nil];
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:filepath];
//    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:asset];
    
    CMTime currentTime = self.player.currentTime;
    
    [self.player.currentItem removeObserver:self forKeyPath:@"status"];
    
    [playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:NULL];
    [self.player replaceCurrentItemWithPlayerItem:playerItem];
    if (self.player.status == AVPlayerItemStatusReadyToPlay) {
        [self.player seekToTime:currentTime completionHandler:^(BOOL finished) {
            if (finished) {
                
            }
        }];
    }
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
    
    [self doSaveFileAndChangPlayLocalFile];
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


- (BOOL)resourceLoader:(AVAssetResourceLoader *)resourceLoader shouldWaitForLoadingOfRequestedResource:(AVAssetResourceLoadingRequest *)loadingRequest {
    if (self.connection == nil) {
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


#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    switch (self.player.currentItem.status) {
        case AVPlayerItemStatusFailed:
            NSLog(@"AVPlayerItemStatusFailed");
            break;
        case AVPlayerItemStatusReadyToPlay: {
            NSLog(@"AVPlayerItemStatusReadyToPlay");
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.player play];
                self.playerLayer.hidden = false;
            });
        }
            break;
        case AVPlayerItemStatusUnknown:
            NSLog(@"AVPlayerItemStatusUnknown");
            break;
        default:
            break;
    }

}
@end
