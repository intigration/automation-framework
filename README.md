# Automated Test Framework

This automated framework is a collection of automated test-scripts for a debian system, which can
be run on LAVA or Non-Lava environment


Each test-suite has a yaml based test definition file for LAVA environment.

To run a lava based test, boot your device in lava and submit the specific
test-suite definition file.

## changelogs:

* [f721f53] linux-package: Update README and folder path
  * [639f4f6] filesystem:Add ext2 file-system support
  * [d3ef05e] filesystem:Add ext3 filesytem support
  * [3b0a7e2] general-kernal-features/smp : Add Symmetric multi processing test-cases
  * [68c2ad4] linux-packages/fuse: Invoke certain call in a subshell
  * [4cfd7cb] filesystem:Add ext4 filesystem support
  * [b5cdac8] linux-package/coreutils:replaced autoconf with autoreconf
  * [cb2d041] fileststem:Add procfs filesystem support
  * [76a5301] general-kernal-features/cgroups : Add Control Groups test cases
  * [f9a7fdd] linux-package/kmod : Added a new test-case for kmod functionalities
  * [46168bf] filesystem:Add tmpfs filesystem support
  * [b59a429] filesystem:Add devtmpfs filesystem support
  * [88d10d3] general-kernal-features/smp : Add cpu-hotplug test-cases
  * [578a8c3] filesystem:Add sysfs filesystem support
  * [d595902] filesystem:Add Readme and runner script for test run
  * [5ffccfc] general-kernal-features/hrt : Add high resolution timer(hrt) test-cases
  * [b1f03dd] ext4: Move unmount_check out of subshell
  * [332f564] ext2:Add CONFIG_EXT2_FS config check for ARM bsp
  * [2371100] oomkiller: Add oomkiller test-cases
  * [efbb534] IO:Add USB automated test-scripts
  * [ca8bfb5] oomkiller : Fix oom_group binary path
  * [184ce8b] gkf:Add Readme and runner script for test run
  * [d71a82e] README for automated-framework
  * [f36a6d3] cpuhotplug: Replace "-le" condition with "-lt"
  * [ba57c84] hrt: Fix background process execution related issue for LAVA
  * [1f6267b] debian: Ship kernel feature, IO and filesystem tests
  * [c37013f] hrt : Fix tu-hrt binary path
  * [a16e259] general-kernel-features/test_runner: Fix name of the general kernel feature test file
  * [1bc87e3] debian/control: Add linux-perf as dependency
  * [5dac78a] Add known tests failure list which are not supported
  * [73a8b5c] README: Fix markdown syntax issues
  * [c1a706f] Add LICENSE file
  * [ba2074d] debian: Add copyright file
  * [f35670f] ethernet: Add ethernet test-cases
  * [0215edb] debian: Specify the source format
  * [7b48a02] ethernet/README: Fix alignment of README
  * [65d99ea] IO: Make test-runner generic to IO
  * [599cb74] debian/control: Replace iperf3 with iperf
  * [71f0d69] general_kernel_features_input:Fix the script path of cgroups
  * [00aa345] Change qa suites folder name from project to artifacts
  * [36fc44a] debian: Rename package to automated-framework
