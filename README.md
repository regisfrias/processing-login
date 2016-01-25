# Simple Processing Login
A simple Processing client that sends POST requests to a server.

## Dependencies
- ControlP5: http://www.sojamo.de/libraries/controlP5/
- Some server-side login stuff, like: https://github.com/Repox/SimpleUsers (you need to change it a bit)

## Usage
- Install the ControlP5 library
- Adjust /data/config.json to reflect your environment if needed
- Ad a `<logintest>` pseudo HTML tag to your server-side code with the word `success` inside. Something like:
```php
if($login) {//normal username/password check, but make sure to return this:
  echo '<logintest>success</logintest>';
} else {
  echo '<logintest>failure</logintest>';
}
```
- Run the server
- Run the applet
