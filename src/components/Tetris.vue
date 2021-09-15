<script setup lang="ts">
import { ref, computed } from "vue";

// defineProps<{ msg: string }>();

const count = ref(0);
const width = ref(10);

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
const random = Math.floor(Math.random() * theTetrominoes.value.length);
let current = ref(theTetrominoes.value[random][currentRotation.value])

const currentValues = computed(() => current.value.map(el => el + currentPosition.value))
console.log(currentValues.value)
</script>

<template>
  <div class="bg-yellow-500 w-200px h-400px flex flex-wrap">
    <div v-for="i in 200" :key="i" :class="[currentValues.includes(i) ? 'bg-red-500' : '', 'w-20px h-20px']"></div>
  </div>
</template>
