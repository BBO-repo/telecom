# Telecoms L1 Algorithm Development Project

A project for developing and optimizing Layer 1 (Physical Layer) algorithms for telecommunications systems using GNU Octave.

## Overview

This project focuses on implementing signal processing algorithms for physical layer communication systems, including modulation, demodulation, channel estimation, equalization, and synchronization.

## Development Environment

### Setup

1. **Build the Docker container**:
   ```bash
   docker build -t telecoms-dev .
   ```

2. **Run the container** (with X11 forwarding for GUI):
   ```bash
   docker run -it --net=host \
     -e DISPLAY=$DISPLAY \
     -e QT_X11_NO_MITSHM=1 \
     -v /tmp/.X11-unix:/tmp/.X11-unix \
     --privileged \
     -v $(pwd):/workspace \
     telecoms-dev
   ```

3. **Or use VS Code Dev Containers**:
   - Open the project in VS Code
   - Use the "Reopen in Container" command
   - The `.devcontainer.json` will configure everything automatically

### Verify Installation

Inside the container, verify Octave and packages:
```octave
octave --version
pkg list
```

## Project Structure
```
├── src/                              # Source code
│   ├── algorithms/                   # Core algorithm implementations
│   │   ├── modulation/               # Modulation schemes
│   │   │   ├── bpsk_modulate.m       # BPSK modulation
│   │   │   ├── qpsk_modulate.m       # QPSK modulation
│   │   │   ├── qam_modulate.m        # QAM modulation
│   │   │   └── ofdm_modulate.m       # OFDM modulation
│   │   ├── demodulation/             # Demodulation algorithms
│   │   │   ├── bpsk_demodulate.m     # BPSK demodulation
│   │   │   ├── qpsk_demodulate.m     # QPSK demodulation
│   │   │   ├── qam_demodulate.m      # QAM demodulation
│   │   │   └── ofdm_demodulate.m     # OFDM demodulation
│   │   ├── channel/                  # Channel models and estimation
│   │   │   ├── ls_channel_est.m      # Least squares channel estimation
│   │   │   ├── mmse_channel_est.m    # MMSE channel estimation
│   │   │   └── pilot_interpolation.m # Pilot-based interpolation
│   │   ├── equalization/             # Equalization algorithms
│   │   │   ├── lms_equalizer.m       # LMS adaptive equalizer
│   │   │   ├── zf_equalizer.m        # Zero-forcing equalizer
│   │   │   └── mmse_equalizer.m      # MMSE equalizer
│   │   ├── coding/                   # Error correction codes
│   │   │   ├── rs_encode.m           # Reed-Solomon encoding
│   │   │   ├── rs_decode.m           # Reed-Solomon decoding
│   │   │   ├── turbo_encode.m        # Turbo code encoding
│   │   │   └── turbo_decode.m        # Turbo code decoding
│   │   └── sync/                     # Synchronization algorithms
│   │       ├── timing_sync.m         # Timing synchronization
│   │       ├── freq_offset_estimate.m # Frequency offset estimation
│   │       ├── freq_offset_correct.m  # Frequency offset correction
│   │       └── ofdm_sync_schmidl_cox.m # Schmidl-Cox OFDM sync
│   ├── utils/                        # Utility functions
│   │   ├── generate_data.m           # Random data generation
│   │   ├── add_awgn.m                # AWGN channel
│   │   ├── rayleigh_fading.m         # Rayleigh fading channel
│   │   ├── multipath_channel.m       # Multipath channel
│   │   ├── calculate_ber.m           # BER calculation
│   │   ├── calculate_evm.m           # EVM calculation
│   │   ├── plot_constellation.m      # Constellation plotting
│   │   └── plot_ber_curve.m          # BER curve plotting
│   ├── 01_basic_bpsk.m               # Level 1: Basic BPSK system
│   ├── 02_qpsk_with_reed_solomon.m   # Level 2: QPSK with error correction
│   ├── 03_16qam_with_lms_equalizer.m # Level 3: 16-QAM with LMS equalizer
│   ├── 04_sc_sync_qpsk.m             # Level 4: QPSK with synchronization
│   ├── 05_basic_ofdm.m               # Level 5: Basic OFDM system
│   ├── 06_ofdm_channel_estimation.m  # Level 6: OFDM with channel estimation
│   ├── 07_ofdm_full_sync.m           # Level 7: OFDM with advanced sync
│   ├── 08_complete_ofdm_turbo.m      # Level 8: Complete OFDM with turbo codes
│   ├── setup_paths.m                 # Path setup helper
│   └── examples_README.md            # Examples documentation
├── Dockerfile                        # Container definition
└── README.md                         # Project overview (this file)
```

## Quick Start

### Running Example Scripts

The `src/` directory contains 8 progressive demonstration scripts showcasing increasing complexity:

1. Navigate to the src directory:
   ```bash
   cd src
   ```

2. Run any demonstration script:
   ```bash
   octave 01_basic_bpsk.m
   ```

3. For detailed information about each script, see [src/examples_README.md](src/examples_README.md)

### Available Examples

- **Level 1** (`01_basic_bpsk.m`): Basic BPSK system with AWGN channel
- **Level 2** (`02_qpsk_with_reed_solomon.m`): QPSK with error correction
- **Level 3** (`03_16qam_with_lms_equalizer.m`): 16-QAM with adaptive equalization
- **Level 4** (`04_sc_sync_qpsk.m`): QPSK with timing and frequency synchronization
- **Level 5** (`05_basic_ofdm.m`): Basic OFDM system
- **Level 6** (`06_ofdm_channel_estimation.m`): OFDM with channel estimation
- **Level 7** (`07_ofdm_full_sync.m`): OFDM with advanced synchronization
- **Level 8** (`08_complete_ofdm_turbo.m`): Complete OFDM system with turbo codes

