# L1 Algorithm Demonstration Scripts

This directory contains 8 progressive demonstration scripts showcasing Layer 1 (Physical Layer) algorithms for wireless communication systems. These scripts demonstrate increasing complexity, from basic single-carrier systems to advanced multi-carrier OFDM systems with comprehensive receiver algorithms.

## Overview

The scripts are designed to demonstrate practical implementation of:
- **Modulation/Demodulation**: BPSK, QPSK, QAM, OFDM
- **Error Correction**: Reed-Solomon codes, Turbo codes
- **Equalization**: LMS adaptive, ZF, MMSE
- **Synchronization**: Timing recovery, frequency offset estimation/correction
- **Channel Estimation**: LS, MMSE methods with interpolation

Each script is self-contained, well-documented, and includes comprehensive visualizations and performance metrics.

---

## Scripts

### Level 1: Basic Single-Carrier BPSK System
**File**: `01_basic_bpsk.m`  
**Complexity**: Beginner  
**Estimated Runtime**: ~30 seconds

**Features**:
- Binary data generation
- BPSK modulation/demodulation
- AWGN channel modeling
- BER calculation and analysis
- Theoretical BER comparison
- Constellation visualization

**Key Algorithms**:
- Coherent BPSK demodulation
- BER analysis vs SNR
- Monte Carlo simulation

**Run**:
```bash
cd src
octave 01_basic_bpsk.m
```

**Expected Output**:
- BER curve comparing simulated vs theoretical performance
- BPSK constellation diagram

---

### Level 2: QPSK with Basic Error Correction
**File**: `02_qpsk_with_reed_solomon.m`  
**Complexity**: Intermediate-Basic  
**Estimated Runtime**: ~2 minutes

**Features**:
- QPSK modulation/demodulation
- Error correction coding (simplified RS-like)
- AWGN channel
- BER comparison: coded vs uncoded
- Coding gain analysis

**Key Algorithms**:
- QPSK Gray-coded modulation
- Block coding with redundancy
- Performance comparison with/without coding

**Run**:
```bash
octave 02_qpsk_with_reed_solomon.m
```

**Expected Output**:
- BER curves for uncoded and coded systems
- QPSK constellation diagram
- Coding gain measurement

---

### Level 3: 16-QAM with Adaptive Equalization
**File**: `03_16qam_with_lms_equalizer.m`  
**Complexity**: Intermediate  
**Estimated Runtime**: ~1 minute

**Features**:
- 16-QAM modulation/demodulation
- FIR multipath channel model
- LMS adaptive equalizer
- Training sequence and decision-directed modes
- Equalizer convergence analysis
- EVM measurement

**Key Algorithms**:
- Higher-order QAM modulation
- LMS adaptive filtering
- Multipath channel modeling
- Equalizer weight convergence

**Run**:
```bash
octave 03_16qam_with_lms_equalizer.m
```

**Expected Output**:
- Constellation diagrams (before/after equalization)
- Equalizer weights (magnitude and phase)
- Channel impulse response
- BER and EVM metrics

---

### Level 4: Single-Carrier QPSK with Synchronization
**File**: `04_sc_sync_qpsk.m`  
**Complexity**: Intermediate-Advanced  
**Estimated Runtime**: ~1 minute

**Features**:
- QPSK with preamble
- Timing synchronization (correlation-based)
- Frequency offset estimation (FFT-based)
- Frequency offset correction
- Frame synchronization
- Performance under synchronization errors

**Key Algorithms**:
- Correlation-based timing recovery
- Frequency offset estimation from phase difference
- Frequency offset correction in time domain
- Frame detection

**Run**:
```bash
octave 04_sc_sync_qpsk.m
```

**Expected Output**:
- Timing correlation metric
- Frequency offset estimation accuracy
- Constellation before/after correction
- Synchronization error analysis

---

### Level 5: Basic OFDM System
**File**: `05_basic_ofdm.m`  
**Complexity**: Advanced-Basic  
**Estimated Runtime**: ~3 minutes

**Features**:
- OFDM modulation (IFFT)
- Cyclic prefix addition
- OFDM demodulation (FFT)
- Subcarrier QAM mapping (16-QAM)
- AWGN channel
- BER vs SNR performance

**Key Algorithms**:
- IFFT/FFT operations for OFDM
- Cyclic prefix insertion/removal
- Frequency-domain modulation
- OFDM symbol structure

**Run**:
```bash
octave 05_basic_ofdm.m
```

**Expected Output**:
- BER performance curve for OFDM
- Time-domain OFDM symbol visualization
- Comparison with theoretical 16-QAM BER

---

### Level 6: OFDM with Channel Estimation & Equalization
**File**: `06_ofdm_channel_estimation.m`  
**Complexity**: Advanced  
**Estimated Runtime**: ~2 minutes

**Features**:
- OFDM with pilot symbols
- Channel estimation (LS/MMSE methods)
- One-tap frequency-domain equalization
- Multipath fading channel
- Pilot interpolation
- Comparison of estimation methods

**Key Algorithms**:
- Least Squares (LS) channel estimation
- MMSE channel estimation
- Frequency-domain equalization
- Linear/spline interpolation

**Run**:
```bash
octave 06_ofdm_channel_estimation.m
```

**Expected Output**:
- Channel frequency response (magnitude and phase)
- Comparison of LS vs MMSE estimates
- Constellation diagrams (before/after equalization)
- Channel impulse response
- BER comparison

---

### Level 7: OFDM with Advanced Synchronization
**File**: `07_ofdm_full_sync.m`  
**Complexity**: Advanced-Expert  
**Estimated Runtime**: ~2 minutes

**Features**:
- Schmidl-Cox synchronization algorithm
- Integer frequency offset (IFO) estimation
- Fractional frequency offset (FFO) estimation
- Symbol timing detection
- Full receiver chain with sync errors
- Robust synchronization under impairments

**Key Algorithms**:
- Schmidl-Cox timing metric
- Fractional frequency offset correction
- Symbol timing recovery
- Frequency offset estimation and correction

**Run**:
```bash
octave 07_ofdm_full_sync.m
```

**Expected Output**:
- Schmidl-Cox timing metric
- Frequency offset estimation results
- Timing synchronization accuracy
- Constellation before/after synchronization
- Synchronization error analysis

---

### Level 8: Complete OFDM System with Turbo Codes
**File**: `08_complete_ofdm_turbo.m`  
**Complexity**: Expert  
**Estimated Runtime**: ~5 minutes

**Features**:
- Full OFDM system with 64-QAM
- Turbo code encoding/decoding
- Channel estimation with interpolation
- Advanced equalization (MMSE)
- Full synchronization chain
- Comprehensive performance analysis
- Comparison with theoretical limits

**Key Algorithms**:
- Complete OFDM transceiver chain
- Turbo coding (simplified implementation)
- MMSE channel estimation
- MMSE equalization
- Full synchronization (timing + frequency)
- End-to-end system performance

**Run**:
```bash
octave 08_complete_ofdm_turbo.m
```

**Expected Output**:
- Complete system performance metrics
- Channel frequency response
- Constellation diagrams
- BER and EVM measurements
- Comparison with theoretical performance
- Full receiver chain visualization

---

## Prerequisites

### Required Software
- **GNU Octave** (recommended version 5.0 or later)
- **Octave packages** (usually included):
  - `octave-signal`
  - `octave-communications` (optional, for advanced features)

### Directory Structure
Ensure the project structure is intact:
```
telecoms/
├── src/
│   ├── 01_basic_bpsk.m
│   ├── 02_qpsk_with_reed_solomon.m
│   ├── ...
│   └── README.md
└── src/
    ├── utils/
    └── algorithms/
        ├── modulation/
        ├── demodulation/
        ├── coding/
        ├── equalization/
        ├── sync/
        └── channel/
```

---

## Running the Scripts

### Quick Start
1. Navigate to the src directory:
   ```bash
   cd /path/to/telecoms/src
   ```

2. Run any script:
   ```bash
   octave 01_basic_bpsk.m
   ```

### Path Setup
Each script automatically adds the necessary paths. If you encounter path issues:

**Option 1**: Use the setup script:
```octave
run setup_paths.m
octave 01_basic_bpsk.m
```

**Option 2**: Manually add paths:
```octave
addpath('./utils');
addpath('./algorithms/modulation');
addpath('./algorithms/demodulation');
addpath('./algorithms/coding');
addpath('./algorithms/equalization');
addpath('./algorithms/sync');
addpath('./algorithms/channel');
```

### Running All Scripts
To run all scripts in sequence:
```bash
for script in 0{1..8}_*.m; do
    echo "Running $script..."
    octave "$script"
done
```

---

## Script Structure

All scripts follow a consistent structure:

1. **Header Comments**: Purpose, features, complexity level, key skills
2. **Configuration**: Parameters at the top (easy to modify)
3. **Transmitter**: Data generation, encoding, modulation
4. **Channel**: AWGN, fading, multipath, impairments
5. **Receiver**: Synchronization, equalization, demodulation, decoding
6. **Performance Analysis**: BER, EVM, throughput metrics
7. **Visualization**: Plots, constellation diagrams, comparison charts

---

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

---

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

---

## Troubleshooting

### Common Issues

**1. Path Errors**
```
Error: 'function_name' undefined
```
**Solution**: Ensure you're running from the `src/` directory, or use `setup_paths.m`

**2. Plot/GUI Issues**
```
Error: gnuplot not found
```
**Solution**: Install gnuplot or set graphics toolkit:
```octave
graphics_toolkit('fltk');  % or 'gnuplot'
```

**3. Slow Execution**
- Reduce `num_trials` or `num_bits`
- Use fewer SNR points in `snr_db_range`
- Reduce OFDM symbols or FFT size

**4. Memory Issues**
- Reduce simulation size
- Process data in smaller blocks
- Clear variables: `clear` between iterations

**5. NaN or Inf Values**
- Check SNR values (not too high/low)
- Verify channel coefficients (not zero)
- Check for division by zero in algorithms

---

## Performance Notes

### Simulation Time Estimates
- **Level 1**: ~30 seconds
- **Level 2**: ~2 minutes
- **Level 3**: ~1 minute
- **Level 4**: ~1 minute
- **Level 5**: ~3 minutes
- **Level 6**: ~2 minutes
- **Level 7**: ~2 minutes
- **Level 8**: ~5 minutes

*Times are approximate and depend on system performance and parameter settings.*

### Expected BER Values
Typical BER ranges for reference:
- **BPSK at 10 dB SNR**: ~10^-3
- **QPSK at 10 dB SNR**: ~10^-3
- **16-QAM at 15 dB SNR**: ~10^-4
- **64-QAM at 20 dB SNR**: ~10^-3

---

## Algorithm Notes

### Simplified Implementations
Some algorithms use simplified implementations for educational purposes:
- **Reed-Solomon codes**: Simplified encoding/decoding (Level 2)
- **Turbo codes**: Simplified iterative decoding (Level 8)
- **Channel models**: Simplified multipath representation

For production use, consider using:
- Octave Communications Toolbox for advanced coding
- More sophisticated channel models
- Industry-standard implementations

### Theoretical Comparisons
Scripts compare results with theoretical limits where applicable:
- **BPSK**: BER = 0.5 * erfc(√SNR)
- **QPSK**: Similar to BPSK (same power efficiency)
- **16-QAM/64-QAM**: Approximate theoretical formulas

---

## References

### Key Algorithms Demonstrated
1. **BPSK/QPSK Modulation**: Basic digital modulation
2. **QAM**: Higher-order constellations
3. **OFDM**: Multi-carrier transmission
4. **LMS Equalization**: Adaptive filtering
5. **Channel Estimation**: LS, MMSE methods
6. **Synchronization**: Timing and frequency recovery
7. **Error Correction**: Block and convolutional codes

### Recommended Reading
- Proakis & Salehi: "Digital Communications"
- Tse & Viswanath: "Fundamentals of Wireless Communication"
- 3GPP specifications (for 5G/LTE algorithms)
- IEEE 802.11 standards (for Wi-Fi OFDM)

---

## Contributing

When modifying scripts:
1. Maintain consistent structure
2. Update header comments
3. Include performance metrics
4. Add visualizations
5. Test with various parameter values

---

## License

[To be determined based on project license]

---

## Contact

For questions or issues:
- Check the main project README.md
- Review algorithm documentation in `../docs/`
- Examine source code in `../src/algorithms/`

---

**Last Updated**: 2024  
**Version**: 1.0  
**Status**: Complete and tested
