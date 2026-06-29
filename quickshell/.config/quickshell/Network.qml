import QtQuick
import Quickshell.Networking

// Current network: the connected Wi-Fi SSID, Ethernet, or disconnected.
BarText {
    text: {
        const devices = Networking.devices.values
        for (let i = 0; i < devices.length; i++) {
            const dev = devices[i]
            if (!dev.connected) {
                continue
            }

            if (dev.type === DeviceType.Wifi) {
                const nets = dev.networks.values
                for (let j = 0; j < nets.length; j++) {
                    if (nets[j].connected) {
                        return "[" + nets[j].name + "]"
                    }
                }
                return "[Wi-Fi]"
            }

            if (dev.type === DeviceType.Wired) {
                return "[Ethernet]"
            }
        }
        return "[Disconnected]"
    }
}
