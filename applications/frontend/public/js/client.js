"use strict";
// Game client class for handling UI interactions
class TicTacToeClient {
    constructor() {
        this.statusElement = document.querySelector('.status');
        this.resetButton = document.querySelector('.reset-btn');
        this.moveForms = document.querySelectorAll('form[action="/move"]');
        this.cellButtons = document.querySelectorAll('.cell');
        this.init();
    }
    init() {
        // Add animation to cells when clicked
        this.cellButtons.forEach(button => {
            button.addEventListener('click', this.handleCellClick.bind(this));
        });
        // Add animation to reset button
        this.resetButton.addEventListener('click', this.handleResetClick.bind(this));
        // Add keyboard navigation for accessibility
        this.addKeyboardNavigation();
    }
    handleCellClick(event) {
        const button = event.currentTarget;
        // Add animation class
        button.classList.add('cell-clicked');
        // Remove class after animation completes
        setTimeout(() => {
            button.classList.remove('cell-clicked');
        }, 300);
    }
    handleResetClick(event) {
        this.resetButton.classList.add('reset-clicked');
        setTimeout(() => {
            this.resetButton.classList.remove('reset-clicked');
        }, 300);
    }
    addKeyboardNavigation() {
        // Make the game playable with keyboard
        let focusIndex = 0;
        // Add tabindex to cells for keyboard navigation
        this.cellButtons.forEach((button, index) => {
            button.setAttribute('tabindex', '0');
            // Handle keyboard enter/space as click
            button.addEventListener('keydown', (e) => {
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
//# sourceMappingURL=client.js.map