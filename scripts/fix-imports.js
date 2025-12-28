// Script to modify imports in transpiled files
// Created with the assistance of Microsoft Copilot

// Import necessary modules from Node.js
import fs from 'fs'; // For file system operations
import path from 'path'; // For path manipulations

// To convert URLs to file paths

// Get the root directory of the project
const rootDir = process.cwd();

// Function to replace text within a file
const replaceInFile = (filePath, searchValue, replaceValue) => {
  // Read the file content
  const data = fs.readFileSync(filePath, 'utf8');
  // Replace the occurrences of searchValue with replaceValue
  const result = data.replace(new RegExp(searchValue, 'g'), replaceValue);
  // Write the updated content back to the file
  fs.writeFileSync(filePath, result, 'utf8');
};

// Function to process directories recursively
const processDirectory = dir => {
  // Read all files and subdirectories in the specified directory
  fs.readdirSync(dir).forEach(file => {
    const fullPath = path.join(dir, file);
    // If it's a directory, process it recursively
    if (fs.lstatSync(fullPath).isDirectory()) {
      processDirectory(fullPath);
    } else if (file.endsWith('.mjs')) {
      // Replaces imports without extension to add '.mjs' only if it is a relative path ('./' or '../')
      replaceInFile(fullPath, /(import .* from ['"])(\..*?)(['"])/g, '$1$2.mjs$3');
      replaceInFile(fullPath, /(require\(['"])(\..*?)(['"]\))/g, '$1$2.mjs$3');
    }
  });
};

// Start processing from the 'dist' directory
processDirectory(path.join(rootDir, 'dist'));

