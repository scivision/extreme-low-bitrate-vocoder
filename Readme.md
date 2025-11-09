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
