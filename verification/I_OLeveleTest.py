# %%
# I/O level test of the RTL FDAF
# - Python port of Documents/MatlabFDAFOLS.txt, fed with the golden signals in fdaf_signals.mat (no RIR is recreated)
# - Compared with the Vivado output (DFContainer/OUTDUMP.txt, written by FSMTESTBENCH.vhd)
# - ERLE of both outputs against vhdl_stimulus.txt
# - Peak and mean ERLE on a trustable region (far end only: no double talk, no silence, filter past its first second)
# AEC roles: X (filter input) = Speaker (far-end reference), D (desired) = Mic (echo + near end)
import numpy as np
import scipy.io as sio
import matplotlib.pyplot as plt
from pathlib import Path

try:
    BASE_DIR = Path(__file__).resolve().parent
except NameError:
    # Jupyter / interactive window: runs from the file's directory (same as genericdatatb.py)
    BASE_DIR = Path.cwd()

MAT_FILE = BASE_DIR / 'fdaf_signals.mat'
STIM_FILE = BASE_DIR / 'vhdl_stimulus.txt'
OUTDUMP_FILE = BASE_DIR.parents[1] / 'DFContainer' / 'OUTDUMP.txt'

# %% MATLAB parameters (MatlabFDAFOLS.txt)
frameSize = 1024
fs = 44100
overlap = frameSize // 2
hopSize = frameSize - overlap
mu = 0.05
exp_decay_coeff = 0.0
LinearFFTCoeff = 1
eps = 1e-6
Lambda = 0.95
mu_lim = 1

# Test options
INPUT_12BIT = True        # True: the same 12-bit samples Vivado gets. False: the raw .mat floats (same LSB units)
NORMALIZATION = "matlab"  # "matlab": muk = min(mu_lim, mu/(P+eps))
                          # "rtl": the RTL step, mu / 2^floor(log2(P/2^15)) with the CSR_Bank values (MU 0x0666, lambda 0x799A).
                          #        Tracks the Vivado output more closely; the gap to "matlab" is the power-of-two normalisation.
SMOOTH_FRAMES = 5         # ERLE curves are smoothed over this many frames
TRUST_SECONDS = (2.0, 4.0)  # Length range (s) of the trustable region the peak and mean ERLE are taken on


# %% Golden signals: .mat -> 12 bit, exactly like genericdatatb.py, then checked against vhdl_stimulus.txt
def load_stimulus(path):
    """vhdl_stimulus.txt (4 columns of 12-bit two's complement) -> dict of signed integers."""
    vals = np.array([[int(b, 2) for b in line.split()] for line in open(path) if line.strip()])
    vals = np.where(vals >= 2048, vals - 4096, vals)
    return dict(zip(('clean', 'echo', 'mic', 'speaker'), vals.T.astype(float)))


mat = sio.loadmat(MAT_FILE)
names = {'clean': 'Full_Clean_Signal', 'echo': 'Full_Echo_Signal', 'mic': 'Full_Mic_Signal', 'speaker': 'Full_Speaker_Signal'}
raw = {k: np.squeeze(mat[v]).astype(float) for k, v in names.items()}
# genericdatatb.py normalises every signal by the same peak, so the echo path gain is kept
global_max = max(np.max(np.abs(v)) for v in raw.values())
q12 = {k: np.round(np.clip(v / global_max, -1.0, 2047.0 / 2048.0) * 2048.0) for k, v in raw.items()}

stim = load_stimulus(STIM_FILE)
mismatch = [k for k in stim if not np.array_equal(stim[k], q12[k])]
print("vhdl_stimulus.txt == 12-bit .mat signals:", "OK" if not mismatch else f"MISMATCH in {mismatch}")

if INPUT_12BIT:
    x, d = q12['speaker'], q12['mic']
else:
    x, d = raw['speaker'] * 2048.0 / global_max, raw['mic'] * 2048.0 / global_max


# %% FDAF: overlap-save, constrained gradient (MatlabFDAFOLS.txt line by line)
def fdaf_ols(x, d, normalization="matlab"):
    """Returns the output e = d - y and the echo estimate y for every full 512-sample frame."""
    n_frames = len(x) // hopSize
    W_fft = np.fft.fft(np.zeros(frameSize))
    if normalization == "rtl":
        mu_k, lam_k, P = 0x0666 / 2**15, 0x799A / 2**15, np.zeros(frameSize)  # CSR_Bank defaults, the P RAM starts at 0
    else:
        mu_k, lam_k, P = mu, Lambda, np.ones(frameSize)
    X_Old = np.zeros(hopSize)
    e_out = np.zeros(n_frames * hopSize)
    y_out = np.zeros(n_frames * hopSize)
    for k in range(n_frames):
        XData = x[k * hopSize:(k + 1) * hopSize]
        DData = d[k * hopSize:(k + 1) * hopSize]   # the live script's tanh(20*DData) mic preamp does not apply to the .mat data
        XBuff = np.concatenate((X_Old, XData))
        X_Old = XData

        X_fft = np.fft.fft(XBuff)
        Y_fft = X_fft * W_fft
        y_conv = np.fft.ifft(Y_fft)
        OutPut = y_conv[hopSize:frameSize].real

        e_frame = DData - LinearFFTCoeff * OutPut
        E_fft = np.fft.fft(np.concatenate((np.zeros(hopSize), e_frame)))
        P = lam_k * P + (1 - lam_k) * np.abs(X_fft) ** 2
        if normalization == "rtl":
            # The RTL keeps P/2^15 as a 24-bit integer; the leading one detector gives floor(log2), 0 below 2
            P_rtl = np.floor(P / 2**15)
            shift = np.where(P_rtl >= 1, np.floor(np.log2(np.maximum(P_rtl, 1))), 0)
            muk = mu_k / (2.0 ** shift * 2**15)
        else:
            muk = np.minimum(mu_lim, mu_k / (P + eps))
        GradJ = muk * np.conj(X_fft) * E_fft
        GradJ_inv = np.fft.ifft(GradJ)
        GradJ = np.fft.fft(np.concatenate((GradJ_inv[:hopSize], np.zeros(hopSize))))
        W_fft = W_fft * np.exp(-exp_decay_coeff) + GradJ

        e_out[k * hopSize:(k + 1) * hopSize] = e_frame
        y_out[k * hopSize:(k + 1) * hopSize] = OutPut
    return e_out, y_out


e_py, y_py = fdaf_ols(x, d, NORMALIZATION)

# %% Vivado output (one sample per line, same row order as vhdl_stimulus.txt; the '#' header lines are skipped)
if OUTDUMP_FILE.exists():
    e_rtl = np.loadtxt(OUTDUMP_FILE)
    print(f"Vivado output: {len(e_rtl)} samples ({len(e_rtl) // hopSize} frames) from {OUTDUMP_FILE}")
else:
    e_rtl = None
    print(f"{OUTDUMP_FILE} not found: run the Vivado simulation (Run All) first. Only the Python FDAF is scored below.")

n_frames = len(e_py) // hopSize if e_rtl is None else min(len(e_py), len(e_rtl)) // hopSize
n = n_frames * hopSize


# %% ERLE against vhdl_stimulus.txt
def frame_energy(v):
    return np.sum(v[:n].reshape(n_frames, hopSize) ** 2, axis=1)


def erle_db(num, den, mask):
    return 10 * np.log10(np.sum(num[mask]) / np.sum(den[mask]))


def erle_curve(num, den, mask):
    """Frame-wise ERLE in dB, smoothed over SMOOTH_FRAMES; NaN where the far end is silent."""
    k = np.ones(SMOOTH_FRAMES)
    num_s, den_s = np.convolve(num, k, 'same'), np.convolve(den, k, 'same')
    out = np.full(n_frames, np.nan)
    ok = mask & (den_s > 0)
    out[ok] = 10 * np.log10(num_s[ok] / den_s[ok])
    return out


mic, echo, near = stim['mic'][:n], stim['echo'][:n], (stim['mic'] - stim['echo'])[:n]
far_active = frame_energy(stim['speaker']) > 25**2 * hopSize   # far end talking (rms > 25 LSB); ERLE is undefined otherwise
double_talk = frame_energy(near) > hopSize                     # near-end speech in the mic (rms > 1 LSB)
converged = np.arange(n_frames) * hopSize >= fs                # skip the first second (filter starts from zero)

E_mic, E_echo = frame_energy(mic), frame_energy(echo)
outputs = {'Python': e_py[:n]} if e_rtl is None else {'Python': e_py[:n], 'Vivado': e_rtl[:n]}
segments = {'whole run': far_active,
            'first second': far_active & ~converged,
            'single talk, after 1 s': far_active & converged & ~double_talk,
            'double talk': far_active & double_talk}

# D/e: mic energy over output energy. Echo domain: echo energy over the echo left in the output (output - near end),
# the meaningful one during double talk, where the near-end speech is supposed to stay in the output.
print(f"\nERLE vs vhdl_stimulus.txt ({n_frames} frames, Python normalisation: {NORMALIZATION})")
print(f"{'':36s}" + "".join(f"{name + ' D/e':>15s}{name + ' echo':>15s}" for name in outputs))
for seg_name, mask in segments.items():
    row = f"{seg_name + f' ({mask.sum()} frames)':36s}"
    for e in outputs.values():
        row += f"{erle_db(E_mic, frame_energy(e), mask):13.2f}dB{erle_db(E_echo, frame_energy(e - near), mask):13.2f}dB"
    print(row)


# %% Peak and mean ERLE on a trustable region
# The longest stretch with the far end talking, no double talk and past the first second, cut to its last
# TRUST_SECONDS[1] seconds (the most converged part). The near end is silent there, so D/e and echo-domain ERLE agree.
def runs(mask):
    """(start, stop) frame indices of every run of True frames."""
    edges = np.flatnonzero(np.diff(np.concatenate(([0], mask.astype(int), [0]))))
    return list(zip(edges[::2], edges[1::2]))


def trust_curve(e):
    """D/e ERLE curve inside the trustable region; energies outside it are zeroed so the smoothing stays inside."""
    return erle_curve(np.where(trust, E_mic, 0), np.where(trust, frame_energy(e), 0), trust)


min_frames, max_frames = (round(s * fs / hopSize) for s in TRUST_SECONDS)
tr0, tr1 = max(runs(far_active & converged & ~double_talk), key=lambda r: r[1] - r[0])
tr0 = max(tr0, tr1 - max_frames)
trust = np.zeros(n_frames, dtype=bool)
trust[tr0:tr1] = True
trust_span = (tr0 * hopSize / fs, tr1 * hopSize / fs)
trust_erle = {name: trust_curve(e) for name, e in outputs.items()}

print(f"\nTrustable region {trust_span[0]:.2f}-{trust_span[1]:.2f} s ({tr1 - tr0} frames, {trust_span[1] - trust_span[0]:.2f} s),"
      f" D/e ERLE curve with {SMOOTH_FRAMES}-frame smoothing")
if tr1 - tr0 < min_frames:
    print(f"  WARNING: shorter than {TRUST_SECONDS[0]} s, the stimulus has no longer single-talk stretch")
print(f"{'':12s}" + "".join(f"{name:>12s}" for name in outputs))
print(f"{'peak ERLE':12s}" + "".join(f"{np.nanmax(c):10.2f}dB" for c in trust_erle.values()))
print(f"{'  at':12s}" + "".join(f"{(np.nanargmax(c) + 0.5) * hopSize / fs:11.2f}s" for c in trust_erle.values()))
print(f"{'mean ERLE':12s}" + "".join(f"{np.nanmean(c):10.2f}dB" for c in trust_erle.values()))


# %% Python vs Vivado
def sqnr_ls(ref, x):
    """Same metric as RTLdatacreationCMC/datacheck.py: least-squares optimal scale, then SQNR."""
    scale = np.dot(ref, x) / np.dot(ref, ref)
    err = x - ref * scale
    return 10 * np.log10(np.sum((ref * scale) ** 2) / np.sum(err ** 2)), scale


if e_rtl is not None:
    conv = np.repeat(converged, hopSize)
    y_rtl = mic - e_rtl[:n]
    print("\nPython vs Vivado (LS-scaled SQNR, Python as reference)")
    for label, sel in (('whole run', slice(None)), ('after 1 s', conv)):
        s_y, a_y = sqnr_ls(y_py[:n][sel], y_rtl[sel])
        s_e, a_e = sqnr_ls(e_py[:n][sel], e_rtl[:n][sel])
        print(f"  {label:10s}: echo estimate y {s_y:6.2f} dB (scale {a_y:.4f}) | output e {s_e:6.2f} dB (scale {a_e:.4f})")
    print("  e is the small residual left after cancellation, so its SQNR sits well below y's even when both cancel"
          " equally well; judge the I/O test by the ERLE table and the y SQNR.")

# %% Plots
C_PY, C_RTL = '#2a78d6', '#eb6834'                # categorical slots 1 and 2
C_CONTEXT, C_DIFF, C_LIGHT = '#898781', '#52514e', '#e1e0d9'   # mic (context), difference trace, grid and double-talk bands
t = np.arange(n) / fs
t_frame = (np.arange(n_frames) + 0.5) * hopSize / fs
dt_spans = [(a * hopSize / fs, b * hopSize / fs) for a, b in runs(double_talk)]


def style(ax, ylabel):
    for i, (a, b) in enumerate(dt_spans):
        ax.axvspan(a, b, color=C_LIGHT, alpha=0.6, lw=0, label='double talk' if i == 0 else None)
    ax.grid(True, color=C_LIGHT, linewidth=0.6)
    ax.set_ylabel(ylabel)
    # Outside the plot area so it never covers data; thicker legend lines than the thin traces
    leg = ax.legend(loc='upper left', bbox_to_anchor=(1.01, 1.0), frameon=False)
    for line in leg.get_lines():
        line.set_linewidth(2.0)


# Zoom in on the interactive window to compare waveform details; the difference panel shows where they diverge.
# Constrained layout re-fits labels and the outside legends whenever the window is resized.
fig1, axs1 = plt.subplots(3 if e_rtl is not None else 1, 1, figsize=(13, 9 if e_rtl is not None else 4), sharex=True,
                          squeeze=False, layout='constrained')
axs1 = axs1[:, 0]
fig1.canvas.manager.set_window_title('I/O test: signals')
out_main, out_name, out_color = (e_py[:n], 'Python', C_PY) if e_rtl is None else (e_rtl[:n], 'Vivado', C_RTL)
axs1[0].plot(t, mic, color=C_CONTEXT, linewidth=0.6, label='Mic (D input)')
axs1[0].plot(t, out_main, color=out_color, linewidth=0.6, label=f'{out_name} output e')
axs1[0].set_title(f"Mic and {out_name} output")
style(axs1[0], "Amplitude (12-bit LSB)")
if e_rtl is not None:
    axs1[1].plot(t, e_py[:n], color=C_PY, linewidth=0.6, label='Python output e')
    axs1[1].plot(t, e_rtl[:n], color=C_RTL, linewidth=0.6, alpha=0.8, label='Vivado output e')
    axs1[1].set_title("Python and Vivado output")
    style(axs1[1], "Amplitude (12-bit LSB)")
    axs1[2].plot(t, e_rtl[:n] - e_py[:n], color=C_DIFF, linewidth=0.6, label='Vivado - Python')
    axs1[2].set_title("Output difference")
    style(axs1[2], "Amplitude (12-bit LSB)")
axs1[-1].set_xlabel("Time (s)")

fig2, axs2 = plt.subplots(2, 1, figsize=(13, 7), sharex=True, layout='constrained')
fig2.canvas.manager.set_window_title('I/O test: ERLE')
for ax in axs2:
    # Hatched, so it stays distinct from the solid double-talk bands
    ax.axvspan(*trust_span, facecolor='none', edgecolor=C_CONTEXT, hatch='/', lw=0, alpha=0.5, label='trustable region')
for name, e, color in (('Python', e_py[:n], C_PY), ('Vivado', None if e_rtl is None else e_rtl[:n], C_RTL)):
    if e is None:
        continue
    axs2[0].plot(t_frame, erle_curve(E_mic, frame_energy(e), far_active), color=color, linewidth=1.5, label=name)
    axs2[1].plot(t_frame, erle_curve(E_echo, frame_energy(e - near), far_active), color=color, linewidth=1.5, label=name)
    # Mean (dashed, across the region) and peak (dot) of the trustable-region curve
    c = trust_erle[name]
    k = np.nanargmax(c)
    axs2[0].plot(trust_span, [np.nanmean(c)] * 2, '--', color=color, linewidth=1.5, label=f'{name} mean {np.nanmean(c):.1f} dB')
    axs2[0].plot(t_frame[k], c[k], 'o', color=color, markersize=8, markeredgecolor='white', markeredgewidth=1.5, zorder=3,
                 label=f'{name} peak {c[k]:.1f} dB')
axs2[0].set_title(f"ERLE, Mic / output (D/e), {SMOOTH_FRAMES}-frame smoothing")
axs2[1].set_title("Echo-domain ERLE, Echo / echo left in the output")
style(axs2[0], "ERLE (dB)")
style(axs2[1], "ERLE (dB)")
axs2[1].set_xlabel("Time (s)")

plt.show()
# %%
