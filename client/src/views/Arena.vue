<template>
  <div class="text-center">
    <vue-tailwind-modal
      :showing="showNewBossModal"
      @close="showNewBossModal = false"
      :showClose="true"
      :backgroundClose="true"
      class="text-gray-900"
    >
      <h2 class="text-2xl">You became the current boss.</h2>
      <p>You can keep playing against yourself or wait for the inevitable defeat</p>
    </vue-tailwind-modal>

    <vue-tailwind-modal
      :showing="showMintModal"
      :showClose="false"
      :backgroundClose="true"
      class="text-gray-900"
    >
      <h2 class="text-2xl">You have been defeated!</h2>
      <p><router-link to="/mint-character" class="underline">Click here</router-link> to go back to the character selection screen</p>
    </vue-tailwind-modal>
    <div
      :class="{ 'animate-bossAttack z-10': attackState == 'bossAttacking', 'animate-shake': attackState == 'playerHit' }"
      class="max-w-xs border border-gray-500 bg-gray-600 overflow-hidden shadow-2xl p-4 mx-auto mt-24 relative"
      v-if="boss"
    >
      <div class="relative">
        <img class="w-full" :src="boss.imageURI" alt="Boss portrait" style="min-width:200px;min-height:200px"/>
        <span
          class="absolute bottom-0 left-0 right-0 bg-gray-900 opacity-70 px-4 py-2 shadow-lg"
        >❤️ {{ boss.hp }}/{{ boss.maxHp }}</span>
      </div>
      <div class="px-6 py-4">
        <div class="font-bold text-xl mb-2">{{ boss.name }}</div>
        <div class="font-bold text-xl mb-2">⚔️ {{ boss.attackDamage }}</div>
        <div class="text-sm mb-1">Owned by:</div>
        <div class="text-sm mb-2 break-all">{{ boss.owner }}</div>
      </div>
      <div class="px-6 pt-4 pb-2"></div>
    </div>

    <div v-if="playerMissed || playerDodged || bossMissed || bossDodged || loading" class="absolute z-20 -mt-16 mx-auto left-0 right-0">
      <div class="mx-auto relative bg-gray-800 opacity-70 py-8">
        <p class="mb-2" v-if="playerMissed">You missed!</p>
        <p class="mb-2" v-if="playerDodged">Boss dodged!</p>
        <p class="mb-2" v-if="bossMissed">The boss missed!</p>
        <p class="mb-2" v-if="bossDodged">You dodged!</p>
        <p class="mb-2" v-if="loading">Loading, please wait</p>
      </div>
    </div>

    <div
      :class="{ 'animate-playerAttack z-10': attackState == 'playerAttacking', 'animate-shake': attackState == 'bossHit' }"
      class="mt-12 max-w-xs border border-gray-500 bg-gray-600 overflow-hidden shadow-2xl p-4 mx-auto relative mb-24"
      v-if="selectedCharacter"
    >
      <div class="relative">
        <img class="w-full" :src="selectedCharacter.imageURI" alt="selectedCharacter portrait"  style="min-width:200px;min-height:200px"/>
        <span
          class="absolute bottom-0 left-0 right-0 bg-gray-900 opacity-70 px-4 py-2 shadow-lg"
        >❤️ {{ selectedCharacter.hp }}/{{ selectedCharacter.maxHp }}</span>
      </div>
      <div class="px-6 py-4">
        <div class="font-bold text-xl mb-2">{{ selectedCharacter.name }}</div>
        <div class="font-bold text-xl mb-2">⚔️ {{ equippedWeaponDamage }}</div>
      </div>
      <div class="px-6 pt-4 pb-2">
        <div class="relative group">
          <div
            class="absolute -inset-0.5 bg-gradient-to-r from-green-600 to-blue-600 rounded-lg filter blur opacity-30 group-hover:opacity-100 transition duration-1000 group-hover:duration-200 animate-tilt"
          ></div>
          <button
            :disabled="(attackState != 'bossHit' && attackState != '') || selectedCharacter.hp == 0"
            :class="{ 'bg-gray-900': (attackState == 'bossHit' || attackState == '') && selectedCharacter.hp != 0 }"
            class="relative bg-gray-700 divide-x divide-gray-600 text-white py-4 rounded-xl w-full"
            @click="() => { setLoading(true); attackBoss(); }"
          >Attack!</button>
        </div>
      </div>
      <div class="px-6 pt-4 pb-2">
        <div class="relative group">
          <div
            class="absolute -inset-0.5 bg-gradient-to-r from-green-600 to-blue-600 rounded-lg filter blur opacity-30 group-hover:opacity-100 transition duration-1000 group-hover:duration-200 animate-tilt"
          ></div>
          <button
            :disabled="(attackState != 'bossHit' && attackState != '') || selectedCharacter.hp == 0"
            :class="{ 'bg-gray-900': (attackState == 'bossHit' || attackState == '') && selectedCharacter.hp != 0 }"
            class="relative bg-gray-700 divide-x divide-gray-600 text-white py-4 rounded-xl w-full"
            title="Healing is possible every two attacks"
            @click="() => { setLoading(true); healCharacter(); }"
          >❤️ Heal</button>
        </div>
      </div>
    </div>
  </div>
</template>

<script>import { mapActions, mapMutations, mapState } from "vuex";

export default {
  name: "Arena",
  data: function() {
    return {
      showNewBossModal: false,
      showMintModal: false,
      playerDodged: false,
      playerMissed: false,
      bossDodged: false,
      bossMissed: false
    }
  },
  async mounted() {
    let body = document.getElementsByTagName("body");
    for(let i = 0; i < body.length; i++) {
      body[i].classList = '';
    }
    await this.fetchWeapons();
    await this.fetchBoss();
    await this.fetchSelectedCharacter();
    const gameContract = await this.$store.dispatch('fetchGameContract');
    gameContract.on('AttackComplete', this.onAttackComplete);
    gameContract.on('CharacterHealed', this.onHealed);
    gameContract.on('NewBigBoss', this.onNewBoss);
    gameContract.on('PlayerAttackMissed', this.onPlayerMissed);
    gameContract.on('PlayerAttackDodged', this.onPlayerDodged);
    gameContract.on('BossAttackMissed', this.onBossMissed);
    gameContract.on('BossAttackDodged', this.onBossDodged);
  },
  computed: {
    ...mapState(['boss', 'selectedCharacter', 'loading', 'attackState', 'selectedWeapon', 'availableWeapons', 'currentAddress']),
    equippedWeaponDamage: function () {
      const weaponId = this.selectedCharacter.equippedWeapon;
      const weaponInArray = this.availableWeapons.find(m => m.id == weaponId);
      console.log(weaponId, weaponInArray);
      return weaponInArray ? weaponInArray.damage : 0;
    }
  },
  methods: {
    ...mapActions(['fetchBoss', 'attackBoss', 'setLoading', 'fetchWeapons', 'healCharacter', 'fetchSelectedCharacter']),
    ...mapMutations({
      setLoading: 'SET_LOADING'
    }),
    async onPlayerDodged(address) {
      if(address.toLowerCase() != this.currentAddress.toLowerCase()) return;
      console.log('ATTACK DODGED');
      this.playerDodged = true;
      await new Promise((res) => setTimeout( res, 2500));
      this.playerDodged = false;
    },
    async onPlayerMissed(address) {
      if(address.toLowerCase() != this.currentAddress.toLowerCase()) return;
      console.log('ATTACK MISSED');
      this.playerMissed = true;
      await new Promise((res) => setTimeout( res, 2500));
      this.playerMissed = false;
    },
    async onBossDodged(address) {
      if(address.toLowerCase() != this.currentAddress.toLowerCase()) return;
      console.log('YOU DODGED');
      this.bossDodged = true;
      await new Promise((res) => setTimeout( res, 2500));
      this.bossDodged = false;
    },
    async onBossMissed(address) {
      if(address.toLowerCase() != this.currentAddress.toLowerCase()) return;
      console.log('YOU HAVE BEEN MISSED');
      this.bossMissed = true;
      await new Promise((res) => setTimeout( res, 2500));
      this.bossMissed = false;
    },
    async onNewBoss() {
      await this.fetchBoss();
      if(this.boss.owner.toLowerCase() == this.currentAddress.toLowerCase()) {
        this.showNewBossModal = true;
      }
    },
    async onAttackComplete(bossHp) {
      this.$store.commit('SET_BOSS_HP', bossHp.toNumber());
      await this.fetchSelectedCharacter();
      if(this.selectedCharacter.hp == 0){
        this.showMintModal = true;
      }
    },
    onHealed() {
      this.fetchSelectedCharacter();
      this.setLoading(false);
    }
  }
}
</script>

