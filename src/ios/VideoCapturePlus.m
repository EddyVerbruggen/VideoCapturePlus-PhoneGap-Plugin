#import "VideoCapturePlus.h"
#import <UIKit/UIDevice.h>

#define kW3CMediaFormatHeight @"height"
#define kW3CMediaFormatWidth @"width"
#define kW3CMediaFormatCodecs @"codecs"
#define kW3CMediaFormatBitrate @"bitrate"
#define kW3CMediaFormatDuration @"duration"

@implementation CDVImagePickerPlus

@synthesize callbackId;

- (uint64_t)accessibilityTraits
{
    NSString* systemVersion = [[UIDevice currentDevice] systemVersion];
    
    if (([systemVersion compare:@"4.0" options:NSNumericSearch] != NSOrderedAscending)) { // this means system version is not less than 4.0
        return UIAccessibilityTraitStartsMediaSession;
    }
    
    return UIAccessibilityTraitNone;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (UIViewController*)childViewControllerForStatusBarHidden {
    return nil;
}

- (void)viewWillAppear:(BOOL)animated {
    SEL sel = NSSelectorFromString(@"setNeedsStatusBarAppearanceUpdate");
    if ([self respondsToSelector:sel]) {
        [self performSelector:sel withObject:nil afterDelay:0];
    }
    
    [super viewWillAppear:animated];
}

@end

@implementation VideoCapturePlus
@synthesize inUse, timer;

- (id)initWithWebView:(UIWebView*)theWebView
{
    self = (VideoCapturePlus*)[super initWithWebView:theWebView];
    if (self) {
        self.inUse = NO;
    }
    return self;
}

-(void)rotateOverlayIfNeeded:(UIView*) overlayView {
    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    
    float rotation = 0;
    if (deviceOrientation == UIDeviceOrientationPortraitUpsideDown) {
        rotation = M_PI;
    } else if (deviceOrientation == UIDeviceOrientationLandscapeLeft) {
        rotation = M_PI_2;
    } else if (deviceOrientation == UIDeviceOrientationLandscapeRight) {
        rotation = -M_PI_2;
    }

    if (rotation != 0) {
      CGAffineTransform transform = overlayView.transform;
      transform = CGAffineTransformRotate(transform, rotation);
      overlayView.transform = transform;
    }
}

-(void)alignOverlayDimensionsWithOrientation {
    if (portraitOverlay == nil && landscapeOverlay == nil) {
        return;
    }

    UIView* overlayView = [[UIView alloc] initWithFrame:pickerController.view.frame];

    // png transparency
    [overlayView.layer setOpaque:NO];
    overlayView.opaque = NO;

    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;

    UIImage* overlayImage;
    if (UIDeviceOrientationIsLandscape(deviceOrientation)) {
        overlayImage = landscapeOverlay;
    } else {
        overlayImage = portraitOverlay;
    }
    // may be null if no image was passed for this orientation
    if (overlayImage != nil) {
        overlayView.backgroundColor = [UIColor colorWithPatternImage:overlayImage];
        [overlayView setFrame:CGRectMake(0, 0, overlayImage.size.width, overlayImage.size.height)]; // x, y, width, height

        // regardless the orientation, these are the width and height in portrait mode
        float width = CGRectGetWidth(pickerController.view.frame);
        float height = CGRectGetHeight(pickerController.view.frame);

        if (CDV_IsIPad()) {
            if (UIDeviceOrientationIsLandscape(deviceOrientation)) {
                [overlayView setCenter:CGPointMake(height/2,width/2)];
            } else {
                [overlayView setCenter:CGPointMake(width/2,height/2)];
            }
        } else {
            // on iPad, the image rotates with the orientation, but on iPhone it doesn't - so we have to manually rotate the overlay on iPhone
            [self rotateOverlayIfNeeded:overlayView];
            [overlayView setCenter:CGPointMake(width/2,height/2)];
        }
        pickerController.cameraOverlayView = overlayView;
    }
}

- (void) orientationChanged:(NSNotification *)notification {
    [self alignOverlayDimensionsWithOrientation];
}

- (void)captureVideo:(CDVInvokedUrlCommand*)command {
    
    NSString* callbackId = command.callbackId;
    NSDictionary* options = [command.arguments objectAtIndex:0];
    
    // emit and capture changes to the deviceOrientation
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:@"UIDeviceOrientationDidChangeNotification" object:nil];

    // enable this line of code if you want to do stuff when the capture session is started
    // [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didStartRunning:) name:AVCaptureSessionDidStartRunningNotification object:nil];
    
    // TODO try this: self.timer = [NSTimer scheduledTimerWithTimeInterval:0.5f target:self selector:@selector(updateStopwatchLabel) userInfo:nil repeats:YES];
    //    timer en session.running property gebruiken?
    
    if ([options isKindOfClass:[NSNull class]]) {
        options = [NSDictionary dictionary];
    }
    
    // options could contain limit, duration, highquality, frontcamera and mode
    // taking more than one video (limit) is only supported if provide own controls via cameraOverlayView property
    NSNumber* duration  = [options objectForKey:@"duration"];
    BOOL highquality    = [[options objectForKey:@"highquality"] boolValue];
    BOOL frontcamera    = [[options objectForKey:@"frontcamera"] boolValue];
    portraitOverlay = [self getImage:[options objectForKey:@"portraitOverlay"]];
    landscapeOverlay = [self getImage:[options objectForKey:@"landscapeOverlay"]];
    NSString* overlayText  = [options objectForKey:@"overlayText"];
    NSString* mediaType = nil;

    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        // there is a camera, it is available, make sure it can do movies
        pickerController = [[CDVImagePickerPlus alloc] init];
        
        NSArray* types = nil;
        if ([UIImagePickerController respondsToSelector:@selector(availableMediaTypesForSourceType:)]) {
            types = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
            // NSLog(@"MediaTypes: %@", [types description]);
            
            if ([types containsObject:(NSString*)kUTTypeMovie]) {
                mediaType = (NSString*)kUTTypeMovie;
            } else if ([types containsObject:(NSString*)kUTTypeVideo]) {
                mediaType = (NSString*)kUTTypeVideo;
            }
        }
    }
    if (!mediaType) {
        // don't have video camera return error
        NSLog(@"Capture.captureVideo: video mode not available.");
        CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageToErrorObject:CAPTURE_NOT_SUPPORTED];
        [self.commandDelegate sendPluginResult:result callbackId:callbackId];
        pickerController = nil;
    } else {
        pickerController.delegate = self;
        
        pickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
        pickerController.allowsEditing = NO;
        // iOS 3.0
        pickerController.mediaTypes = [NSArray arrayWithObjects:mediaType, nil];
        
        if ([mediaType isEqualToString:(NSString*)kUTTypeMovie]){
            if (duration) {
                pickerController.videoMaximumDuration = [duration doubleValue];
            }
        }
        
        // iOS 4.0
        if ([pickerController respondsToSelector:@selector(cameraCaptureMode)]) {
            pickerController.cameraCaptureMode = UIImagePickerControllerCameraCaptureModeVideo;
            if (highquality) {
                pickerController.videoQuality = UIImagePickerControllerQualityTypeHigh;
            }
            if (frontcamera) {
                pickerController.cameraDevice = UIImagePickerControllerCameraDeviceFront;
            }
            
            pickerController.delegate = self;
            [self alignOverlayDimensionsWithOrientation];



			if(overlayText != nil) {
                NSUInteger txtLength = overlayText.length;
                
                CGRect labelFrame = CGRectMake(10, 40, CGRectGetWidth(pickerController.view.frame) - 20, 40 + (20*(txtLength/25)));
                
                self.overlayBox = [[UILabel alloc] initWithFrame:labelFrame];
                
                self.overlayBox.textColor = [UIColor colorWithRed:3/255.0f green:211/255.0f blue:255/255.0f alpha:1.0f];
                self.overlayBox.backgroundColor = [UIColor colorWithRed:0/255.0f green:0/255.0f blue:0/255.0f alpha:0.7f];
                self.overlayBox.font = [UIFont systemFontOfSize:16];
                self.overlayBox.lineBreakMode = NSLineBreakByWordWrapping;
                self.overlayBox.numberOfLines = 10;
                self.overlayBox.alpha = 0.90;
                self.overlayBox.textAlignment = NSTextAlignmentCenter;
                self.overlayBox.text = overlayText;
                [pickerController.view addSubview:self.overlayBox];
            }
			
            
            // trying to add a progressbar to the bottom
            /*
             CGRect progressbarLabelFrame = CGRectMake(0, 0, pickerController.cameraOverlayView.frame.size.width/2, 4);
             self.progressbarLabel = [[UILabel alloc] initWithFrame:progressbarLabelFrame];
             self.progressbarLabel.backgroundColor = [UIColor redColor];
             [pickerController.cameraOverlayView addSubview:self.progressbarLabel];
             
             self.timer = [NSTimer scheduledTimerWithTimeInterval:0.5f target:self selector:@selector(updateStopwatchLabel) userInfo:nil repeats:YES];
             */

            // TODO make this configurable via the API (but only if Android supports it)
            // pickerController.cameraFlashMode = UIImagePickerControllerCameraFlashModeAuto;
        }
        
        // CDVImagePickerPlus specific property
        pickerController.callbackId = callbackId;
        [self.viewController presentViewController:pickerController animated:YES completion:nil];
    }
}

-(UIImage*)getImage: (NSString *)imageName {
    UIImage *image = nil;
    if (imageName != (id)[NSNull null]) {
        if ([imageName rangeOfString:@"http"].location == 0) { // from the internet?
            image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imageName]]];
        } else if ([imageName rangeOfString:@"www/"].location == 0) { // www folder?
            image = [UIImage imageNamed:imageName];
        } else if ([imageName rangeOfString:@"file://"].location == 0) {
            // using file: protocol? then strip the file:// part
            image = [UIImage imageWithData:[NSData dataWithContentsOfFile:[[NSURL URLWithString:imageName] path]]];
        } else {
            // assume anywhere else, on the local filesystem
            image = [UIImage imageWithData:[NSData dataWithContentsOfFile:imageName]];
        }
    }
    return image;
}

//- (void)updateStopwatchLabel {
    // update the label with the elapsed time
    //  [self.stopwatchLabel setText:[self.timer.timeInterval]];
    //   [self.timerLabel setText:[self formatTime:self.avRecorder.currentTime]];
//}

- (CDVPluginResult*)processVideo:(NSString*)moviePath forCallbackId:(NSString*)callbackId {
    // save the movie to photo album (only avail as of iOS 3.1)
    NSDictionary* fileDict = [self getMediaDictionaryFromPath:moviePath ofType:nil];
    NSArray* fileArray = [NSArray arrayWithObject:fileDict];
    return [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:fileArray];
}

- (NSString*)getMimeTypeFromFullPath:(NSString*)fullPath {
    NSString* mimeType = nil;
    
    if (fullPath) {
        CFStringRef typeId = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)[fullPath pathExtension], NULL);
        if (typeId) {
            mimeType = (__bridge_transfer NSString*)UTTypeCopyPreferredTagWithClass(typeId, kUTTagClassMIMEType);
            if (!mimeType) {
                // special case for m4a
                if ([(__bridge NSString*)typeId rangeOfString : @"m4a-audio"].location != NSNotFound) {
                    mimeType = @"audio/mp4";
                } else if ([[fullPath pathExtension] rangeOfString:@"wav"].location != NSNotFound) {
                    mimeType = @"audio/wav";
                }
            }
            CFRelease(typeId);
        }
    }
    return mimeType;
}

- (void)getFormatData:(CDVInvokedUrlCommand*)command {
    NSString* callbackId = command.callbackId;
    // existence of fullPath checked on JS side
    NSString* fullPath = [command.arguments objectAtIndex:0];
    // mimeType could be null
    NSString* mimeType = nil;

    if ([command.arguments count] > 1) {
        mimeType = [command.arguments objectAtIndex:1];
    }
    BOOL bError = NO;
    CDVCaptureError errorCode = CAPTURE_INTERNAL_ERR;
    CDVPluginResult* result = nil;

    if (!mimeType || [mimeType isKindOfClass:[NSNull class]]) {
        // try to determine mime type if not provided
        mimeType = [self getMimeTypeFromFullPath:fullPath];
        if (!mimeType) {
            // can't do much without mimeType, return error
            bError = YES;
            errorCode = CAPTURE_INVALID_ARGUMENT;
        }
    }
    if (!bError) {
        // create and initialize return dictionary
        NSMutableDictionary* formatData = [NSMutableDictionary dictionaryWithCapacity:5];
        [formatData setObject:[NSNull null] forKey:kW3CMediaFormatCodecs];
        [formatData setObject:[NSNumber numberWithInt:0] forKey:kW3CMediaFormatBitrate];
        [formatData setObject:[NSNumber numberWithInt:0] forKey:kW3CMediaFormatHeight];
        [formatData setObject:[NSNumber numberWithInt:0] forKey:kW3CMediaFormatWidth];
        [formatData setObject:[NSNumber numberWithInt:0] forKey:kW3CMediaFormatDuration];

        if (([mimeType rangeOfString:@"video/"].location != NSNotFound) && (NSClassFromString(@"AVURLAsset") != nil)) {
            NSURL* movieURL = [NSURL fileURLWithPath:fullPath];
            AVURLAsset* movieAsset = [[AVURLAsset alloc] initWithURL:movieURL options:nil];
            CMTime duration = [movieAsset duration];
            [formatData setObject:[NSNumber numberWithFloat:CMTimeGetSeconds(duration)]  forKey:kW3CMediaFormatDuration];

            NSArray* allVideoTracks = [movieAsset tracksWithMediaType:AVMediaTypeVideo];
            if ([allVideoTracks count] > 0) {
                AVAssetTrack* track = [[movieAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
                CGSize size = [track naturalSize];

                [formatData setObject:[NSNumber numberWithFloat:size.height] forKey:kW3CMediaFormatHeight];
                [formatData setObject:[NSNumber numberWithFloat:size.width] forKey:kW3CMediaFormatWidth];
            } else {
                NSLog(@"No video tracks found for %@", fullPath);
            }
        }
        result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:formatData];
    }
    if (bError) {
        result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
    }
    if (result) {
        [self.commandDelegate sendPluginResult:result callbackId:callbackId];
    }
}

- (NSDictionary*)getMediaDictionaryFromPath:(NSString*)fullPath ofType:(NSString*)type {
    NSFileManager* fileMgr = [[NSFileManager alloc] init];
    NSMutableDictionary* fileDict = [NSMutableDictionary dictionaryWithCapacity:5];
    
    [fileDict setObject:[fullPath lastPathComponent] forKey:@"name"];
    [fileDict setObject:fullPath forKey:@"fullPath"];
    // determine type
    if (!type) {
        NSString* mimeType = [self getMimeTypeFromFullPath:fullPath];
        [fileDict setObject:(mimeType != nil ? (NSObject*)mimeType : [NSNull null]) forKey:@"type"];
    }
    NSDictionary* fileAttrs = [fileMgr attributesOfItemAtPath:fullPath error:nil];
    [fileDict setObject:[NSNumber numberWithUnsignedLongLong:[fileAttrs fileSize]] forKey:@"size"];
    NSDate* modDate = [fileAttrs fileModificationDate];
    NSNumber* msDate = [NSNumber numberWithDouble:[modDate timeIntervalSince1970] * 1000];
    [fileDict setObject:msDate forKey:@"lastModifiedDate"];
    
    return fileDict;
}

- (void)imagePickerController:(UIImagePickerController*)picker didFinishPickingImage:(UIImage*)image editingInfo:(NSDictionary*)editingInfo {
    // older api calls new one
    [self imagePickerController:picker didFinishPickingMediaWithInfo:editingInfo];
}

/* Called when movie is finished recording.
 * Calls success or error code as appropriate
 * if successful, result  contains an array (with just one entry since can only get one image unless build own camera UI) of MediaFile object representing the image
 *      name
 *      fullPath
 *      type
 *      lastModifiedDate
 *      size
 */
- (void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary*)info {
    CDVImagePickerPlus* cameraPicker = (CDVImagePickerPlus*)picker;
    NSString* callbackId = cameraPicker.callbackId;
    
    if ([picker respondsToSelector:@selector(presentingViewController)]) {
        [[picker presentingViewController] dismissViewControllerAnimated:YES completion:nil];
    } else {
        [[picker parentViewController] dismissViewControllerAnimated:YES completion:nil];
    }
    
    CDVPluginResult* result = nil;
    NSString* moviePath = [[info objectForKey:UIImagePickerControllerMediaURL] path];
    if (moviePath) {
        result = [self processVideo:moviePath forCallbackId:callbackId];
    }
    if (!result) {
        result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageToErrorObject:CAPTURE_INTERNAL_ERR];
    }
    [self.commandDelegate sendPluginResult:result callbackId:callbackId];
    pickerController = nil;
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController*)picker {
    CDVImagePickerPlus* cameraPicker = (CDVImagePickerPlus*)picker;
    NSString* callbackId = cameraPicker.callbackId;
    
    if ([picker respondsToSelector:@selector(presentingViewController)]) {
        [[picker presentingViewController] dismissViewControllerAnimated:YES completion:nil];
    } else {
        [[picker parentViewController] dismissViewControllerAnimated:YES completion:nil];
    }
    
    CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageToErrorObject:CAPTURE_NO_MEDIA_FILES];
    [self.commandDelegate sendPluginResult:result callbackId:callbackId];
    pickerController = nil;
}

@end
