const readline = require('readline');

function createBagOfLetters(words) {
    const letterFrequency = {
        'a': 8.2, 'b': 1.5, 'c': 2.8, 'd': 4.3, 'e': 12.7,
        'f': 2.2, 'g': 2.0, 'h': 6.1, 'i': 7.0, 'j': 0.2,
        'k': 0.8, 'l': 4.0, 'm': 2.4, 'n': 6.7, 'o': 7.5,
        'p': 1.9, 'q': 0.1, 'r': 6.0, 's': 6.3, 't': 9.1,
        'u': 2.8, 'v': 1.0, 'w': 2.4, 'x': 0.2, 'y': 2.0,
        'z': 0.1
    };

    const letterArray = [];

    // Combine the letters from the three words and shuffle them
    const combinedLetters = words.join('').split('');
    combinedLetters.sort(() => Math.random() - 0.5);

    // Add the shuffled letters from the words to the array
    letterArray.push(...combinedLetters.slice(0, 35));

    // Calculate the remaining number of occurrences needed
    const remainingOccurrences = 35 - letterArray.length;

    // Loop through the letters in the frequency distribution
    for (const letter in letterFrequency) {
        // Calculate the number of occurrences based on the frequency
        const occurrences = Math.round((letterFrequency[letter] / 100) * remainingOccurrences);

        // Add the letter to the array the specified number of times
        letterArray.push(...Array(occurrences).fill(letter));
    }

    // Shuffle the entire array to randomize the order of letters
    letterArray.sort(() => Math.random() - 0.5);

    return letterArray;
}

const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout
});

const words = ["vader", "twins", "papa"]; // Hardcoding the three words for this example

// Ensure the array contains exactly three words
if (words.length !== 3) {
    console.log('Please provide exactly three words.');
} else {
    const bagOfLetters = createBagOfLetters(words);
    console.log('Bag of Letters:', bagOfLetters.join('').toUpperCase());
}
