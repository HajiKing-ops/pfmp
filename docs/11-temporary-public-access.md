# 11 - Temporary Public Access

This procedure is only for short local testing. It is not a production deployment.

Goal: expose only the Nginx frontend on port 80. Nginx forwards `/api` requests to the internal API container.

## Principle

```text
Internet
  |
  | WAN 80
  v
Router
  |
  | forward to PC LAN IP, port 80
  v
Local PC
  |
  v
Docker pfmp_flutter / Nginx
  |
  | /api
  v
Docker pfmp_api
  |
  v
Docker pfmp_mysql
```

Do not expose:

- MySQL;
- the API directly;
- development ports.

## Start Production-Style Docker

```bash
docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d --build
```

Check:

```bash
docker compose ps
docker logs pfmp_flutter
docker logs pfmp_api
docker logs pfmp_mysql
```

Test locally:

```text
http://localhost
```

## Find the PC LAN IP

Windows:

```powershell
ipconfig
```

Look for the IPv4 address of the active network adapter, for example:

```text
192.168.1.50
```

## Configure Router Port Forwarding

In the router/box admin interface:

```text
WAN 80 -> PC_LAN_IP port 80
```

Example:

```text
WAN 80 -> 192.168.1.50:80
```

Do not forward:

- `3306` or `3307` for MySQL;
- `5002` for the API;
- `65427` for development Flutter.

## Test from Outside the Network

1. Use a phone.
2. Turn off Wi-Fi.
3. Open the browser over mobile data.
4. Go to the public IP address:

```text
http://YOUR_PUBLIC_IP
```

5. Test login and a few protected pages.

## After the Test

Disable or delete the router port forwarding rule immediately.

Then stop the stack if needed:

```bash
docker compose -f docker-compose.yml -f docker-compose.prod.yml down
```

## CGNAT Warning

If the phone test does not work, the Internet provider may use CGNAT. In that case, the router does not have a real inbound public IP.

Possible signs:

- the router WAN IP differs from the IP shown by a "what is my IP" website;
- port forwarding never works.

Temporary alternatives:

- Cloudflare Tunnel;
- ngrok;
- another temporary HTTPS tunnel.

## Security Warning

This mode is for testing only:

- use test accounts;
- avoid sensitive data;
- use a strong JWT secret even for demos;
- do not expose MySQL;
- do not expose the API directly;
- remove port forwarding after the test;
- use HTTPS for any real deployment.

## Temporary Public Test Checklist

- [ ] Production-style stack is running.
- [ ] `http://localhost` works on the PC.
- [ ] Only `WAN 80 -> PC LAN 80` is forwarded.
- [ ] Test was done from phone with Wi-Fi off.
- [ ] Login works.
- [ ] A protected page loads.
- [ ] `/api` works through Nginx.
- [ ] Port forwarding was removed after the test.
