# Netsh
Netsh cheatsheet


## Setup port forwarding

### Show:
`netsh interface portproxy show all`

### Add:
`netsh interface portproxy add v4tov4 listenport=<listen_port> listenaddress=<listen_ip> connectport=<connect_port> connectaddress=<connect_ip>`

### Remove:
`netsh interface portproxy delete v4tov4 listenport=<listen_port> listenaddress=<listen_ip>`
