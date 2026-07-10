# 11 - Temporary public access

This procedure is only meant for a short test from a local PC. It is not a production deployment.

Goal: expose only the Nginx frontend on port 80, which proxies `/api` to the internal API.

## Principle

```text
Internet
  |
  | WAN 80
  v
Router / box
  |
  | forwarded to the PC's LAN IP, port 80
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
- the development ports.

## Start the production-style stack

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

## Find the PC's LAN IP

Windows:

```powershell
ipconfig
```

Look for the IPv4 address of the active network adapter, for example:

```text
192.168.1.50
```

## Configure port forwarding on the router

In the router/box admin interface:

```text
WAN 80 -> PC_LAN_IP port 80
```

Example:

```text
WAN 80 -> 192.168.1.50:80
```

Do not create a forwarding rule for:

- `3306` / `3307` MySQL;
- `5002` API;
- `65427` Flutter dev.

## Test from outside

1. Grab a phone.
2. Turn off Wi-Fi.
3. Open the browser over 4G/5G.
4. Go to the connection's public IP:

```text
http://YOUR_PUBLIC_IP
```

5. Test login and a few pages.

## After the test

Disable or delete the port forwarding rule immediately.

Then stop the stack if needed:

```bash
docker compose -f docker-compose.yml -f docker-compose.prod.yml down
```

## CGNAT

If the phone test doesn't work, the internet provider may be using CGNAT. In that case, the router does not have a real, routable public IP.

Possible signs:

- the WAN IP shown in the router differs from the IP shown by a "what is my IP" website;
- no port forwarding rule works.

Temporary alternatives:

- Cloudflare Tunnel;
- ngrok;
- another temporary HTTPS tunnel.

## Security

This mode is still just a test:

- use test accounts;
- do not use sensitive data;
- use a strong JWT secret even for a demo;
- do not expose MySQL;
- do not expose the API directly;
- remove the port forwarding rule after the test;
- move to HTTPS for any real deployment.

## Public test checklist

- [ ] Production-style stack started.
- [ ] `http://localhost` works on the PC.
- [ ] Port forwarding limited to `WAN 80 -> PC LAN 80`.
- [ ] Tested from a phone with Wi-Fi off.
- [ ] Login works.
- [ ] A protected page loads.
- [ ] `/api` works through Nginx.
- [ ] Port forwarding removed after the test.
