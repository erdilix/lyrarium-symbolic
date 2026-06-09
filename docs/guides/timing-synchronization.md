author: gemini
---
# Timing Synchronization: ABC Notation vs. MML

This guide explains how to achieve a "True Speed Match" between ABC notation (used for MIDI synthesis) and MML (used for retro soundchip synthesis like NES/ppmck).

## The 50% Speed Discrepancy Issue

In MML (ppmck), it is common to use `l12` for eighth-note triplets, which provides a natural swing and rhythmic density. A tempo of `t170` combined with `l12` results in a specific, fast playback speed.

However, many ABC parsers (including `abc2midi`) do not officially support `L: 1/12` as a base note length. When a parser encounters `L: 1/12`, it typically defaults to `L: 1/8`. 

**The result:** Because a 1/8 note is exactly 50% longer than a 1/12 note, the ABC track will play 50% slower than the MML track, even if the BPM is set to the same value.

## The Solution: The "True Speed Match" Formula

To achieve a perfect 1:1 speed match while remaining compatible with standard ABC parsers, we must change the meter and the way the tempo is calculated.

### 1. Change Meter to 12/8
Instead of `M: 4/4` with invalid `L: 1/12` notes, use `M: 12/8` with `L: 1/8`. This maintains the 12-unit-per-measure structure that `l12` provides in MML.

### 2. Group Tempo by Triplet (3/8)
In a 12/8 meter, a "beat" is typically a dotted-quarter note (3 eighth-notes). By setting the tempo relative to the triplet group, we match the MML's pulse.

### Comparison

| Format | Notation | Result |
| :--- | :--- | :--- |
| **MML** | `t170 l12` | 170 BPM with 12 units per bar. |
| **ABC (Old)** | `Q: 170`, `L: 1/12` | **Failed.** Defaults to 1/8, plays 50% too slow. |
| **ABC (Fixed)** | `Q: 3/8=170`, `M: 12/8`, `L: 1/8` | **Success.** Perfect 1:1 match with MML. |

## Corrected ABC Header Template

Use this header for any ABC files intended to sync with MML at 170 BPM:

```abc
X: 1
T: Melody (True Speed Match)
M: 12/8
L: 1/8
Q: 3/8=170
K: Cmin
```

This mathematical adjustment ensures that both the 8-bit retro engine and the modern MIDI engine pulse at the exact same frequency, allowing for cross-platform musical consistency.

---
author: gemini
