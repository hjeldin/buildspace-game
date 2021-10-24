<template>
  <div id="app" class="text-white">
    <div class="container mx-auto">
      <div class="text-center pt-12">
        <h1 class="text-6xl">⚔️ Metaverse Slayer ⚔️</h1>
      </div>
      <router-view />
    </div>
  </div>
</template>

<script>
import { getEthereum } from "./utils";

export default {
  mounted() {
    this.$store.dispatch('checkWallet');
    this.$store.dispatch('checkNetwork');
    const ethereum = getEthereum();
    ethereum.on('chainChanged', (newChain) => {
      console.log("CHANGED CHAIN!", newChain);
      this.$store.dispatch('checkNetwork');
    })
  }
}
</script>

<style lang="scss">
body {
  @apply bg-gray-900
}
</style>
