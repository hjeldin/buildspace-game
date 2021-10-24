<template>
  <div class="text-center">
    <div 
    :class="{'animate-bossAttack z-10': attackState == 'bossAttacking', 'animate-shake': attackState == 'playerHit'}"
    class="max-w-sm border border-gray-500 bg-gray-600 overflow-hidden shadow-2xl p-4 mx-auto mt-24 relative" v-if="boss">
      <div class="relative">
        <img class="w-full" :src="boss.imageURI" alt="Boss portrait" />
        <span
          class="absolute bottom-0 left-0 right-0 bg-gray-900 opacity-70 px-4 py-2 shadow-lg"
        >❤️ {{ boss.hp }}/{{ boss.maxHp }}</span>
      </div>
      <div class="px-6 py-4">
        <div class="font-bold text-xl mb-2">{{ boss.name }}</div>
        <div class="font-bold text-xl mb-2">⚔️ {{boss.attackDamage}}</div>
      </div>
      <div class="px-6 pt-4 pb-2"></div>
    </div>

    <div 
    :class="{'animate-playerAttack z-10': attackState == 'playerAttacking', 'animate-shake': attackState == 'bossHit'}"
    class="mt-12 max-w-sm border border-gray-500 bg-gray-600 overflow-hidden shadow-2xl p-4 mx-auto relative mb-24" v-if="selectedCharacter">
      <div class="relative">
        <img class="w-full" :src="selectedCharacter.imageURI" alt="selectedCharacter portrait" />
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
              :class="{'bg-gray-900': (attackState == 'bossHit' || attackState == '') && selectedCharacter.hp != 0}"
              class="relative bg-gray-700 divide-x divide-gray-600 text-white  py-4 rounded-xl w-full"
              @click="() => { setLoading(true); attackBoss(); }"
            >Attack!</button>
          </div>
        </div>
    </div>
  </div>
</template>

<script>import { mapActions, mapState } from "vuex";

export default {
  name: "Arena",
  async mounted() {
    await this.fetchWeapons();
    await this.fetchBoss();
    const gameContract = await this.$store.dispatch('fetchGameContract');
    gameContract.on('AttackComplete', this.onAttackComplete);
  },
  computed: {
    ...mapState(['boss', 'selectedCharacter', 'loading', 'attackState', 'selectedWeapon', 'availableWeapons']),
    equippedWeaponDamage: function() {
      const weaponId = this.selectedCharacter.equippedWeapon;
      const weaponInArray = this.availableWeapons.find(m => m.id == weaponId);
      console.log(weaponId, weaponInArray);
      return weaponInArray ? weaponInArray.damage : 0;
    }
  },
  methods: {
    ...mapActions(['fetchBoss', 'attackBoss', 'setLoading', 'fetchWeapons']),
    onAttackComplete(bossHp, characterHp) {
      console.log(bossHp, characterHp);
      this.$store.commit('SET_BOSS_HP', bossHp.toNumber());
      this.$store.commit('SET_CHARACTER_HP', characterHp.toNumber());
    }
  }
}
</script>

