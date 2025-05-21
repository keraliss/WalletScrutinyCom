#!/usr/bin/env node

const fs = require('fs');
const path = require('path');
const util = require('util');

// Promisify fs functions
const readdir = util.promisify(fs.readdir);
const readFile = util.promisify(fs.readFile);
const stat = util.promisify(fs.stat);

// Function to recursively find all markdown files in a directory
async function findMarkdownFiles(directory) {
  const files = await readdir(directory);
  let markdownFiles = [];

  for (const file of files) {
    const filePath = path.join(directory, file);
    const stats = await stat(filePath);

    if (stats.isDirectory()) {
      // Recursively search subdirectories
      const subDirFiles = await findMarkdownFiles(filePath);
      markdownFiles = markdownFiles.concat(subDirFiles);
    } else if (file.endsWith('.md')) {
      markdownFiles.push(filePath);
    }
  }

  return markdownFiles;
}

// Function to check if a file meets the criteria
async function checkFileCriteria(filePath) {
  try {
    const content = await readFile(filePath, 'utf8');
    
    // Check if the file contains both criteria
    const hasSourceAvailable = content.includes('verdict: sourceavailable');
    const hasMetaOk = content.includes('meta: ok');
    
    // Only return the file path if it meets both criteria
    if (hasSourceAvailable && hasMetaOk) {
      return filePath;
    }
    
    return null;
  } catch (error) {
    console.error(`Error reading file ${filePath}: ${error.message}`);
    return null;
  }
}

// Function to filter Android and hardware related markdown files
function isAndroidOrHardwareFile(filePath) {
  const normalizedPath = filePath.toLowerCase();
  
  // Check if path contains android or hardware indicators
  return normalizedPath.includes('android') || 
         normalizedPath.includes('hardware') || 
         normalizedPath.includes('/hw/') || 
         normalizedPath.includes('/device/');
}

// Main function to execute the script
async function main() {
  try {
    // Get the root directory from command line or use current directory
    const rootDir = process.argv[2] || process.cwd();
    console.log(`Scanning for Android and hardware markdown files in: ${rootDir}`);
    
    // Find all markdown files
    const allMarkdownFiles = await findMarkdownFiles(rootDir);
    console.log(`Found ${allMarkdownFiles.length} total markdown files`);
    
    // Filter for Android and hardware related files
    const androidAndHardwareFiles = allMarkdownFiles.filter(isAndroidOrHardwareFile);
    console.log(`Found ${androidAndHardwareFiles.length} Android and hardware related markdown files`);
    
    // Check each file for the criteria
    const matchPromises = androidAndHardwareFiles.map(checkFileCriteria);
    const matchedFiles = (await Promise.all(matchPromises)).filter(Boolean);
    
    console.log('\nFiles matching criteria (verdict: sourceavailable and meta: ok):');
    console.log('================================================================');
    
    if (matchedFiles.length === 0) {
      console.log('No files found matching the criteria.');
    } else {
      matchedFiles.forEach((file, index) => {
        console.log(`${index + 1}. ${file}`);
      });
      console.log(`\nTotal matching files: ${matchedFiles.length}`);
    }
    
  } catch (error) {
    console.error(`Error executing script: ${error.message}`);
    process.exit(1);
  }
}

// Execute the main function
main();