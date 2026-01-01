# Telecoms L1 Algorithm Development Project

A project for developing and optimizing Layer 1 (Physical Layer) algorithms for telecommunications systems using GNU Octave.

## Overview

This project focuses on implementing signal processing algorithms for physical layer communication systems, including modulation, demodulation, channel estimation, equalization, and synchronization. The project contains 8 progressive demonstration scripts showcasing increasing complexity, from basic single-carrier systems to advanced multi-carrier OFDM systems with comprehensive receiver algorithms.

The scripts demonstrate practical implementation of:
- **Modulation/Demodulation**: BPSK, QPSK, QAM, OFDM
- **Error Correction**: Reed-Solomon codes, Turbo codes
- **Equalization**: LMS adaptive, ZF, MMSE
- **Synchronization**: Timing recovery, frequency offset estimation/correction
- **Channel Estimation**: LS, MMSE methods with interpolation

Each script is self-contained, well-documented, and includes comprehensive visualizations and performance metrics.


## Project Structure

```
├── demo_01_basic_bpsk.m               # Demo 1: Basic BPSK system
├── demo_02_qpsk_with_reed_solomon.m   # Demo 2: QPSK with error correction
├── demo_03_16qam_with_lms_equalizer.m # Demo 3: 16-QAM with LMS equalizer
├── demo_04_sc_sync_qpsk.m             # Demo 4: QPSK with synchronization
├── demo_05_basic_ofdm.m               # Demo 5: Basic OFDM system
├── demo_06_ofdm_channel_estimation.m  # Demo 6: OFDM with channel estimation
├── demo_07_ofdm_full_sync.m           # Demo 7: OFDM with advanced sync
├── demo_08_complete_ofdm_turbo.m      # Demo 8: Complete OFDM with turbo codes
├── setup_paths.m                 # Path setup helper
├── algorithms/                   # Core algorithm implementations
│   ├── modulation/               # Modulation schemes
│   │   ├── bpsk_modulate.m       # BPSK modulation
│   │   ├── qpsk_modulate.m       # QPSK modulation
│   │   ├── qam_modulate.m        # QAM modulation
│   │   └── ofdm_modulate.m       # OFDM modulation
│   ├── demodulation/             # Demodulation algorithms
│   │   ├── bpsk_demodulate.m     # BPSK demodulation
│   │   ├── qpsk_demodulate.m     # QPSK demodulation
│   │   ├── qam_demodulate.m      # QAM demodulation
│   │   └── ofdm_demodulate.m     # OFDM demodulation
│   ├── channel/                  # Channel models and estimation
│   │   ├── ls_channel_est.m      # Least squares channel estimation
│   │   ├── mmse_channel_est.m    # MMSE channel estimation
│   │   └── pilot_interpolation.m # Pilot-based interpolation
│   ├── equalization/             # Equalization algorithms
│   │   ├── lms_equalizer.m       # LMS adaptive equalizer
│   │   ├── zf_equalizer.m        # Zero-forcing equalizer
│   │   └── mmse_equalizer.m      # MMSE equalizer
│   ├── coding/                   # Error correction codes
│   │   ├── rs_encode.m           # Reed-Solomon encoding
│   │   ├── rs_decode.m           # Reed-Solomon decoding
│   │   ├── turbo_encode.m        # Turbo code encoding
│   │   └── turbo_decode.m        # Turbo code decoding
│   └── sync/                     # Synchronization algorithms
│       ├── timing_sync.m         # Timing synchronization
│       ├── freq_offset_estimate.m # Frequency offset estimation
│       ├── freq_offset_correct.m  # Frequency offset correction
│       └── ofdm_sync_schmidl_cox.m # Schmidl-Cox OFDM sync
├── utils/                        # Utility functions
│   ├── generate_data.m           # Random data generation
│   ├── add_awgn.m                # AWGN channel
│   ├── rayleigh_fading.m         # Rayleigh fading channel
│   ├── multipath_channel.m       # Multipath channel
│   ├── calculate_ber.m           # BER calculation
│   ├── calculate_evm.m           # EVM calculation
│   ├── plot_constellation.m      # Constellation plotting
│   └── plot_ber_curve.m          # BER curve plotting
├── Dockerfile                    # Container definition
└── README.md                     # This file
```

## Quick Start

### Running Scripts

The root directory contains 8 progressive demonstration scripts showcasing increasing complexity:

1. Run any demonstration script directly:
   ```bash
   octave demo_01_basic_bpsk.m
   ```

2. Each script automatically adds the necessary paths. If you encounter path issues, use:
   ```octave
   run setup_paths.m
   ```

### Available Examples

- **Demo 1** (`demo_01_basic_bpsk.m`): Basic BPSK system with AWGN channel
- **Demo 2** (`demo_02_qpsk_with_reed_solomon.m`): QPSK with error correction
- **Demo 3** (`demo_03_16qam_with_lms_equalizer.m`): 16-QAM with adaptive equalization
- **Demo 4** (`demo_04_sc_sync_qpsk.m`): QPSK with timing and frequency synchronization
- **Demo 5** (`demo_05_basic_ofdm.m`): Basic OFDM system
- **Demo 6** (`demo_06_ofdm_channel_estimation.m`): OFDM with channel estimation
- **Demo 7** (`demo_07_ofdm_full_sync.m`): OFDM with advanced synchronization
- **Demo 8** (`demo_08_complete_ofdm_turbo.m`): Complete OFDM system with turbo codes

## Demonstration Scripts Details

### Demo 1: Basic Single-Carrier BPSK System
**File**: `demo_01_basic_bpsk.m`  

**Features**:
- Binary data generation
- BPSK modulation/demodulation
- AWGN channel modeling
- BER calculation and analysis
- Theoretical BER comparison
- Constellation visualization

---

### Demo 2: QPSK with Basic Error Correction
**File**: `demo_02_qpsk_with_reed_solomon.m`

**Features**:
- QPSK modulation/demodulation
- Error correction coding (simplified RS-like)
- AWGN channel
- BER comparison: coded vs uncoded
- Coding gain analysis

---

### Demo 3: 16-QAM with Adaptive Equalization
**File**: `demo_03_16qam_with_lms_equalizer.m`

**Features**:
- 16-QAM modulation/demodulation
- FIR multipath channel model
- LMS adaptive equalizer
- Training sequence and decision-directed modes
- Equalizer convergence analysis
- EVM measurement

---

### Demo 4: Single-Carrier QPSK with Synchronization
**File**: `demo_04_sc_sync_qpsk.m`  

**Features**:
- QPSK with preamble
- Timing synchronization (correlation-based)
- Frequency offset estimation (FFT-based)
- Frequency offset correction
- Frame synchronization
- Performance under synchronization errors

---

### Demo 5: Basic OFDM System
**File**: `demo_05_basic_ofdm.m`  

**Features**:
- OFDM modulation (IFFT)
- Cyclic prefix addition
- OFDM demodulation (FFT)
- Subcarrier QAM mapping (16-QAM)
- AWGN channel
- BER vs SNR performance

---

### Demo 6: OFDM with Channel Estimation & Equalization
**File**: `demo_06_ofdm_channel_estimation.m`  

**Features**:
- OFDM with pilot symbols
- Channel estimation (LS/MMSE methods)
- One-tap frequency-domain equalization
- Multipath fading channel
- Pilot interpolation
- Comparison of estimation methods

---

### Demo 7: OFDM with Advanced Synchronization
**File**: `demo_07_ofdm_full_sync.m`  

**Features**:
- Schmidl-Cox synchronization algorithm
- Integer frequency offset (IFO) estimation
- Fractional frequency offset (FFO) estimation
- Symbol timing detection
- Full receiver chain with sync errors
- Robust synchronization under impairments


### Demo 8: Complete OFDM System with Turbo Codes
**File**: `demo_08_complete_ofdm_turbo.m`  

**Features**:
- Full OFDM system with 64-QAM
- Turbo code encoding/decoding
- Channel estimation with interpolation
- Advanced equalization (MMSE)
- Full synchronization chain
- Comprehensive performance analysis
- Comparison with theoretical limits

## Docker Development Environment

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

## Script Structure

All scripts follow a consistent structure:

1. **Header Comments**: Purpose and features
2. **Configuration**: Parameters at the top (easy to modify)
3. **Transmitter**: Data generation, encoding, modulation
4. **Channel**: AWGN, fading, multipath, impairments
5. **Receiver**: Synchronization, equalization, demodulation, decoding
6. **Performance Analysis**: BER, EVM, throughput metrics
7. **Visualization**: Plots, constellation diagrams, comparison charts

## Output and Visualization

Each script generates:
- **Console Output**: Performance metrics, BER values, synchronization results
- **Figure Windows**: Multiple plots including:
  - BER curves (log scale)
  - Constellation diagrams
  - Channel responses (time/frequency domain)
  - Synchronization metrics
  - Comparison plots (with/without techniques)
  - Convergence plots (for adaptive algorithms)

**Note**: Scripts use `figure()` which opens new windows. If running in a headless environment, configure Octave appropriately or use `graphics_toolkit('gnuplot')` for alternative plotting.

## Customization

### Adjusting Parameters
Most parameters can be modified at the top of each script:
- **SNR range**: Change `snr_db_range`
- **Modulation order**: Modify `M` (4, 16, 64, etc.)
- **Number of trials**: Adjust `num_trials` for better statistics
- **FFT size**: Change `N` for OFDM scripts
- **Channel parameters**: Modify `channel_taps`, `channel_delays`

### Performance vs Accuracy Trade-off
- **Faster simulation**: Reduce `num_bits`, `num_trials`, or `num_ofdm_symbols`
- **Better statistics**: Increase `num_trials` or simulation length
- **Higher accuracy**: Use more samples, longer sequences

### Expected BER Values
Typical BER ranges for reference:
- **BPSK at 10 dB SNR**: ~10^-3
- **QPSK at 10 dB SNR**: ~10^-3
- **16-QAM at 15 dB SNR**: ~10^-4
- **64-QAM at 20 dB SNR**: ~10^-3

## Algorithm Notes

### Simplified Implementations
Some algorithms use simplified implementations for educational purposes:
- **Reed-Solomon codes**: Simplified encoding/decoding (Demo 2)
- **Turbo codes**: Simplified iterative decoding (Demo 8)
- **Channel models**: Simplified multipath representation

### Theoretical Comparisons
Scripts compare results with theoretical limits where applicable:
- **BPSK**: BER = 0.5 * erfc(√SNR)
- **QPSK**: Similar to BPSK (same power efficiency)
- **16-QAM/64-QAM**: Approximate theoretical formulas

