# Monitor NGINX in realtime

## To Install ngxtop on Ubuntu
Use below command to install PIP

```
apt-get install python-pip
```

And now use following to install ngxtop

```
pip install ngxtop
```

Run:

```
sudo ngxtop
```

## Check top client’s IP
It’s very handy to see who is making a large number of requests to your Nginx server.

```
ngxtop top remote_addr
```

How about displaying request only, which has 404 status code?

```
ngxtop -i 'status >= 404'
```
It’s not just real-time but also you can analyze it offline by parsing access log.

To analyze access.log, you can use:

```
ngxtop –l /path/access.log
```
Another example would be to parse the offline access.log from Apache

```
ngxtop –f common –l /path/access.log
```
There is multiple combinations you can use to filter out access.log for meaningful data. You can always refer the official GitHub project of ngxtop for more information.
