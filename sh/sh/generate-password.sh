#!/usr/bin/env bash

# Passphrase that still satisfies "must have upper/digit/symbol" rules.
# Entropy comes from the words alone (64-103 bits); the decorations are there
# to pass validators, so they stay at word boundaries to keep it typeable.

set -eu

WORDLIST="eff-long"

MIN_WORDS=5
MAX_WORDS=8

MIN_WORD_LEN=4
MAX_WORD_LEN=9

MIN_SUBS=1
MAX_SUBS=2

MIN_DIGITS=1
MAX_DIGITS=2

# Substitutions are 1:1 so word length never changes. Every substitution is
# drawn from this one list, so keeping the replacements symbols is what makes
# a symbol guaranteed to appear.
SUBS_FROM="aiso"
SUBS_TO='7!$0'

# One uint32 per rnd() call. A run spends under a dozen; the rest is margin,
# because reading past the end of the pool yields "" and "" % n == 0, which
# would silently stop being random instead of erroring.
POOL_BYTES=256

# Kernel CSPRNG. od -tu4 is POSIX, works on Linux + macOS.
pool=$(od -An -N"$POOL_BYTES" -tu4 </dev/urandom | tr -s ' \n' ' ')
words=$(( $(printf '%s\n' "$pool" | awk '{print $1}') % (MAX_WORDS - MIN_WORDS + 1) + MIN_WORDS ))

xkcdpass -w "$WORDLIST" -d "-" -n "$words" \
  --min "$MIN_WORD_LEN" --max "$MAX_WORD_LEN" | awk \
  -v pool="$pool" \
  -v subs_from="$SUBS_FROM" -v subs_to="$SUBS_TO" \
  -v min_subs="$MIN_SUBS" -v max_subs="$MAX_SUBS" \
  -v min_digits="$MIN_DIGITS" -v max_digits="$MAX_DIGITS" '
  function rnd(n) { return R[ri++] % n }
  BEGIN { split(pool, R, " "); ri = 2 }  # R[1] was spent on the word count
  {
    nw = split($0, W, "-")

    # Capitalize one whole word: one shift keypress at a word boundary.
    c = rnd(nw) + 1
    W[c] = toupper(substr(W[c], 1, 1)) substr(W[c], 2)

    # Collect every substitutable letter left, after capitalizing so that an
    # uppercased "A" is not a target. Resolve the replacement now: positions
    # stay valid as we mutate, but the original letter does not.
    ne = 0
    for (i = 1; i <= nw; i++) {
      len = length(W[i])
      for (j = 1; j <= len; j++) {
        k = index(subs_from, substr(W[i], j, 1))
        if (k == 0) continue
        ne++; EW[ne] = i; EP[ne] = j; ET[ne] = substr(subs_to, k, 1)
      }
    }

    ns = rnd(max_subs - min_subs + 1) + min_subs
    if (ns > ne) ns = ne
    for (i = 1; i <= ne; i++) IDX[i] = i
    for (i = 1; i <= ns; i++) {
      k = i + rnd(ne - i + 1)
      t = IDX[i]; IDX[i] = IDX[k]; IDX[k] = t
      e = IDX[i]; w = EW[e]; p = EP[e]
      W[w] = substr(W[w], 1, p - 1) ET[e] substr(W[w], p + 1)
    }
    # No SUBS_FROM letter anywhere in the passphrase: overwrite some other
    # character instead, skipping the one we capitalized so it survives.
    if (ne == 0) {
      nc = 0
      for (i = 1; i <= nw; i++) {
        len = length(W[i])
        for (j = 1; j <= len; j++) {
          if (i == c && j == 1) continue
          nc++; CW[nc] = i; CP[nc] = j
        }
      }
      if (nc > 0) {
        e = rnd(nc) + 1
        w = CW[e]; p = CP[e]
        W[w] = substr(W[w], 1, p - 1) \
               substr(subs_to, rnd(length(subs_to)) + 1, 1) \
               substr(W[w], p + 1)
      }
    }

    # Digits glued to the end of one word.
    d = rnd(nw) + 1
    n = ""
    for (i = rnd(max_digits - min_digits + 1) + min_digits; i > 0; i--) n = n rnd(10)
    W[d] = W[d] n

    out = W[1]
    for (i = 2; i <= nw; i++) out = out "-" W[i]
    print out
  }'
