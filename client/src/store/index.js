import { ethers } from "ethers";
import Vue from "vue";
import Vuex from "vuex";
import { getEthereum, transformBossData, transformCharacterData, transformWeaponData } from "../utils";
import * as GameAbi from '../utils/HeroesABI.json';
import * as LootAbi from '../utils/LootABI.json';

const storeConfig = {
  state: {
    currentAddress: null,
    selectedCharacter: null,
    selectedWeapon: null,
    availableCharacters: null,
    availableWeapons: [],
    currentNetwork: null,
    defaultCharacters: [],
    gameContract: null,
    loading: false,
    weaponTypes: [{
      name: 'Sword',
      index: 0,
      imageUri: 'https://bafkreih2u25boco57kn4ydqnlfl7hyb3j4f3er7rnyuutrxxmlfyye5qum.ipfs.dweb.link/',
      minDmg: 80,
      maxDmg: 80+40
    },{
      name: 'Axe',
      index: 1,
      imageUri: 'https://bafkreibs6hpzzrtsqwj73ja6c5uc3ppewqwxwznze4auo3ypgibhbv6cii.ipfs.dweb.link/',
      minDmg: 50,
      maxDmg: 50+90
    }, {
      name: 'Bow',
      index: 2,
      imageUri: 'https://bafkreiclfah454anm7fcslfpzlurxdnujsrc6grzk7uqhio7nebar4m3ca.ipfs.dweb.link',
      minDmg: 30,
      maxDmg: 30+80
    }], // hardcoded from contract uin8 ItemType
    boss: null,
    attackState: ''
  },
  mutations: {
    SET_CURRENT_ADDRESS(state, payload) {
      state.currentAddress = payload;
    },
    SET_CURRENT_NETWORK(state, payload) {
      state.currentNetwork = payload;
    },
    SET_DEFAULT_CHARACTERS(state, payload) {
      state.defaultCharacters = payload;
    },
    SELECT_CHARACTER(state, payload) {
      state.selectedCharacter = payload;
    },
    SELECT_WEAPON(state, payload) {
      state.selectedWeapon = payload;
    },
    SET_LOADING(state, loading) {
      state.loading = loading;
    },
    SET_AVAILABLE_WEAPONS(state, payload) {
      state.availableWeapons = payload;
    },
    SET_BOSS(state, payload) {
      state.boss = payload;
    },
    SET_BOSS_HP(state, payload) {
      state.boss.hp = payload;
    },
    SET_CHARACTER_HP(state, payload) {
      state.selectedCharacter.hp = payload;
    },
    SET_ATTACKING(state, payload) {{
      state.attackState = payload;
    }}
  },
  actions: {
    async checkNetwork(context) {
      const ethereum = getEthereum();
      const chainId = ethereum.chainId;
      context.commit('SET_CURRENT_NETWORK', chainId);
      if (chainId == 0x1) {
        alert(`Running on ethereum mainnet. You might want to move to rinkeby. Currently serving on chain ID: ${process.env.VUE_APP_CHAIN_ID} `);
      }
    },
    async checkWallet(context) {
      try {
        const ethereum = getEthereum();
        const accounts = await ethereum.request({ method: "eth_accounts" });

        if (accounts.length !== 0) {
          const account = accounts[0];
          console.log("Found an authorized account:", account);
          context.commit('SET_CURRENT_ADDRESS', account);
        } else {
          console.log("No authorized account found");
        }
      } catch (error) {
        console.log(error);
      }
    },
    async connectWallet(context) {
      try {
        const ethereum = getEthereum();

        const accounts = await ethereum.request({
          method: "eth_requestAccounts",
        });

        console.log("Connected", accounts[0]);
        context.commit('SET_CURRENT_ADDRESS', accounts[0]);
      } catch (error) {
        console.log(error);
      }
    },
    async checkWeaponsBalance(context) {
      console.log(context)
    },
    async fetchGameContract() {
      const provider = new ethers.providers.Web3Provider(window.ethereum);
      const signer = provider.getSigner();
      const gameContract = new ethers.Contract(
        process.env.VUE_APP_LOCAL_DEPLOYED_HERO,
        GameAbi.abi,
        signer
      );
      return gameContract;
    },
    async fetchLootContract() {
      const provider = new ethers.providers.Web3Provider(window.ethereum);
      const signer = provider.getSigner();
      const gameContract = new ethers.Contract(
        process.env.VUE_APP_LOCAL_DEPLOYED_LOOT,
        LootAbi.abi,
        signer
      );
      return gameContract;
    },
    async fetchSelectedCharacter(context) {
      console.log('Checking for Character NFT on address:', context.state.currentAddress);

      const gameContract = await context.dispatch('fetchGameContract');

      const txn = await gameContract.checkIfUserHasNFT();
      if (txn.name) {
        const character = transformCharacterData(txn);
        context.commit('SELECT_CHARACTER', character);
      } else {
        console.warn('No selected character');
      }
    },
    async fetchDefaultCharacters(context) {
      console.log('Checking for default character NFT on address:');

      const gameContract = await context.dispatch('fetchGameContract');
      const txn = await gameContract.getAllDefaultCharacters();
      const characters = txn.map((characterData) =>
        transformCharacterData(characterData)
      );

      context.commit('SET_DEFAULT_CHARACTERS', characters);
    },
    async fetchWeapons(context) {
      const lootContract = await context.dispatch('fetchLootContract');
      const txn = await lootContract.getAvailableItems();
      const txnToken = await lootContract.tokenURI(1);
      console.log(txnToken);
      const weapons = txn.map((weaponsData) =>
        transformWeaponData(weaponsData)
      );
      context.commit('SET_AVAILABLE_WEAPONS', weapons);
    },
    async mintWeapon(context, payload) {
      try {
        const lootContract = await context.dispatch('fetchLootContract');
        const txn = await lootContract.mintLoot(payload.itemType, payload.name, payload.description);
        await txn.wait();
        console.warn("WIP: mint character without weapon", context)
      } catch (err) {
        console.error(err);
        context.commit('SET_LOADING', false);
      }
    },
    async equipWeapon(context, weaponId) {
      try {
        const gameContract = await context.dispatch('fetchGameContract');
        const txn = await gameContract.equipWeapon(weaponId);
        await txn.wait();
      } catch (err) {
        console.error(err);
        context.commit('SET_LOADING', false);
      }
    },
    async mintCharacterWithWeapon(context) {
      console.warn("WIP: mint character without weapon", context)
    },
    async mintCharacterWithoutWeapon(context, characterIndex) {
      try {
        const gameContract = await context.dispatch('fetchGameContract');
        const mintTx = await gameContract.mintCharacterWithoutWeapon(characterIndex);
        await mintTx.wait();
      } catch (err) {
        context.commit('SET_LOADING', false);
      }
    },
    async fetchBoss(context) {
      const gameContract = await context.dispatch('fetchGameContract');
      const bossTxn = await gameContract.getBigBoss();
      context.commit('SET_BOSS', transformBossData(bossTxn));
    },
    async attackBoss(context) {
      try{
        context.commit('SET_LOADING', true);
        const gameContract = await context.dispatch('fetchGameContract');
        const attackTxn = await gameContract.attackBoss();
        context.commit('SET_ATTACKING', 'playerAttacking');
        await new Promise((resolve)=> { setTimeout( resolve, 750 )});
        await attackTxn.wait();
        context.commit('SET_ATTACKING', 'playerHit');
        await new Promise((resolve)=> { setTimeout( resolve, 1500 )});
        context.commit('SET_ATTACKING', 'bossAttacking');
        await new Promise((resolve)=> { setTimeout( resolve, 750 )});
        context.commit('SET_ATTACKING', 'bossHit');
        context.commit('SET_LOADING', false);
      } catch (error) {
        console.error(error);
        context.commit('SET_ATTACKING', '');
        context.commit('SET_LOADING', false);
      }
    },
    async healCharacter(context) {
      const gameContract = await context.dispatch('fetchGameContract');
      const healTxn = await gameContract.healCharacter();
      await healTxn.wait();
    }
  },
};

Vue.use(Vuex);
const store = new Vuex.Store(storeConfig);

export default store;