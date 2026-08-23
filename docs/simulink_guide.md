# eDRis Simulink Bandwidth Controller Guide

Since your project is sponsored by MathWorks (SIH 26038), the judges will want to see an actual **Simulink Block Diagram**, not just a MATLAB script. 

While your first MATLAB window is busy preprocessing the images, you can open a **second window of MATLAB** and follow these steps to build your Simulink model!

## Step 1: Create the Model
1. In your new MATLAB window, click the **Simulink** button on the Home tab.
2. Click **Blank Model**.
3. Save it as `simulate_bandwidth_controller.slx` inside your `eDRis/src` folder.

## Step 2: Add the Core Blocks
Open the **Library Browser** and drag the following blocks onto your canvas:

1. **Inport** (x2): 
   - Name one `Raw_Image`
   - Name the other `Network_Speed_Mbps`
2. **MATLAB Function**: 
   - Name it `Compressor`
3. **Switch** (from Signal Routing): 
   - This will route the data based on the network speed.
4. **Constant**:
   - Set the value to `5` (This represents our 5 Mbps threshold for 4G).
5. **Outport** (x1):
   - Name it `Transmitted_Payload`

## Step 3: Wire the Logic
1. Double-click the **MATLAB Function** block and paste this code:
   ```matlab
   function compressed_img = fcn(raw_img)
       % Simulate 2G compression
       compressed_img = imresize(raw_img, 0.15);
   end
   ```
2. Connect `Raw_Image` to the input of the `Compressor` block.
3. Wire the **Switch** block:
   - **Top Input (True)**: Connect to `Raw_Image` directly.
   - **Middle Input (Condition)**: Connect to `Network_Speed_Mbps`.
   - **Bottom Input (False)**: Connect to the output of your `Compressor` block.
4. Double-click the **Switch** block and set the threshold to `u2 >= Threshold`. 
   - Set the Threshold value to `5`.
5. Connect the output of the **Switch** to your `Transmitted_Payload` Outport.

## Step 4: Run and Test
You have now built a visual simulation of your rural edge node! If the network drops below 5 Mbps, the Switch automatically routes the image through the compressor before transmitting it to the cloud. You can take a screenshot of this beautiful block diagram for your Pitch Deck!
