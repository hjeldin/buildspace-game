<template>
  <div class="mx-auto pt-12 text-center">
    <h1 class="text-6xl">⚔️ Metaverse Slayer ⚔️</h1>
    <img src='https://media4.giphy.com/media/2z6x8UzzCdBBu/giphy.webp' class="mx-auto py-24"/>
    <button v-if="currentAccount == null" class="rounded rounded-lg bg-blue-500 text-white px-8 py-4 text-xl" @click="connectWallet">Connect Wallet</button>
  </div>
</template>

<script>
export default {
  name: "Home",
  data() {
    return {
      currentAccount: null,
      contractAddress:
        process.env.VUE_APP_LOCAL_DEPLOYED_HERO,
    };
  },
  mounted() {
    this.checkIfWalletIsConnected();
  },
  methods: {
    checkIfWalletIsConnected: async function() {
      try {
        const { ethereum } = window;

        if (!ethereum) {
          alert("Make sure you have metamask!");
          return;
        } else {
          console.log("We have the ethereum object", ethereum);
        }

        const accounts = await ethereum.request({ method: "eth_accounts" });

        if (accounts.length !== 0) {
          const account = accounts[0];
          console.log("Found an authorized account:", account);
          this.currentAccount = account;
        } else {
          console.log("No authorized account found");
        }
      } catch (error) {
        console.log(error);
      }
    },
    connectWallet: async function() {
      try {
        const { ethereum } = window;

        if (!ethereum) {
          alert("Get MetaMask!");
          return;
        }

        const accounts = await ethereum.request({
          method: "eth_requestAccounts",
        });

        console.log("Connected", accounts[0]);
        this.currentAccount = accounts[0];
      } catch (error) {
        console.log(error);
      }
    },
  },
};
</script>

<style lang="scss" scoped>
</style>
