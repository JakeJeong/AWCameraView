# `JBCameraView`

UIView to show the camera, take a picture, preview it, return UIImage.

Even though an `UIImagePickerController` allows a custom overlay to override the
default camera controls, it gives you no control over its camera bounds. Instead
it captures a UIImage in full camera resolution, giving you the option to edit
as a second step.

Note: as of v0.3.0, you must specify the camera position before the camera will
activate.

## Installation

```ruby
pod 'JBCameraView'
```

## Usage

### Interface Builder

* Drag a UIView into the interface and set its type to `JBCameraView`
* Set its delegate to a class that implements `JBCameraViewDelegate`
* Set the preferred camera position (will failover to the other one)
* Call `takePicture` on `JBCameraView` the UIImage on your delegate

### Code

```objc
JBCameraView *cameraView = [[JBCameraView alloc] initWithFrame:CGRect(320, 320)];
cameraView.delegate = self;
cameraView.position = JBCameraViewPositionBack;

[cameraView takePicture];
```

## Support

Please open an issue on this repository.

## Authors

- James Billingham <james@jamesbillingham.com>
- Markos Charatzas <markos@qnoid.com>

## License

MIT licensed - see [LICENSE](LICENSE) file
