# SAIFU transfer
SAIFU transfer is a safe, air-gapped file transfer for all devices

_NOTE: All scripts in this repository are only intended to be run on Ubuntu 20.04.4 LTS._

If your host machine is not running ubuntu, you can still run all the commands below inside the docker container which contains `dart`, `flutter`, `fvm` and all other essential dependencies that you might need. So no need to install anything and you are ready to go :)

### 1. Download Repository
```bash
git clone git@github.com:KiraCore/saifu-transfer.git -b "branch-name"

# optionally start docker
make docker-start
cd /saifu
# run commands 2., 3. ...
...
exit
make docker-stop
```
### 2. Build 
After successful build, you can find `index.html` in `/saifu/build/` directory
```bash
make build
```

### 3. Publish
Used to create release a self contained `zip` file
```bash
make publish
```

### Run project in the Chrome browser
```bash
# Run project in the Chrome browser
flutter run -d chrome --dart-define=FLUTTER_WEB_USE_SKIA=true
# or
flutter run -d chrome
```
### Cleanup
```bash
# cleanup docker containers, images and any other local resources
make clean
```

### Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what would like to improve. Please 
make sure to update tests as well.

### License
[GNU AGPLv3](https://choosealicense.com/licenses/agpl-3.0/)

