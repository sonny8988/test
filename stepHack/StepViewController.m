//
//  StepViewController.m
//  stepHack
//
//  Created by Indra Bagus Wicaksono on 11/9/14.
//  Copyright (c) 2014 Indra Bagus Wicaksono. All rights reserved.
//

#import "StepViewController.h"
#import "AAPLMotionActivityQuery.h"
#import "AAPLActivityDataManager.h"
#import <AVFoundation/AVFoundation.h>


@interface StepViewController ()
@property (weak, nonatomic) IBOutlet UILabel *counterLabel;
@property (weak, nonatomic) IBOutlet UILabel *pointLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;

@end

@implementation StepViewController{
    AAPLActivityDataManager *_activityDataManager;
    NSInteger _stepCount;
    NSInteger _pointCount;
    AVAudioPlayer *_audioPlayer;
    NSArray *_arrayOfBeats;
}

- (void)loadBeats{
    _arrayOfBeats = [NSArray arrayWithObjects:
                     //[NSNumber numberWithFloat:0.01],
                     //[NSNumber numberWithFloat:0],
                     //[NSNumber numberWithFloat:0],
                     //[NSNumber numberWithFloat:0],
                     [NSNumber numberWithFloat:1.89],
                     //[NSNumber numberWithFloat:0],
                     //[NSNumber numberWithFloat:0],
                     //[NSNumber numberWithFloat:0],
                     [NSNumber numberWithFloat:3.76],
                     //[NSNumber numberWithFloat:0],
                     //[NSNumber numberWithFloat:0],
                     //[NSNumber numberWithFloat:0],
                     [NSNumber numberWithFloat:5.66],
                     //[NSNumber numberWithFloat:0],
                     //[NSNumber numberWithFloat:0],
                     //[NSNumber numberWithFloat:0],
                     [NSNumber numberWithFloat:7.56],
                     //[NSNumber numberWithFloat:0],
                     //[NSNumber numberWithFloat:0],
                     //[NSNumber numberWithFloat:0],
                     [NSNumber numberWithFloat:9.39],
                     //[NSNumber numberWithFloat:0],
                     //[NSNumber numberWithFloat:0],
                     //[NSNumber numberWithFloat:0],
                     [NSNumber numberWithFloat:11.26],
                     //[NSNumber numberWithFloat:0],
                     //[NSNumber numberWithFloat:0],
                     //[NSNumber numberWithFloat:0],
                     [NSNumber numberWithFloat:13.13],
                     //[NSNumber numberWithFloat:0],
                     //[NSNumber numberWithFloat:0],
                     //[NSNumber numberWithFloat:0],
                     [NSNumber numberWithFloat:15.00],
                     
                     nil];
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _stepCount = 0;
    _pointCount = 0;
    [self loadBeats];
    
    //Load Audio
    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle]
                                         pathForResource:@"test-audio"
                                         ofType:@"m4a"]];
    
    NSError *error;
    _audioPlayer = [[AVAudioPlayer alloc]
                    initWithContentsOfURL:url
                    error:&error];
    if (error)
    {
        NSLog(@"Error in audioPlayer: %@",
              [error localizedDescription]);
    } else {
        [_audioPlayer prepareToPlay];
        [_audioPlayer play];
    }
    
    //Step stuff
    if([AAPLActivityDataManager checkAvailability]){
        _activityDataManager = [[AAPLActivityDataManager alloc] init];
        [_activityDataManager startStepUpdates:^(NSNumber *stepCount) {
            _stepCount = [stepCount integerValue];
            //self.counterLabel.text = [@(_stepCount) stringValue];
            [self stepTaken];
        }];
    } else {
        self.counterLabel.text = @"Error: iPhone5S or newer";
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)incrementStepAction:(id)sender {
    [self stepTaken];
}

- (void) stepTaken {
    [self incrementStepCount];
    self.counterLabel.text = [@(_stepCount) stringValue];
    
    //Get Time from music
    NSTimeInterval currentTime = [_audioPlayer currentTime];
    NSNumber* beat = [self findNearestBeat: currentTime];
    
    //Update Label
    if([beat floatValue] + 0.15 >= currentTime && [beat floatValue] - 0.15 <= currentTime  ){
        //Time Well
        if(arc4random() % 2 == 0){
            self.statusLabel.text = @"Good";
        } else {
            self.statusLabel.text = @"Perfect";
        }
        self.statusLabel.textColor = [UIColor greenColor];
        _pointCount ++;
    } else {
        //Missed Time
        self.statusLabel.text = @"";
        self.statusLabel.textColor = [UIColor redColor];
    }
    self.pointLabel.text = [NSString stringWithFormat:@"%d", (int)_pointCount];
}

- (void)incrementStepCount {
    _stepCount++;
}

- (NSNumber*) findNearestBeat:(NSTimeInterval)currentTime {
    int last = (int)[_arrayOfBeats count] - 1;
    int first = 0;
    int middle;
    float leftDistance;
    float rightDistance;
    int closestIdx = 0;
    
    while(first < last){
        middle = (first + last)/2;
        leftDistance = fabsf([(NSNumber *)_arrayOfBeats[middle] floatValue] - currentTime);
        rightDistance = fabsf([(NSNumber *)_arrayOfBeats[middle + 1] floatValue] - currentTime);
        
        if(leftDistance <= rightDistance){
            closestIdx = middle;
            last = middle;
        } else {
            closestIdx = middle + 1;
            first = middle + 1;
        }
    }
    return _arrayOfBeats[closestIdx];
    
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
