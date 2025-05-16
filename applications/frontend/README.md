# Tic-Tac-Toe Game in TypeScript

A simple Tic-Tac-Toe game implemented in TypeScript using Express and EJS templates. This application also includes Azure Application Insights integration for monitoring.

## Features

- Interactive Tic-Tac-Toe game with a web interface
- Game state management on the server
- Win detection logic
- Azure Application Insights integration for monitoring
- Dockerized for easy deployment

## Prerequisites

- Node.js (v14+)
- npm

## Installation

1. Clone the repository
2. Navigate to the project directory
3. Install dependencies:

```bash
npm install
```

## Configuration

Edit the `.env` file to configure application settings:

```
PORT=3000
APPINSIGHTS_CONNECTION_STRING=InstrumentationKey=your-instrumentation-key
```

Replace `your-instrumentation-key` with your actual Azure Application Insights connection string.

## Running the Application

### Development Mode

To run the application in development mode with auto-restart on file changes:

```bash
npm run dev
```

### Production Mode

To build and run the application in production mode:

```bash
npm run build
npm start
```

### Using Docker

To build and run the application using Docker:

```bash
docker build -t tic-tac-toe-typescript .
docker run -p 3000:3000 tic-tac-toe-typescript
```

## How to Play

1. Open your browser and go to `http://localhost:3000`
2. Players take turns clicking on the grid to place their mark (X or O)
3. The game detects when a player has won or when the game ends in a draw
4. Click "Reset Game" to start a new game

## Project Structure

- `src/app.ts` - Main application file
- `views/index.ejs` - EJS template for the game interface
- `public/css/styles.css` - Styling for the game
- `dist/` - Compiled JavaScript files
- `Dockerfile` - Docker configuration for containerization
