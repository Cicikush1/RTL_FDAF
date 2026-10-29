# %%
import scipy.io as sio
import matplotlib.pyplot as plt
import numpy as np
import h5py
import os
from pathlib import Path

scale_factor = 2048.0  # 2^11
max_float = 2047.0 / 2048.0  # 0.99951171875

try:
    BASE_DIR = Path(__file__).resolve().parent
except NameError:
    BASE_DIR = Path.cwd()

mat_file_path = BASE_DIR / 'fdaf_signals.mat'

try:
    mat_data = sio.loadmat(mat_file_path)
    print("Success! File loaded from:", mat_file_path)
except FileNotFoundError:
    print("Error: Could not find the file at", mat_file_path)

# %%
fixed_data_arrays = []
variables_to_plot = {k: v for k, v in mat_data.items() if not k.startswith('__')}

all_raw_arrays = [np.squeeze(data) for data in variables_to_plot.values()]

global_max = np.max([np.max(np.abs(arr)) for arr in all_raw_arrays])

num_vars = len(variables_to_plot)
fig, axes = plt.subplots(num_vars, 1, figsize=(10, 3 * num_vars))

if num_vars == 1:
    axes = [axes]

for i, (var_name, data) in enumerate(variables_to_plot.items()):
    ax = axes[i]

    clean_data = np.squeeze(data) 
    normalized_data = clean_data / global_max
    #Code from some stackoverflow thingy
    y_clamped = np.clip(normalized_data, -1.0, max_float)
    y_fixed = np.round(y_clamped * scale_factor).astype(np.int16)
    fixed_data_arrays.append(y_fixed)

    ax.plot(y_fixed)
    ax.set_title(f"Variable: {var_name}")
    ax.grid(True, linestyle='--', alpha=0.6)

plt.tight_layout()
plt.show()
# %%
plt.figure()
diffsig = axes[2].lines[0].get_ydata() - axes[1].lines[0].get_ydata()

plt.plot(diffsig)
plt.show()
# %%
output_txt = BASE_DIR / 'vhdl_stimulus_test.txt'
bit_width = 12

with open(output_txt, 'w') as f:
    for samples in zip(*fixed_data_arrays):
        row_strings = []
        for val in samples:
            if val < 0:
                val = (1 << bit_width) + val

            row_strings.append(f"{val:012b}")

        f.write(" ".join(row_strings) + "\n")

print(f"Success! VHDL stimulus file written to: {output_txt}")

# %%
bit_width = 12
threshold = 1 << (bit_width - 1)  # 2048
offset = 1 << bit_width           # 4096

try:
    BASE_DIR = Path(__file__).resolve().parent
except NameError:
    BASE_DIR = Path.cwd()

filename = BASE_DIR / 'vhdl_stimulus_test.txt'

sig1, sig2, sig3, sig4 = [], [], [], []

with open(filename, 'r') as f:
    for line in f:
        binary_strings = line.strip().split()
        if len(binary_strings) != 4:
            continue
        
        row_vals = []
        for b in binary_strings:
            val_unsigned = int(b, 2)

            if val_unsigned >= threshold:
                val_signed = val_unsigned - offset
            else:
                val_signed = val_unsigned
                
            row_vals.append(val_signed)
            
        sig1.append(row_vals[0])
        sig2.append(row_vals[1])
        sig3.append(row_vals[2])
        sig4.append(row_vals[3])

data_arrays = [np.array(sig1), np.array(sig2), np.array(sig3), np.array(sig4)]
titles = ['Signal 1 (Speaker)', 'Signal 2 (Echo)', 'Signal 3 (Mic)', 'Signal 4 (Clean)']

fig, axes = plt.subplots(4, 1, figsize=(10, 12), sharex=True)
fig.canvas.manager.set_window_title('VHDL Text File Verification')

for i in range(4):
    axes[i].plot(data_arrays[i], color='teal', linewidth=1.5)
    axes[i].set_title(titles[i] + " [12-bit Fixed Point]")
    axes[i].set_ylabel("Amplitude")
    axes[i].grid(True, linestyle='--', alpha=0.6)

axes[3].set_xlabel("Sample Index")
plt.tight_layout()
plt.show() 
# %%
