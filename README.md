# RTL_FDAF
Frequency Domain Adaptive Filter designed in Register Transfer Level. This project aims for audio applications, therefore it adapts a resource sharing architecture rather than an unfolded one.

# IMPORTANT NOTICES
The FDAF algorithm is based on Algorithm-1 this article:
D. Comminiello, M. Scarpiniti, R. Parisi and A. Uncini, "Frequency-domain Adaptive Filtering: from Real to Hypercomplex Signal Processing," ICASSP 2019 - 2019 IEEE International Conference on Acoustics, Speech and Signal Processing (ICASSP), Brighton, UK, 2019, pp. 7745-7749, doi: 10.1109/ICASSP.2019.8683403. keywords: {Frequency-domain analysis;Time-domain analysis;Signal processing algorithms;Quaternions;Signal processing;3D audio;Switches;Frequency-domain adaptive filter;Quaternion adaptive filtering;3D audio;Adaptive signal processing;Hypercom-plex signal processing;DSP education.},

The FFT module utilized in this project is from: https://github.com/owocomm-0/fpga-fft. The complex multiplication engine is also derived from the one in the FFT module
