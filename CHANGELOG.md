# Changelog

## [1.1.0](https://github.com/RanielliMontagna/dotfiles/compare/v1.0.0...v1.1.0) (2025-11-01)


### Features

* add Android sdk setup to development tools script and update .zshrc for environment variables ([bfc9d37](https://github.com/RanielliMontagna/dotfiles/commit/bfc9d378f8812c7d179d427fbb9315376712e324))
* add Bitwarden password manager installation to applications script and documentation ([f368e1f](https://github.com/RanielliMontagna/dotfiles/commit/f368e1f43692a47fd3ae8f11f31c54ddf269ca4c))
* add bun JavaScript runtime and package manager support, update configuration and documentation ([3530e5d](https://github.com/RanielliMontagna/dotfiles/commit/3530e5dbc488fd80eb72e4e43ff79ac4732f3aea))
* add gparted as a partition editor to documentation and installation scripts ([6451b56](https://github.com/RanielliMontagna/dotfiles/commit/6451b5601c341e3c4f9d0ab48890f4547077f4b5))
* add installation of Dash to Panel extension for improved GNOME desktop experience, combining dash and top panel into a single panel ([7295eb3](https://github.com/RanielliMontagna/dotfiles/commit/7295eb3415606c691d0994ea9b4322b19f003c17))
* add installation summary to bootstrap script, detailing installed tools and applications ([1cbbacb](https://github.com/RanielliMontagna/dotfiles/commit/1cbbacb8d88242b1a7777bf31ca8989f12295e68))
* add visual customization script for dark theme setup, including gtk themes, icon sets, custom fonts, and gnome terminal configuration ([7d01200](https://github.com/RanielliMontagna/dotfiles/commit/7d01200e6563d7cafd67ec25f1230d3b1fa7327e))
* add wallpaper configuration support in customization script, enabling automatic detection and setting of user wallpapers ([d3d2ebe](https://github.com/RanielliMontagna/dotfiles/commit/d3d2ebeda0df5eb0f9495ce08ae7ff459713208a))
* automate powerlevel10k configuration and update related documentation ([67968de](https://github.com/RanielliMontagna/dotfiles/commit/67968de7bdc5838a85ab6d91657ee95ec794986e))
* enhance apt package list update function with retry logic and improved error handling for better reliability ([e2de285](https://github.com/RanielliMontagna/dotfiles/commit/e2de2852a3de8edea5fc28288cce4eb2437904b3))
* enhance bootstrap script to dynamically locate dotfiles directory and verify essential scripts ([9b100ef](https://github.com/RanielliMontagna/dotfiles/commit/9b100ef148d5e83987478bcf10ba7523864b6012))
* enhance extension installation process with improved error handling, validation of download URLs, and multiple fallback options for Clipboard Indicator and Vitals extensions ([dab87e8](https://github.com/RanielliMontagna/dotfiles/commit/dab87e859ea6328e3ca63bcfbe0b184e43b52efb))
* enhance GNOME extension download functionality with improved URL retrieval methods, including multiple parsing techniques and fallback options for version detection ([157027f](https://github.com/RanielliMontagna/dotfiles/commit/157027fa6d8ef3d3f4443df328191481e3929221))
* enhance GNOME extensions management in customization script, adding support for gnome-extensions-cli, Extension Manager installation, and configuring system monitoring extensions ([e732caa](https://github.com/RanielliMontagna/dotfiles/commit/e732caa8f887b65d26b2691ce84e4db3005743ab))
* enhance installation scripts with download caching, disk space checks, and progress indicators for improved user experience ([5d24f09](https://github.com/RanielliMontagna/dotfiles/commit/5d24f097db7c9c218060408f39e012097b93f9b1))
* enhance powerlevel10k configuration with additional segments and improved visual indicators for a more informative prompt ([845005b](https://github.com/RanielliMontagna/dotfiles/commit/845005b990e09995cd31e58fc779a4ffb032532d))
* enhance project setup by adding personal Git configuration and creating project directories ([8e75c20](https://github.com/RanielliMontagna/dotfiles/commit/8e75c20f9fac3dd99a7bcb0fce44caae9186712a))
* implement common functions for improved download reliability and connectivity checks across scripts ([2b2f972](https://github.com/RanielliMontagna/dotfiles/commit/2b2f9720b74c7b3a590d24c68c61d8afadabf760))
* implement comprehensive visual customization for Zorin OS, including dark theme setup, GTK and icon themes, custom fonts, GNOME terminal configuration, and system monitoring extensions ([fadf2fc](https://github.com/RanielliMontagna/dotfiles/commit/fadf2fcb2a81e444d121b9338bebbe899d208c12))
* implement visual customization script as the first step in the installation process, including dark theme setup, custom fonts, and GNOME terminal configuration ([b9fa729](https://github.com/RanielliMontagna/dotfiles/commit/b9fa72946bb1dd593ae18f9b7d84c6f9c8bc32b1))
* improve cursor installation process with enhanced download methods and error handling ([b11153c](https://github.com/RanielliMontagna/dotfiles/commit/b11153c432a8ee37b02129c8adc10fa3624b4def))
* improve NordVPN installation script with enhanced error handling, safe download method, and user feedback for installation status ([0071e5b](https://github.com/RanielliMontagna/dotfiles/commit/0071e5b2f3795264748c8023921cb70b59e76663))
* optimize apt management by centralizing package list updates and adding architecture and checksum validation functions for improved installation reliability ([491b0f5](https://github.com/RanielliMontagna/dotfiles/commit/491b0f5ec31c3d4ae215efad8a6f2419e082f764))
* refactor docker installation script to include retry logic for GPG key download, enhanced error handling, and improved user feedback during installation process ([82b350d](https://github.com/RanielliMontagna/dotfiles/commit/82b350d2bb243879e6c4a822397d12d47d6c035f))
* refactor extras installation script to improve error handling, add fallback for missing common functions, and enhance user feedback during package installations ([7cda853](https://github.com/RanielliMontagna/dotfiles/commit/7cda8537f022cea0b970af154eb8a015a6b17198))
* streamline GNOME extension installation process with new helper functions, improved error handling, and support for multiple installation methods for Clipboard Indicator, Blur My Shell, Caffeine, and Vitals extensions ([862f481](https://github.com/RanielliMontagna/dotfiles/commit/862f481435f5ee023e4e59a5310be526769d5eb4))
* update Cursor installation method to use official API and direct download links, improving reliability and support for multiple architectures ([ff32bfc](https://github.com/RanielliMontagna/dotfiles/commit/ff32bfcfaa5d15d4df65aa178e66370c5d48cce4))
* update installation commands in customization script to use non-interactive mode for improved automation and error handling ([d4926ad](https://github.com/RanielliMontagna/dotfiles/commit/d4926adc101f9345d138f10657d3d4c4e1b7132a))
* visual customization ([bcf7ae4](https://github.com/RanielliMontagna/dotfiles/commit/bcf7ae4811124b8f8d7e95676ed8806714785735))


### Bug Fixes

* correct alias command in .zshrc to ensure accurate user guidance ([89459f3](https://github.com/RanielliMontagna/dotfiles/commit/89459f395d9e0d9824b5eb5fffbc4c02348617a5))
* improve java installation script to handle version installation errors and fallback options ([470aaf3](https://github.com/RanielliMontagna/dotfiles/commit/470aaf35bf33c814e516c5383a5d40f14ff1e965))
* improve powerlevel10k configuration loading logic and update related documentation for clarity ([a1930f8](https://github.com/RanielliMontagna/dotfiles/commit/a1930f8799550b13bf2590f179e8a380b18d2c9a))
* refine cursor installation checks to ensure accurate detection of installed status and provide user guidance ([d4a386d](https://github.com/RanielliMontagna/dotfiles/commit/d4a386d58f14d53b7fb49e19b7c56986ffad63fc))
* streamline cursor installation by enabling non-interactive mode and pre-configuring debconf to avoid prompts ([9cae4da](https://github.com/RanielliMontagna/dotfiles/commit/9cae4dadc57dfa5b3a4afdc42f6f71079b54ebf5))
* update java installation script to suppress prompts and dynamically set default java version ([b0b969b](https://github.com/RanielliMontagna/dotfiles/commit/b0b969b2d2ea9fea4c9b8cb184dc532d3b293437))

## 1.0.0 (2025-11-01)


### Features

* add application installation script and update bootstrap to include it; rename extras script and update documentation ([c803e41](https://github.com/RanielliMontagna/dotfiles/commit/c803e419b0c3e296acd5a85a2b27e3b851ae95cd))
* add bootstrap script and essential configuration files for Zorin OS dotfiles setup ([57faefa](https://github.com/RanielliMontagna/dotfiles/commit/57faefa26a9e595947ef538192f82b268936bdc7))
* add gitHub actions workflow for automated releases ([0c97018](https://github.com/RanielliMontagna/dotfiles/commit/0c970187fa270eb2aaa2dc309131f1aea160173c))
* add script for installing code editors and update documentation ([b022f1e](https://github.com/RanielliMontagna/dotfiles/commit/b022f1e593b1e19128fc3ae14c8505e3d61f7847))
* implement the first setup ([72a84b6](https://github.com/RanielliMontagna/dotfiles/commit/72a84b60efe60df3bf0bc4d70ec1e8490ac8c396))
* update bootstrap script to always install Docker, Java SDK, and development tools; add new installation scripts for Java and development tools ([8de9a5b](https://github.com/RanielliMontagna/dotfiles/commit/8de9a5b29912070d3f303d4433d9f43353a40bfd))
