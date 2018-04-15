# How to fix sudo permission in Brew

```bash
sudo chown -R $(whoami) $(brew --prefix)/*
```
