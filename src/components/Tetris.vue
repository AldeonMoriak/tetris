<script setup lang="ts">
import { ref, computed } from "vue";

// defineProps<{ msg: string }>();

interface Cell { class: string, isTaken: boolean }
const width = ref(10);
const availableCells = ref<Cell[]>([])
const takenCells = ref(10);
for (let i = 0; i < 200; i++) {
  const cell: Cell = { class: '', isTaken: false }
  availableCells.value.push(cell);
}

for (let i = 0; i < 10; i++) {
  const cell: Cell = { class: '', isTaken: true }
  availableCells.value.push(cell);
}

const lTetromino = ref([
  [1, width.value + 1, width.value * 2 + 1, 2],
  [width.value, width.value + 1, width.value + 2, width.value * 2 + 1],
  [1, width.value + 1, width.value * 2 + 1, width.value * 2],
  [width.value, width.value * 2, width.value * 2 + 1, width.value * 2 + 2],
]);

const oTetromino = ref([
  [0, 1, width.value, width.value + 1],
  [0, 1, width.value, width.value + 1],
  [0, 1, width.value, width.value + 1],
  [0, 1, width.value, width.value + 1],
]);

const zTetromino = ref([
  [1, 2, width.value, width.value + 1],
  [0, width.value, width.value + 1, width.value * 2 + 1],
  [1, 2, width.value, width.value + 1],
  [0, width.value, width.value + 1, width.value * 2 + 1],
]);

const tTetromino = ref([
  [1, width.value, width.value + 1, width.value + 2],
  [1, width.value + 1, width.value + 2, width.value * 2 + 1],
  [width.value, width.value + 1, width.value + 2, width.value * 2 + 1],
  [1, width.value, width.value + 1, width.value * 2 + 1],
]);

const iTetromino = ref([
  [1, width.value + 1, width.value * 2 + 1, width.value * 3 + 1],
  [width.value, width.value + 1, width.value + 2, width.value + 3],
  [1, width.value + 1, width.value * 2 + 1, width.value * 3 + 1],
  [width.value, width.value + 1, width.value + 2, width.value + 3],
]);

const theTetrominoes = ref([
  iTetromino.value,
  zTetromino.value,
  iTetromino.value,
  oTetromino.value,
  lTetromino.value,
]);

let currentPosition = ref(4)
const currentRotation = ref(0)
let random = Math.floor(Math.random() * theTetrominoes.value.length);
let current = ref(theTetrominoes.value[random][currentRotation.value])

const again = () => {
  random = Math.floor(Math.random() * theTetrominoes.value.length);
  current = ref(theTetrominoes.value[random][currentRotation.value])
  currentPosition.value = 4
}

const draw = () => {
  current.value.map(cellNumber => {
    availableCells.value[cellNumber + currentPosition.value].class = 'bg-red-500'
  })
}

const undraw = () => {
  current.value.map(cellNumber => {
    availableCells.value[cellNumber + currentPosition.value].class = ''
  })
}
draw()

const moveDown = () => {
  freeze()
  undraw();
  currentPosition.value += width.value
  draw()
}

const moveLeft = () => {
  undraw()
  const isAtLeftEdge = current.value.some(cellNumber => (currentPosition.value + cellNumber) % width.value === 0)
  if (!isAtLeftEdge) {
    currentPosition.value--
  }
  if (current.value.some(cellNumber => availableCells.value[currentPosition.value + cellNumber].isTaken)) currentPosition.value++
  draw()
}
const keyController = (e: KeyboardEvent) => {
  e.preventDefault()
  if (e.code.toLowerCase() === 'arrowleft') {
    moveLeft();
  }
}

addEventListener('keydown', keyController)

const freeze = () => {
  if (current.value.some(cellNumber => availableCells.value[currentPosition.value + cellNumber + width.value].isTaken)) {
    current.value.map(cellNumber => {
      availableCells.value[cellNumber + currentPosition.value].isTaken = true;
      // availableCells.value[cellNumber + currentPosition.value].class = 'bg-purple-500';
    })
    again()
  }
}
const timer = setInterval(moveDown, 500);
</script>

<template>
  <div class="bg-yellow-500 w-200px h-400px flex flex-wrap">
    <div
      v-for="(cell, index) in availableCells"
      :key="index"
      :class="[cell.isTaken ? 'opacity-80 ' + cell.class : cell.class, 'w-20px h-20px']"
    ></div>
  </div>
</template>
