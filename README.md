# Grain Boundary Detection and Grain Size Distribution Analysis

## Overview
This MATLAB script processes a micrograph image (e.g., an SEM image of an etched sample) to identify grain boundaries, highlight them in the processed image, and compute the grain size distribution. The script uses image processing techniques such as edge detection, watershed segmentation, and region properties analysis to achieve this.

## Requirements
- **MATLAB**: Ensure you have MATLAB installed (R2018b or later recommended).
- **Image Processing Toolbox**: Required for functions like `imgaussfilt`, `edge`, `imdilate`, `bwareaopen`, `watershed`, and `regionprops`.
- **Input Image**: A micrograph image in `.jpg`, `.png`, or `.tif` format, with visible grain boundaries (e.g., an etched SEM image).

## Usage
1. **Prepare the Image**: Ensure your micrograph image is ready and has a known scale bar (e.g., 50 µm) for accurate grain size calculation.
2. **Run the Script**:
   - Open MATLAB.
   - Copy the script into a `.m` file (e.g., `grain_analysis.m`) or directly into the MATLAB command window.
   - Run the script.
3. **Upload the Image**:
   - A file selection dialog will prompt you to upload your micrograph image.
   - Select an image file (`.jpg`, `.png`, or `.tif`) and click "Open".
4. **View Results**:
   - The script will display a figure with two subplots:
     - Left: The processed image with grain boundaries highlighted in red.
     - Right: A histogram of the grain size distribution (in µm).
   - The average grain size and quartiles (Q1, Q2, Q3, and 90th percentile) will be printed in the command window.
   - The processed image will be saved in the same directory as the input image with `_processed` appended to the filename (e.g., `image_processed.jpg`).

## Customization
- **Scale Bar Calibration**:
  - The script assumes a 50 µm scale bar corresponds to 100 pixels (`pixels_per_um = 100 / 50`).
  - Adjust the `pixels_per_um` value based on your image's scale bar. For example, if 50 µm is 200 pixels, set `pixels_per_um = 200 / 50`.
- **Edge Detection Parameters**:
  - The Canny edge detection thresholds are set to `[0.05 0.2]`. Adjust these values if the grain boundaries are not well-detected (e.g., increase for more edges, decrease for fewer).
- **Noise Reduction**:
  - The Gaussian filter sigma is set to `2` (`imgaussfilt(img_gray, 2)`). Increase this value for noisier images to smooth more, or decrease for sharper images.
- **Morphological Operations**:
  - The dilation structuring element (`se = strel('disk', 1)`) and small object removal threshold (`bwareaopen(binary_img, 50)`) can be adjusted for better boundary connectivity and noise removal.

## Outputs
- **Processed Image**: The input image with grain boundaries highlighted in red, saved as `<input_filename>_processed.jpg`.
- **Grain Size Distribution**:
  - A histogram showing the distribution of grain diameters (in µm).
  - Command window output includes:
    - Average grain size.
    - First quartile (Q1), second quartile (median, Q2), third quartile (Q3).
    - 90th percentile (90% of grains are smaller than this size).

## Example
If your input image is `micrograph.jpg`:
- Run the script and select `micrograph.jpg`.
- The script will generate `micrograph_processed.jpg` with highlighted grain boundaries.
- A figure will show the processed image and a histogram of grain sizes.
- The command window might output:
  ```
  Average Grain Size: 12.34 µm
  First Quartile: 8.56 µm
  Second Quartile: 11.78 µm
  Third Quartile: 15.90 µm
  Only ten percent of the grains are of size greater than: 20.12 µm
  Processed image saved as: micrograph_processed.jpg
  ```

## Notes
- The script assumes grains are roughly circular for equivalent diameter calculation. For more complex shapes, consider using other metrics like Feret diameter.
- If grain boundaries are not well-detected, try adjusting the edge detection thresholds or preprocessing steps.
- Ensure the scale bar calibration is accurate for meaningful grain size measurements.

## License
This script is provided as-is for educational and research purposes. Feel free to modify and distribute it as needed.
