//
//  AppDelegate.m
//  PhotoEffects
//
//  Created by Bennett Smith on 1/28/12.
//  Copyright (c) 2012 iDevelopSoftware, Inc. All rights reserved.
//

#import "AppDelegate.h"
#import <QuartzCore/QuartzCore.h>
#import <Quartz/Quartz.h>
#import "NSImage+JPegHelpers.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize quartzComposerView = _quartzComposerView;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
}

#undef QCVIEW_VERSION
#define CALAYER_VERSION

- (void)awakeFromNib {

    NSString *compositionFilePath = [[NSBundle mainBundle] pathForResource:@"PhotoEffects" ofType:@"qtz"];

#ifdef QCVIEW_VERSION
    [_quartzComposerView loadCompositionFromFile:compositionFilePath];
    [_quartzComposerView setValue:[NSNumber numberWithInt:0] forInputKey:@"Effect"];
    [_quartzComposerView setValue:[NSNumber numberWithBool:NO] forInputKey:@"CapturePhoto"];
    [_quartzComposerView startRendering];
#endif
    
#ifdef CALAYER_VERSION
    QCCompositionLayer *layer = [[QCCompositionLayer alloc] initWithFile:compositionFilePath];
    [layer setFrame:NSRectToCGRect([[_window contentView] frame])];
    [layer setValue:[NSNumber numberWithInt:0] forInputKey:@"Effect"];
    [layer setValue:[NSNumber numberWithBool:NO] forInputKey:@"CapturePhoto"];

#if 0
    CATextLayer *text = [CATextLayer layer];
    [text setString:@"hello World"];
    [text setFrame:NSRectToCGRect([[_window contentView] frame])];
    [layer addSublayer:text];
#endif
    
    [[_window contentView] setLayer:layer];    
    [[_window contentView] setWantsLayer:YES];
#endif
    
}

- (void)finalizeImageCapture:(id)sender {
    NSLog(@"finalizeImageCapture:");
    
#ifdef QCVIEW_VERSION
    id value = [_quartzComposerView valueForOutputKey:@"Photo"];
    NSImage *photo = (NSImage *)value;
    [photo saveAsJpegWithName:@"/tmp/capture.jpg"];
    [_quartzComposerView setValue:[NSNumber numberWithBool:NO] forInputKey:@"CapturePhoto"];
#endif
    
#ifdef CALAYER_VERSION
    QCCompositionLayer *layer = (QCCompositionLayer *)[[_window contentView] layer];
    
    // Switch the capture back off. The still image should be in the accumulator now.
    [layer setValue:[NSNumber numberWithBool:NO] forInputKey:@"CapturePhoto"];
#endif
    
}

- (IBAction)captureImage:(id)sender {
  
    NSLog(@"captureImage:");
    
#ifdef QCVIEW_VERSION
    [_quartzComposerView setValue:[NSNumber numberWithBool:YES] forInputKey:@"CapturePhoto"];
    [self performSelector:@selector(finalizeImageCapture:) withObject:self afterDelay:1];
#endif
    
#ifdef CALAYER_VERSION
    QCCompositionLayer *layer = (QCCompositionLayer *)[[_window contentView] layer];
    
    // Switch the capture on, filling the image accumulator.
    [layer setValue:[NSNumber numberWithBool:YES] forInputKey:@"CapturePhoto"];

    [self performSelector:@selector(finalizeImageCapture:) withObject:self afterDelay:1];
#endif
}


- (IBAction)showSelectedFilter:(id)sender
{
    NSLog(@"showSelectedFilter:");
    
    if ([sender isKindOfClass:[NSToolbarItem class]]) {
        NSToolbarItem *item = (NSToolbarItem *)sender;
        NSInteger filterMuxNumber = [item tag];
        
#ifdef QCVIEW_VERSION
        [_quartzComposerView setValue:[NSNumber numberWithInteger:filterMuxNumber] forInputKey:@"Effect"];
#endif
        
#ifdef CALAYER_VERSION
        CALayer *layer = [[_window contentView] layer];
        if ([layer isKindOfClass:[QCCompositionLayer class]]) {
            QCCompositionLayer *compLayer = (QCCompositionLayer *)layer;
            [compLayer setValue:[NSNumber numberWithInteger:filterMuxNumber] forInputKey:@"Effect"];
        }
#endif
        
    }
}
@end
