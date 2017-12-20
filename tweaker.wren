class MyTweak {
    construct new()
    tweak(name, ext, text) {
        if(name == "ef0953d4112bbb36" && ext == "5438de50d62a13f2") {
            Logger.log("Loading %(name).%(ext): %(text)")
            return IO.read("mods/BigLobby3-master/biglobby_network_settings.xml")
        }
    }
}

TweakRegistry.RegisterTweaker(MyTweak.new())
