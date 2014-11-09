function captureLocalizedScreenshot(name) {
  var target = UIATarget.localTarget();
  var model = target.model();
  var rect = target.rect();

  if (model.match(/iPhone/)) 
  {
    if (rect.size.height > 667) {
      model = "iPhone6Plus";
    } else if (rect.size.height == 667) {
      model = "iPhone6";
    } else if (rect.size.height == 568){
      model = "iPhone5";
    } else {
    model = "iPhone4";
    }
  } 
  else 
  {
    model = "iOS-iPad";
  }

  var orientation = "portrait";
  if (rect.size.height < rect.size.width) orientation = "landscape";

  var result = target.host().performTaskWithPathArgumentsTimeout("/usr/bin/printenv" , ["SNAPSHOT_LANGUAGE"], 5);
  var language = result.stdout.substring(0, result.stdout.length - 1);

  var parts = [language, model, orientation, name];
  target.captureScreenWithName(parts.join("-"));
}