using RedPitayaDAQServer
using PyPlot

#rp = RedPitaya("rp-f04972.local")
rp = RedPitaya("192.168.178.46")

dec = 64
modulus = 4800
base_frequency = 125000000
periods_per_step = 50
samples_per_period = div(modulus, dec)*periods_per_step
periods_per_frame = div(1000, periods_per_step) # about 0.5 s frame length
frame_period = dec*samples_per_period*periods_per_frame / base_frequency
slow_dac_periods_per_frame = periods_per_frame

decimation(rp, dec)
samplesPerPeriod(rp, samples_per_period)
periodsPerFrame(rp, periods_per_frame)

slowDACPeriodsPerFrame(rp, slow_dac_periods_per_frame)
numSlowDACChan(rp, 1)
lut = collect(range(0,1,length=slow_dac_periods_per_frame))
setSlowDACLUT(rp, lut)

modeDAC(rp, "STANDARD")
frequencyDAC(rp,1,1, base_frequency / modulus)

freq = frequencyDAC(rp,1,1)
println(" frequency = $(freq)")
signalTypeDAC(rp, 1 , "SINE")
amplitudeDAC(rp, 1, 1, 400)
phaseDAC(rp, 1, 1, 0.0 ) # Phase has to be given in between 0 and 1

ramWriterMode(rp, "TRIGGERED")
triggerMode(rp, "INTERNAL")
masterTrigger(rp, false)
startADC(rp)
masterTrigger(rp, true)

sleep(0.1)

uFirstPeriod = readData(rp, 0, 2)

currFr = enableSlowDAC(rp, true, 2, frame_period, 0.5)
uCurrentPeriod = readData(rp, currFr, 2)

sleep(0.1)
currFr = enableSlowDAC(rp, true, 2, frame_period, 0.5)
uCurrentPeriod2 = readData(rp, currFr, 2)


figure(1)
clf()
subplot(2,1,1)
plot(vec(uCurrentPeriod[:,2,:,:]))
plot(vec(uCurrentPeriod[:,1,:,:]))
plot(vec(uCurrentPeriod2[:,1,:,:]))
legend(("DF", "FF1", "FF2"))
subplot(2,1,2)
plot(vec(uFirstPeriod[:,2,:,:]))
plot(vec(uCurrentPeriod[:,2,:,:]))
legend(("DF1", "DF2"))

stopADC(rp)
