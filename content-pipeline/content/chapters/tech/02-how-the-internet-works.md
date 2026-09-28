---
topic: tech
position: 2
title: How the internet works
summary: Packets, IP addresses, TCP, DNS, HTTP and HTTPS, and the cables, towers and data centres that carry every message.
difficulty: 2
sources:
- Wikipedia: Internet protocol suite | https://en.wikipedia.org/wiki/Internet_protocol_suite
- Wikipedia: Domain Name System | https://en.wikipedia.org/wiki/Domain_Name_System
- Wikipedia: HTTPS | https://en.wikipedia.org/wiki/HTTPS
- Wikipedia: Submarine communications cable | https://en.wikipedia.org/wiki/Submarine_communications_cable
---
## A network of networks

The internet is not one network but tens of thousands of independent networks (internet providers, mobile operators, universities, companies) that agree to exchange traffic using common rules called **protocols**. It grew out of ARPANET, a US research network that sent its first message in 1969. On 1 January 1983 ARPANET switched to the TCP/IP protocols, which is often counted as the birth of the modern internet.

## Packets

Data does not travel as one continuous stream. It is chopped into **packets**, typically up to about 1500 bytes each. Every packet carries a header with its source and destination addresses. Packets from one message may take different routes and arrive out of order; the receiving computer puts them back together. This **packet switching** makes the network resilient: if one link fails, routers send packets another way.

## IP addresses and routing

Every device on the internet needs an **IP address**. The older IPv4 format looks like 196.44.186.10 and allows about 4.3 billion addresses, which ran out as the internet grew. **IPv6** uses 128-bit addresses such as 2001:db8::1, giving an almost unlimited supply. Home and office networks usually share one public IPv4 address using **NAT** (network address translation) on the router.

**Routers** read each packet's destination and forward it one hop closer. Between large networks, the **Border Gateway Protocol (BGP)** tells routers which networks can reach which addresses.

## TCP and UDP

**TCP** (Transmission Control Protocol) makes delivery reliable. It numbers the packets, has the receiver acknowledge them, resends anything lost and slows down when the network is congested. Web pages, email and file downloads use TCP.

**UDP** skips those guarantees for speed. Video calls, live streaming and online games often use UDP, because a late packet is useless anyway: better to drop it and keep going.

## DNS: the internet's phone book

People remember names like google.com; computers need IP addresses. The **Domain Name System** translates between them. Your phone asks a DNS resolver (usually your provider's), which asks the root servers, then the servers for .com, then Google's own servers, and caches the answer so the next lookup is instant. If DNS fails, the internet appears to be "down" even though the connection works.

## HTTP and HTTPS

The web runs on **HTTP**. Your browser sends a request such as "GET /news" and the server replies with a status code (200 OK, 404 Not Found, 500 Server Error) and the content.

**HTTPS** is HTTP inside an encrypted **TLS** connection. It does three things:

- **Encryption:** people on the same Wi-Fi or network cannot read what you send.
- **Integrity:** data cannot be changed in transit without detection.
- **Authentication:** a **certificate** proves you are talking to the real site, not an impostor.

The padlock in the browser means HTTPS is in use. It does not mean the site itself is trustworthy: scam sites can have certificates too.

![Your request is looked up in DNS, then travels as packets through routers, your ISP and undersea cables.](internet_path)

## The physical internet

The "cloud" is very physical:

- **Undersea cables** carry over 95 percent of intercontinental data. Cables such as SAT-3, WACS, EASSy and Google's Equiano connect Africa to Europe and the rest of the world; landlocked countries like Zimbabwe reach them through terrestrial fibre across neighbouring countries.
- **Fibre optic** cables carry data as pulses of light, with huge capacity over long distances.
- **Mobile networks** (4G, 5G) connect phones to towers, which connect to fibre.
- **Satellites** fill gaps. Low-orbit constellations such as Starlink orbit only a few hundred kilometres up, giving far lower delay than traditional geostationary satellites at about 36,000 km.
- **Data centres** hold thousands of servers that host websites, apps and cloud services.

## Speed and latency

**Bandwidth** is how much data per second a link can carry (for example 20 Mbit/s). **Latency** is how long a packet takes to travel (for example 40 ms). Downloads depend mostly on bandwidth; games and video calls depend on latency. Light in fibre travels at about 200,000 km/s, so distance alone adds delay: that is why content delivery networks keep copies of popular content close to users.

# Key points
- The internet is many networks exchanging packets using shared protocols (TCP/IP).
- Packets carry source and destination IP addresses; routers forward them hop by hop.
- TCP is reliable (acknowledgements, resends); UDP is faster without guarantees.
- DNS turns names into IP addresses.
- HTTPS encrypts web traffic with TLS and proves the server's identity with a certificate.
- Undersea and land fibre cables carry most traffic; latency is delay, bandwidth is capacity.

# Quiz
Q: What does DNS do?
- Encrypts web traffic
* Translates domain names into IP addresses
- Splits data into packets
- Charges for data usage
> DNS is the internet's phone book: it finds the IP address for a name like example.com.

Q: Which protocol resends lost packets to make delivery reliable?
* TCP
- UDP
- DNS
- HTML
> TCP numbers packets, waits for acknowledgements and resends anything missing.

Q: What does the padlock in a browser tell you?
- The website is safe and honest
* The connection is encrypted with HTTPS
- The website is run by the government
- The page has no advertising
> HTTPS protects the connection. Scam sites can still use HTTPS, so the padlock is not a promise of honesty.

Q: Why do video calls often use UDP instead of TCP?
- UDP is more secure
* A late packet is useless in real time, so speed matters more than resending
- TCP cannot carry video
- UDP uses less electricity
> Waiting to resend a lost packet would freeze the call; skipping it keeps the conversation flowing.

Q: What carries most intercontinental internet traffic?
- Satellites
* Undersea fibre optic cables
- Radio towers
- Copper telephone wires
> Well over 95% of international data travels through undersea cables.
