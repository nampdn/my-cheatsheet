# Kill in used port by find its PID

Find:
```bash
[sudo] lsof -i :3000
```

Kill:
```
kill -9 <PID>
```
