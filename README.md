# Pure-TS-Template

## Overview
Pure-TS-Template is a robust and ready-to-use template for starting new projects with a powerful tech stack. It includes pre-installed configurations for Node.js, TypeScript, DotEnv, Express, Jest, Babel, and Mocha, providing a comprehensive setup for both JavaScript and TypeScript development and testing.

## Features
- **Node.js**: Server-side JavaScript runtime environment.
- **TypeScript**: Strongly typed programming language that builds on JavaScript.
- **DotEnv**: Environment variable management.
- **Express**: Minimalist web framework for Node.js.
- **Jest**: Testing framework for TypeScript code.
- **Babel**: Compiler for JavaScript code, specifically for testing.
- **Mocha**: Testing framework, used in combination with Babel for JavaScript tests.

## Getting Started
Follow these instructions to get your development environment set up.

### Prerequisites
Ensure you have Node.js and npm installed on your machine.

### Installation
1. **Clone the repository**:
   ```bash
   git clone https://github.com/jlucasss/Pure-TS-Template.git
2. Install the dependencies:
```bash
npm install
```

## Use
Start the server:
```bash
npm start
```

## ▶️ Basic Usage (via `manager-container.bash`)

- **Image Build**:

``bash
./manager-container.bash -m dev -e podman build

``

The **-m** stands for mode, which can be dev or prod. The **-e** stands for engine, which can be docker or podman.

- **Start containers in the background**:

``bash
./manager-container.bash up

``

- **Stop containers**:

``bash
./manager-container.bash down

``

- **View logs**:

``bash
./manager-container.bash logs

``

- **Access the terminal inside the container**:

``bash
./manager-container.bash exec

``

- **Restart containers**:

``bash
./manager-container.bash restart

``

- **Clean up orphaned images**:

``bash
./manager-container.bash clean

``

- **Deploy local Podman via Quadlet**

``bash
./manager-container.bash local-deploy

```

> ⚠️ Note: There's no need to run `npm install` manually — this is already done within the Dockerfile during the image build.

---

## Available Scripts

In the project directory, you can run the following scripts:

### Build Scripts
- **`npm run build:src`**: Compiles the TypeScript files in the `src` directory into JavaScript using Babel and outputs them to the `dist/src` directory.
- **`npm run build:test`**: Compiles the TypeScript test files in the `test` directory into JavaScript using Babel and outputs them to the `dist/test` directory.
- **`npm run build:rename`**: Renames the compiled `.js` files to `.mjs` in the `dist` directory for compatibility with ES module syntax.
- **`npm run build:fix-imports`**: Compiles the `scripts/fix-imports.ts` script into JavaScript and executes it to fix import statements in the compiled `.mjs` files.
- **`npm run build`**: Runs the `build:src`, `build:test`, `build:rename`, and `build:fix-imports` scripts sequentially to perform a full build.

### Start Scripts
- **`npm start`**: Executes the application from the `dist/src/index.mjs` file.
- **`npm run dev`**: Starts the development server using `ts-node` with the `src/index.ts` file.
- **`npm run startdev`**: Compiles the TypeScript files and starts the application from the `dist/src/index.mjs` file.

### Test Scripts
- **`npm run test:ts`**: Runs all the TypeScript tests using Jest.
- **`npm run test:js`**: Runs all the compiled JavaScript tests in the `dist/test` directory using Mocha.
- **`npm test`**: Executes the `test:ts`, `build`, and `test:js` scripts sequentially to perform a full test cycle.
- **`npm run test:ts:watch`**: Runs Jest in watch mode, automatically re-running TypeScript tests when files change.
- **`npm run test:js:watch`**: Builds the project and then runs Mocha in watch mode to re-run JavaScript tests when files change.
- **`npm run test:watch`**: Runs both Jest and Mocha in watch mode, allowing you to monitor and automatically re-run both TypeScript and JavaScript tests when files change.

These scripts provide a streamlined workflow for building, starting, and testing your project.


## Commands Used

1. **Initialize Project**:
   ```bash
   npm init
   ```
   - Create the `package.json` file.

2. **Install TypeScript and Node Types**:
   ```bash
   npm install typescript @types/node --save-dev
   ```
   - Create and configure `tsconfig.json`.
   - Update `scripts` in `package.json`.

3. **Create Entry File**:
   - Create the file `src/index.ts` and add a simple server with "Hello World".

4. **Transpile TypeScript to JavaScript**:
   ```bash
   tsc index.ts
   ```
   - Transpile the TypeScript file to `index.js`.

5. **Run the Server**:
   ```bash
   npm test
   ```
   - Run `index.js`.

6. **Initialize Git Repository**:
   ```bash
   git init
   ```

7. **Configure Git User**:
   ```bash
   git config --local user.name "Author"
   git config --local user.email "email@email.com"
   ```

8. **Check Git Status**:
   ```bash
   git status
   ```
   - Show the working tree status.

9. **Create .gitignore**:
   - Create the file `.gitignore` and add `node_modules/` and other necessary paths.

10. **Stage and Commit Initial Files**:
    ```bash
    git add .
    git status
    git commit -m "feat: initial project setup with Node.js and TypeScript"
    ```

11. **Install dotenv**:
    ```bash
    npm install dotenv
    ```
    - Create the file `.env`.

12. **Install Express and Types**:
    ```bash
    npm install express @types/express
    ```

13. **Install Jest and Related Packages**:
    ```bash
    npm install --save-dev jest
    npm install --save-dev ts-jest
    npm install --save-dev @types/jest
    ```
      - Create the file `jest.config.ts`.

14. **Install ts-node**:
    ```bash
    npm install ts-node --save-dev
    ```

15. **Install Babel and Presets**:
    ```bash
    npm install --save-dev @babel/cli
    npm install --save-dev @babel/preset-env
    npm install --save-dev @babel/preset-typescript
    ```

16. **Install Mocha**:
    ```bash
    npm install --save-dev mocha
    ```

17. **Create fix-imports.ts**:
    - Create the file `<rootDir>/scripts/fix-imports.ts` to handle `.mjs` imports in the `dist` folder.

18. **Commit Changes**:
    ```bash
    git commit -m "chore: add DotEnv, Express, Jest, Babel, Mocha and TypeScript dependencies"
    ```

## Future:
- [VITE](https://vite.dev/guide/);
- [TESTING-LIBRARY](https://testing-library.com/docs/guiding-principles)

## Contribution
Contributions are welcome! Please see the file `CONTRIBUTING.md` for details.

## License
This project is licensed under the MIT License.