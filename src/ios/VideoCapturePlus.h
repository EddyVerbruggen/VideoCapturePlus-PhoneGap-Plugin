/*
 Licensed to the Apache Software Foundation (ASF) under one
 or more contributor license agreements.  See the NOTICE file
 distributed with this work for additional information
 regarding copyright ownership.  The ASF licenses this file
 to you under the Apache License, Version 2.0 (the
 "License"); you may not use this file except in compliance
 with the License.  You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing,
 software distributed under the License is distributed on an
 "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 KIND, either express or implied.  See the License for the
 specific language governing permissions and limitations
 under the License.
 */

#import <Foundation/Foundation.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <AVFoundation/AVFoundation.h>
#import <Cordova/CDVPlugin.h>
#import "CDVFile.h"

enum CDVCaptureError {
    CAPTURE_INTERNAL_ERR = 0,
    CAPTURE_APPLICATION_BUSY = 1,
    CAPTURE_INVALID_ARGUMENT = 2,
    CAPTURE_NO_MEDIA_FILES = 3,
    CAPTURE_NOT_SUPPORTED = 20
};
typedef NSUInteger CDVCaptureError;

@interface CDVImagePicker : UIImagePickerController {
}
@property (copy)   NSString* callbackId;

@end

@interface CDVCapture : CDVPlugin <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{
    CDVImagePicker* pickerController;
    BOOL inUse;
    NSTimer* timer;
	AVCaptureSession *CaptureSession;
	AVCaptureMovieFileOutput *MovieFileOutput;
    UIImage* portraitOverlay;
    UIImage* landscapeOverlay;
}
@property BOOL inUse;
@property (nonatomic, strong) NSTimer* timer;
@property (strong, nonatomic) UILabel *stopwatchLabel;
@property (strong, nonatomic) UILabel *progressbarLabel;
- (void)captureVideo:(CDVInvokedUrlCommand*)command;
- (CDVPluginResult*)processVideo:(NSString*)moviePath forCallbackId:(NSString*)callbackId;
- (NSDictionary*)getMediaDictionaryFromPath:(NSString*)fullPath ofType:(NSString*)type;
- (void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary*)info;
- (void)imagePickerController:(UIImagePickerController*)picker didFinishPickingImage:(UIImage*)image editingInfo:(NSDictionary*)editingInfo;

@end