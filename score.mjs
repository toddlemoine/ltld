// Function that takes two arrays and returns a score between 0 and 1
// based on how many elements they have in common. 1 means they are identical.
// 0 means they have nothing in common.
function varietyScore(arr1, arr2) {
    // const arr1Set = new Set(arr1);
    // const arr2Set = new Set(arr2);
    // const intersection = new Set([...arr1Set].filter(x => arr2Set.has(x)));
    // return intersection.size / arr1.length;
    const results = arr1.reduce(
        (acc, letter) => {
            if (arr2.includes(letter)) {
                acc.same++;
            } else {
                acc.diff++;
            }
            return acc;
        },
        { same: 0, diff: 0 },
    );
    if (results.diff === 0) {
        return 1;
    }
    return results.same / results.diff;
}

console.log('Expect score 1:');
console.log(varietyScore(['a', 'b', 'c'], ['a', 'b', 'c'])); // 1

console.log('Expect score 0:');
console.log(varietyScore(['a', 'b', 'c'], ['d', 'e', 'f'])); // 1

console.log('Expect score in between:');
console.log(varietyScore('defayunwiapolikujmbc'.split(''), 'abc'.split(''))); // 1

console.log('This score is closer to 1:');
console.log(
    varietyScore('dbbbbbefayunbwiapcaobblikujmbc'.split(''), 'abc'.split('')),
); // 1
