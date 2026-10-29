# RTL_FDAF
Frequency Domain Adaptive Filter designed in Register Transfer Level. This project aims for audio applications, therefore it adapts a resource sharing architecture rather than an unfolded one.


## References
[1] D. Comminiello, M. Scarpiniti, R. Parisi, and A. Uncini, "Frequency-domain adaptive filtering: From real to hypercomplex signal processing," in *Proc. IEEE Int. Conf. Acoust., Speech Signal Process. (ICASSP)*, Brighton, UK, 2019, pp. 7745–7749, doi: [10.1109/ICASSP.2019.8683403](https://doi.org/10.1109/ICASSP.2019.8683403).

The FDAF follows Algorithm 1 of [1]. The RTL implements it in fixed point and replaces the per-bin division by the power estimate with a power-of-two shift (leading-one detector).

## Credits
The FFT core is **fpga-fft** by owocomm-0 (https://github.com/owocomm-0/fpga-fft), licensed under [CC BY-NC-SA 2.0](https://creativecommons.org/licenses/by-nc-sa/2.0/).
- `sources/fpga-fft/`: files from fpga-fft, unmodified except `complex_multiplyCMC.vhd`.
- `complex_multiplyCMC.vhd`: modified from fpga-fft's `complex_multiply2.vhd`, adding power and gradient shift modes, convergent rounding and saturation. It sits inside this project's complex multiplier wrapper, `ComplexMultiplierCore.vhd`.
- `sources/codegen/`: generated with fpga-fft's code generator (1024-point FFT).

