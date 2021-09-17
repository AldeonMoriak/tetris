<script setup lang="ts">
import { ref, computed, onDeactivated } from "vue";

// defineProps<{ msg: string }>();

interface Cell {
  class: string;
  isTaken: boolean;
  isBedRock?: boolean;
  isGhost?: boolean;
  isOccupied: boolean;
}

const width = 10;
const previewWidth = 4;
const score = ref(0);
const message = ref("");
const availableCells = ref<Cell[]>([]);
const previewCells = ref<Cell[]>([]);
let timer: number = -1;
let isGameOver = ref(false);
const isPaused = ref(true);

// fill the empty cells with initial data
for (let i = 0; i < 200; i++) {
  const cell: Cell = { class: "", isTaken: false, isOccupied: false };
  availableCells.value.push(cell);
}

// fill the bedrock with taken cells
for (let i = 0; i < 10; i++) {
  const cell: Cell = {
    class: "",
    isTaken: true,
    isBedRock: true,
    isOccupied: false,
  };
  availableCells.value.push(cell);
}

// fill the preview cells with initial data
for (let i = 0; i < 25; i++) {
  const cell: Cell = { class: "", isTaken: false, isOccupied: false };
  previewCells.value.push(cell);
}

const lTetromino = [
  [1, width + 1, width * 2 + 1, 2],
  [width, width + 1, width + 2, width * 2 + 2],
  [1, width + 1, width * 2 + 1, width * 2],
  [width, width * 2, width * 2 + 1, width * 2 + 2],
];

const oTetromino = [
  [0, 1, width, width + 1],
  [0, 1, width, width + 1],
  [0, 1, width, width + 1],
  [0, 1, width, width + 1],
];

const zTetromino = [
  [1, 2, width, width + 1],
  [0, width, width + 1, width * 2 + 1],
  [1, 2, width, width + 1],
  [0, width, width + 1, width * 2 + 1],
];

const tTetromino = [
  [1, width, width + 1, width + 2],
  [1, width + 1, width + 2, width * 2 + 1],
  [width, width + 1, width + 2, width * 2 + 1],
  [1, width, width + 1, width * 2 + 1],
];

const iTetromino = [
  [1, width + 1, width * 2 + 1, width * 3 + 1],
  [width, width + 1, width + 2, width + 3],
  [1, width + 1, width * 2 + 1, width * 3 + 1],
  [width, width + 1, width + 2, width + 3],
];

const reversedLTetromino = [
  [0, 1, width + 1, width * 2 + 1],
  [width, width + 1, width + 2, width * 2],
  [1, width + 1, width * 2 + 1, width * 2 + 2],
  [width + 2, width * 2, width * 2 + 1, width * 2 + 2],
];

const reversedZTetromino = [
  [1, 2, width + 2, width + 3],
  [2, width + 2, width + 1, width * 2 + 1],
  [1, 2, width + 2, width + 3],
  [2, width + 2, width + 1, width * 2 + 1],
];

const theTetrominoes = [
  iTetromino,
  zTetromino,
  tTetromino,
  oTetromino,
  lTetromino,
  reversedLTetromino,
  reversedZTetromino,
];

const colors = [
  "bg-green-500",
  "bg-blue-500",
  "bg-fuchsia-500",
  "bg-orange-500",
  "bg-rose-500",
  "bg-yellow-500",
  "bg-teal-500",
];

const previewTetrominoes = [
  [
    previewWidth + 2,
    previewWidth * 2 + 2,
    previewWidth * 3 + 2,
    previewWidth * 4 + 2,
  ], //iTetromino
  [
    previewWidth * 3,
    previewWidth * 3 + 1,
    previewWidth * 2 + 1,
    previewWidth * 2 + 2,
  ], //zTetromino
  [
    previewWidth * 2 + 1,
    previewWidth * 2 + 2,
    previewWidth * 2 + 3,
    previewWidth + 2,
  ], // tTetromino
  [
    previewWidth + 1,
    previewWidth + 2,
    previewWidth * 2 + 1,
    previewWidth * 2 + 2,
  ], // oTetromino
  [
    previewWidth + 1,
    previewWidth + 2,
    previewWidth * 2 + 1,
    previewWidth * 3 + 1,
  ], // lTetromino
  [0, 1, previewWidth + 1, previewWidth * 2 + 1], // reversedLTetromino
  [1, 2, previewWidth + 2, previewWidth + 3], // reversedZTetromino
];

let currentPosition = ref(4);
let currentRotation = 0;
let random = Math.floor(Math.random() * theTetrominoes.length);
let previewRandom = Math.floor(Math.random() * theTetrominoes.length);
let current = ref(theTetrominoes[random][currentRotation]);
let currentPreview = ref(previewTetrominoes[previewRandom]);

const drawPreview = () => {
  currentPreview.value.map((cellNumber) => {
    previewCells.value[cellNumber].isOccupied = true;
    previewCells.value[cellNumber].class = colors[previewRandom];
  });
};

const undrawPreview = () => {
  currentPreview.value.map((cellNumber) => {
    previewCells.value[cellNumber].isOccupied = false;
    previewCells.value[cellNumber].class = "";
  });
};

const again = () => {
  undrawPreview();
  // undrawGhost();
  random = previewRandom;
  previewRandom = Math.floor(Math.random() * theTetrominoes.length);
  currentPosition.value = 4;
  currentRotation = 0;
  current.value = theTetrominoes[random][currentRotation];
  currentPreview.value = previewTetrominoes[previewRandom];
  drawPreview();
};

const draw = () => {
  current.value.map((cellNumber) => {
    availableCells.value[cellNumber + currentPosition.value].isOccupied = true;
    availableCells.value[cellNumber + currentPosition.value].class =
      colors[random];
  });
};

const undraw = () => {
  current.value.map((cellNumber) => {
    availableCells.value[cellNumber + currentPosition.value].isOccupied = false;
    availableCells.value[cellNumber + currentPosition.value].class = "";
  });
};

const getFirstOccupiedCellInColumn = () => {
  let columns: number[] = [];
  current.value.map((cellNumber) => {
    const i = (cellNumber + currentPosition.value) % width;
    let column: number = -1;
    for (let x = 0; x < 21; x++) {
      if (availableCells.value[i + width * x].isTaken) {
        column = i + width * x;
        break;
      }
    }
    if (column !== -1) columns.push(column);
  });
  columns = [...new Set(columns.sort())];

  return columns[0];
};

const drawGhost = () => {
  const firstOccupiedCell = getFirstOccupiedCellInColumn();
  current.value.map((cellNumber) => {
    availableCells.value[cellNumber + firstOccupiedCell - width * 2].isGhost =
      true;
  });
};

const undrawGhost = () => {
  const firstOccupiedCell = getFirstOccupiedCellInColumn();
  current.value.map((cellNumber) => {
    availableCells.value[cellNumber + firstOccupiedCell - width * 2].isGhost =
      false;
  });
};

const moveDown = () => {
  // undrawGhost();
  freeze();
  undrawPreview();
  undraw();
  currentPosition.value += width;
  draw();
  // drawGhost();
  drawPreview();
  gameOver();
};

const moveLeft = () => {
  undraw();
  // undrawGhost();
  const isAtTheEdge = isAtTheEdges("left");
  if (!isAtTheEdge) {
    currentPosition.value--;
  }
  if (isCellBlocked()) currentPosition.value++;
  draw();
  // drawGhost();
};

const moveRight = () => {
  undraw();
  // undrawGhost();
  const isAtTheEdge = isAtTheEdges("right");
  if (!isAtTheEdge) {
    currentPosition.value++;
  }
  if (isCellBlocked()) currentPosition.value--;
  draw();
  // drawGhost();
};

const isAtTheEdges = (direction: string) => {
  return direction === "right"
    ? current.value.some(
        (cellNumber) => (currentPosition.value + cellNumber + 1) % width === 0
      )
    : current.value.some(
        (cellNumber) => (currentPosition.value + cellNumber) % width === 0
      );
};
const isCellBlocked = () => {
  return current.value.some(
    (cellNumber) =>
      availableCells.value[currentPosition.value + cellNumber].isTaken
  );
};

const checkRotatedPosition = (P?: number) => {
  P = P || currentPosition.value; //get current position.  Then, check if the piece is near the left side.
  console.log(P);
  if ((P + 1) % width < 4) {
    //add 1 because the position index can be 1 less than where the piece is (with how they are indexed).
    if (isAtTheEdges("right")) {
      //use actual position to check if it's flipped over to right side
      currentPosition.value += 1; //if so, add one to wrap it back around
      checkRotatedPosition(P); //check again.  Pass position from start, since long block might need to move more.
    }
  } else if (P % width > 5) {
    if (isAtTheEdges("left")) {
      currentPosition.value -= 1;
      checkRotatedPosition(P);
    }
  }
};

const rotate = () => {
  undraw();
  // undrawGhost();

  const isAtRight = isAtTheEdges("right");
  const isAtLeft = isAtTheEdges("left");
  const lastRotationIndex = currentRotation;
  currentRotation =
    currentRotation === current.value.length - 1 ? 0 : currentRotation + 1;
  current.value = theTetrominoes[random][currentRotation];
  if (isCellBlocked()) {
    current.value = theTetrominoes[random][lastRotationIndex];
  }
  checkRotatedPosition();
  draw();
  // drawGhost();
};

onDeactivated(() => removeEventListener("keydown", keyController));

const keyController = (e: KeyboardEvent) => {
  const key = e.code.toLowerCase() || e.key.toLowerCase();
  if (isGameOver.value || isPaused.value) return;
  switch (key) {
    case "arrowleft": {
      e.preventDefault();
      moveLeft();
      break;
    }
    case "arrowright": {
      e.preventDefault();
      moveRight();
      break;
    }
    case "arrowdown": {
      e.preventDefault();
      moveDown();
      break;
    }
    case "arrowup": {
      e.preventDefault();
      rotate();
      break;
    }

    default:
      break;
  }
};

addEventListener("keydown", keyController);

const freeze = () => {
  if (
    current.value.some(
      (cellNumber) =>
        availableCells.value[currentPosition.value + cellNumber + width].isTaken
    )
  ) {
    current.value.map((cellNumber) => {
      availableCells.value[cellNumber + currentPosition.value].isTaken = true;
      // availableCells.value[cellNumber + currentPosition.value].class = 'bg-purple-500';
    });
    addScore();
    again();
  }
};
const toggleGame = () => {
  if (isGameOver.value) return;
  if (!isPaused.value) {
    isPaused.value = true;
    clearInterval(timer);
    timer = -1;
  } else {
    timer = setInterval(moveDown, 1000);
    isPaused.value = false;
    // drawGhost();
  }
};

const addScore = () => {
  let localScore = 0;
  for (let i = 0; i < 199; i += width) {
    const row = [
      i,
      i + 1,
      i + 2,
      i + 3,
      i + 4,
      i + 5,
      i + 6,
      i + 7,
      i + 8,
      i + 9,
    ];
    if (
      row.every(
        (cell) =>
          availableCells.value[cell].isTaken &&
          !availableCells.value[cell].isBedRock
      )
    ) {
      localScore += 10;
      score.value += 10;
      row.forEach((cell) => {
        availableCells.value[cell].class = "";
        availableCells.value[cell].isTaken = false;
      });
      const removedCells = availableCells.value.splice(i, 10);
      availableCells.value = removedCells.concat(availableCells.value);
    }
  }
  if (localScore === 40) score.value += 20;
};

let downTimer: number;
let rightTimer: number;
let leftTimer: number;


const mouseDownLeft = () => {
  leftTimer = setInterval(moveLeft, 100);
};

const mouseDownRight = () => {
  rightTimer = setInterval(moveRight, 100);
};

const mouseDownDown = () => {
  downTimer = setInterval(moveDown, 100);
};

const mouseUpDown = () => {
  clearInterval(downTimer);
};
const mouseUpRight = () => {
  clearInterval(rightTimer);
};
const mouseUpLeft = () => {
  clearInterval(leftTimer);
};

const gameOver = () => {
  if (
    current.value.some(
      (cellNumber) =>
        availableCells.value[currentPosition.value + cellNumber].isTaken
    )
  ) {
    message.value = "Game Over";
    isGameOver.value = true;
    clearInterval(timer);
  }
};

const resetGame = () => {
  window.location.replace("/");
};
</script>

<template>
  <div class="bg-teal-100 h-screen">
    <div class="flex mx-auto max-w-md py-15">
      <div class="flex flex-col">
        <div
          class="w-200px h-400px flex flex-wrap bg-white shadow-inner rounded"
        >
          <div
            v-for="(cell, index) in availableCells"
            :key="index"
            :class="[
              cell.isTaken ? 'opacity-80 ' + cell.class : cell.class,
              cell.isGhost && !cell.isOccupied ? 'opacity-30 bg-pink-500 ' : '',
              cell.isOccupied ? cell.class + ' border border-gray-100 ' : '',
              cell.isBedRock ? '' : ' ',
              'w-20px h-20px ',
            ]"
          ></div>
        </div>
        <div class="flex flex-col mt-5">
          <button
            type="button"
            class="rounded-full shadow bg-purple-400 w-25px h-25px mx-auto"
            @click="rotate"
          ></button>
          <div class="flex justify-between">
            <button
              type="button"
              class="rounded-full shadow bg-purple-400 w-25px h-25px"
              v-on="{ mousedown: mouseDownLeft, mouseup: mouseUpLeft }"
            ></button>
            <button
              type="button"
              class="rounded-full shadow bg-purple-400 w-25px h-25px"
              v-on="{ mousedown: mouseDownRight, mouseup: mouseUpRight }"
            ></button>
          </div>
          <button
            type="button"
            class="rounded-full shadow bg-purple-400 w-25px h-25px mx-auto"
            v-on="{ mousedown: mouseDownDown, mouseup: mouseUpDown }"
          ></button>
        </div>
      </div>
      <div class="flex flex-col ml-10">
        <div class="bg-transparent w-80px h-80px flex flex-wrap">
          <div
            v-for="(cell, index) in previewCells"
            :key="index + 'preview'"
            :class="[
              cell.isOccupied ? cell.class + ' border border-gray-100 ' : '',
              'w-20px h-20px',
            ]"
          ></div>
        </div>
        <div class="flex">
          <div
            @click="toggleGame"
            :class="[
              isPaused
                ? 'border-blue-500 bg-blue-50 text-blue-600 hover:(bg-blue-200 text-blue-800) focus:ring-blue-800'
                : 'border-red-500 bg-red-50 text-red-600 hover:(bg-red-200 text-red-800) focus:ring-red-800',
              'border p-1 my-15  rounded hover:shadow focus:ring  w-30px h-30px mr-3',
            ]"
          >
            <svg
              v-if="isPaused"
              viewBox="0 0 24 24"
              fill="none"
              xmlns="http://www.w3.org/2000/svg"
            >
              <path
                fill-rule="evenodd"
                clip-rule="evenodd"
                d="M12 21C16.9706 21 21 16.9706 21 12C21 7.02944 16.9706 3 12 3C7.02944 3 3 7.02944 3 12C3 16.9706 7.02944 21 12 21ZM12 23C18.0751 23 23 18.0751 23 12C23 5.92487 18.0751 1 12 1C5.92487 1 1 5.92487 1 12C1 18.0751 5.92487 23 12 23Z"
                fill="currentColor"
              />
              <path d="M16 12L10 16.3301V7.66987L16 12Z" fill="currentColor" />
            </svg>
            <svg
              v-else
              viewBox="0 0 24 24"
              fill="none"
              xmlns="http://www.w3.org/2000/svg"
            >
              <path d="M9 9H11V15H9V9Z" fill="currentColor" />
              <path d="M15 15H13V9H15V15Z" fill="currentColor" />
              <path
                fill-rule="evenodd"
                clip-rule="evenodd"
                d="M1 5C1 2.79086 2.79086 1 5 1H19C21.2091 1 23 2.79086 23 5V19C23 21.2091 21.2091 23 19 23H5C2.79086 23 1 21.2091 1 19V5ZM5 3H19C20.1046 3 21 3.89543 21 5V19C21 20.1046 20.1046 21 19 21H5C3.89543 21 3 20.1046 3 19V5C3 3.89543 3.89543 3 5 3Z"
                fill="currentColor"
              />
            </svg>
          </div>
          <svg
            @click="resetGame"
            :class="[
              !isGameOver
                ? 'border-blue-500 bg-blue-50 text-blue-600 hover:(bg-blue-200 text-blue-800) focus:ring-blue-800'
                : 'border-red-500 bg-red-50 text-red-600 hover:(bg-red-200 text-red-800) focus:ring-red-800',
              'border p-1 my-15  rounded hover:shadow focus:ring  w-30px h-30px',
            ]"
            xmlns="http://www.w3.org/2000/svg"
            xmlns:xlink="http://www.w3.org/1999/xlink"
            aria-hidden="true"
            role="img"
            width="1em"
            height="1em"
            preserveAspectRatio="xMidYMid meet"
            viewBox="0 0 15 15"
          >
            <g fill="none">
              <path
                fill-rule="evenodd"
                clip-rule="evenodd"
                d="M1.85 7.5c0-2.835 2.21-5.65 5.65-5.65c2.778 0 4.152 2.056 4.737 3.15H10.5a.5.5 0 0 0 0 1h3a.5.5 0 0 0 .5-.5v-3a.5.5 0 0 0-1 0v1.813C12.296 3.071 10.666.85 7.5.85C3.437.85.85 4.185.85 7.5c0 3.315 2.587 6.65 6.65 6.65c1.944 0 3.562-.77 4.714-1.942a6.77 6.77 0 0 0 1.428-2.167a.5.5 0 1 0-.925-.38a5.77 5.77 0 0 1-1.216 1.846c-.971.99-2.336 1.643-4.001 1.643c-3.44 0-5.65-2.815-5.65-5.65z"
                fill="currentColor"
              />
            </g>
          </svg>
        </div>
        <p class="mt-5 font-semibold">Score: {{ score }}</p>
        <p class="mt-5 font-extrabold text-red-600 text-2xl">{{ message }}</p>
      </div>
    </div>
  </div>
</template>
