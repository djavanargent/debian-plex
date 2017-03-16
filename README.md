# djavanangent/debian-plex

![plex](http://the-gadgeteer.com/wp-content/uploads/2015/10/plex-logo-e1446990678679.png)

## Usage

```
docker run -d --name=plex \
--net=host \
-e VERSION=latest \
-e PUID=1001 -e PGID=1001 \
-e TZ=US/Eastern \
-v /etc/localtime:/etc/localtime:ro \
-v /docker/config/plex:/config \
-v /docker/media/tv:/data/tvshows \
-v /docker/media/movies:/data/movies \
-v /docker/media/music:/data/music \
djavanargent/debian-plex
```

## Parameters

`The parameters are split into two halves, separated by a colon, the left hand side representing the host and the right the container side. 
For example with a port -p external:internal - what this shows is the port mapping from internal to external of the container.
So -p 8080:80 would expose port 80 from inside the container to be accessible from the host's IP on port 8080
http://192.168.x.x:8080 would show you what's running INSIDE the container on port 80.`


* `--net=host` - Shares host networking with container, **required**.
* `-v /config` - Plex library location. *This can grow very large, 50gb+ is likely for a large collection.*
* `-v /data/xyz` - Media goes here. Add as many as needed e.g. `/data/movies`, `/data/tv`, etc.
* `-v /transcode` - Path for transcoding folder, *optional*.
* `-e VERSION=latest` - Set whether to update plex or not - see Setting up application section.
* `-e PGID=` for for GroupID - see below for explanation
* `-e PUID=` for for UserID - see below for explanation
* `-e TZ` - for timezone information *eg Europe/London, etc*

It is based on ubuntu xenial with s6 overlay, for shell access whilst the container is running do `docker exec -it plex /bin/bash`.

*Special note* - If you'd like to run Plex without requiring `--net=host` (`NOT recommended`) then you will need the following ports in your `docker create` command:

```
  -p 32400:32400 \
  -p 32400:32400/udp \
  -p 32469:32469 \
  -p 32469:32469/udp \
  -p 5353:5353/udp \
  -p 1900:1900/udp
```

### User / Group Identifiers

Sometimes when using data volumes (`-v` flags) permissions issues can arise between the host OS and the container. We avoid this issue by allowing you to specify the user `PUID` and group `PGID`. Ensure the data volume directory on the host is owned by the same user you specify and it will "just work" <sup>TM</sup>.

In this instance `PUID=1001` and `PGID=1001`. To find yours use `id user` as below:

```
  $ id <dockeruser>
    uid=1001(dockeruser) gid=1001(dockergroup) groups=1001(dockergroup)
```

## Setting up the application
Webui can be found at `<your-ip>:32400/web`

** Note about updates, if there is no value set for the VERSION variable, then no updates will take place.**

** For new users, no updates will take place on the first run of the container as there is no preferences file to read your token from, to update restart the Docker container after logging in through the webui**

Valid settings for VERSION are:-

`IMPORTANT NOTE:- YOU CANNOT UPDATE TO A PLEXPASS ONLY VERSION IF YOU DO NOT HAVE PLEXPASS`

+ **`latest`**: will update plex to the latest version available that you are entitled to.
+ **`public`**: will update plexpass users to the latest public version, useful for plexpass users that don't want to be on the bleeding edge but still want the latest public updates.
+ **`<specific-version>`**: will select a specific version (eg 0.9.12.4.1192-9a47d21) of plex to install, note you cannot use this to access plexpass versions if you do not have plexpass.

## Info

* Shell access whilst the container is running: `docker exec -it plex /bin/bash`
* To monitor the logs of the container in realtime: `docker logs -f plex`
* Upgrade to the latest version (see setting up application section) : `docker restart plex`
