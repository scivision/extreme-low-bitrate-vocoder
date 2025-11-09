# Extreme low bit rate vocoder

This code is from a 2011 hackathon and uses Signal Processing Toolbox.

`Main.m` is the only program to run.

## Voiced Speech Compression Experiments at 625 and 312 bits per second

The field of speech compression via digital signal processing techniques has flourished for over four decades since
[Bogert, Healy, and Tukey][1]
presented their novel idea of cepstral analysis.
The present state-of-the-art is highly intelligible (MOS > 3.5) speech compression algorithms with transmission rates of 300 bps or less.
Raytheon advertises a
[300bps NRV vocoder][2]
as does
[TWELP][3].
The Speex and
[Opus algorithms][4]
allows highly intelligible speech transmission at 2kbps, and are freely available.
A target set by
[Rabiner][5]
in 1978 was a 600bps encoder in 1978, when the price of 100 seconds of lightly compressed voice recording was estimated to be about $4,000 in computer memory, which audio compressed to 600bps was predicted by Rabiner to cost $60.
Commonly available dialup modems did not commonly exceed 2400bps until the early [1980s][6].
Even today, applications such as Apple’s Siri and Google Gemini voice features require frequent transmissions of several seconds of voice so end users can search the Internet for directions or information rapidly.
To avoid excessive data usage and battery drainage, highly compressed voice continues to be of high relevance.

[1]: https://share.google/zNgPkrO6Dw6aQtiCw
[2]: https://ieeexplore.ieee.org/document/5680311
[3]: https://dspini.com/vocoders/lowrate/twelp-lowrate/twelp300
[4]: https://commons.wikimedia.org/wiki/File:Speech_12dB_opus_2kbps.opus
[5]: L. R. Rabiner and R. W. Schafer. “Digital Processing of Speech Signals.” Prentice-Hall, New Jersey, 1978.
[6]: G. B. Giannakis, “Highlights of Signal Processing for Communications,” IEEE Sig. Proc. Mag., pp. 14-50, Mar. 1999.

## Introduction

We examine methods of speech compression and apply them in a MATLAB program.
The provided speech samples consist of voiced male speech, specifically the vowels “ah”, “ee” and “oh.”
The goal is to compress the speech as much as possible while still maintaining basic intelligibility, such that one can still distinguish between these vowels (e.g. MOS > 1.5).
The goal we set out to achieve was 312 bps.
Performance at 625 bps is much better than 312 bps.

A fundamental principle used in this project is understanding cepstral analysis. The human speech system has been discussed at great length in the literature and is commonly broken into three segments: Excitation (vocal cords), Filter Cascade (vocal tract), and Load (lips). A rich body of literature describes sophisticated mathematical relations and models thereof. One of the most important steps to understanding speech analysis and synthesis is that the vocal output of a human convolves their vocal cord excitation with the vocal tract, which is often modeled as an all-pole filter for voiced speech. The transfer function of this system is often simplified to something of the form below, following Rabiner [4]

𝐻(𝑒𝑗𝜔)=𝐺(𝑒𝑗𝜔)𝑉(𝑒𝑗𝜔)𝑅(𝑒𝑗𝜔)


Where:

Glottal Pulse Model (we implement following Rosenberg[])

𝑉(𝑒𝑗𝜔) = Vocal Tract Model (all-pole model)

𝑅(𝑒𝑗𝜔) = Lip Radiation model (differentiator)

The Glottal Pulse Model is implemented in glotEx.m, and the reader may verify the equations used there to be as follows, based off of [9]:


𝑔(𝑡=0..𝑡𝑓)=𝑠𝑖𝑛2(𝜋2𝑡−𝑡0𝑡𝑓−𝑡0)

𝑔(𝑡=𝑡𝑓..𝑇𝑝)=𝑐𝑜𝑠(𝜋2𝑡−𝑡𝑓𝑇𝑝−𝑡𝑓)


The Vocal Tract Model has been shown by Rabiner and many others to be a suitable model of the reflections occurring in the vocal tract.
By selecting some reasonable number of simulated reflections, typically chosen in the literature to be in the 10 to 15 section range, good simulation of speech can be achieved.
 solved for via the Toeplitz matrix structure of the Levinson-Durbin recursion, as implemented in this program.

𝑉(𝑧)=𝐺1−∑𝑝𝑘=1𝛼𝑘𝑧−𝑘

The Lip Radiation Model has been shown by Rabiner and numerous other authors to be a reasonable model of the finite load presented by the mouth opening. We choose a typical model of the form following Rabiner and many others:

𝑅(𝑧)=(1−𝛽𝑧−1)

The Vocal Tract Model has been shown by Rabiner and many others to be a suitable model of the reflections occurring in the vocal tract. By selecting some reasonable number of simulated reflections, typically chosen in the literature to be in the 10 to 15 section range, good simulation of speech can be achieved [4][6]. The all-pole model takes the form below, which as we have learned in class lends itself well to LPC modeling, solved for via the Toeplitz matrix structure of the Levinson-Durbin recursion, as implemented in this program.

𝑉(𝑧)=𝐺1−∑𝑝𝑘=1𝛼𝑘𝑧−𝑘

The Lip Radiation Model has been shown by Rabiner and numerous other authors to be a reasonable model of the finite load presented by the mouth opening. We choose a typical model of the form following Rabiner and many others:

𝑅(𝑧)=(1−𝛽𝑧−1)

As noted in the algorithm description, we found
𝛽=0.99

to experimentally be a suitable value.

Finding the constituents to the optimal H(z) will result in a speech compressor system that uses the least bits possible for a given voice quality. In particular, to estimate G(z) and V(z) requires cepstral analysis, since G(z) and V(z) are by definition convolved at the speaker. The cepstrum defined by Oppenheim [6] and Proakis is:

𝑥ˆ[𝑛]=12𝜋∫𝜋−𝜋𝑙𝑜𝑔[𝑋(𝑒𝑗𝜔)]𝑒𝑗𝜔𝑛𝑑𝜔

By the properties of logarithms, the product of G(z)V(z) can be represented in the cepstrum as

𝑔ˆ[𝑛]+𝑣ˆ[𝑛]

and so on, thereby allowing separation of vocal tract responses V(z) from the glottal excitation G(z). The process of “liftering” as discussed by lifter.m allow this selection to be made almost trivially easy.

This project did not comprise an exhaustive optimization by any means, but was a reasonable first pass at applying introductory graduate-level knowledge to the task.

## Algorithm

The program uses several modules to process data.
A separate GUI was developed to look at Spectrograms of the data.
The main program did not yet have a GUI developed.
Instead, the user enters relevant parameters into “setparams.m” as text.
A simplified block diagram overview of the final implementation is given in Figure 1 for the transmitter, and Figure 2 for the receiver.

<figure>
<img alt="Picture1" src="https://github.com/user-attachments/assets/dc1950bb-1074-4e45-9ab7-9e9ffbaed549" />
<caption>Figure 1: Transmitter</caption>
</figure>

<figure>
<img alt="Picture2" src="https://github.com/user-attachments/assets/27cfcc4d-24d4-4a9d-b601-3743bc350085" />
<caption>Figure 2: Receiver</caption>
</figure>

### SetParams.m

The program loads user parameters such as:

Cepstrum liftering parameters:

Low-quefrency pass: to allow estimation of glottal pulse period

High-Quefrequency pass: to allow LPC modeling of vocal tract, all-pole model

Pre-emphasis freq. for LPC model

Window type for time-domain signal (e.g. Hamming)

Window length (typically 256 samples)

Frame length (typically 128 samples—50% overlap)

VOX start/stop parameters

Set glottal excitation:

Simulated glottal pulse train

Feedforward to estimate residual error

Frame length: 128 samples (16 milliseconds)

Window length: 256 samples (32 milliseconds

That is, 50% overlap between windows.

Window type: Hamming (other types selectable)

The program can optionally Low-Pass filter the incoming signal, but this was experimentally determined to not be necessary (it could in the future be deemed useful to band-pass filter the signal, by ignoring frequency bands with little content in “MyFilterbank.m”.

### getSound.m

Simple voice detection algorithm is used, by detecting the first and last time indices that the sound crosses a threshold amplitude value. Before and after this time, the sound is set to zero. This helps avoid the program making filters for non-existent speech.

Optionally, a 200-tap FIR filter can be used to low-pass filter, but this functionality was not used for this program.

### windowData.m

Break up data into frames, and window each frame (Hamming window) in “windowData.m”

Currently, can choose “Hann”, “Bartlett (triangular)”, “Hamming”, and “rectangular”. The frame/window arrangement is seen in Figure 3.

<figure>
<img src="https://github.com/user-attachments/assets/d01ce420-99d6-44ca-b34f-7f1e3cbd52fa" />
 <caption>Figure 3: a column of data</caption>
</figure>

There are “nFrames” frames of data, ultimately arranged as in Figure 4. 

<figure>
<img src="https://github.com/user-attachments/assets/2d419578-7540-4b59-bbc7-3313675260fa" />

<caption> Figure 4: Windowed Data Arrangement</caption>
</figure>

The data is windowed in a fashion such that the overlap-add condition is satisfied, that is, that adding each column offset by the frame length will equal the original signal, or more typically, the original signal processed in these short-time segments, and reassembled via overlap-add. 
By zero-padding by the overlap amount at the beginning and end of the overall time period to be processed, the full processed signal is recovered as in Figure 9. 
Because the original signal was 12800 samples long, the output signal is also 12800 samples long when the slow-time signal is completely reconstructed as a processed system output.  

From the MATLAB documentation for ‘hamming.m’, the Hamming window used is depicted in Figure 5. 

𝑤(𝑛) = 0.54 − 0.46𝑐𝑜𝑠(2𝜋𝑛𝑁), 0 ≤ 𝑛 ≤ 𝑁 

<figure>
 <img src="https://github.com/user-attachments/assets/f64466d4-b2c1-4b65-911e-f46f08e4fe8b" />

<caption>Figure 5: Hamming window used on short-time sections</caption>
</figure>
 
 The “symmetric” option is used so that the overlap-add condition holds, as tested with unit input. 


### MyFilterbank.m 

This code essentially takes the short-time segments and implements an FFT on each section according to frequencies in Hz. 
In the future, the output could be examined like a spectrogram, to allow rejection of unimportant frequencies, and devotion of more energy to useful frequencies. 

### EstimateGlottalFreq.m 

This code iterates through each short-time window of data (again, 256 sample window, with 50% overlap each frame contains 128 “new” samples). 
The algorithm is as follows: 

1. Take Complex Cepstrum of signal, phase unwrapped 
2. High-time “Lifter” the short-time segment to eliminate high-time frequencies that are from vocal tract reflections. This is accomplished using lifter.m 
3. Use the exhaustive search “max.m” of MATLAB to find the highest amplitude quefrency content in the glottal quefrency range (< 0.005 quefrency seconds) 
4. For plotting or diagnostic purposes, the liftered glottal cepstrum is transformed back to the time domain as the “LifteredGlottal” variable

### Lifter.m 

Since obviously FFT operations are inherent in computing the complex cepstrum, the MATLAB cepstral transform accomplished by taking `real(ifft(log(abs(fft(xWind))))`, where xWind is the short-time windowed segment of speech of length WinL samples, the cepstrum will start with the highest quefrencies at index 1, proceeding to the lowest quefrencies at index Win/2, and then going symmetrically back up to the highest quefrencies at index WinL. 
To accomplish liftering as discussed throughout the literature, we implement the following algorithm applied to input cepstrum “C”, to yield liftered output “CL”. 

High-time lifter (eliminate high-time quefrencies over “cutoff” value) 

𝐶𝐿={𝐶,∣∣𝑖𝑛𝑑𝑒𝑥∣∣≤𝑐𝑢𝑡𝑜𝑓𝑓0,∣∣𝑖𝑛𝑑𝑒𝑥∣∣>𝑐𝑢𝑡𝑜𝑓𝑓

In similar manner, the low-time lifter[4] is applied via the algorithm: 

𝐶𝐿={𝐶,∣∣𝑖𝑛𝑑𝑒𝑥∣∣≥𝑐𝑢𝑡𝑜𝑓𝑓0,∣∣𝑖𝑛𝑑𝑒𝑥∣∣<𝑐𝑢𝑡𝑜𝑓𝑓

### GenerateLPCcoeff.m 

For each frame of short-time windowed speech data, the following algorithm steps occur: 

Apply the effect of the lips/mouth opening as an FIR filter with a zero near 
𝜔=0
 
This creates approximately a 6dB/octave preemphasis curve. The frequency response chosen for this filter was [8]:  

𝐻(𝑧)=𝑧−0.99𝑧

Low-time lifter (reject low-time quefrencies) the glottal excitation pulse train, so as to capture the vocal tract reflection characteristics alone. 

Transform the liftered cepstrum back to the time domain, now containing only vocal tract responses. 

Execute Levinson-Durbin recursion using LevDurb.m, to develop Linear Prediction Coefficients that will be used as a simplified vocal tract model. Here we chose to use 15 coefficients. 

The error residuals are computed by feeding-forward the original audio thoroughly the newly designed filter using the LPC coefficients and gains for each short time section. 
Using these residuals, virtually perfect speech can be recovered—of course, there will be a large number of bit required to transmit the residuals unless they are quantized and themselves compressed. 

The “roots” function of MATLAB is used to compute the roots of the LPC model for each short time segment.  

Using the Arctangent function atan2 of MATLAB, the angular frequency is extracted from each root, then converted to Hertz using the sampling frequency 8000Hz. 

At this time, the poles occurring outside the unit circle are counted. It would be possible to using the inverse conjugate of each pole with an all-pass filter section to correct the gain as discussed in class. 
At this time, there wasn’t enough time to implement this, so the end user is only alerted to potential LPC model instabilities. 

### LevDurb.m 

While the full Levinson-Durbin recursion was discussed in class and in Oppenheim [6] and many other sources, to save time, the “levinson” function of MATLAB was used. The autocorrelation coefficients needed are pre-computed in LevDurb.m, and then passed to MATLAB’s levinson.m. The gain G for each short-time section is determined by using the indirect error EI from levinson.m as: 

𝐺 = sqrt(𝐸𝐼)

First, we lifter the cepstrum to select only the vocal tract as seen in Figure 4. Next, only select the glottal excitation as in Figure 6. 
We obtain the glottal excitation as in Figure 7. 

<figure>
 <img src="https://github.com/user-attachments/assets/9582e7ef-a772-440a-9e18-de62dce2a48e" />
 <caption>Figure 6: High-time Liftered Cepstrum, selecting only quefrencies regarding glottal excitation</caption>
</figure>

<figure>
 <img src="https://github.com/user-attachments/assets/1d099685-99f0-45c6-80a8-d17d29bcec6f" />

 <caption>Figure 7. Glottal excitation synthesized. </caption>
</figure>

### LPCceps.m 

Looking at the amplitudes of the cepstrum of the frequency response of the LPC frequency response, we observe that only the first few values contribute significant amplitudes. The transition from LPC to complex cepstrum is accomplished via MATLAB’s DSP toolbox, due to limited time to write a fresh algorithm. The LPC to Complex Cepstrum transform takes place via the following three equations, from the MATLAB documentation for the DSP System Toolbox: 

𝑐0=𝑙𝑜𝑔𝑒𝑃

𝑐𝑚=−𝑎𝑚+1𝑚∑𝑚−1𝑘=1[−(𝑚−𝑘)𝑎𝑘𝑐𝑚−𝑘],1≤𝑚≤𝑝


𝑐𝑚=∑𝑝𝑘=1[−(𝑚−𝑘)𝑚𝑎𝑘𝑐𝑚−𝑘],𝑝<𝑚<𝑛
 
 
Doing this transformation, it is observed that only the first 3-6 values of the LPC cepstrum are of significant amplitude. It was experimentally determined that by setting all the but the first 3 or 4 values to zero, the intelligibility of the voice was mostly maintained, while gaining another large factor of compress (15 LPC numbers down to as few as 3 LPC cesptral coefficients!). These LPC cepstral coefficients will be quantized down to 4 bits for transmission, given another factor of 8 savings over the 32-bit floating point numbers. 

To go from LPC Cepstrum back to LPC coefficients will occur in the receiver. However, for testing purposes the inverse algorithm was implemented here as well. From the MATLAB documentation for the DSP System Toolbox, the inverse transform consists of the following two equations, where the 
𝑎𝑚

are the LPC coefficients for order p: 

𝑎𝑚=−𝑐𝑚−1𝑚∑𝑚−1𝑘=1[(𝑚−𝑘)𝑎𝑘𝑐𝑚−𝑘]


𝑃=𝑒𝐶0

 
; where m=1,2,…,p 

The frequency response of the filter is computed for later plotting. The feedfoward error is computed, but is not transmitted at this time (possible future voice quality improvements after compression). 

transmitterCeps.m 

Now the LPC cepstral coefficients are ready to transmit. The components of each transmitted frame are: 


Variable | Purpose | Bits / frame | Bits / second
---------|---------|--------------|---------------

fundExcite | fundamental glottal excitation frequency | 2 | 125
LPCcep  | LPC cepstral coefficients (4 numbers per frame) | 4*2 = 8 | 500 

Table 1: Data Parameters 

Since the sample rate is fixed at 8000Hz for the given audio samples, and each frame is 128 samples long, each frame is 128/8000 = 16 milliseconds long. 
Thus from Table 1, it is evident that 625 bits per second are used to transmit the voice, as verified by checking the file sizes on disk.  
An obvious way to go to 312 bits per second is to double the frame length. 
However, given the short time allotted, there wasn’t enough time to optimize the routine for 312bps. Noise was produced at 312bps, but it was too hard to distinguish between the voiced sounds to make 312bps useful at this time. 
Certainly, Raytheon and others have shown that quality speech is possible at 300bps. 


### receiverCeps.m 

This subroutine reads the “transmitted” file from disk, and transforms the 2-bit quantized data back to floating point (not every MATLAB feature works well with non-floating point numbers). 
The Cepstral Coefficients are transformed back to LPC Poles. 
To save transmission space, the vocal tract model gains are set to be identically one—this can easily be changed at a future time. 

### RegenerateSignalFromLPCcoeff.m 

The vocal tract model transmitted through the disk file needs to be driven with glottal pulses, as provided by glotEx.m. 
At this time, no measurements of speaker glottal pulses were undertaken, so an arbitrary shape was used based off of Rosenberg [9]. 
The frames are finally once again rejoined into a vector of the same length of the original signal in OLA.m.

### glotEx.m 

Based on Rosenberg [9], the glottal pulse is an effort at making a semi-realistic driving pulse train to the simulated vocal tract. 
Instead of merely impulses, the shape in Figure 8 is realized. 
Each frame will have a few of these pulses, depending on the measured fundamental glottal frequency for that frame. 

<figure>
 <img src="https://github.com/user-attachments/assets/ddeb75b1-21cc-4a9d-b153-786d550e2d35" />

 <caption> Figure 8: Glottal pulse train</caption>
</figure>

### OLA.m 

The job of any overlap-add algorithm is to add the windowed data (in this case, Hamming windowed data with 50% overlap) such that the overlap-add condition is satisfied. The algorithm is described here and illustrated in Figure 9.
References for such algorithms are given in Proakis, Oppenheim, etc. 

Algorithm: 

1. initialize vector x with zeros, for length of original signal
2. insert first column of xWind, length WinL samples into first positions of vector x 
3. take second column of xWind samples, and increment in x vector by FrameL 
4. add 2nd column to first column--some values overlap, compensating for window originally used 
5. repeat this process across all columns of xWind

<figure>
 <img src="https://github.com/user-attachments/assets/f50f6182-663d-4187-ac10-ab0031f5cece" />

 <caption>Figure 9: recovering the processed output signal as a vector via overlap-add. </caption>
</figure>

## Experiment Results 

Plots comparing spectrum are given for “ah” in Figure 10, “ee” in Figure 11, and “oh” in Figure 12. 
We see that the harmonic content of the original human glottal pulses is well represented as the “picket fence” of spectral spikes. 
The heavy compression inflicted by LPC modeling and cepstral censoring of the LPC model causes the LPC Spectrum to be a good, though not exact match to the overall spectral envelope. 
The blue line directly compares synthesized spectrum with the black dashed original spectrum. 
Essentially, the goal is to have the blue line match the black line as closely as possible overall, but especially near the first three formant frequencies, with from Rabiner, et al, are the most important to speech reproduction and comprehension. 

Of course, the human ear is the final decider on simulated voice quality. 
Overall, the speech quality is quite rough at 625bps, but this is only a first pass at the task. 
With more time, certainly better results could be achieved, even down to 300bps. 

<figure>
 <img src="https://github.com/user-attachments/assets/a939667a-a106-47af-baf6-5c335646692c" />

 <caption>Figure 10: "ah" sound spectrum</caption>
</figure>

<figure>
 <img src="https://github.com/user-attachments/assets/5bf7ca6f-fb8a-4a46-8895-b9cbea01be51" />

<caption>Figure 11: "ee" sound spectrum</caption>
</figure>


<figure>
 <img src="https://github.com/user-attachments/assets/c96d9f52-eca8-4972-ad3c-01eb97dd90d8" />

<caption>Figure 12: "oh" sound spectrum</caption>
</figure>

​[6] A. V. Oppenheim and R. W. Schaefer. “Discrete-Time Signal Processing.” 3rd Ed. Pearson, New York. 2010. 

​[7] J. G. Proakis and D. G. Manolakis. “Digital Signal Processing.” 4th Ed. Prentice-Hall, New Jersey, 2006. 

​[8] D. Y. Wong,  C.  C. Hsiao, and J. D. Markel. ”Spectral  Mismatch  Due to Preemphasis in  ​LPC Analysis/Synthesis.” IEEE Trans. Acoustics, Speech, and Sig. Proc., ASSP-28, No. 2, Apr. 1980. 

​[9] A. E. Rosenberg, “Effect of glottal pulse shape on the quality of natural vowels,” J. Acoust. Soc. Amer., vol. 49, pp. 583-590, 1971. 
