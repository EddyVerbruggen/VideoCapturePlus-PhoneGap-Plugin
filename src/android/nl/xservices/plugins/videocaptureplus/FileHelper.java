package nl.xservices.plugins.videocaptureplus;

import android.net.Uri;
import android.webkit.MimeTypeMap;

import org.apache.cordova.CordovaInterface;

import java.util.Locale;

// TODO: Replace with CordovaResourceApi.getMimeType() post 3.1.
public class FileHelper {
  public static String getMimeTypeForExtension(String path) {
    String extension = path;
    int lastDot = extension.lastIndexOf('.');
    if (lastDot != -1) {
      extension = extension.substring(lastDot + 1);
    }
    // Convert the URI string to lower case to ensure compatibility with MimeTypeMap (see CB-2185).
    extension = extension.toLowerCase(Locale.getDefault());
    if (extension.equals("3ga")) {
      return "audio/3gpp";
    }
    return MimeTypeMap.getSingleton().getMimeTypeFromExtension(extension);
  }

  /**
   * Returns the mime type of the data specified by the given URI string.
   *
   * @param uri the URI string of the data
   * @return the mime type of the specified data
   */
  public static String getMimeType(Uri uri, CordovaInterface cordova) {
    String mimeType = null;
    if ("content".equals(uri.getScheme())) {
      mimeType = cordova.getActivity().getContentResolver().getType(uri);
    } else {
      mimeType = getMimeTypeForExtension(uri.getPath());
    }

    return mimeType;
  }
}
