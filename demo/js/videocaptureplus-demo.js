"use strict";

function videoCapturePlusDemo(highquality, frontcamera, duration) {
  window.plugins.videocaptureplus.captureVideo(
      captureSuccess,
      captureError,
      {
        limit: 1,
        duration: duration,
        highquality: highquality,
        frontcamera: frontcamera,
        // you'll want to sniff the useragent/device and pass the best overlay based on that.. assuming iphone here
        portraitOverlay: 'www/img/cameraoverlays/overlay-iPhone-portrait.png',
        landscapeOverlay: 'www/img/cameraoverlays/overlay-iPhone-landscape.png'
      }
  );
}

function captureSuccess(mediaFiles) {
  var i, len;
  for (i = 0, len = mediaFiles.length; i < len; i++) {
    var mediaFile = mediaFiles[i];
    mediaFile.getFormatData(getFormatDataSuccess, getFormatDataError);

    var vid = document.createElement('video');
    vid.id = "theVideo";
    vid.width = "240";
    vid.height = "160";
    vid.controls = "controls";
    var source_vid = document.createElement('source');
    source_vid.id = "theSource";
    source_vid.src = mediaFile.fullPath;
    vid.appendChild(source_vid);
    document.getElementById('video_container').innerHTML = '';
    document.getElementById('video_container').appendChild(vid);
    document.getElementById('video_meta_container2').innerHTML = parseInt(mediaFile.size / 1000) + 'KB ' + mediaFile.type;
  }
}

function getFormatDataSuccess(mediaFileData) {
  document.getElementById('video_meta_container').innerHTML = mediaFileData.duration + ' seconds, ' + mediaFileData.width + ' x ' + mediaFileData.height;
}

function captureError(error) {
  // code 3 = cancel by user
  alert('Returncode: ' + JSON.stringify(error.code));
}

function getFormatDataError(error) {
  alert('A Format Data Error occurred during getFormatData: ' + error.code);
}