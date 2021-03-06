<template>
  <div class="text-center">
    <vue-tailwind-modal
      :showing="showMintModal"
      @close="showMintModal = false"
      :showClose="true"
      :backgroundClose="true"
      class="text-gray-900"
    >
      <h2 class="text-2xl mb-8">Give your weapon a name.</h2>
      <input type='text' class="mb-4 bg-gray-200 px-4 py-2" v-model="name" placeholder="Name"/><br />
      <input type='text' class="mb-4 bg-gray-200 px-4 py-2" v-model="description" placeholder="Description"/> <br />
      <button @click="() => { if(name != '' && description != '') {showMintModal = false; setLoading(true); mintWeapon({itemType: weaponIndex, name, description}); } }">Mint!</button>
    </vue-tailwind-modal>
    <h3 class="text-xl py-12">Hello, {{ currentAddress }}</h3>
    <p class="pb-8" v-if="!loading">Loadout</p>
    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 grid-row-auto mx-auto text-center gap-24 justify-items-center mb-24" v-if="!loading && availableWeapons && availableWeapons.length != 0">
      <div
        class="max-w-sm border border-gray-500 bg-gray-600 overflow-hidden shadow-2xl p-4 transition duration-200 ease-in-out transform hover:scale-110"
        v-for="weapon of availableWeapons"
        v-bind:key="weapon.id"
      >
        <div class="relative">
          <img class="w-full" :src="weapon.imageUri" alt="Weapon portrait" />
          <span class="absolute bottom-0 left-0 right-0 bg-gray-900 opacity-70 px-4 py-2 shadow-lg">⚔️ {{weapon.damage}}</span>
        </div>
        <div class="px-6 py-4">
          <div class="font-bold text-xl mb-2">{{ weapon.name }}</div>
          <div class="mb-2">{{ weapon.description }}</div>
        </div>
        <div class="px-6 pt-4 pb-2">
          <div class="relative group">
            <div
              class="absolute -inset-0.5 bg-gradient-to-r from-green-600 to-blue-600 rounded-lg filter blur opacity-30 group-hover:opacity-100 transition duration-1000 group-hover:duration-200 animate-tilt"
            ></div>
            <button
              class="relative bg-gray-900 divide-x divide-gray-600 text-white px-8 py-4 rounded-xl w-full"
              :disabled="!allowedToMint"
              @click="() => { setLoading(true); equipWeapon(weapon.id); }"
            >Equip</button>
          </div>
        </div>
      </div>
    </div>

    <div class="my-8" v-if="!loading && availableWeapons.length == 0">Mint a new weapon for your character</div>
    <div class="my-8" v-if="!loading && availableWeapons.length != 0">Or mint a new one</div>

    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 grid-row-auto mx-auto text-center gap-24 justify-items-center" v-if="!loading">
      <div
        class="max-w-sm border border-gray-500 bg-gray-600 overflow-hidden shadow-2xl p-4 transition duration-200 ease-in-out transform hover:scale-110"
        v-for="weapon of weaponTypes"
        v-bind:key="weapon.index"
      >
        <div class="relative">
          <img class="w-full" :src="weapon.imageUri" alt="Weapon portrait" />
          <span class="absolute bottom-0 left-0 right-0 bg-gray-900 opacity-70 px-4 py-2 shadow-lg">⚔️ Min {{weapon.minDmg}} - Max {{weapon.maxDmg}}</span>
        </div>
        <div class="px-6 py-4">
          <div class="font-bold text-xl mb-2">{{ weapon.name }}</div>
        </div>
        <div class="px-6 pt-4 pb-2">
          <div class="relative group">
            <div
              class="absolute -inset-0.5 bg-gradient-to-r from-green-600 to-blue-600 rounded-lg filter blur opacity-30 group-hover:opacity-100 transition duration-1000 group-hover:duration-200 animate-tilt"
            ></div>
            <button
              class="relative bg-gray-900 divide-x divide-gray-600 text-white px-8 py-4 rounded-xl w-full"
              :disabled="!allowedToMint"
              @click="() => { showMintModal = true; weaponIndex = weapon.index; }"
            >Mint</button>
          </div>
        </div>
      </div>
    </div>
    <div v-if="loading" class="w-full">
      <img src='https://media4.giphy.com/media/hCiQVo1dzVwPu/giphy.webp' class="mx-auto"/>
      Loading...please wait
    </div>
    <div v-if="allowedToSkip">
      <button class="bg-green-300 rounded mt-12 px-4 py-2 text-gray-800">Or skip to the arena</button>
    </div>
  </div>
</template>

<script>
import { mapActions, mapMutations, mapState } from "vuex";
import router from "../router";

export default {
  name: 'SelectWeapon',
  async mounted() {
    let body = document.getElementsByTagName("body");
    for(let i = 0; i < body.length; i++) {
      body[i].classList = '';
    }
    await this.fetchWeapons();
    await this.fetchSelectedCharacter();
    const gameContract = await this.$store.dispatch('fetchGameContract');
    const lootContract = await this.$store.dispatch('fetchLootContract');
    gameContract.on('WeaponEquipped', this.onWeaponEquipped);
    lootContract.on('WeaponMinted', this.onWeaponMinted);
  },
  data: () => {
    return {
      name: '',
      description: '',
      weaponIndex: 0,
      showMintModal: false
    }
  },
  computed: {
    ...mapState(['weaponTypes', 'currentAddress', 'loading',  'availableWeapons', 'selectedCharacter']),
    allowedToSkip: () => {
      return false;
    },
    allowedToMint: () => {
      return true;
    }
  },
  methods: {
    ...mapActions(['mintWeapon', 'fetchWeapons', 'equipWeapon', 'fetchSelectedCharacter']),
    ...mapMutations({
      setLoading: 'SET_LOADING'
    }),
    async onWeaponEquipped(selectedWeaponId) {
      const gameContract = await this.$store.dispatch('fetchGameContract');
      gameContract.off('WeaponEquipped', this.onWeaponEquipped);
      this.$store.commit('SELECT_WEAPON', selectedWeaponId.toNumber());
      router.push({name: 'Arena'}).catch(() => {});
    },
    async onWeaponMinted() {
      await this.fetchWeapons();
      await this.setLoading(false);
    }
  },
  watch: {
    '$store.state.selectedCharacter.equippedWeapon': function (n) {
      console.log(`SELECTED WEAPON: ${n}`)
      router.push({name: 'Arena'}).catch(() => {});
    }
  }
}
</script>

<style>
</style>