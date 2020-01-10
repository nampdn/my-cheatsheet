# How to use Docker with Gitlab Runner in Anka

```shell

docker run -t asafg6/gitlab-anka-runner --executor anka \
--url https://gitlab.com \
--registration-token <token> \
--ssh-user anka \
--ssh-password admin \
--anka-controller-address http://<controller-ip> \
--anka-image-id <guid-image-id> \ --anka-tag latest \
--name anka-runner

```
