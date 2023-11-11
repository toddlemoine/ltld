import _ from 'lodash';

const freq =  {
  E: 0.111607,
  A: 0.084966,
  R: 0.075809,
  I: 0.075448,
  O: 0.071635,
  T: 0.069509,
  N: 0.066544,
  S: 0.057351,
  L: 0.054893,
  C: 0.045388,
  U: 0.036308,
  D: 0.033844,
  P: 0.031671,
  M: 0.030129,
  H: 0.030034,
  G: 0.024705,
  B: 0.02072,
  F: 0.018121,
  Y: 0.017779,
  W: 0.012899,
  K: 0.011016,
  V: 0.010074,
  X: 0.002902,
  Z: 0.002722,
  J: 0.001965,
  Q: 0.001965,
}


const morphemes = "ab ad bi de en ex in ob re se un al ar er ic st ty ve ze ly or ry th";

// Give each morpheme the same freq as its starting letter.
const morphemeFreq = morphemes.split(" ")
  .reduce((acc, m) => {
    const key = m.toUpperCase();
    acc[key] = freq[key[0]];
    return acc; 
  }, {});


function makeBag(bagSize, freq) {
  return Object.entries(freq).flatMap(([letter, letterFreq]) => {
    const numOfLetter = Math.round(bagSize*letterFreq);
    const tmpBag = []
    for (let i=0; i<numOfLetter; i++) {
      tmpBag.push(letter);
    }
    return tmpBag;
  });
}

const bigBagSize = 1000;                          // Start with a giant bag of letters and morphemes, to ensure all get generated
const bagSize = process.argv[2] ?? 100;           // The final bag we produce.
const percentLetters = process.argv[3] ?? 0.70;
const percentMorphemes = (1.00-percentLetters).toFixed(2);
const letterSize = bagSize * percentLetters;
const morphemeSize = bagSize * percentMorphemes;

const morphemeBag = _.shuffle(makeBag(bigBagSize, morphemeFreq)).slice(0, morphemeSize).join('');
const letterBag = _.shuffle(makeBag(bigBagSize, freq)).slice(0, letterSize).join('');

// Shuffle
console.log(`Output (Bag size: ${bagSize})`);
console.log(`Morphemes: ${morphemeBag.length}`)
console.log(`Letters: ${letterBag.length}`)
console.log({ results: JSON.stringify([letterBag, morphemeBag].join(' ')) });




