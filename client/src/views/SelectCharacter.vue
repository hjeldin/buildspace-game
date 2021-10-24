<template>
  <div class="text-center">
    <h3 class="text-xl py-12">Hello, {{ currentAddress }}</h3>
    <p class="pb-8">Mint your personal hero!</p>
    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 grid-row-auto mx-auto text-center gap-24 justify-items-center" v-if="!loading">
      <div
        class="max-w-sm border border-gray-500 bg-gray-600 overflow-hidden shadow-2xl p-4 transition duration-200 ease-in-out transform hover:scale-110"
        v-for="defaultHero of defaultCharacters"
        v-bind:key="defaultHero.characterIndex"
      >
        <div class="relative">
          <img class="w-full" :src="defaultHero.imageURI" alt="Hero portrait" />
          <span class="absolute bottom-0 left-0 right-0 bg-gray-900 opacity-70 px-4 py-2 shadow-lg">❤️ {{defaultHero.maxHp}}</span>
        </div>

        <div class="px-6 py-4">
          <div class="font-bold text-xl mb-2">{{ defaultHero.name }}</div>
        </div>
        <div class="px-6 pt-4 pb-2">
          <div class="relative group">
            <div
              class="absolute -inset-0.5 bg-gradient-to-r from-green-600 to-blue-600 rounded-lg filter blur opacity-30 group-hover:opacity-100 transition duration-1000 group-hover:duration-200 animate-tilt"
            ></div>
            <button
              class="relative bg-gray-900 divide-x divide-gray-600 text-white  py-4 rounded-xl w-full"
              @click="() => { setLoading(true); mintCharacterWithoutWeapon(defaultHero.characterIndex); }"
            >Mint</button>
          </div>
        </div>
      </div>
    </div>
    <div v-if="loading" class="w-full">
      <img src='https://media4.giphy.com/media/hCiQVo1dzVwPu/giphy.webp' class="mx-auto"/>
      Minting...please wait
    </div>
  </div>
</template>

<script>
import { mapActions, mapMutations, mapState } from "vuex";
import router from "../router";

export default {
  name: "SelectCharacter",
  async mounted() {
    this.setLoading(true);
    await this.fetchSelectedCharacter();
    await this.fetchDefaultCharacters();
    await this.listenToMintedEvent()
    this.setLoading(false);
  },
  computed: {
    ...mapState(['defaultCharacters', 'currentAddress', 'loading'])
  },
  methods: {
    ...mapActions([
      'mintCharacterWithoutWeapon',
      'fetchSelectedCharacter', 
      'fetchDefaultCharacters'
    ]),
    ...mapMutations({
      setLoading: 'SET_LOADING'
    }),
    async eventCallback() {
      const gameContract = await this.$store.dispatch('fetchGameContract');
      gameContract.off('CharacterNFTMinted', this.eventCallback);
      console.log("A new character has been minted");
      await this.$store.dispatch('fetchSelectedCharacter');
      this.setLoading(false);
      router.push({name: 'MintWeapon'}).catch(() => {});
    },
    async listenToMintedEvent() {
      const gameContract = await this.$store.dispatch('fetchGameContract');
      gameContract.on('CharacterNFTMinted', this.eventCallback);
    }
  },
  watch: {
    '$store.state.selectedCharacter': function(n) {
      if(n !== null) {
        router.push({name: 'MintWeapon'});
      }
    }
  }
}
</script>

<style>
</style>