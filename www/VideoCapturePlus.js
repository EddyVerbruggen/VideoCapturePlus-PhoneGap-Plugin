function VideoCapturePlus() {
}

// TODO fix params (see -Dev project)
VideoCapturePlus.prototype.captureVideo = function (message, subject, image, url, successCallback, errorCallback) {
  cordova.exec(successCallback, errorCallback, "VideoCapturePlus", "captureVideo", [message, subject, image, url]);
};

VideoCapturePlus.install = function () {
  if (!window.plugins) {
    window.plugins = {};
  }

  window.plugins.videocaptureplus = new VideoCapturePlus();
  return window.plugins.videocaptureplus;
};

cordova.addConstructor(VideoCapturePlus.install);