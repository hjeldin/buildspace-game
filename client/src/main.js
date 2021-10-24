import Vue from "vue";
import App from "./App.vue";
import router from "./router";
import { ethers } from "ethers";
import Vuex from "vuex";
import "./main.css";


Vue.use(ethers);
Vue.use(Vuex);

Vue.config.productionTip = false;

new Vue({
  router,
  render: (h) => h(App),
}).$mount("#app");
