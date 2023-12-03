import fs from 'fs';
import csv from 'csv-parser';
import _ from 'lodash';
import { add } from 'date-fns';

const freq = {
    a: 8.2,
    b: 1.5,
    c: 2.8,
    d: 4.3,
    e: 12.7,
    f: 2.2,
    g: 2.0,
    h: 6.1,
    i: 7.0,
    j: 0.2,
    k: 0.8,
    l: 4.0,
    m: 2.4,
    n: 6.7,
    o: 7.5,
    p: 1.9,
    q: 0.1,
    r: 6.0,
    s: 6.3,
    t: 9.1,
    u: 2.8,
    v: 1.0,
    w: 2.4,
    x: 0.2,
    y: 2.0,
    z: 0.1,
};

const morphemes =
    'ab ad bi de en ex in ob re se un al ar er ic st ty ve ze ly or ry th ch es gh sh ck ng qu wh io ph ti';

// Give each morpheme the same freq as its starting letter.
const morphemeFreq = morphemes.split(' ').reduce((acc, m) => {
    const key = m.toLowerCase();
    acc[key] = freq[key[0]];
    return acc;
}, {});

function createBagOfLetters(words, size = 50) {
    const wordLetters = words.join('').toUpperCase().split('');
    let mixedBagSize = size - wordLetters.length;
    const mixedLetters = generateBag().slice(0, mixedBagSize);
    // const score = varietyScore(mixedLetters, wordLetters);
    // console.log({ score, words, mixedLetters });
    // if (score < minimumVariety) {
    //     return createBagOfLetters(words, size, minimumVariety, count + 1);
    // }

    // Include word letters in the first 35 letters
    const partWithWordLetters = _.shuffle(
        wordLetters.concat(mixedLetters.slice(0, size - wordLetters.length)),
    );
    return partWithWordLetters.concat(mixedLetters.slice(wordLetters.length));
}

function makeBag(bagSize, freq) {
    return Object.entries(freq).flatMap(([letter, letterFreq]) => {
        const numOfLetter = Math.round(bagSize * letterFreq);
        const tmpBag = [];
        for (let i = 0; i < numOfLetter; i++) {
            tmpBag.push(letter.toUpperCase());
        }
        return tmpBag;
    });
}

// Function that generate a bag of 100 random letters based on their frequency in the English language
function generateBag() {
    const freq = {
        a: 8.2,
        b: 1.5,
        c: 2.8,
        d: 4.3,
        e: 12.7,
        f: 2.2,
        g: 2.0,
        h: 6.1,
        i: 7.0,
        j: 0.2,
        k: 0.8,
        l: 4.0,
        m: 2.4,
        n: 6.7,
        o: 7.5,
        p: 1.9,
        q: 0.1,
        r: 6.0,
        s: 6.3,
        t: 9.1,
        u: 2.8,
        v: 1.0,
        w: 2.4,
        x: 0.2,
        y: 2.0,
        z: 0.1,
    };

    const letterArray = [];

    // Calculate the number of occurrences for each letter based on the frequency
    for (const letter in freq) {
        const occurrences = Math.min(1, Math.round((freq[letter] / 100) * 100));

        // Add the letter to the array the specified number of times
        letterArray.push(...Array(occurrences).fill(letter.toUpperCase()));
    }

    // Shuffle the entire array to randomize the order of letters
    // letterArray.sort(() => Math.random() - 0.5);

    return _.shuffle(letterArray);
}

const currentDate = new Date();
const numOfLetters = 35;
const numOfMorphemes = 20;
const bigBagSize = 1000; // Start with a giant bag of letters and morphemes, to ensure all get generated
let rowCount = 0;

function dateFilename(date) {
    console.log({ date });
    return `./daily/${date.toISOString().slice(0, 10)}.json`;
}

function varietyScore(arr1, arr2) {
    const source = new Set(arr2.map(l => l.toUpperCase()));
    const results = arr1.reduce(
        (acc, letter) => {
            if (source.has(letter.toUpperCase())) {
                acc.same++;
            } else {
                acc.diff++;
            }
            return acc;
        },
        { same: 0, diff: 0 },
    );
    // console.log({ arr1, arr2, results });

    return results.diff === 0 ? 1 : results.same / results.diff;
}

function parseWordsInRow(row) {
    const words = row.words.toUpperCase().split(' ');
    const letterBag = createBagOfLetters(words, 50, 0.7).join('');
    const morphemeBag = _.shuffle(makeBag(bigBagSize, morphemeFreq))
        .slice(0, numOfMorphemes)
        .join('');

    // console.log('');
    // console.log(row.words);

    const data = {
        words,
        bag: [letterBag, morphemeBag].join(' '),
    };
    const filename = dateFilename(add(currentDate, { days: rowCount }));

    console.log({
        filename,
        ...data,
    });

    fs.writeFileSync(filename, JSON.stringify(data));
    rowCount += 1;
}

const filePath = './daily/2024.csv';
fs.createReadStream(filePath)
    .pipe(csv())
    .on('data', parseWordsInRow)
    .on('error', err => {
        console.error(err);
    })
    .on('end', () => {
        console.log('CSV parsing completed');
    });
