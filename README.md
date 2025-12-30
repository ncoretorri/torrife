# Torri

Torri is a self-hostable solution to easily manage video torrent files from Hungarian torrent site nCore. It has a backend part and an Android mobile application. It is designed to work with [Kodi](https://kodi.tv/ "Kodi") but you can use any video player.

Torri is not a streaming platform. It just downloads the video files and organizes them. Then you can share the downloads or the Kodi folders through SMB and play the downloaded content on your devices.

## Installation

Just download the latest Torri-X.Y.Z.apk file from the [releases](https://github.com/ncoretorri/torrife/releases "releases") page and install it on your phone.

## Setup

When you first open the application the nCore login screen will be displayed. Enter your credentials and log in.

Then the website disappears and you will be on the Info screen. Here you have to enter the address of the [API application](https://github.com/ncoretorri/torriapi "API application") which consist of the IP address of the machine it's running on and the port of the backend. Example:

```
http://192.168.1.100:5000
```
Then press *Mentés*. After that press *Betöltés* and you should see the remaining space on your server. If you don't see that message then you misconfigured something. Check the IP and the port, and make sure the port is open on the server.

Optional: navigate to the *Beállítások* screen and increase *Maximum Half Open Connections* to 16 and press the *Mentés* button.

## Contributing

Pull requests are welcome. For major changes, please open an issue first
to discuss what you would like to change.

Please make sure to update tests as appropriate.

## License

[MIT](https://choosealicense.com/licenses/mit/)
