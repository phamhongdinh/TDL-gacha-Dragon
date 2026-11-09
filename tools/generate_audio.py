"""Generate original, dependency-free ambient music and game sound effects."""
import math, random, wave
from array import array
from pathlib import Path

RATE = 22050
OUT = Path(__file__).resolve().parents[1] / 'assets' / 'audio'
OUT.mkdir(parents=True, exist_ok=True)
random.seed(71)

def save(name, samples):
    pcm = array('h', (int(max(-1, min(1, x)) * 28000) for x in samples))
    with wave.open(str(OUT / (name + '.wav')), 'wb') as f:
        f.setparams((1, 2, RATE, 0, 'NONE', 'not compressed'))
        f.writeframes(pcm.tobytes())

def tone(freq, t): return math.sin(math.tau * freq * t)

def effect(name, duration, func):
    save(name, (func(i / RATE, i / (duration * RATE)) for i in range(int(duration * RATE))))

effect('hover', .08, lambda t, p: .08 * tone(920, t) * math.sin(math.pi * p)**2)
effect('click', .16, lambda t, p: .22 * (tone(640, t) + .4*tone(960, t)) * math.exp(-25*t) * min(t*250,1))
effect('crack', .32, lambda t, p: (.5*(random.random()*2-1)*math.exp(-28*t) + .13*tone(130,t)*math.exp(-12*t)) * min(t*400,1))
effect('charge', 2.8, lambda t, p: (.12*tone(90+35*p,t)+.07*tone(220+170*p*p,t)+.025*(random.random()*2-1))*math.sin(math.pi*p)**.7)
effect('hatch', 1.3, lambda t, p: (.20*tone(65+40*math.exp(-t*9),t)*math.exp(-t*5)+.16*(random.random()*2-1)*math.exp(-t*9)+.12*tone(660,t)*math.exp(-t*2))*min(t*300,1)*(1-p))
effect('reveal', 1.8, lambda t, p: sum(.1*tone(f,t)*math.exp(-max(0,t-j*.09)*2.8)*(1 if t>=j*.09 else 0) for j,f in enumerate([523.25,659.25,783.99,1046.5]))*min(t*90,1)*(1-p))
effect('rare', 2.8, lambda t, p: sum(.075*tone(f,t)*math.exp(-max(0,t-j*.14)*1.6)*(1 if t>=j*.14 else 0) for j,f in enumerate([261.63,392,523.25,659.25,783.99,1046.5]))*min(t*80,1)*(1-p))

# 24-second seamless pentatonic pad + quiet glass-like arpeggio.
notes = [261.63,329.63,392,493.88,392,329.63,293.66,392,440,587.33,440,392,261.63,329.63,493.88,659.25]
duration = 24
samples = []
for i in range(RATE*duration):
    t = i/RATE
    fade = min(t/1.0, (duration-t)/1.0, 1)
    pad = sum(.026*tone(f,t) for f in [130.8128,196.0,261.6256])*(.75+.25*math.sin(math.tau*t/12))
    arpeggio = 0
    for delay, gain in [(0,1),(.32,.28),(.64,.12)]:
        phase = (t-delay) % duration
        slot = int(phase/1.5)
        age = phase-slot*1.5
        envelope = (1-math.exp(-age*60))*math.exp(-age*3)
        arpeggio += gain*envelope*(.065*tone(notes[slot],age)+.017*tone(notes[slot]*2,age))
    samples.append((pad+arpeggio)*fade)
save('longdong_ambient', samples)
print('Generated 8 original WAV tracks/effects in', OUT)
