# `JBCameraView`

UIView to show the camera, take a picture, preview it, return UIImage.

Even though an `UIImagePickerController` allows a custom overlay to override the
default camera controls, it gives you no control over its camera bounds. Instead
it captures a UIImage in full camera resolution, giving you the option to edit
as a second step.

## Installation

```ruby
pod 'JBCameraView', '~> 0.1.0'
```

## Usage

### Interface Builder

* Drag a UIView into the interface and set its type to `JBCameraView`
* Set its delegate to a class that implements `JBCameraViewDelegate`
* Call `takePicture` on `JBCameraView` the UIImage on your delegate

### Code

```objc
JBCameraView *cameraView = [[JBCameraView alloc] initWithFrame:CGRect(320, 320)];
cameraView.delegate = self;

[cameraView takePicture];
```

## Support

Please open an issue on this repository.

## Authors

- James Billingham <james@jamesbillingham.com>
- Markos Charatzas <markos@qnoid.com>

## License

MIT licensed - see [LICENSE](LICENSE) file
