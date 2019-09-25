# MaterialResponsiveUiData

MaterialResponsiveUiData is a class that can be queried for breakpoints based on
the guidelines in the
[Material responsive UI guidelines](https://material.io/guidelines/layout/responsive-ui.html)

# Example usage

The code below tells you whether a given device is considered a handset or a
tablet by Material.

```dart
class DeviceTypeDetector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final deviceType = MaterialResponsiveUiData.of(context).deviceType;
    final deviceText = deviceType == MobileDeviceType.handset ?
        'handset' : 'tablet';
    return Center(
        child: Text('I\'m a $deviceText');
    );
  }
}
```
