/**
 *  Check Yaci DevKit Status
 * 
 * This script verifies that Yaci DevKit is running and
 * displays current blockchain information.
 */

import axios from 'axios';
import chalk from 'chalk';
import dotenv from 'dotenv';

dotenv.config();

const YACI_API_URL = process.env.YACI_DEVKIT_URL || 'http://localhost:8080/api/v1';

async function checkYaciStatus() {
    console.log(chalk.blue('='.repeat(50)));
    console.log(chalk.blue('Checking yaci status...'));
    console.log(chalk.blue('='.repeat(50)));
    console.log();

    try {
        //api reachability check
        console.log(chalk.yellow('connecting to Yaci DevKit...'));
        console.log(chalk.gray(`URL: ${YACI_API_URL}`));
        console.log('');

        //latest epoch
        console.log(chalk.yellow('Fetching blockchain info...'));
        const epochResponse = await axios.get(`${YACI_API_URL}/epochs/latest`);
        const epoch = epochResponse.data;

        console.log("Yaci devkit is running!");
        console.log('');
        console.log(chalk.cyan('Blockchain Information:'));
        console.log(chalk.white(`  Current Epoch: ${epoch.epoch}`));
        console.log(chalk.white(`  Blocks: ${epoch.blkCount}`));
        console.log(chalk.white(`  Transactions: ${epoch.txCount || 0}`));
        console.log('');

        //latest block
        const blockResponse = await axios.get(`${YACI_API_URL}/blocks/latest`);
        const block = blockResponse.data;
        console.log(chalk.cyan('Latest Block:'));
        console.log(chalk.white(`  Block Number: ${block.number}`));
        console.log(chalk.white(`  Block Hash: ${block.hash}`));
        console.log(chalk.white(`  Time: ${block.time ? new Date(block.time * 1000).toISOString() : 'N/A'}`));
        console.log('');

         console.log(chalk.cyan('Network:'));
        console.log(chalk.white(`  Network Magic: ${process.env.NETWORK_MAGIC}`));
        console.log(chalk.white(`  Network ID: ${process.env.NETWORK_ID}`));
        console.log('');

        console.log(chalk.green('='.repeat(50)));
        console.log(chalk.green('✓ All checks passed!'));
        console.log(chalk.green('='.repeat(50)));
        console.log('');

    } catch(error){
        console.log(chalk.red('Error connecting to yaci'));
        console.log('');
      if (error.code === 'ECONNREFUSED') { //server is not listening on that port 
        console.log(chalk.yellow('Troubleshooting:'));
        console.log(chalk.white('  1. Is Yaci DevKit running?'));
        console.log(chalk.white('     Start it with: devkit start'));
        console.log(chalk.white('  2. Check the URL in .env file'));
        console.log(chalk.white(`     Current: ${YACI_API_URL}`));
    } else {
        console.log(chalk.red('Error details:'));
        console.log(chalk.gray(error.message));
    }
    process.exit(1);
    }
}
checkYaciStatus();