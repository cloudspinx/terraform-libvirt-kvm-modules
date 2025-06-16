## Cloud images module

To streamline instance creation, we created a [cloud images management module](https://github.com/cloudspinx/terraform-libvirt-kvm-modules/tree/main/modules/os-images)

### 1. Automatic image download (Default) - using the module

- Users can specify `os_name`, and optionally a `version`.
- If `version` is not provided, the latest available version is used.
- Terraform will automatically download the required cloud image during provisioning.

Table of images populated into sub-module: `modules/os-images`:

#### Supported OS Images

If version is not specified, it will default to using the latest version for that os.

| **OS Name**       | **Version** | **Latest Version(Default choice)** |
|-------------------|------------|--------------------|
| **ubuntu**        | latest     | 24.04              |
|                   | 24.04      |                    |
|                   | 20.04      |                    |
|                   | 18.04      |                    |
|                   | 16.04      |                    |
| **rockylinux**    | latest     | 9                  |
|                   | 9          |                    |
|                   | 8          |                    |
| **almalinux**     | latest     | 9                  |
|                   | 9          |                    |
|                   | 8          |                    |
| **oraclelinux**   | latest     | 9                  |
|                   | 9          |                    |
|                   | 8          |                    |
| **centos-stream** | latest     | 9                  |
|                   | 9          |                    |
| **debian**        | latest     | 12                 |
|                   | 12         |                    |
|                   | 11         |                    |
|                   | 10         |                    |
| **fedora**        | latest     | 42                 |
|                   | 41         |                    |
| **alpine**        | latest     | 3.21               |
|                   | 3.20       |                    |
| **amazonlinux**   | latest     | 2023               |
| **opensuse**      | latest     | 15.6               |
|                   | 15.5       |                    |
| **archlinux**     | latest     | latest             |
| **freebsd**       | latest     | 14                 |
|                   | 13         |                    |

Usage example:

```bash
# Ubuntu 24.04 cloud image
os_name             = "ubuntu"
os_version          = "24.04"

# AlmaLinux 8 cloud image
os_name             = "almalinux"
os_version          = "8"

# If you just provide the os_name, then latest release is used:
os_name             = "debian"
```

#### 2. Cached Image Approach (Recommended for slow networks)

- Instead of downloading the image every time, users can pre-cache frequently used images locally.
- The module allows specifying a local path for the image, bypassing the need for downloads.
- This approach is particularly useful in development environments where instances are frequently created and destroyed. Or if bandwidth is an issue.


```bash
IMAGE_PATH="/home/os-images" # Define path to store cloud images
mkdir -p /home/os-images     # Create directory where images are cached
cd /home/os-images           # Naviage to the directory
wget <cloud-image-url>       # Download remote cloud image locally
```

To use the cached image method, simply set `custom_image_path_url` to the local path of the pre-downloaded image. If left empty, the module will revert to automatic image downloading. The default image chosen in latest Ubuntu LTS, which at the time of updating this content it's `24.04`.

The `custom_image_path_url` can also be used to specify remote custom link to a cloud image to be downloaded. See below examples.

```bash
# Example
custom_image_path_url = "file:///home/os-images/ubuntu-latest.qcow2"
```

The `custom_image_path_url` can also be used to specify custom image URL:
```bash
custom_image_path_url = "https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img"
```
