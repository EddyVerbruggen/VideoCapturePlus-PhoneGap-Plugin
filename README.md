# VideoCapturePlus PhoneGap plugin

by [Eddy Verbruggen](http://www.x-services.nl/blog)

## 0. Index

1. [Description](https://github.com/EddyVerbruggen/VideoCapturePlus-PhoneGap-Plugin#1-description)
2. [Screenshots](https://github.com/EddyVerbruggen/VideoCapturePlus-PhoneGap-Plugin#2-screenshots)
3. [Installation](https://github.com/EddyVerbruggen/VideoCapturePlus-PhoneGap-Plugin#3-installation)
	3. [Automatically (CLI / Plugman)](https://github.com/EddyVerbruggen/VideoCapturePlus-PhoneGap-Plugin#automatically-cli--plugman)
	3. [Manually](https://github.com/EddyVerbruggen/VideoCapturePlus-PhoneGap-Plugin#manually)
	3. [PhoneGap Build](https://github.com/EddyVerbruggen/VideoCapturePlus-PhoneGap-Plugin#phonegap-build)
4. [Usage](https://github.com/EddyVerbruggen/VideoCapturePlus-PhoneGap-Plugin#4-usage)
5. [Credits](https://github.com/EddyVerbruggen/VideoCapturePlus-PhoneGap-Plugin#5-credits)
6. [License](https://github.com/EddyVerbruggen/VideoCapturePlus-PhoneGap-Plugin#6-license)

## 1. Description

* This plugin offers some useful extras on top of the [default PhoneGap Video Capture capabilities](http://docs.phonegap.com/en/3.3.0/cordova_media_capture_capture.md.html#capture.captureVideo):
  * HD recording
  * Starting with the front camera
  * A custom overlay (currently iOS only)
* For PhoneGap 3.0.0 and up
* Works on the same Android and iOS versions as the [original plugin](http://docs.phonegap.com/en/3.3.0/cordova_media_capture_capture.md.html#capture.captureVideo).
* Compatible with [Cordova Plugman](https://github.com/apache/cordova-plugman).
* Pending official support at [PhoneGap Build](https://build.phonegap.com/plugins).

## 2. Screenshots

Before recording, portrait mode (the 'Please rotate' text is part of the [overlay png file](https://github.com/EddyVerbruggen/VideoCapturePlus-PhoneGap-Plugin/blob/master/demo/img/cameraoverlays/overlay-iPhone-portrait.png))
![ScreenShot](screenshots/screenshot-before-recording-portrait.png)

During recording, landscape mode
![ScreenShot](https://raw.github.com/EddyVerbruggen/VideoCapturePlus-PhoneGap-Plugin/master/screenshot-during-recording-landscape.png)

Reviewing the recording, portrait mode
![ScreenShot](https://raw.github.com/EddyVerbruggen/VideoCapturePlus-PhoneGap-Plugin/master/screenshot-reviewing-recording-landscape.png)

After recording you can extract the metadata, [see the demo folder for this example](https://github.com/EddyVerbruggen/VideoCapturePlus-PhoneGap-Plugin/tree/master/demo)
![ScreenShot](https://raw.github.com/EddyVerbruggen/VideoCapturePlus-PhoneGap-Plugin/master/screenshot-after-recording.png)

## 3. Installation

### Automatically (CLI / Plugman)
VideoCapturePlus is compatible with [Cordova Plugman](https://github.com/apache/cordova-plugman), compatible with [PhoneGap 3.0 CLI](http://docs.phonegap.com/en/3.0.0/guide_cli_index.md.html#The%20Command-line%20Interface_add_features), here's how it works with the CLI:

```
$ phonegap local plugin add https://github.com/EddyVerbruggen/VideoCapturePlus-PhoneGap-Plugin.git
```
or
```
$ cordova plugin add https://github.com/EddyVerbruggen/VideoCapturePlus-PhoneGap-Plugin.git
```
run this command afterwards:
```
$ cordova prepare
```

VideoCapturePlus.js is brought in automatically. There is no need to change or add anything in your html.

### Manually

1\. Add the following xml to your `config.xml` in the root directory of your `www` folder:
```xml
<!-- for iOS -->
<feature name="VideoCapturePlus">
  <param name="ios-package" value="VideoCapturePlus" />
</feature>
```
```xml
<!-- for Android -->
<feature name="VideoCapturePlus">
  <param name="android-package" value="nl.xservices.plugins.VideoCapturePlus" />
</feature>
```

For Android, images from the internet are only shareable with this permission added to `AndroidManifest.xml`:
```xml
<config-file target="AndroidManifest.xml" parent="/manifest">
  <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
</config-file>
```

For iOS, you'll need to add the `Social.framework` to your project.

2\. Grab a copy of VideoCapturePlus.js, add it to your project and reference it in `index.html`:
```html
<script type="text/javascript" src="js/VideoCapturePlus.js"></script>
```

3\. Download the source files for iOS and/or Android and copy them to your project.

iOS: Copy `VideoCapturePlus.h` and `VideoCapturePlus.m` to `platforms/ios/<ProjectName>/Plugins`

Android: Copy `VideoCapturePlus.java` to `platforms/android/src/nl/xservices/plugins` (create the folders)

### PhoneGap Build

VideoCapturePlus works with PhoneGap build too! Version 3.0 of this plugin is compatible with PhoneGap 3.0.0 and up.
Use an older version of this plugin if you target PhoneGap < 3.0.0.

Just add the following xml to your `config.xml` to always use the latest version of this plugin:
```xml
<gap:plugin name="nl.x-services.plugins.videocaptureplus" />
```
or to use this exact version:
```xml
<gap:plugin name="nl.x-services.plugins.videocaptureplus" version="1.0" />
```

VideoCapturePlus.js is brought in automatically. There is no need to change or add anything in your html.

## 4. Usage
You can share text, a subject (in case the user selects the email application), (any type and location of) image, and a link.
However, what exactly gets shared, depends on the application the user chooses to complete the action. A few examples:
- Mail: message, subject, image.
- Twitter: message, image, link (which is automatically shortened).
- Google+ / Hangouts: message, subject, link
- Facebook iOS: message, image, link.
- Facebook Android: sharing a message is not possible. Sharing links and images is, but a description can not be prefilled.

Here are some examples you can copy-paste to test the various combinations:
```html
<button onclick="window.plugins.socialsharing.share('Message only')">message only</button>
```


## 5. CREDITS ##

Cordova, for [the original plugin repository](https://github.com/apache/cordova-plugin-media-capture), which is the basis for this one.

## 6. License

[The MIT License (MIT)](http://www.opensource.org/licenses/mit-license.html)

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.


[![Bitdeli Badge](https://d2weczhvl823v0.cloudfront.net/EddyVerbruggen/VideoCapturePlus-PhoneGap-Plugin/trend.png)](https://bitdeli.com/free "Bitdeli Badge")