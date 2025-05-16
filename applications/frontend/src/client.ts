// Define types for game states
interface GameState {
  board: string[][];
  currentPlayer: 'X' | 'O';
  winner: string | null;
  gameOver: boolean;
}

// Game client class for handling UI interactions
class TicTacToeClient {
  private statusElement: HTMLElement;
  private resetButton: HTMLElement;
  private moveForms: NodeListOf<HTMLFormElement>;
  private cellButtons: NodeListOf<HTMLButtonElement>;
  
  constructor() {
    this.statusElement = document.querySelector('.status') as HTMLElement;
    this.resetButton = document.querySelector('.reset-btn') as HTMLElement;
    this.moveForms = document.querySelectorAll('form[action="/move"]');
    this.cellButtons = document.querySelectorAll('.cell');
    
    this.init();
  }
  
  private init(): void {
    // Add animation to cells when clicked
    this.cellButtons.forEach(button => {
      button.addEventListener('click', this.handleCellClick.bind(this));
    });
    
    // Add animation to reset button
    this.resetButton.addEventListener('click', this.handleResetClick.bind(this));
    
    // Add keyboard navigation for accessibility
    this.addKeyboardNavigation();
  }
  
  private handleCellClick(event: MouseEvent): void {
    const button = event.currentTarget as HTMLButtonElement;
    
    // Add animation class
    button.classList.add('cell-clicked');
    
    // Remove class after animation completes
    setTimeout(() => {
      button.classList.remove('cell-clicked');
    }, 300);
  }
  
  private handleResetClick(event: MouseEvent): void {
    this.resetButton.classList.add('reset-clicked');
    
    setTimeout(() => {
      this.resetButton.classList.remove('reset-clicked');
    }, 300);
  }
  
  private addKeyboardNavigation(): void {
    // Make the game playable with keyboard
    let focusIndex = 0;
    
    // Add tabindex to cells for keyboard navigation
    this.cellButtons.forEach((button, index) => {
      button.setAttribute('tabindex', '0');
      
      // Handle keyboard enter/space as click
      button.addEventListener('keydown', (e: KeyboardEvent) => {
        if (e.key === 'Enter' || e.key === ' ') {
          e.preventDefault();
          button.click();
        }
      });
    });
  }
}

// Initialize the client-side functionality when the DOM is loaded
document.addEventListener('DOMContentLoaded', () => {
  const client = new TicTacToeClient();
});
