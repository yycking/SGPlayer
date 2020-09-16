//
//  SGPlayViewController.m
//  demo-ios
//
//  Created by Single on 2017/3/15.
//  Copyright © 2017年 single. All rights reserved.
//

#import "SGPlayViewController.h"

@interface SGPlayViewController ()

@property (nonatomic, assign) BOOL seeking;
@property (nonatomic, strong) SGPlayer *player;

@property (weak, nonatomic) IBOutlet UILabel *stateLabel;
@property (weak, nonatomic) IBOutlet UILabel *durationLabel;
@property (weak, nonatomic) IBOutlet UILabel *currentTimeLabel;
@property (weak, nonatomic) IBOutlet UISlider *progressSilder;

@end

@implementation SGPlayViewController

- (instancetype)init
{
    if (self = [super init]) {
        self.player = [[SGPlayer alloc] init];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(infoChanged:) name:SGPlayerDidChangeInfoNotification object:self.player];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.player.videoRenderer.view = self.view;
    self.player.videoRenderer.displayMode = self.videoItem.displayMode;
    [self.player replaceWithAsset:self.videoItem.asset];
    [self.player play];
}

#pragma mark - SGPlayer Notifications

- (void)infoChanged:(NSNotification *)notification
{
    SGTimeInfo time = [SGPlayer timeInfoFromUserInfo:notification.userInfo];
    SGStateInfo state = [SGPlayer stateInfoFromUserInfo:notification.userInfo];
    SGInfoAction action = [SGPlayer infoActionFromUserInfo:notification.userInfo];
    if (action & SGInfoActionTime) {
        if (action & SGInfoActionTimePlayback && !(state.playback & SGPlaybackStateSeeking) && !self.seeking && !self.progressSilder.isTracking) {
            self.progressSilder.value = CMTimeGetSeconds(time.playback) / CMTimeGetSeconds(time.duration);
            self.currentTimeLabel.text = [self timeStringFromSeconds:CMTimeGetSeconds(time.playback)];
        }
        if (action & SGInfoActionTimeDuration) {
            self.durationLabel.text = [self timeStringFromSeconds:CMTimeGetSeconds(time.duration)];
        }
    }
    if (action & SGInfoActionState) {
        if (state.playback & SGPlaybackStateFinished) {
            self.stateLabel.text = @"Finished";
        } else if (state.playback & SGPlaybackStatePlaying) {
            self.stateLabel.text = @"Playing";
        } else {
            self.stateLabel.text = @"Paused";
        }
    }
}

#pragma mark - Actions

- (IBAction)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)play:(id)sender
{
    [self.player play];
}

- (IBAction)pause:(id)sender
{
    [self.player pause];
}

- (IBAction)progressTouchUp:(id)sender
{
    CMTime time = CMTimeMultiplyByFloat64(self.player.currentItem.duration, self.progressSilder.value);
    if (!CMTIME_IS_NUMERIC(time)) {
        time = kCMTimeZero;
    }
    self.seeking = YES;
    [self.player seekToTime:time result:^(CMTime time, NSError *error) {
        self.seeking = NO;
    }];
}

- (void)share:(NSArray *) items {
    UIActivityViewController *controller = [[UIActivityViewController alloc] initWithActivityItems:items applicationActivities:NULL];
    [self presentViewController:controller animated:YES completion:NULL];
}

- (IBAction)snapshot:(UIButton *)sender {
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"Image.png"];
    UIImage *image = [self.player.videoRenderer currentImage];
    [UIImagePNGRepresentation(image) writeToFile:path atomically:YES];
    NSURL *file = [NSURL fileURLWithPath:path];
    
    [self share:@[file]];
}

- (IBAction)recorder:(UIButton *)sender {
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"Video.mp4"];
    NSURL *file = [NSURL fileURLWithPath:path];
    
    if ([self.player isRecording]) {
        [self.player stopRecorde:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self share:@[file]];
            });
        }];
    } else {
        [self.player startRecordeMP4:file];
    }
    
    [sender setSelected:[self.player isRecording]];
}

#pragma mark - Tools

- (NSString *)timeStringFromSeconds:(CGFloat)seconds
{
    return [NSString stringWithFormat:@"%ld:%.2ld", (long)seconds / 60, (long)seconds % 60];
}

@end
