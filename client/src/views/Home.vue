<template>
  <div class="mx-auto text-center">
    <img src='https://media4.giphy.com/media/2z6x8UzzCdBBu/giphy.webp' class="mx-auto py-24"/>
    <button v-if="currentAddress == null" class="rounded rounded-lg bg-blue-500 text-white px-8 py-4 text-xl" @click="connectWallet">Connect Wallet</button>
  </div>
</template>

<script>
import { mapActions, mapState } from "vuex";
import router from "../router";

export default {
  name: "Home",
  data() {
    return {}
  },
  mounted() {
  },
  computed: {
    ...mapState(['currentAddress'])
  },
  methods: {
    ...mapActions(['connectWallet'])
  },
  watch: {
    '$store.state.currentAddress': function(n) {
      if(n != null)
        router.push('Arena').catch(() => {});
    }
  }
};
</script>

<style lang="scss" scoped>
</style>
