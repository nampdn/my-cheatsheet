# How to configure ssl A Plus

```
server {
    listen [::]:443 ssl http2;
    listen 443 ssl http2;
    server_name example.tv;

    ssl_certificate /etc/nginx/certs/<cert>.crt;
    ssl_certificate_key /etc/nginx/certs/<cert>.key;
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;

    ssl_protocols TLSv1.2 TLSv1.1 TLSv1;

    ssl_prefer_server_ciphers on;
    ssl_ciphers EECDH+ECDSA+AESGCM:EECDH+aRSA+AESGCM:EECDH+ECDSA+SHA512:EECDH+ECDSA+SHA384:EECDH+ECDSA+SHA256:ECDH+AESGCM:ECDH+AES256:DH+AESGCM:DH+AES256:RSA+AESGCM:!aNULL:!eNULL:!LOW:!RC4:!3DES:!MD5:!EXP:!PSK:!SRP:!DSS;
    ssl_session_cache shared:TLS:2m;

    ssl_stapling on;
    ssl_stapling_verify on;
    resolver 8.8.8.8;

    add_header Strict-Transport-Security 'max-age=31536000; includeSubDomains';

    location / {
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_pass http://example_proxy;
        proxy_read_timeout 90;
    }
}
```
