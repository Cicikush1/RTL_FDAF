# RTL_FDAF ## Current Version :0.9.0
Frequency Domain Adaptive Filter designed in Register Transfer Level. This project aims for audio applications, therefore it adapts a resource sharing architecture rather than an unfolded one.

## Authors Notes 
This is my very first FDAF project, therefore some bad architectural/systematic decisions were made (such as a monolith file) these decisions had to be kept until the end since so much work was already done. However, I do acknowledge that the resulting work is quite hard to maintain/work on. Also an important point would be to state that LLMs have been utilized in this project.

## Architecture
As stated in the entry, this module targets audio applications, therefore implements Time Division Multiplexing on FFT Core, Complex Multiplier and several wide pipeline busses as high parallelism and high throughput are not really necessary for audio applications since audio sampling frequencies are much lower than typical FPGA/ASIC operating frequencies. 

The design can marginally close 100 MHz on Nexys A7-100T (xc7a100tcsg324-1) with a WNS = 0.157 ns which is quite acceptable since ~2.6 MHz operating frequency is enough for 44.1 kHz sampled audio. This brings us the advantage of low power draw even at 100 MHz:

<img width="375" height="390" alt="image" src="https://github.com/user-attachments/assets/8d76a572-f4b8-4311-bef7-5d6e277f8190" />

## References
[1] D. Comminiello, M. Scarpiniti, R. Parisi, and A. Uncini, "Frequency-domain adaptive filtering: From real to hypercomplex signal processing," in *Proc. IEEE Int. Conf. Acoust., Speech Signal Process. (ICASSP)*, Brighton, UK, 2019, pp. 7745–7749, doi: [10.1109/ICASSP.2019.8683403](https://doi.org/10.1109/ICASSP.2019.8683403).

The FDAF follows Algorithm 1 of [1]. The RTL implements it in fixed point and replaces the per-bin division by the power estimate with a power-of-two shift (leading-one detector).

## Credits
The FFT core is **fpga-fft** by owocomm-0 (https://github.com/owocomm-0/fpga-fft), licensed under [CC BY-NC-SA 2.0](https://creativecommons.org/licenses/by-nc-sa/2.0/).
- `sources/fpga-fft/`: files from fpga-fft, unmodified except `complex_multiplyCMC.vhd`.
- `complex_multiplyCMC.vhd`: modified from fpga-fft's `complex_multiply2.vhd`, adding power and gradient shift modes, convergent rounding and saturation. It sits inside this project's complex multiplier wrapper, `ComplexMultiplierCore.vhd`.
- `sources/codegen/`: generated with fpga-fft's code generator (1024-point FFT).

