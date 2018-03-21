# Issue new certificate

## Deprecated command:
```
sudo certbot --nginx -d example.com
```

## New command:

### Webroot:
```
sudo certbot --authenticator webroot --installer nginx
```

### Non-webroot:
```
sudo certbot --authenticator standalone --installer nginx --pre-hook "service nginx stop" --post-hook "service nginx start"
```
