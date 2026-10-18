# Tailcat for Kindle (KUAL)


<img src="./files/kindle_tailcat_kual_header.webp">


No account. No plan. Just plain tailscale data plane without the management overhead. 

<br>
<br>



# Prerequisites:

0. The [minimum kernel version reqirement](https://go.dev/wiki/MinimumRequirements) for [Go](https://go.dev/) (and hence [tailscale](https://github.com/tailscale/tailscale)) is `2.6.32`. You should check your kernel version via `uname -r` before proceeding.
1. Jailbroken Kindle ([see](https://kindlemodding.gitbook.io/kindlemodding)) running 32-bit ARMv7 (qrencode uses armel binaries) 
2. [KUAL](https://wiki.mobileread.com/wiki/KUAL) installed. ([see](https://kindlemodding.gitbook.io/kindlemodding/post-jailbreak/installing-kual-mrpi))

<br>

# Quickstart:

### 1. Download this repository and unzip it.

<br>

###  2. Place the **`tailcat`** (not the whole tailcat_kual) folder into the `extensions` folder on your kindle.

<br>

###  3. In the KUAL menu, tap **`[ Install / Update Tailcat ]`** . This will download tailcat and qrencode binaries (Wi-Fi connection necessary). 

<br>

###  4. Still in KUAL menu, tap **`[ Generate Default Key ]`**

>>  This creates a persistent tailcat address. This ensures a reusable tailcat address across **restarts and reboots**.

<br>

###  5. Show QR Code

>>  The address is printed to the screen as well as a QR code.
>>  it looks like **tcomFwWCCcjS5..._dKdnDRYQ8uNGF**. Scan it with your phone and use it on any device running tailcat.

<br><br>


# Usage Modes:

##  [ Start Tailcat ]  Tailcat file listener mode (SFTP drop box) 

```bash
tailcat ping tcomFwWCCcjS5..._dKdnDRYQ8uNGF # should respond with pong 
tailcat cp tailcat_test.epub tcomFwWCCcjS5..._dKdnDRYQ8uNGF: # keep the : 
```

Incoming files are stored  within ```/mnt/us/extensions/tailcat/inbox``` by default. You can change this by `[ Receive folder ]` 

> [!TIP]
> As an alternative to the CLI `tailcat` - You can upload file on https://tailscale.github.io/tailcat/  **on any web browser**  that supports WebRTC. 


<br><br>


##  [ Start Insecure SSH ] Tailcat ssh mode

This spawn an encrypted tunnel which can establish a ssh connection by providing the tailcat address. Start Insecure SSH is basically ``tailcat serve no-auth-ssh``. The tailcat address is the sole identifier to access (root) of the kindle. ***Anyone*** with the tailcat adress has access to it. 

This allows a seemless ssh tunnel from another device to the kindle without any setup 
```bash
tailcat ssh <KINDLE_TAILCAT_ADDRESS> 
```

<br><br>



##  [ Stop Tailcat ]

It does exactly what it says. 


<br><br>

# Final Notes

- **Insecure SSH Warning**: The "Start Insecure SSH" mode opens an SSH server on your Kindle **without requiring a password or SSH keys**. While this is incredibly convenient for quick file transfers or terminal access, it is inherently dangerous. **Only use this on a trusted network** and remember to tap **Stop Tailcat** when you are finished.
- **Logs**: Logs are stored in the `/mnt/us/extensions/tailcat/bin/` directory 
- **Kernel Limitations**: If your Kindle's kernel is older than `2.6.32`, the Tailcat binary will likely crash or fail to start due to missing system calls required by modern Go binaries.

- **Does it work on my kindle?**: If have no idea, this was tested on a pw2 32-bit ARMv7 (ARMel) kindle, which should support all other kindles running the ARMel port. If someone has a newer kindle, I cann add ARMhf support, just open an issue. 

Thank you mitanshu7 for providing the predecessor https://github.com/mitanshu7/tailscale_kual.


