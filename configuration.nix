{ config, pkgs, modulesPath, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      (modulesPath + "/profiles/all-hardware.nix")
    ];

  # ==========================================
  # LICENSE CONFIGURATION
  # ==========================================
  nixpkgs.config.allowUnfree = true;

  # ==========================================
  # BOOT & KERNEL TWEAKS
  # ==========================================
  # FIXED: Use explicit 6.6 kernel to avoid alias errors
  boot.kernelPackages = pkgs.linuxPackages_6_6;
  
  boot.initrd.kernelModules = [ "vmd" "nvme" "xhci_pci" "ahci" "usbhid" "sd_mod" ];

  boot.loader.systemd-boot.enable = false; # Disable the old bootloader

  boot.loader.grub = {
    enable = true;
    device = "nodev";      # "nodev" is required for EFI systems
    efiSupport = true;
    useOSProber = true;    # <--- This detects Windows automatically
  };

  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot"; 

  boot.kernelParams = [
    "nvidia-drm.modeset=1"
    "nvidia.NVreg_PreserveVideoMemoryAllocations=1"
    "nvidia.NVreg_TemporaryFilePath=/var/temp"
    "nvme_core.default_ps_max_latency_us=0"
    "pcie_aspm=off"
  ];

  # ==========================================
  # HARDWARE & POWER
  # ==========================================
  services.fstrim.enable = true;

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  # ==========================================
  # STORAGE OPTIMIZATION
  # ==========================================
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };
  nix.settings.auto-optimise-store = true;

  # ==========================================
  # NETWORKING & LOCALIZATION
  # ==========================================
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  networking.firewall = {
  enable = true;
  allowedTCPPorts = [ 8080 ];
  };


  time.timeZone = "Africa/Cairo";

  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "ar_EG.UTF-8";
    LC_IDENTIFICATION = "ar_EG.UTF-8";
    LC_MEASUREMENT = "ar_EG.UTF-8";
    LC_MONETARY = "ar_EG.UTF-8";
    LC_NAME = "ar_EG.UTF-8";
    LC_NUMERIC = "ar_EG.UTF-8";
    LC_PAPER = "ar_EG.UTF-8";
    LC_TELEPHONE = "ar_EG.UTF-8";
    LC_TIME = "ar_EG.UTF-8";
  };

  # --- KEYBOARD LAYOUT ---
  services.xserver.xkb = {
    layout = "us,ara";
    variant = ",";
    options = "grp:alt_shift_toggle";
  };

  # ==========================================
  # USER ACCOUNT
  # ==========================================
  users.users.sa7 = {
    isNormalUser = true;
    description = "SA7";
    extraGroups = [ "networkmanager" "wheel" "docker" "wireshark" "adbusers" ];
    packages = with pkgs; [];
  };

  system.stateVersion = "25.05";

  # ==========================================
  # FONTS (FIXED FOR 25.05)
  # ==========================================
  fonts.packages = with pkgs; [
    nerd-fonts.fira-code
    nerd-fonts.jetbrains-mono
  ];

  # ==========================================
  # GRAPHICS & DESKTOP ENVIRONMENT
  # ==========================================
  hardware.graphics.enable = true;

  services.xserver = {
    enable = true;
    videoDrivers = ["nvidia"];
    
    desktopManager.gnome.enable = true;
    displayManager.gdm = {
      enable = true;
      wayland = false;
    };
  };

  hardware.nvidia = {
    prime = {
      sync.enable = true;
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };
    modesetting.enable = true;
    powerManagement.enable = true;
    open = false;
    nvidiaSettings = true;
  };

  # ==========================================
  # SERVICES & PROGRAMS
  # ==========================================
  virtualisation.docker.enable = true;
 # virtualisation.vmware.host.enable = true; # <--- Added VMware Service here
  programs.wireshark.enable = true;
  programs.adb.enable = true;

  # ==========================================
  # SYSTEM PACKAGES
  # ==========================================
  environment.systemPackages = with pkgs; [
    # --- Desktop & GUI Apps ---
    discord
    vlc
    vscode
    gnome-tweaks
    kitty
    copyq
    brave
    telegram-desktop    
    android-studio
    scrcpy
    android-tools
    steam-run    
    # --- GPU Utils ---
    libva
    libva-utils
    vulkan-tools
    glxinfo
    pciutils 

    # --- Core Utilities ---
    git
    curl
    wget
    unzip
    zip
    gnupg
    file
    which
    tree
    htop
    tmux
    neovim
    vim
    jq
    ripgrep
    fd
   
    # --- Networking & Debugging ---
    tcpdump
    nmap
    netcat
    socat
    wireshark
    mitmproxy
    openssl

    # --- Web & API Testing ---
    burpsuite
    httpie

    # --- Android Pentesting ---
    apktool
    jadx 
    apksigner

    # --- Reverse Engineering ---
    ghidra
    radare2
    binwalk
    patchelf
    strace
    ltrace

    # --- Development ---
    gcc       # The GNU Compiler Collection
    gnumake   # Make
    cmake     # Cross-platform build system
    gdb       # GNU Debugger
    pkg-config
    cargo     # Rust package manager
    rustc     # Rust compiler
    rustfmt   # Rust code formatter
    rust-analyzer # IDE Support for Rust    
    python3
    python3Packages.pip
    python3Packages.virtualenv
    jdk17
    sqlite

    # --- Containerization ---
    docker
    docker-compose
  ];
}
